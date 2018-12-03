'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.assetsummary
 * @description
 * # assetsummary
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .service('assetsummary', function () {
    // AngularJS will instantiate a singleton by calling "new" on this function
    var summary = {
      assetTotalAmt: 0,
      additionalFeeTotalAmt: 0,
      afeTotalAmt: 0
    };

    return summary;
  });
