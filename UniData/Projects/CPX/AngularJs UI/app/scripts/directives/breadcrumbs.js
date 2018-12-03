'use strict';

/**
 * @ngdoc directive
 * @name cpxUiApp.directive:breadcrumbs
 * @description
 * # breadcrumbs
 */

angular.module('cpxUiApp')
        .directive('breadcrumbs', function () {
            return {
                restrict: 'EA',
                replace: false,
                templateUrl: 'views/templates/breadcrumbs.html',
                controller: 'BreadcrumbsCtrl'
            };
        });