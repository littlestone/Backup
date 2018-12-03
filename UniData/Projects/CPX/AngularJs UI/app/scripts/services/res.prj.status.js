'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectStatus
 * @description
 * # resProjectStatus
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resProjectStatus', function ($resource, svApiURLs) {
    return $resource(svApiURLs.projectStatus);
  });
