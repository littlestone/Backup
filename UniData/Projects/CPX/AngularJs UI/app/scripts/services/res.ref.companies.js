'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resCompanies
 * @description
 * # resCompanies
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resCompanies', function ($resource, svApiURLs) {
    return $resource(svApiURLs.Companies, {}, {
      query: { method: "POST", isArray: true }
    });
  });
