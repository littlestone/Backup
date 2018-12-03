'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.res.ref.attachmentTypes
 * @description
 * # res.ref.attachmentTypes
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
  .factory('resAttachmentTypes', function ($resource, svApiURLs) {
    return $resource(svApiURLs.AttachmentTypes);
  });
