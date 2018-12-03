'use strict';


angular.module('cpxUiApp')
  .factory('resPoPayments', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.poPayments);
  }]);


