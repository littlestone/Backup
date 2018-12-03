'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPoListByAfe
 * @description
 * # resPoListByAfe
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resPoListByAfe', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.poListByAfe);
  }]);
