'use strict';

angular.module('cpxUiApp')
  .factory('resPrjRPanel', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.prjRPanelSummary);
  }]);

