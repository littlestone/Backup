'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svtoast
 * @description
 * # svtoast
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('svToast', function ($mdToast) {

        var last = {
            bottom: true,
            top: false,
            left: false,
            right: true
        };

        var toastPosition = angular.extend({}, last);

        function getToastPosition() {
            sanitizePosition();

            return Object.keys(toastPosition)
                .filter(function (pos) {
                    return toastPosition[pos];
                })
                .join(' ');
        }

        function sanitizePosition() {
            var current = toastPosition;

            if (current.bottom && last.top) {
                current.top = false;
            }
            if (current.top && last.bottom) {
                current.bottom = false;
            }
            if (current.right && last.left) {
                current.left = false;
            }
            if (current.left && last.right) {
                current.right = false;
            }

            last = angular.extend({}, current);
        }


        this.showSimpleToast = function (message) {
            var pinTo = getToastPosition();

            $mdToast.show(
                $mdToast.simple()
                    .textContent(message)
                    .position(pinTo)
                    .hideDelay(3000)
            );
        };
    });
