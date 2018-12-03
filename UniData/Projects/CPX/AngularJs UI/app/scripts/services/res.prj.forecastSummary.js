'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjForecastSummary
 * @description
 * # resPrjForecastSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPrjForecastSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.prjForecastSummary);
    });
