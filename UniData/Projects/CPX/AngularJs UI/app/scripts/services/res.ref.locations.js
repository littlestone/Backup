'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resLocations
 * @description
 * # resLocations
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resLocations', function ($resource, svApiURLs) {
    return $resource(svApiURLs.Locations, {}, {
      query: { method: "POST", isArray: true }
    });
  });
