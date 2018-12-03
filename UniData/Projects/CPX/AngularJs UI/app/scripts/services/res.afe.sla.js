'use strict';

angular.module('cpxUiApp')
  .factory('resAfeSla', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.afeSla);
  }]);