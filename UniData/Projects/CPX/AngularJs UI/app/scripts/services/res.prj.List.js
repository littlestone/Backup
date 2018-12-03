'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjBudget
 * @description
 * # resPrjBudget
 * Factory in the cpxUiApp.
 */

angular.module('cpxUiApp')
        .factory('resProjectList', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.ProjectList);
        }]);
