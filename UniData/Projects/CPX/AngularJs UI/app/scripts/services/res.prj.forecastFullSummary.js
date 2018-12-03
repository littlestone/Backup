'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectForeFullSummary
 * @description
 * # resProjectForeFullSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resProjectForeFullSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.prjForecastFullSummary);
    });
