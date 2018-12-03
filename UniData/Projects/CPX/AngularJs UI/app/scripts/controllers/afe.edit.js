
'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeEditCtrl
 * @description
 * # AfeEditCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeEditCtrl', function ($scope, svAppBusy, currentAFE) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    $scope.isOverviewOpen = true;
    $scope.OverviewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0) - 65;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    var formHeight = '730';
    var contentHeight = '625'; // '625';

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
      $scope.formStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: contentHeight + 'px'};
      $scope.formStyle = {height: formHeight + 'px'};
    }


    var cAfeEdit = this;

    cAfeEdit.afe = currentAFE;


    $scope.prjOverviewStyle = {
      'width': '250px',
      'height': formHeight + 'px',
      'border-left-style': 'solid',
      'border-bottom-style': 'solid',
      'border-radius': '5px'
    };

    $scope.showOverview = function(){
      $scope.isOverviewOpen = true;
      $scope.prjOverviewStyle = {
        'width': '250px',
        'height': formHeight + 'px',
        'border-left-style': 'solid',
        'border-bottom-style': 'solid',
        'border-radius': '5px'
      };
    };

    $scope.hideOverview = function(){
      $scope.isOverviewOpen = false;
        $scope.prjOverviewStyle = {
          'width': '56px',
          'height': '49px'
        };
    };

    $scope.toggleOverview = function () {
      if (!$scope.isOverviewOpen) {
        $scope.showOverview();
      } 
      else {
        $scope.hideOverview();
      }
    };

    svAppBusy.state = false;

});
