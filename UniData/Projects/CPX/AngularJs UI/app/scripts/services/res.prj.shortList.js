'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectShortList
 * @description
 * # resProjectShortList
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resProjectShortList', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.prjListShort);
        }]);
