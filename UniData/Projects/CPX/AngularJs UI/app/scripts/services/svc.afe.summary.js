'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svAfeSummary
 * @description
 * # svAfeSummary
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .service('svAfeSummary', function () {
    var summary = {
      afeTotalAmt: 0,
      afeSupplementals: 0,
      afeNextYrPhasing: 0,
      afePrevYear: 0,
      afeActual: 0,
      afeCurrentYrForecast: 0 ,
      available: function(){
        var sum = summary.afeTotalAmt + summary.afeSupplementals - summary.afeNextYrPhasing - summary.afePrevYear - summary.afeActual - summary.afeCurrentYrForecast;
        //Rounding to two decimals
        return parseFloat(sum.toFixed(2));
      }
    };

    return summary;
  });
