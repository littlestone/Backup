'use strict';

angular.module('cpxUiApp')
  .factory('resAfeAssets', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.assetByAfe);
  }]);