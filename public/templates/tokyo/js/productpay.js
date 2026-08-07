/**
 * Tokyo Theme - Product Pay Protocol
 * ZFAKA payment requests, response dispatch, polling, and redirects.
 */
(function(window, document) {
    'use strict';

    var ui = window.TokyoPaymentUI;
    var pollTimer = null;
    var redirectTimer = null;

    function showError(message) {
        alert(message || '支付请求失败，请重试');
    }

    function clearProtocolTimers() {
        if (pollTimer) {
            clearTimeout(pollTimer);
            pollTimer = null;
        }
        if (redirectTimer) {
            clearTimeout(redirectTimer);
            redirectTimer = null;
        }
    }

    function schedulePoll(oid) {
        if (pollTimer) clearTimeout(pollTimer);
        pollTimer = setTimeout(function() {
            pollTimer = null;
            pollPaymentStatus(oid);
        }, 3000);
    }

    function pollPaymentStatus(oid) {
        if (!ui.isActive()) return;
        var formData = new FormData();
        formData.append('csrf_token', TOKEN);
        formData.append('oid', oid);
        fetch('/product/query/pay', {
            method: 'POST',
            body: formData,
            credentials: 'same-origin'
        })
        .then(function(response) {
            if (!response.ok) throw new Error('Network error');
            return response.json();
        })
        .then(function(data) {
            if (!ui.isActive()) return;
            if (data.code === 1 && data.data && data.data.orderid) {
                ui.close();
                window.location.href = '/product/query/?zlkbmethod=auto&orderid=' + encodeURIComponent(data.data.orderid);
            } else if (data.code > 1) {
                schedulePoll(oid);
            } else {
                showError(data.msg || '支付状态查询失败');
                ui.close();
            }
        })
        .catch(function() {
            if (ui.isActive()) schedulePoll(oid);
        });
    }

    function scheduleRedirect(url, delay) {
        if (redirectTimer) clearTimeout(redirectTimer);
        redirectTimer = setTimeout(function() {
            redirectTimer = null;
            if (ui.isActive()) window.location.href = url;
        }, delay);
    }

    function dispatchPayment(data, paymethod, oid) {
        ui.open(data, paymethod, clearProtocolTimers);
        pollPaymentStatus(oid);
        if (data.type > 0) {
            if (data.url) scheduleRedirect(data.url, 3000);
            return;
        }
        if (data.subjump > 0 && data.subjumpurl) {
            var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
            var isWechat = /MicroMessenger/i.test(navigator.userAgent);
            if (isMobile && !isWechat) scheduleRedirect(data.subjumpurl, 2000);
        }
    }

    function handlePaymentClick(event) {
        event.preventDefault();
        var button = event.currentTarget;
        var paymethod = button.getAttribute('data-type');
        var paytype = button.getAttribute('data-paytype') || '';
        var oidInput = document.getElementById('oid');
        if (!paymethod || !oidInput) {
            showError('参数错误');
            return;
        }
        var oid = oidInput.value;
        var formData = new FormData();
        formData.append('csrf_token', TOKEN);
        formData.append('oid', oid);
        formData.append('paymethod', paymethod);
        formData.append('paytype', paytype);
        fetch('/product/order/payajax', {
            method: 'POST',
            body: formData,
            credentials: 'same-origin'
        })
        .then(function(response) {
            if (!response.ok) throw new Error('Network error');
            return response.json();
        })
        .then(function(response) {
            if (response.code !== 1) {
                showError(response.msg || '支付请求失败');
                return;
            }
            if (!response.data) {
                showError('支付数据异常');
                return;
            }
            dispatchPayment(response.data, paymethod, oid);
        })
        .catch(function() {
            showError('网络请求失败，请检查网络连接');
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        var payButtons = document.querySelectorAll('.orderpaymethod');
        payButtons.forEach(function(button) {
            button.addEventListener('click', handlePaymentClick);
        });
        ui.initOrderCountdown();
    });
})(window, document);
