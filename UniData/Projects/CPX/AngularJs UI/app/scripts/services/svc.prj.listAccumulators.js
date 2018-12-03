'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svPrjListAccumulators
 * @description
 * # svPrjListAccumulators
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .service('svPrjListAccumulators', function () {

                var accumulators = {
                        originalBudget: 0,
                        transaction: 0,
                        currentBudget: 0,
                        prevYear: 0,
                        remainingBud: 0,
                        commited: 0,
                        poReceipt: 0,
                        actuals: 0,
                        forecast: 0,
                        remaining: 0,
                        actualYTD: 0,
                        NextYear: 0,
                        Available: 0
                };

                return accumulators;
        });
