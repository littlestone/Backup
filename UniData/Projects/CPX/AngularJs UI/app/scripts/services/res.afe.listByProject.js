'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeListProject
 * @description
 * # resAfeListProject
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resAfeListByProject', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.afeListByProject);
  }]);
