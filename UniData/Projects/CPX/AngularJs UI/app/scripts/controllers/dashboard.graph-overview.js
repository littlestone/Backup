'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:GraphOverviewCtrl
 * @description
 * # GraphOverviewCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('GraphOverviewCtrl', ['appUsers', '$scope', function (appUsers, $scope) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var self = this;

    self.users = appUsers;

    $scope.dataSource = {
      'chart': {
        'caption': 'Projects',
        'subcaption': 'Overview',
        'xaxisname': '',
        'yaxisname': '$ Amount',
        'theme': 'fint',
        'showBorder': '0',
        'bgColor': 'F5F5F5'
      },
      'categories': [{
        'category': [{
          'label': 'Total Budget'
        }, {
          'label': 'Spent to Date'
        }, {
          'label': 'Forecast'
        }, {
          'label': 'Over/Under'
        }]
      }],
      'dataset': [{
        'seriesname': 'Values',
        'allowDrag': '0',
        'data': [{
          'value': '8000000'
        }, {
          'value': '4210000'
        }, {
          'value': '7020000'
        }, {
          'value': '2810000'
        }]
      }]
    };
  }]);
