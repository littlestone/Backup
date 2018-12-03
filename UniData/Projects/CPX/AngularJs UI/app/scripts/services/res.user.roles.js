'use strict';

angular.module('cpxUiApp')
  .factory('resUserRoles', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
          return $resource(svApiURLs.roleInfo);
  }]);