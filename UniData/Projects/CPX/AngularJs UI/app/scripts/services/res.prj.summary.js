'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectSummary
 * @description
 * # resProjectSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resProjectSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.projectSummary);
    });
