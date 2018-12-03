'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:MenupanelctrlCtrl
 * @description
 * # MenupanelctrlCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('MenupanelctrlCtrl', function ($mdPanel) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    this._mdPanel = $mdPanel;

    this.desserts = [
      'Apple Pie',
      'Donut',
      'Fudge',
      'Cupcake',
      'Ice Cream',
      'Tiramisu'
    ];

    this.selected = {favoriteDessert: 'Donut'};
    this.disableParentScroll = false;
  });
