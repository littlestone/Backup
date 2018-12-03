'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeProjectSummary
 * @description
 * # resAfeProjectSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resAfeProjectSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.afePrjSummary);
    });
