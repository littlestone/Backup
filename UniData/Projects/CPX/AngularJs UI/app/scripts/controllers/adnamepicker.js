'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AdnamepickerCtrl
 * @description
 * # AdnamepickerCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('adnamepickerCtrl', function ($scope, svApiURLs, $http, $mdDialog) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    $scope.queryResult = [];
    $scope.searchString = '';
    $scope.selectedUser = '';
    $scope.selectedADUser = {userName: '', displayName: ''};

    $scope.adLookup = function (query) {
      $http.get(svApiURLs.userLookup + query)
        .then(function (result) {
          $scope.queryResult = result.data;
        },
              function () {
                $scope.queryResult = null;
              });
    };

    $scope.listClick = function (userName, displayName) {
      $scope.selectedADUser = {
        userName: userName,
        displayName: displayName.substring(0, displayName.indexOf(" ("))
      };
    };

    $scope.answer = function (answer) {
      $mdDialog.hide(answer);
    };
  });
