'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.prjActualsResource
 * @description
 * # prjActualsResource
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('prjActualsResource', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.PrjActual);
        }]);
