'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resAfeShortList
 * @description
 * # resAfeShortList
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resAfeShortList', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.afeListShort);
        }]);
