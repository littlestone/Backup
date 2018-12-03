'use strict';

angular.module('cpxUiApp')
  .directive('ixPhasingAmount', function ($filter) {
    var formatter = function (num) {
      return $filter('currency')(num);
    };

    return {
      templateUrl: 'views/templates/phasingamount.html',
      restrict: 'E',
      require: 'ngModel',
      scope: {
        label: '@',
        actual: '@',
        year: '@',
        month: '@',
        budgetTypeId: '@',
        baseCurrencyId: '@',
        targetCurrencyId: '@',
        categoryId: '@',
        projectId: '@',
        afeId: '@',
        ngModel: '=',
        ngReadonly: '=',
        form: '=',
        ngChange: '&'
      },
      controller: 'ixPhasingAmountCtrl',

      link: function (scope, element, attr, ngModel) {

        // scope.$parent.$watch('selectedCurrencyId', function(newVal, oldVal) {
        //   if (scope.$parent.selectedCurrencyId !== undefined && newVal !== oldVal) {
        //     // console.log("newVal=" + newVal);
        //     // console.log("oldVal=" + oldVal);
        //   }
        // });

        ngModel.$formatters.push(formatter);

        ngModel.$parsers.push(function (str) {
          return str ? Number(str) : '';
        });

        element.on('change', 'input', function () {
          scope.ngChange();
        });

        element.on('blur', 'input', function () {
          element[0].firstChild.getElementsByClassName('phAmountInput')[0].value = (!angular.isUndefined(ngModel.$modelValue) ? formatter(ngModel.$modelValue) : '');
        });
        element.on("focus", 'input', function () {
          element[0].firstChild.getElementsByClassName('phAmountInput')[0].value = (!angular.isUndefined(ngModel.$modelValue) ? ngModel.$modelValue : '');
        });
      }
    };
  })
  .controller('ixPhasingAmountCtrl', function ($scope, colorPhasing, resCurrencyRate, resPrjForecastEach, resAfeForecast) {
    $scope.ixColorForecast = colorPhasing.forecast;
    $scope.ixColorActuals = colorPhasing.actuals;

    $scope.$watch('targetCurrencyId', function(newVal, oldVal) {
      // if ($scope.month === '1' && $scope.targetCurrencyId !== undefined && newVal !== oldVal) {
      if ($scope.targetCurrencyId !== undefined && newVal !== oldVal) {
        var inputAmount = $scope.ngModel;
        console.log("newVal=" + newVal);
        console.log("oldVal=" + oldVal);

        // console.log('acutal=' + $scope.actual);
        // console.log('year=' + $scope.year);
        // console.log('month=' + $scope.month);
        // console.log('budgetTypeId=' + $scope.budgetTypeId);
        // console.log('baseCurrencyId=' + $scope.baseCurrencyId);
        // console.log('targetCurrencyId=' + $scope.targetCurrencyId);
        // console.log("categoryId=" + $scope.categoryId);
        // console.log("projectId=" + $scope.projectId);
        // console.log("afeId=" + $scope.afeId);

        // prepare params for the currency rate web api
        var objParams = {
          year: $scope.year,
          month: $scope.month,
          budgetTypeId: $scope.budgetTypeId,
          baseCurrencyId: $scope.baseCurrencyId,
          targetCurrencyId: $scope.targetCurrencyId
        };
        // console.log(objParams);

        // refresh the amount with new exchange rate
        var exchangeRate = null;
        resCurrencyRate.get(objParams, function(data) {
          exchangeRate = data.exchangeRate === null ? 1 : data.exchangeRate;

          var month = $scope.label.toLowerCase();
          var originalAmount = 0;
          if ($scope.targetCurrencyId === $scope.baseCurrencyId && exchangeRate !== 1.0) {
            if ($scope.afeId === '') {
              resPrjForecastEach.query({prjId: $scope.projectId, budYear: $scope.year}, function (data) {
                var prjForecastData = data[$scope.categoryId];
                originalAmount = prjForecastData[month];
                $scope.ngModel = originalAmount;
                // console.log(prjForecastData);
                // console.log("originalAmount=" + originalAmount);
              });
            } else {
              resAfeForecast.query({afeID: $scope.afeId, afeYear: $scope.year}, function (data) {
                var afeForecastData = data[$scope.categoryId];
                originalAmount = afeForecastData[month];
                $scope.ngModel = originalAmount;
                // console.log(afeForecastData);
                // console.log(originalAmount[month]);
              });
            }
          }
          else {
            $scope.ngModel = exchangeRate === 1 ? inputAmount : (inputAmount * exchangeRate).toFixed(2);
          }

          // console.log("month=" + month);
          // console.log("inputAmount=" + inputAmount);
          // console.log("originalAmount=" + originalAmount);
          // console.log("exchangeRate=" + exchangeRate);
          // console.log("");
        });
      }
    });

    /*
      $scope.$watch('currencyId', function(newVal, oldVal) {
      if ($scope.currencyId !== undefined && newVal !== oldVal) {
      console.log("newVal=" + newVal);
      console.log("oldVal=" + oldVal);

      var monthIndex = undefined;
      switch($scope.label.toLowerCase()) {
      case 'january':
      monthIndex = 0;
      break;
      case 'february':
      monthIndex = 1;
      break;
      case 'march':
      monthIndex = 2;
      break;
      case 'april':
      monthIndex = 3;
      break;
      case 'may':
      monthIndex = 4;
      break;
      case 'june':
      monthIndex = 5;
      break;
      case 'july':
      monthIndex = 6;
      break;
      case 'august':
      monthIndex = 7;
      break;
      case 'september':
      monthIndex = 8;
      break;
      case 'october':
      monthIndex = 9;
      break;
      case 'november':
      monthIndex = 10;
      break;
      case 'december':
      monthIndex = 11;
      break;
      default:
      monthIndex = undefined;
      }

      // TODO: pass as parameter
      var currencyRate = $scope.$parent.currencyRate;

      if ($scope.ngModel !== undefined && currencyRate !== undefined) {
      // var currencyRate = angular.fromJson(scope.currencyRate);
      var rate = currencyRate.types.filter(function(obj) {
      if ($scope.actual) {
      return obj.budgetTypeId === 3; // actual
      }
      else {
      return obj.budgetTypeId === 2; // forecast
      }
      })[0];

      var inputAmount = $scope.ngModel;
      var rateFrom = rate.from[monthIndex];
      var rateTo = rate.to[monthIndex];

      console.log(currencyRate);
      console.log('acutal=' + $scope.actual);
      console.log('month=' + $scope.label.toLowerCase());
      console.log('monthIndex=' + monthIndex);
      console.log('year=' + currencyRate.year);
      console.log('currencyId=' + currencyRate.currencyId);
      console.log(rate);
      console.log('inputAmount=' + inputAmount);
      console.log('rateFrom=' + rateFrom);
      console.log('rateTo=' + rateTo);

      $scope.ngModel = (inputAmount * rateFrom).toFixed(2);
      }
      }
      });
    */
  });
