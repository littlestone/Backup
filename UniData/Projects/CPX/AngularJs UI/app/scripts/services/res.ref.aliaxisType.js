'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAliaxisType
 * @description
 * # resAliaxisType
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resAliaxisType', function ($resource, svApiURLs) {
        return $resource(svApiURLs.AliaxisType);
    });
