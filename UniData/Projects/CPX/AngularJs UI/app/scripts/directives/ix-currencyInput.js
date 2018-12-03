'use strict';

angular.module('cpxUiApp')
  .directive('ixCurrencyInput', function() {
    return {
      templateUrl: 'views/templates/currencyInput.html',
      restrict: 'E',
      require: 'ngModel',
      scope: {
        tooltip: '@',
        label: '@',
        rateFrom: '@',
        rateTo: '@',
        ngModel: '=',
        ngReadonly: '=',
        form: '=',
        ngChange: '&',
        refresh: '='
      },
      controller: 'ixCurrencyInputCtrl',

      link: function(scope) {
        // refresh input currency rate when parent variable selectedCurr changed
        // TODO: refactor to bind an object with property selectedCurr to ngModel instead of watching on parent scope variable change
        scope.$parent.$watch('selectedCurr', function(newVal, oldVal) {
          if (scope.$parent.selectedCurr !== undefined && newVal !== oldVal) {
            scope.ngModel = scope.inputAmount * scope.rateFrom;
          }
        });
      }
    };
  })
  .controller('ixCurrencyInputCtrl', function($scope) {
    $scope.inputAmount = 0;

    var rateFrom = -1;
    var rateTo = -1;

    if (typeof $scope.rateFrom !== 'undefined') {
      rateFrom = $scope.rateFrom;
    }
    if (typeof $scope.rateTo !== 'undefined') {
      rateTo = $scope.rateTo;
    }

    $scope.inputAmount = $scope.ngModel * rateTo;

    $scope.updateModel = function() {
      $scope.ngModel = $scope.inputAmount * $scope.rateFrom;
    };
  });
