'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeForecast
 * @description
 * # resAfeForecast
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resAfeForecast', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.afeForecast);
        }]);
