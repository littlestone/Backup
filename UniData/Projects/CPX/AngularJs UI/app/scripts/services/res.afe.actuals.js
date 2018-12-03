'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.afeActualResource
 * @description
 * # afeActualResource
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resAfeActuals', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.afeActuals);
        }]);
