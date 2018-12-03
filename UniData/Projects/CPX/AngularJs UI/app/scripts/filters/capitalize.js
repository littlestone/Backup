'use strict';

/**
 * @ngdoc filter
 * @name cpxUiApp.filter:capitalize
 * @function
 * @description
 * # capitalize
 * Filter in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .filter('capitalize', function () {
            return function (input) {

                var retVal = '';

                if (input !== undefined && input !== null) {
                    input = input.toLowerCase();
                    retVal = input.substring(0, 1).toUpperCase() + input.substring(1);
                }
                return retVal;
            };
        });
