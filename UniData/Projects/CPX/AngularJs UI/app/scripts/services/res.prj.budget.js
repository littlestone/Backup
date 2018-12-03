'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjBudget
 * @description
 * # resPrjBudget
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPrjBudget', function ($resource, svApiURLs) {
        return $resource(svApiURLs.PrjBudget);
    });
