'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resGraphAfePhasing
 * @description
 * # resGraphAfePhasing
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resGraphAfePhasing', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.AfePhasingGraph);
        }]);
