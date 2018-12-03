'use strict';

angular.module('cpxUiApp')
  .controller('newUserDialogCtrl', function ($scope, $mdDialog) {

    $scope.selectedUser = null;
        
    $scope.answer = function(answer){
        $mdDialog.hide(answer);
    };
  });
