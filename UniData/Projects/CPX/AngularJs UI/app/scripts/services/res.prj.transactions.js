'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectTransactions
 * @description
 * # resProjectTransactions
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resProjectTransactions', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.Transactions);
        }]);
