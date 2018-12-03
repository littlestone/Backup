'use strict';

angular.module('cpxUiApp')
  .factory('resAnalysis', function ($resource, svApiURLs) {
    return $resource(svApiURLs.analysis);
  });
