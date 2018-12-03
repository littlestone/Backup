'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeAfe
 * @description
 * # resAfeAfe
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resAfeAfe', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.AFE);
        }]);
