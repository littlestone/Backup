'use strict';

angular.module('cpxUiApp')
  .directive('ixSec', function () {

    return {
      restrict: 'A',
      scope: {
        id: '@'
        // See if needed:         ngChange: '&',
      },
      link: function (scope, element, attr) {
        // --- See if needed
        //        element.on('change', 'input', function () {
        //          scope.ngChange();
        //        });
        // ---
        //
        // Cast to object
        var secMsk = scope.$eval(attr.ixSec);

        // TODO: Apply read-only user security based on pre-configured bit masked value
        var isReadOnly = (parseInt(secMsk.readOnly) & Math.pow(2,parseInt(scope.id))) === Math.pow(2,parseInt(scope.id));
        isReadOnly = false;
        if (isReadOnly) {
          attr.$set('disabled', 'disabled');
        }
        else {
          element.removeAttr('disabled');
        }

        // TODO: Apply read-only user security based on pre-configured bit masked value
        var isInvisible = (parseInt(secMsk.readOnly) & Math.pow(2,parseInt(scope.id))) === Math.pow(2,parseInt(scope.id));
        isInvisible = false;
        if (isInvisible) {
          attr.$set('hidden', 'hidden');
        }
        else {
          element.removeAttr('hidden');
        }
      }
    };
  });
