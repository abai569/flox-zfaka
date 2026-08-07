/**
 * Tokyo Theme - Product Query JS
 * 订单查询功能
 */
(function() {
    'use strict';

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function createTime(value) {
        var date = new Date(parseInt(value, 10) * 1000);
        if (Number.isNaN(date.getTime())) {
            return '';
        }
        var y = date.getFullYear();
        var m = String(date.getMonth() + 1).padStart(2, '0');
        var d = String(date.getDate()).padStart(2, '0');
        var h = String(date.getHours()).padStart(2, '0');
        var i = String(date.getMinutes()).padStart(2, '0');
        var s = String(date.getSeconds()).padStart(2, '0');
        return y + '-' + m + '-' + d + ' ' + h + ':' + i + ':' + s;
    }

    function statusLabel(status) {
        switch (String(status)) {
            case '0':
                return '<span class="layui-badge layui-bg-gray">待付款</span>';
            case '1':
                return '<span class="layui-badge layui-bg-blue">待处理</span>';
            case '2':
                return '<span class="layui-badge layui-bg-green">已完成</span>';
            default:
                return '<span class="layui-badge layui-bg-black">处理失败</span>';
        }
    }

    function renderResult(container, response) {
        var rows = Array.isArray(response.data) ? response.data : [];
        container.hidden = false;
        if (rows.length === 0) {
            container.innerHTML = '<div class="tokyo-alert tokyo-alert-error">无数据</div>';
            return;
        }

        var html = '<div class="tokyo-table-wrap"><table class="tokyo-commodity-table tokyo-query-table"><thead><tr>' +
            '<th>订单ID</th><th>订单名称</th><th>数量</th><th>金额</th><th>下单时间</th><th>状态</th>' +
            '</tr></thead><tbody>';

        rows.forEach(function(item) {
            html += '<tr>' +
                '<td>' + escapeHtml(item.orderid) + '</td>' +
                '<td>' + escapeHtml(item.productname) + '</td>' +
                '<td>' + escapeHtml(item.number) + '</td>' +
                '<td>' + escapeHtml(item.money) + '</td>' +
                '<td>' + escapeHtml(createTime(item.addtime)) + '</td>' +
                '<td>' + statusLabel(item.status) + '</td>' +
                '</tr>';
        });

        container.innerHTML = html + '</tbody></table></div>';
    }

    function refreshCaptcha(form) {
        var captcha = form.querySelector('.loadcode');
        if (captcha) {
            captcha.setAttribute('src', '/Captcha?t=productquery&n=' + Math.random());
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        var forms = document.querySelectorAll('.tokyo-query-form');
        forms.forEach(function(form) {
            form.addEventListener('submit', function(e) {
                var required = Array.prototype.slice.call(this.querySelectorAll('[required]'));
                var missing = required.some(function(input) {
                    return !input.value.trim();
                });

                e.preventDefault();
                if (missing) {
                    alert('请输入完整查询内容');
                    return;
                }

                var result = document.getElementById('tokyo-query-result');
                var button = this.querySelector('button[type="submit"]');
                if (button) {
                    button.disabled = true;
                }

                fetch('/product/query/ajax/', {
                    method: 'POST',
                    body: new FormData(this),
                    credentials: 'same-origin'
                })
                    .then(function(res) { return res.json(); })
                    .then(function(res) {
                        if (!result) {
                            return;
                        }
                        if (String(res.code) === '1') {
                            renderResult(result, res);
                        } else {
                            refreshCaptcha(form);
                            result.hidden = false;
                            result.innerHTML = '<div class="tokyo-alert tokyo-alert-error">' + escapeHtml(res.msg || '查询失败') + '</div>';
                        }
                    })
                    .catch(function() {
                        if (result) {
                            result.hidden = false;
                            result.innerHTML = '<div class="tokyo-alert tokyo-alert-error">服务器连接失败，请联系管理员</div>';
                        }
                    })
                    .finally(function() {
                        if (button) {
                            button.disabled = false;
                        }
                    });
            });
        });

        document.querySelectorAll('.loadcode').forEach(function(captcha) {
            captcha.addEventListener('click', function(event) {
                event.preventDefault();
                captcha.setAttribute('src', '/Captcha?t=productquery&n=' + Math.random());
            });
        });
    });
})();
