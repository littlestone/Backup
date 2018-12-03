'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resActionItem
 * @description
 * # resActionItem
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resActionItem', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.toDo);
        }]);
