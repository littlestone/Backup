'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resUserInfo
 * @description
 * # resUserInfo
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resCurrentUserInfo', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.currentUserInfo);
        }]);
