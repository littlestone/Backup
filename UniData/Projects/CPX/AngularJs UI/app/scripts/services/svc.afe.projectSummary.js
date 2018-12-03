'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svAfePrjSummary
 * @description
 * # svAfePrjSummary
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .service('svAfePrjSummary', function () {
    var prjSummary = {
      originalAmount: 0,
      transactions: 0,
      nextYear: 0,
      prevYear: 0,
      forecast: 0,
      currentActuals: 0,
      currentForecast: 0,
      available: function(){
        return prjSummary.originalAmount + prjSummary.transactions - prjSummary.nextYear - prjSummary.prevYear - prjSummary.forecast - prjSummary.currentActuals - prjSummary.currentForecast;
      }
    };

    return prjSummary;
  });
