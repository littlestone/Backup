'use strict';

/**
 * @ngdoc filter
 * @name cpxUiApp.filter:prjListFilter
 * @function
 * @description
 * # prjListFilter
 * Filter in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .filter('prjListFilter', function () {
        return function (items) {
            //var filtered = [];

            var originalBudget = 0;


            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                if (true) {
                    //filtered.push(item);
                    originalBudget = originalBudget + item.originalBud;
                }
            }
            return originalBudget;
        };
    });
