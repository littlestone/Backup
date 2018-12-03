'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:RefCategoriesCtrl
 * @description
 * # RefCategoriesCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('RefCategoriesCtrl', function (appReferences, $scope) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    $scope.categories = appReferences.categories;
    $scope.selectedCat = -1;
  });
