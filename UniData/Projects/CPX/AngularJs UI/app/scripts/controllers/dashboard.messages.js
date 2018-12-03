'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:MessagesCtrl
 * @description
 * # MessagesCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('MessagesCtrl', ['appUsers', '$http', '$mdDialog', 'svApiURLs', function (appUsers, $http, $mdDialog, svApiURLs) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var self = this;

    self.users = appUsers;
    self.dataLoading = true;
    self.userName = self.users.UserName;

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

    self.url = svApiURLs.messages + '?userName=' + 'CORP\\erigau';

    $http.get(svApiURLs.messages + '?userName=' + 'CORP\\erigau')
      .then(function (response) {
        self.messages = response.data;
        self.dataLoading = false;
      }, function () {
        showAlert();
      });
  }]);
