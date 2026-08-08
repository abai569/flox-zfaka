/**
 * Tokyo Theme - Product Pay UI
 * Payment modal, views, and countdown lifecycle.
 */
(function(window, document) {
    'use strict';

    var countdownTimer = null;
    var modalEl = null;
    var closeBtn = null;
    var overlay = null;
    var deactivateCallback = null;
    var paymentActive = false;

    function escapeHtml(value) {
        if (!value) return '';
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function formatCountdown(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = seconds % 60;
        return (h > 0 ? h + '时' : '') +
            (m < 10 ? '0' + m : m) + '分' +
            (s < 10 ? '0' + s : s) + '秒';
    }

    function deactivate() {
        paymentActive = false;
        if (countdownTimer) {
            clearInterval(countdownTimer);
            countdownTimer = null;
        }
        if (deactivateCallback) {
            var callback = deactivateCallback;
            deactivateCallback = null;
            callback();
        }
    }

    function onEscape(event) {
        if (event.key === 'Escape' && paymentActive) close();
    }

    function detachListeners() {
        if (closeBtn) closeBtn.removeEventListener('click', close);
        if (overlay) overlay.removeEventListener('click', close);
        document.removeEventListener('keydown', onEscape);
        closeBtn = null;
        overlay = null;
    }

    function close() {
        deactivate();
        detachListeners();
        if (modalEl) {
            modalEl.remove();
            modalEl = null;
        }
        document.body.style.overflow = '';
    }

    function buildPaymentContent(data, paymethod) {
        var payIcon = '';
        if (paymethod === 'yipay' || paymethod === 'alipay' || paymethod === 'zfbf2f' || paymethod === 'zfbweb') {
            payIcon = '<img src="/res/images/pay/alipay.ico" class="tokyo-pay-icon" alt="支付宝">';
        } else if (paymethod === 'wxpay' || paymethod === 'wxf2f' || paymethod === 'wxh5') {
            payIcon = '<img src="/res/images/pay/wxpay.ico" class="tokyo-pay-icon" alt="微信">';
        } else if (paymethod === 'usdt' || paymethod === 'uzhifu' || paymethod === 'gmpay') {
            payIcon = '<img src="/res/images/pay/usdt.ico" class="tokyo-pay-icon" alt="USDT">';
        }

        if (data.type > 0) {
            return '<div class="tokyo-payment-header">' +
                payIcon +
                '<span class="tokyo-payment-title">' + escapeHtml(data.payname || '支付') + '</span>' +
                '</div><div class="tokyo-payment-body">' +
                '<p class="tokyo-payment-scan">扫一扫付款</p>' +
                '<div class="tokyo-payment-amount-large">¥ ' + escapeHtml(data.money) + '</div>' +
                '<div class="tokyo-payment-qr"><img src="/res/images/pay/load.gif" alt="加载中" id="tokyo-pay-qr"></div>' +
                (data.overtime > 0 ? '<div class="tokyo-payment-countdown" id="tokyo-countdown">二维码剩余有效期 ' + formatCountdown(data.overtime) + '</div>' : '') +
                '<p class="tokyo-payment-hint">请尽快完成付款</p>' +
                '</div>';
        }

        var qrHtml = '<img src="' + escapeHtml(data.qr) + '" alt="' + escapeHtml(data.payname) + '" id="tokyo-pay-qr">';
        if (data.subjump > 0 && data.subjumpurl) {
            qrHtml = '<a href="' + escapeHtml(data.subjumpurl) + '" target="_blank" rel="noopener noreferrer">' + qrHtml + '</a>';
        }
        var walletHtml = '';
        if (paymethod === 'uzhifu' && data.wallet_address) {
            walletHtml = '<div class="tokyo-payment-wallet">' +
                '<p>使用支持 TRC20 网络的 USDT 钱包转账</p>' +
                '<p class="tokyo-payment-warn">转账金额必须为 <strong>' + escapeHtml(data.money) + ' USDT</strong>（请勿多转或少转）</p>' +
                '<p>收款地址：</p><code class="tokyo-payment-address">' + escapeHtml(data.wallet_address) + '</code></div>';
        }
        return '<div class="tokyo-payment-header">' +
            payIcon +
            '<span class="tokyo-payment-title">' + escapeHtml(data.payname || '扫码支付') + '</span>' +
            '</div><div class="tokyo-payment-body">' + walletHtml +
            '<p class="tokyo-payment-scan">扫一扫付款</p>' +
            '<div class="tokyo-payment-amount-large">' + (paymethod === 'uzhifu' ? escapeHtml(data.money) + ' USDT' : '¥ ' + escapeHtml(data.money)) + '</div>' +
            '<div class="tokyo-payment-qr">' + qrHtml + '</div>' +
            (data.overtime > 0 ? '<div class="tokyo-payment-countdown" id="tokyo-countdown">二维码剩余有效期 ' + formatCountdown(data.overtime) + '</div>' : '') +
            '<p class="tokyo-payment-hint">请尽快完成付款</p>' +
            '</div>';
    }

    function startCountdown(overtime) {
        var remaining = overtime;
        var displayEl = document.getElementById('tokyo-countdown');
        countdownTimer = setInterval(function() {
            if (!paymentActive) return deactivate();
            remaining--;
            if (remaining <= 0) {
                if (displayEl) displayEl.innerHTML = '<span style="color:#ff4d4f;">支付超时，请重新下单</span>';
                var qrImg = document.getElementById('tokyo-pay-qr');
                if (qrImg) {
                    qrImg.src = '/res/images/pay/overtime.png';
                    qrImg.alt = '二维码已失效';
                }
                deactivate();
                return;
            }
            if (displayEl) displayEl.textContent = '剩余时间：' + formatCountdown(remaining);
        }, 1000);
    }

    function open(data, paymethod, onDeactivate) {
        close();
        paymentActive = true;
        deactivateCallback = onDeactivate;
        modalEl = document.createElement('div');
        modalEl.className = 'tokyo-payment-modal';
        modalEl.innerHTML = '<div class="tokyo-payment-overlay"></div>' +
            '<div class="tokyo-payment-dialog"><button class="tokyo-payment-close" aria-label="关闭">&times;</button>' +
            '<div class="tokyo-payment-content">' + buildPaymentContent(data, paymethod) + '</div>' +
            (data.type > 0 ? '<div class="tokyo-payment-actions"><a href="' + escapeHtml(data.url) + '" target="_blank" rel="noopener noreferrer" class="tokyo-button tokyo-button-dark">打开支付页面</a></div>' : '') +
            '</div>';
        document.body.appendChild(modalEl);
        document.body.style.overflow = 'hidden';
        closeBtn = modalEl.querySelector('.tokyo-payment-close');
        overlay = modalEl.querySelector('.tokyo-payment-overlay');
        if (closeBtn) closeBtn.addEventListener('click', close);
        if (overlay) overlay.addEventListener('click', close);
        document.addEventListener('keydown', onEscape);
        if (data.overtime > 0) startCountdown(data.overtime);
    }

    function initOrderCountdown() {
        var countdownEl = document.getElementById('countdown-time');
        if (!countdownEl) return;
        var totalSeconds = 15 * 60;
        var parts = countdownEl.textContent.trim().split(':');
        if (parts.length === 2) {
            var minutes = parseInt(parts[0], 10);
            var seconds = parseInt(parts[1], 10);
            if (!isNaN(minutes) && !isNaN(seconds)) totalSeconds = minutes * 60 + seconds;
        }
        var timer = setInterval(function() {
            totalSeconds--;
            if (totalSeconds <= 0) {
                clearInterval(timer);
                countdownEl.textContent = '00:00';
                countdownEl.style.color = '#ff4d4f';
                return;
            }
            var minutes = Math.floor(totalSeconds / 60);
            var seconds = totalSeconds % 60;
            countdownEl.textContent = (minutes < 10 ? '0' + minutes : minutes) + ':' + (seconds < 10 ? '0' + seconds : seconds);
        }, 1000);
    }

    window.TokyoPaymentUI = {
        close: close,
        initOrderCountdown: initOrderCountdown,
        isActive: function() { return paymentActive; },
        open: open
    };
})(window, document);
