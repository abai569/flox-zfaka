/**
 * Tokyo Theme - Index Page JS
 * 分类切换 + 搜索功能
 */
(function() {
    'use strict';

    document.addEventListener('DOMContentLoaded', function() {
        var categoryItems = document.querySelectorAll('.tokyo-category-item');
        var searchInput = document.getElementById('item-search-input');
        var searchTrigger = document.getElementById('item-search-trigger');
        var sidebar = document.querySelector('.tokyo-sidebar-panel');
        var backdrop = document.querySelector('.tokyo-mobile-sidebar-backdrop');

        // Category click
        categoryItems.forEach(function(item) {
            item.addEventListener('click', function() {
                var tid = this.getAttribute('data-tid');
                if (tid) {
                    window.location.href = '/?tid=' + tid;
                }
            });
        });

        // Search
        function doSearch() {
            var keyword = searchInput ? searchInput.value.trim() : '';
            var currentTid = 0;
            var activeCat = document.querySelector('.tokyo-category-item.active');
            if (activeCat) {
                currentTid = activeCat.getAttribute('data-tid') || 0;
            }
            var url = '/';
            var params = [];
            if (currentTid > 0) params.push('tid=' + currentTid);
            if (keyword) params.push('q=' + encodeURIComponent(keyword));
            if (params.length > 0) url += '?' + params.join('&');
            window.location.href = url;
        }

        if (searchTrigger) {
            searchTrigger.addEventListener('click', doSearch);
        }

        if (searchInput) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    doSearch();
                }
            });
        }

        // Close sidebar on mobile after category click
        if (backdrop) {
            categoryItems.forEach(function(item) {
                item.addEventListener('click', function() {
                    if (window.innerWidth <= 992) {
                        sidebar.classList.remove('is-open');
                        backdrop.classList.remove('is-visible');
                    }
                });
            });
        }
    });
})();
