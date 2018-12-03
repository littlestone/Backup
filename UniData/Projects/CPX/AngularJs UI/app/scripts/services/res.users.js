'use strict';

angular.module('cpxUiApp')
  .factory('resUsers', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
          return $resource(svApiURLs.users);
  }]);

