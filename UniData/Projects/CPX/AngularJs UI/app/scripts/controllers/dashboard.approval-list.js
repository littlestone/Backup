'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ApprovalListCtrl
 * @description
 * # ApprovalListCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ApprovalListCtrl', ['appUsers', function (appUsers) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var self = this;

    self.users = appUsers;
  }]);
