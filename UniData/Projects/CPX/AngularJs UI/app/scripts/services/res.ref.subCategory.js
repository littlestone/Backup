'use strict';

angular.module('cpxUiApp')
  .factory('resSubCategory', function ($resource, svApiURLs) {
    return $resource(svApiURLs.subCategory);
  });

