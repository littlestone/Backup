'use strict';

angular.module('cpxUiApp')
        .factory('resAfeAfeAlt', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.AFE);
        }]);
