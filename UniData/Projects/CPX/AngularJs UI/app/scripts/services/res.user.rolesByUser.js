'use strict';

angular.module('cpxUiApp')
  .factory('resUserRolesByUser', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
          return $resource(svApiURLs.userRoles);
  }]);