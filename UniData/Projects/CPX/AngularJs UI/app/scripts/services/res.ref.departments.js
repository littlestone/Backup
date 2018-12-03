'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resDepartments
 * @description
 * # resDepartments
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resDepartments', function ($resource, svApiURLs) {
        return $resource(svApiURLs.Departments);
    });
