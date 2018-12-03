'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resCurrencies
 * @description
 * # resCurrencies
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resCurrencies', function ($resource, svApiURLs) {
        return $resource(svApiURLs.Currencies);
    });
