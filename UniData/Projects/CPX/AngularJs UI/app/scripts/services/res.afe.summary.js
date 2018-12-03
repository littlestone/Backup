'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeSummary
 * @description
 * # resAfeSummary
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resAfeSummary', function ($resource, svApiURLs) {
        return $resource(svApiURLs.afeSummary);
    });
