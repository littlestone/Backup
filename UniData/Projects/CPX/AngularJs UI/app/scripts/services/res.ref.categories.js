'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resCategories
 * @description
 * # resCategories
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resCategories', function ($resource, svApiURLs) {
    return $resource(svApiURLs.categories, {}, {
      query: { method: "POST", isArray: true }
    });
  });
