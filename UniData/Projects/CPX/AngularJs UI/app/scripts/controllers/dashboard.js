'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:DashboardCtrl
 * @description
 * # DashboardCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('DashboardCtrl', ['appUsers', function (appUsers) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var self = this;
    self.users = appUsers.userName;
  }]);
