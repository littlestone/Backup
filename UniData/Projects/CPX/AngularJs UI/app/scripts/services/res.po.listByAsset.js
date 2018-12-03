'use strict';

angular.module('cpxUiApp')
  .factory('resPoByAsset', function ($resource, svApiURLs) {
    return $resource(svApiURLs.poListByAsset);
  });