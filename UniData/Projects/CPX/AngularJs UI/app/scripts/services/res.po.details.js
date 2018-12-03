'use strict';


angular.module('cpxUiApp')
  .factory('resPoDetails', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.poHeader);
        }]);
