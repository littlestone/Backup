'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPriorities
 * @description
 * # resPriorities
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPriorities', function ($resource, svApiURLs) {
        return $resource(svApiURLs.Priorities);
    });
