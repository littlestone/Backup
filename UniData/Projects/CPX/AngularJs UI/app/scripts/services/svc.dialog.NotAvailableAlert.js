'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.notAvailableAlertDialog
 * @description
 * # notAvailableAlertDialog
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('notAvailableAlertDialog', function (svDialog) {
        return function () {
            svDialog.showSimpleDialog(
                'This function will be available in a future milestone. Please try again later.',
                'Development'
            );
        };
    });
