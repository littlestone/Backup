'use strict';

/**
 * @ngdoc directive
 * @name cpxUiApp.directive:ixBudgetamount
 * @description
 * # ixBudgetamount
 */
angular.module('cpxUiApp')
  .directive('ixBudgetamount', function () {

    return {
      templateUrl: 'views/templates/budgetamount.html',
      restrict: 'E',
      require: 'ngModel',
      scope: {
        label: '@',
        year: '@',
        month: '@',
        budgetTypeId: '@',
        baseCurrencyId: '@',
        targetCurrencyId: '@',
        categoryId: '@',
        projectId: '@',
        ngModel: '=',
        ngReadonly: '=',
        form: '=',
        ngChange: '&'
      },
      controller: 'ixBudgetAmountCtrl',

      link: function (scope, element) {

        element.on('change', 'input', function () {
          scope.ngChange();
        });
      }
    };
  }).controller('ixBudgetAmountCtrl', function ($scope, colorPhasing, resCurrencyRate, resPrjBudget) {
    $scope.ixColorBudget = colorPhasing.budget;

    $scope.$watch('targetCurrencyId', function(newVal, oldVal) {
      if ($scope.targetCurrencyId !== undefined && newVal !== oldVal) {
        var inputAmount = $scope.ngModel;
        console.log("newVal=" + newVal);
        console.log("oldVal=" + oldVal);

        console.log('acutal=' + $scope.actual);
        console.log('year=' + $scope.year);
        console.log('month=' + $scope.month);
        console.log('budgetTypeId=' + $scope.budgetTypeId);
        console.log('baseCurrencyId=' + $scope.baseCurrencyId);
        console.log('targetCurrencyId=' + $scope.targetCurrencyId);
        console.log("categoryId=" + $scope.categoryId);
        console.log("projectId=" + $scope.projectId);

        if (inputAmount !== 0.0) {
          // prepare params for the currency rate web api
          var objParams = {
            year: $scope.year,
            month: $scope.month === 'nextYear' ? 12 : $scope.month,
            budgetTypeId: $scope.budgetTypeId,
            baseCurrencyId: $scope.baseCurrencyId,
            targetCurrencyId: $scope.targetCurrencyId
          };
          console.log(objParams);

          // refresh the amount with new exchange rate
          var exchangeRate = null;
          resCurrencyRate.get(objParams, function(data) {
            console.log(data);
            exchangeRate = data.exchangeRate === null ? 1 : data.exchangeRate;

            var month = $scope.label.toLowerCase();
            if ($scope.month === 'nextYear') {
              month = 'nextYear';
            }
            console.log(month);
            var originalAmount = 0;
            if ($scope.targetCurrencyId === $scope.baseCurrencyId) {
              resPrjBudget.query({prjId: $scope.projectId, budYear: $scope.year}, function (data) {
                var budgetData = data[$scope.categoryId];
                console.log(budgetData);
                originalAmount = budgetData[month];
                $scope.ngModel = originalAmount;
                console.log("originalAmount=" + originalAmount);
              });
            }
            else {
              $scope.ngModel = exchangeRate === 1 ? inputAmount : (inputAmount * exchangeRate).toFixed(2);
            }

            console.log("inputAmount=" + inputAmount);
            console.log("originalAmount=" + originalAmount);
            console.log("exchangeRate=" + exchangeRate);
          });
        }
      }
    });
  });
