'use strict';


angular.module('cpxUiApp')
  .factory('resPoLines', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.poLines);
        }]);
