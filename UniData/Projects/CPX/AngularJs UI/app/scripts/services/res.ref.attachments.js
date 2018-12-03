'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.res.ref.attachments
 * @description
 * # res.ref.attachments
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resAttachments', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
    return $resource(svApiURLs.Attachment);
  }]);
