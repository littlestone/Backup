'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeStatus
 * @description
 * # resAfeStatus
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resAfeStatus', function ($resource, svApiURLs) {
    return $resource(svApiURLs.afeStatus);
  });
