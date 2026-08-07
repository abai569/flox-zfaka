/**
 * Tokyo Theme - Common JS
 */
(function() {
    'use strict';

    // Console branding
    console.log('%c Tokyo Theme - 默认美学 ', 'background: #000; color: #fff; font-size: 14px; padding: 4px 8px; border-radius: 4px;');

    // Mobile sidebar toggle
    document.addEventListener('DOMContentLoaded', function() {
        var sidebar = document.querySelector('.tokyo-sidebar-panel');
        var backdrop = document.querySelector('.tokyo-mobile-sidebar-backdrop');
        var filterBtn = document.querySelector('.tokyo-mobile-filter-trigger');
        var closeBtn = document.querySelector('.tokyo-mobile-sidebar-close');
        var navToggle = document.querySelector('.tokyo-nav-toggle');
        var navMenu = document.getElementById('tokyoNavMenu');

        if (filterBtn && sidebar) {
            filterBtn.addEventListener('click', function() {
                sidebar.classList.add('is-open');
                if (backdrop) backdrop.classList.add('is-visible');
            });
        }

        if (closeBtn && sidebar) {
            closeBtn.addEventListener('click', function() {
                sidebar.classList.remove('is-open');
                if (backdrop) backdrop.classList.remove('is-visible');
            });
        }

        if (backdrop) {
            backdrop.addEventListener('click', function() {
                if (sidebar) sidebar.classList.remove('is-open');
                backdrop.classList.remove('is-visible');
            });
        }

        // Notice modal
        var NOTICE_ACK_KEY = 'tokyo_notice_ack';
        var NOTICE_ACK_TTL = 60 * 60 * 1000; // 1 hour
        var noticeTrigger = document.querySelector('.tokyo-notice-trigger');
        var noticeModal = document.getElementById('tokyo-notice-modal');
        if (noticeTrigger && noticeModal) {
            var noticeOverlay = noticeModal.querySelector('.tokyo-notice-overlay');
            var noticeDialog = noticeModal.querySelector('.tokyo-notice-dialog');
            var noticeCancelBtn = noticeModal.querySelector('[data-notice-action="cancel"]');
            var noticeConfirmBtn = noticeModal.querySelector('[data-notice-action="confirm"]');

            function isNoticeAcknowledged() {
                try {
                    var ts = localStorage.getItem(NOTICE_ACK_KEY);
                    if (!ts) return false;
                    var t = parseInt(ts, 10);
                    if (isNaN(t)) return false;
                    return (Date.now() - t) < NOTICE_ACK_TTL;
                } catch (e) {
                    return false;
                }
            }

            function setNoticeAcknowledged() {
                try {
                    localStorage.setItem(NOTICE_ACK_KEY, String(Date.now()));
                    return true;
                } catch (e) {
                    return false;
                }
            }

            function openNotice() {
                noticeModal.hidden = false;
                noticeTrigger.classList.add('is-active');
                noticeTrigger.setAttribute('aria-expanded', 'true');
                document.body.style.overflow = 'hidden';
                if (noticeConfirmBtn) noticeConfirmBtn.focus();
            }

            function closeNotice() {
                noticeModal.hidden = true;
                noticeTrigger.classList.remove('is-active');
                noticeTrigger.setAttribute('aria-expanded', 'false');
                document.body.style.overflow = '';
                noticeTrigger.focus();
            }

            // Nav pill always opens on manual click
            noticeTrigger.addEventListener('click', function() {
                openNotice();
            });

            // Overlay click closes without persisting
            if (noticeOverlay) {
                noticeOverlay.addEventListener('click', function() {
                    closeNotice();
                });
            }

            // Cancel closes without persisting
            if (noticeCancelBtn) {
                noticeCancelBtn.addEventListener('click', function() {
                    closeNotice();
                });
            }

            // Confirm closes and stores ack
            if (noticeConfirmBtn) {
                noticeConfirmBtn.addEventListener('click', function() {
                    setNoticeAcknowledged();
                    closeNotice();
                });
            }

            // Escape closes without persisting
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && !noticeModal.hidden) {
                    closeNotice();
                }
            });

            // Trap focus inside dialog while open
            noticeModal.addEventListener('keydown', function(e) {
                if (e.key !== 'Tab') return;
                var focusable = noticeModal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
                if (!focusable.length) return;
                var first = focusable[0];
                var last = focusable[focusable.length - 1];
                if (e.shiftKey) {
                    if (document.activeElement === first) {
                        e.preventDefault();
                        last.focus();
                    }
                } else {
                    if (document.activeElement === last) {
                        e.preventDefault();
                        first.focus();
                    }
                }
            });

            // Prevent dialog clicks from bubbling to overlay
            if (noticeDialog) {
                noticeDialog.addEventListener('click', function(e) {
                    e.stopPropagation();
                });
            }

            // Auto-open on page load if not acknowledged
            if (!isNoticeAcknowledged()) {
                openNotice();
            }
        }

        // Share button - auto copy current page URL
        var shareBtn = document.getElementById('share-btn');
        if (shareBtn) {
            shareBtn.addEventListener('click', function() {
                var url = window.location.href;
                var showCopied = function() {
                    var toast = document.createElement('div');
                    toast.textContent = '链接已复制到剪贴板';
                    toast.style.cssText = 'position:fixed;left:50%;bottom:32px;transform:translateX(-50%);background:rgba(0,0,0,0.78);color:#fff;padding:8px 18px;border-radius:20px;font-size:13px;z-index:2000;';
                    document.body.appendChild(toast);
                    setTimeout(function() { toast.remove(); }, 1600);
                };
                var legacyCopy = function() {
                    var ta = document.createElement('textarea');
                    ta.value = url;
                    ta.style.position = 'fixed';
                    ta.style.opacity = '0';
                    document.body.appendChild(ta);
                    ta.select();
                    var ok = false;
                    try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
                    document.body.removeChild(ta);
                    return ok;
                };
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(url).then(showCopied, function() {
                        if (legacyCopy()) showCopied();
                    });
                } else if (legacyCopy()) {
                    showCopied();
                }
            });
        }

        // Captcha refresh
        var captchaImg = document.getElementById('captcha-image');
        if (captchaImg) {
            captchaImg.addEventListener('click', function() {
                this.src = '/Captcha?t=product&r=' + Math.random();
            });
        }

        // Copy order ID
        var copyBtn = document.getElementById('copy-orderid');
        if (copyBtn) {
            copyBtn.addEventListener('click', function() {
                var orderId = document.querySelector('.tokyo-order-id');
                if (orderId) {
                    navigator.clipboard.writeText(orderId.textContent.trim()).then(function() {
                        alert('订单号已复制');
                    });
                }
            });
        }

        // Copy card
        var copyCards = document.querySelectorAll('.tokyo-copy-card');
        copyCards.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var card = this.getAttribute('data-card');
                navigator.clipboard.writeText(card).then(function() {
                    alert('卡密已复制');
                });
            });
        });

        // Mobile navigation toggle
        var navTogglers = document.querySelectorAll('[data-bs-toggle="collapse"]');
        navTogglers.forEach(function(toggler) {
            toggler.addEventListener('click', function() {
                var target = document.querySelector(this.getAttribute('data-bs-target'));
                if (target) {
                    target.classList.toggle('show');
                    var expanded = target.classList.contains('show');
                    this.setAttribute('aria-expanded', expanded ? 'true' : 'false');
                    var nav = this.closest('.tokyo-nav');
                    if (nav) nav.classList.toggle('is-expanded', expanded);
                }
            });
        });
    });
})();
