'use strict';

angular.module('cpxUiApp')
  .factory('resAfeAsset', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.asset);
  }]);