'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjBudgetOwners
 * @description
 * # resPrjBudgetOwners
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPrjBudgetOwners', function ($resource, svApiURLs) {
        return $resource(svApiURLs.budgetOwners);
    });
