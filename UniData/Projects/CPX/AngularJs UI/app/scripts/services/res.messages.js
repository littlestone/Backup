'use strict';


angular.module('cpxUiApp')
        .factory('resMessages', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.messages);
        }]);
