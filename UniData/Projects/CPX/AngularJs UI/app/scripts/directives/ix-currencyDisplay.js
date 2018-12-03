'use strict';

angular.module('cpxUiApp')
  .directive('ixCurrencyDisplay', function() {
    return {
      templateUrl: 'views/templates/currencyDisplay.html',
      restrict: 'E',
      scope: {
        ngValue: '@',
        rate: '@'
      },
      controller: 'ixCurrencyDisplayCtrl'
    };
  })
  .controller('ixCurrencyDisplayCtrl', function($scope) {
    $scope.displayAmount = function() {
      var rate = 1;

      if (typeof $scope.rate !== 'undefined') {
        rate = $scope.rate;
      }

      return $scope.ngValue * rate;
    };
  });
