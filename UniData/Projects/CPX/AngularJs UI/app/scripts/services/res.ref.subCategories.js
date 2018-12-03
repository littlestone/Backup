'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resSubCategories
 * @description
 * # resSubCategories
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resSubCategories', function ($resource, svApiURLs) {
        return $resource(svApiURLs.subCategories);
    });
