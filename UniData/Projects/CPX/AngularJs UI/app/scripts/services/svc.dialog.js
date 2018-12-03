'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svDialog
 * @description
 * # svDialog
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('svDialog', function ($mdDialog) {

        this.showSimpleDialog = function (dialogMess, dialogTitle, isAlert) {

            $mdDialog.show({
                templateUrl: 'views/templates/dialogtemplate.html',
                controller: 'svDialogCtrl',
                parent: angular.element(document.body),
                clickOutsideToClose: false,
                fullscreen: 'false',
                multiple: 'ture',
                locals: {
                    dialogMess: dialogMess,
                    dialogTitle: dialogTitle,
                    isAlert: isAlert
                }
            });
        };

        //            //-- In Dev
        //            this.showYesNoDialog = function () {
        //                var confirm = $mdDialog.prompt()
        //                        .title('What would you name your dog?')
        //                        .textContent('Bowser is a common name.')
        //                        .ok('Okay!')
        //                        .cancel('I\'m a cat person');
        //
        //                return $mdDialog.show(confirm);
        //            };
    })
//-- In Dev

    .controller('svDialogCtrl', function ($scope, $mdDialog, locals) {

        $scope.dialogMessage = locals.dialogMess;
        $scope.dialogTitle = locals.dialogTitle;

        //            if (!locals.isAlert){
        //                $scope.headColor = $mdColors.getThemeColor('primary-hue-2');
        //            }
        //            else {
        //                $scope.headColor = $mdColors.getThemeColor('warn-hue-2');
        //            }
        //

        $scope.closeDialog = function () {
            $mdDialog.hide();
        };
    });
