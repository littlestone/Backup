'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resPrjByAfeNbr
 * @description
 * # resPrjByAfeNbr
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .factory('resPrjByAfeNbr', function ($resource, svApiURLs) {
        return $resource(svApiURLs.projectByAFENumber);
    });
