'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeForecastFullSummary
 * @description
 * # resAfeForecastFullSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resAfeForecastFullSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.afeForecastFullSummary);
    });
