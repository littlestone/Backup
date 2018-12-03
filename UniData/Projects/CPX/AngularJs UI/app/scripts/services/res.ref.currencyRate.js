'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resCurrencyRate
 * @description
 * # resCurrencyRate
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resCurrencyRate', function($resource, svApiURLs) {
    return $resource(svApiURLs.currencyRate);
  });
