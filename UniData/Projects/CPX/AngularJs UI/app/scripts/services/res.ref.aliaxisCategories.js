'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAliaxisCategories
 * @description
 * # resAliaxisCategories
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resAliaxisCategories', function ($resource, svApiURLs) {
        return $resource(svApiURLs.AliaxisCategories);
    });
