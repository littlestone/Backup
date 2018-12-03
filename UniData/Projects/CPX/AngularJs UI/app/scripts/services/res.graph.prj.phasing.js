'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resGraphProjectPhasing
 * @description
 * # resGraphProjectPhasing
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resGraphProjectPhasing', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.PhasingGraph);
        }]);
