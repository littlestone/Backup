'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectEditCtrl
 * @description
 * # ProjectEditCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectEditCtrl', function ($scope, currentProject, svAppBusy) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cProjectEdit = this;

    cProjectEdit.currentProject = currentProject;

    $scope.OverviewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0) - 65;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    var formHeight = '730';
    //var contentHeight = '675'; // '625';
    var overviewHeight = formHeight - 45;

    $scope.isOverviewOpen = true; //cProjectEdit.currentProject.status > 0;

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: '585px'};//{height: (windowHeight - 137) + 'px'};
      $scope.formStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: '585px'};
      $scope.formStyle = {height: formHeight + 'px'};
    }

    //$scope.contentStyle =  {height: '585px'};

    $scope.prjOverviewStyle = {
      'width': '250px',
      'height': overviewHeight + 'px',
      'border-left-style': 'solid',
      'border-bottom-style': 'solid',
      'border-radius': '5px'
    };

    $scope.showOverview = function(){
      $scope.isOverviewOpen = true;
      $scope.prjOverviewStyle = {
        'width': '250px',
        'height': overviewHeight + 'px',
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
