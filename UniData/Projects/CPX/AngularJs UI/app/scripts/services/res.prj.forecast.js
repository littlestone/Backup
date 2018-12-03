'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectForecast
 * @description
 * # resProjectForecast
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resProjectForecast', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.PrjForecast);
        }]);
