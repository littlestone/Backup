'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectTransactionDetailsCtrl
 * @description
 * # ProjectTransactionDetailsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectTransactionDetailsCtrl', function ($scope, $mdDialog, locals) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    // var self = this;

    $scope.transaction = locals.transaction;
    $scope.project = locals.project;
    $scope.appUsers = locals.appUsers;

    $scope.closeDialog = function() {
      $mdDialog.hide();
    };

    // function to show attachment utility
    $scope.showAttachmentUtility = function($event) {
      var parentEl = angular.element(document.body);
      $mdDialog.show({
        parent: parentEl,
        targetEvent: $event,
        escapeToClose: true,
        clickOutsideToClose: true,
        bindToController: true,
        scope: $scope,        // use parent scope in template
        preserveScope: true,  // do not forget this if use parent scope
        multiple: true,
        template: '<md-dialog aria-label="Attachment utility dialog" style="width:580px;">' +
                  '  <ix-attachments upload-enabled="true" download-enabled="true" delete-enabled="true" entity-type-id="3" entity-record-id="{{transaction.id}}" attachment-type-id="" userid="{{appUsers.userName}}">' +
                  '  </ix-attachments>' +
                  '</md-dialog>'
      });
    };
  });
