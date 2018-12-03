'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjForecastEach
 * @description
 * # resPrjForecastEach
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPrjForecastEach', function ($resource, svApiURLs) {
        return $resource(svApiURLs.prjForecastEach);
    });
