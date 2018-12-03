'use strict';

angular.module('cpxUiApp')
  .factory('resPoReceipts', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.poReceipts);
  }]);





