'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectAttachementsCtrl
 * @description
 * # ProjectAttachementsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
    .controller('ProjectAttachementsCtrl', function ($scope, currentProject, appUsers, notAvailableAlertDialog) { //, $http, svApiURLs) {

        this.awesomeThings = [
            'HTML5 Boilerplate',
            'AngularJS',
            'Karma'
        ];

        $scope.showNotAvailableAlert = notAvailableAlertDialog;

        var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

        if ((windowHeight - 327) < 647)
        {
            $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
        } else
        {
            $scope.contentStyle = {height: '670px'};
        }

        $scope.curProject = currentProject;
        $scope.appUsers = appUsers;
    });
