'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svPrjSummary
 * @description
 * # svPrjSummary
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .service('svPrjSummary', function () {

    var prjSummary = {
      prjAmount: 0,
      prjTransac: 0,
      nextYear: 0,
      prevYear: 0,
      forecast: 0,
      currentActuals: 0,
      currentForecast: 0,
      available: function(){
        var sum = prjSummary.prjAmount + prjSummary.prjTransac - prjSummary.nextYear - prjSummary.prevYear - prjSummary.forecast - prjSummary.currentActuals - prjSummary.currentForecast;
        //Rounding to two decimals
        return parseFloat(sum.toFixed(2));
      }
    };

    return prjSummary;
  });
