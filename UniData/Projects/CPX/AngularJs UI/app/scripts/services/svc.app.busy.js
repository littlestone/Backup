'use strict';

angular.module('cpxUiApp')
  .service('svAppBusy', function () {
    var appBusy = {'state': false};
    return appBusy;
  });
