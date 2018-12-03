'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AboutCtrl', function () {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
    this.testOk = true;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    this.windowStyle = {height: (windowHeight - 90) + 'px'};
    //this.contentStyle = {height: (windowHeight - 110) + 'px'};
    this.contentStyle = {height: (windowHeight - 177) + 'px'};

  });
