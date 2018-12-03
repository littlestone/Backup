'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjProjects
 * @description
 * # resPrjProjects
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resPrjProjects', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.Project);
        }]);
