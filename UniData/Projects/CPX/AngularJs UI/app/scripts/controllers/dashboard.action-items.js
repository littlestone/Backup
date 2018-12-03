'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ActionItemsCtrl
 * @description
 * # ActionItemsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ActionItemsCtrl', ['$http', '$mdDialog', 'svApiURLs', function ($http, $mdDialog, svApiURLs) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var self = this;

    self.toDo = [];
    self.dataLoading = true;

    var showAlert = function (ev) {
      $mdDialog.show(
        $mdDialog.alert()
          .parent(angular.element(document.querySelector('#popupContainer')))
          .clickOutsideToClose(true)
          .title('Alert')
          .textContent('Something happened')
          .ok('Ok')
          .targetEvent(ev)
      );
    };

    $http.get(svApiURLs.toDo + '?userName=' + 'CORP\\erigau')
      .then(function (response) {
        self.toDo = response.data;
        self.dataLoading = false;
      }, function () {
        showAlert();
      });
  }]);
