/**
 * Tokyo Theme - Product Detail JS
 * Layui module for buy form submission with real ZFAKA contract
 */
layui.define(['layer', 'form', 'laytpl', 'element'], function(exports){
    var $ = layui.jquery;
    var layer = layui.layer;
    var laytpl = layui.laytpl;
    var element = layui.element;
    var form = layui.form;
    var device = layui.device();

    // Mobile adaptation
    if(device.weixin || device.android || device.ios){
        $(".tokyo-detail-info .tokyo-form-label").css("text-align", "left");
    }

    function isNotANumber(inputData) {
        if (parseFloat(inputData).toString() == "NaN") {
            return false;
        } else {
            return true;
        }
    }

    function changeTwoDecimal_f(x) {
        var f_x = parseFloat(x);
        if (isNaN(f_x)) {
            alert('function:changeTwoDecimal->parameter error');
            return false;
        }
        var f_x = Math.round(x * 100) / 100;
        var s_x = f_x.toString();
        var pos_decimal = s_x.indexOf('.');
        if (pos_decimal < 0) {
            pos_decimal = s_x.length;
            s_x += '.';
        }
        while (s_x.length <= pos_decimal + 2) {
            s_x += '0';
        }
        return f_x.toFixed(2);
    }

    function changeTwoDecimal_html(x) {
        var f_x = parseFloat(x);
        if (isNaN(f_x)) {
            alert('function:changeTwoDecimal->parameter error');
            return false;
        }
        var f_x = Math.round(x * 100) / 100;
        var s_x = f_x.toString();
        var pos_decimal = s_x.indexOf('.');
        if (pos_decimal < 0) {
            pos_decimal = s_x.length;
            s_x += '.';
        }
        while (s_x.length <= pos_decimal + 2) {
            s_x += '0';
        }
        return s_x;
    }

    function htmlspecialchars_decode(str) {
        if(str.length > 0){
            str = str.replace(/&amp;/g, '&');
            str = str.replace(/&lt;/g, '<');
            str = str.replace(/&gt;/g, '>');
            str = str.replace(/&quot;/g, '"');
            str = str.replace(/&#039;/g, "'");
        }
        return str;
    }

    function buyNumCheck() {
        var qty = $('#qty').val();
        var number = $('#number').val();
        var stockcontrol = $('#stockcontrol').val();
        if(stockcontrol > 0){
            if(parseInt(number) > parseInt(qty)){
                return false;
            }
        }
        return true;
    }

    // Quantity +/- buttons
    $('#qty-minus').on('click', function() {
        var val = parseInt($('#number').val()) || 1;
        if (val > 1) {
            $('#number').val(val - 1);
            $('#number').trigger('input');
        }
    });

    $('#qty-plus').on('click', function() {
        var val = parseInt($('#number').val()) || 1;
        var stockcontrol = Number($('#stockcontrol').val());
        var qty = Number($('#qty').val());
        if(stockcontrol > 0){
            if(val < qty){
                $('#number').val(val + 1);
                $('#number').trigger('input');
            }
        } else {
            $('#number').val(val + 1);
            $('#number').trigger('input');
        }
    });

    // Number input handler
    $('#number').on('input', function() {
        var stockcontrol = Number($('#stockcontrol').val());
        var qty = Number($('#qty').val());
        var number_value = $('#number').val();
        var number = Number(number_value);

        if(isNotANumber(number_value)){
            if(number < 1){
                number = 1;
                $('#number').val(1);
            }
        }

        if(stockcontrol > 0){
            if(number > qty){
                $('#number').val(qty);
                number = qty;
            }
        }
    });

    // Form verification
    form.verify({
        numberCheck: function(value, item) {
            var qty = $('#qty').val();
            var number = $('#number').val();
            var stockcontrol = $('#stockcontrol').val();
            var limitorderqty = $('#limitorderqty').val();
            if(stockcontrol > 0){
                if(parseInt(number) > parseInt(qty)){
                    return '下单数量超出库存';
                }
            }
            if(parseInt(number) > limitorderqty){
                return '下单数量超限';
            }
        },
        chapwd: function(value, item) {
            if(!new RegExp("^[a-zA-Z0-9_\u4e00-\u9fa5\\s·]+$").test(value)){
				return '安全密码不能有特殊字符';
            }
        }
    });

    // Buy form submission
    form.on('submit(buy)', function(data) {
        data.field.csrf_token = TOKEN;
        var i = layer.load(2, {shade: [0.5, '#fff']});

        if(buyNumCheck()){
            $.ajax({
                url: '/product/order/buy/',
                type: 'POST',
                dataType: 'json',
                data: data.field,
            })
            .done(function(res) {
                if (res.code == '1') {
                    var oid = res.data.oid;
                    if(oid.length > 0){
                        location.href = '/product/order/pay/?oid=' + res.data.oid;
                    } else {
                        layer.msg("订单异常", {icon:2, time:5000});
                    }
                } else {
                    layer.msg(res.msg, {icon:2, time:5000});
                }
            })
            .fail(function() {
                layer.msg('服务器连接失败，请联系管理员', {icon:2, time:5000});
            })
            .always(function() {
                layer.close(i);
            });

            return false;
        } else {
            layer.msg("下单数量超限", {icon:2, time:5000});
            layer.close(i);
        }
        return false;
    });

    // Share button
    var shareBtn = document.getElementById('share-btn');
    if (shareBtn) {
        shareBtn.addEventListener('click', function() {
            if (navigator.share) {
                navigator.share({
                    title: document.title,
                    url: window.location.href
                });
            } else {
                navigator.clipboard.writeText(window.location.href).then(function() {
                    layer.msg('链接已复制到剪贴板', {icon:1, time:2000});
                });
            }
        });
    }

    // Image zoom - custom modal
    document.querySelectorAll('[data-product-gallery]').forEach(function(gallery) {
        var image = gallery.querySelector('#detail-image');
        var thumbnails = Array.prototype.slice.call(gallery.querySelectorAll('[data-gallery-index]'));
        var counter = gallery.querySelector('[data-gallery-current]');
        var activeIndex = 0;

        function showImage(index) {
            var thumbnail = thumbnails[index];
            if (!thumbnail || !image) return;
            activeIndex = index;
            image.src = thumbnail.getAttribute('data-gallery-src');
            image.alt = thumbnail.getAttribute('data-gallery-alt');
            thumbnails.forEach(function(item, itemIndex) {
                var active = itemIndex === activeIndex;
                item.classList.toggle('is-active', active);
                item.setAttribute('aria-pressed', active ? 'true' : 'false');
            });
            if (counter) counter.textContent = String(activeIndex + 1);
            thumbnail.scrollIntoView({block:'nearest', inline:'nearest'});
        }

        thumbnails.forEach(function(thumbnail, index) {
            thumbnail.addEventListener('click', function() { showImage(index); });
        });
        gallery.querySelectorAll('[data-gallery-direction]').forEach(function(button) {
            button.addEventListener('click', function() {
                var offset = button.getAttribute('data-gallery-direction') === 'next' ? 1 : -1;
                showImage((activeIndex + offset + thumbnails.length) % thumbnails.length);
            });
        });
    });

    var zoomBtn = document.getElementById('image-zoom-btn');
    if (zoomBtn) {
        zoomBtn.addEventListener('click', function() {
            var img = document.getElementById('detail-image');
            if (img) {
                var modal = document.createElement('div');
                modal.className = 'tokyo-image-modal';
                modal.innerHTML = '<div class="tokyo-image-modal-overlay"></div>' +
                    '<div class="tokyo-image-modal-content"><img src="' + img.src + '" alt="原图">' +
                    '<button class="tokyo-image-modal-close" aria-label="关闭">&times;</button></div>';
                document.body.appendChild(modal);
                document.body.style.overflow = 'hidden';
                var closeBtn = modal.querySelector('.tokyo-image-modal-close');
                var overlay = modal.querySelector('.tokyo-image-modal-overlay');
                var onImageModalEscape;
                var closeModal = function() {
                    if (modal.classList.contains('is-closing')) return;
                    modal.classList.add('is-closing');
                    document.removeEventListener('keydown', onImageModalEscape);
                    setTimeout(function() {
                        modal.remove();
                        document.body.style.overflow = '';
                    }, 180);
                };
                onImageModalEscape = function(e) {
                    if (e.key === 'Escape') closeModal();
                };
                closeBtn.addEventListener('click', closeModal);
                overlay.addEventListener('click', closeModal);
                modal.addEventListener('click', function(e) {
                    if (e.target === modal) closeModal();
                });
                document.addEventListener('keydown', onImageModalEscape);
                modal.querySelector('.tokyo-image-modal-content').addEventListener('click', function(e) {
                    e.stopPropagation();
                });
            }
        });
    }

    // Wholesale discount popup
    $('#view-youhui').on('click', function(event) {
        if(typeof PIFA === 'undefined' || !PIFA) return;
        var getTpl = youhui_tpl.innerHTML;
        var youhui_html = "";
        laytpl(getTpl).render(PIFA, function(html){
            youhui_html = html;
        });
        layer.open({
            type: 1,
            title: false,
            closeBtn: true,
            offset: "auto",
            area: ['600px', 'auto'],
            id: 'layerYouhuiAuto',
            content: youhui_html,
            shade: 0,
            yes: function(){
                layer.closeAll();
            }
        });
    });

    // Password product
    if(typeof PASSWORD_PRODUCT !== "undefined"){
        if(PASSWORD_PRODUCT > 0){
            var html = '<div style="padding: 30px; line-height: 22px; background: var(--tokyo-card, #fff); color: var(--tokyo-text, #333);"><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:8px;">商品密码</label><input type="password" id="productpassword" name="productpassword" lay-verify="required" placeholder="请输入密码" autocomplete="off" class="tokyo-form-input" style="width:100%;"></div></div>';
            layer.open({
                type: 1,
                title: false,
                closeBtn: true,
                area: '360px;',
                shade: 0.8,
                id: 'product_password',
                btn: ['提交', '放弃'],
                btnAlign: 'c',
                moveType: 1,
                content: html,
                yes: function(layero){
                    var pid = $("#pid").val();
                    var productpassword = $("#productpassword").val();
                    if(productpassword.length > 0){
                        $.ajax({
                            url: '/product/get/proudctinfo',
                            type: 'POST',
                            dataType: 'json',
                            data: {'pid': pid, 'password': productpassword, 'csrf_token': TOKEN},
                            success: function(res) {
                                if(res.code == '1'){
                                    layer.closeAll();
                                } else {
                                    layer.msg(res.msg, {icon:2, time:5000});
                                }
                            }
                        });
                    } else {
                        layer.msg("请输入密码", {icon:2, time:5000});
                    }
                },
                btn2: function(){
                    location.href = '/product/';
                },
                cancel: function(){
                    location.href = '/product/';
                }
            });
        }
    }

    exports('product', null);
});
