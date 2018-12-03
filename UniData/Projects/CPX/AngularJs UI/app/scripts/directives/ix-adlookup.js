'use strict';

/**
 * @ngdoc directive
 * @name cpxUiApp.directive:ixAdLookup
 * @description
 * # ixAdLookup
 */
angular.module('cpxUiApp')
  .directive('ixAdLookup', function () {
    return {
      templateUrl: 'views/templates/adlookuptemplate.html',
      restrict: 'E',
      controller: 'cAdLookup',
      scope: {
        label: '@',
        ngReadonly: '=',
        form: '=',
        ngChange: '&',
        selectedItem: '='
    },
    link: function postLink(scope, element, attrs) {

        scope.isRequired = false;

        if (attrs.$attr.hasOwnProperty("required")) {
          scope.isRequired = true;
        }

        element.on('change', 'md-autocomplete', function () {
          scope.ngChange();
        });
      }
    };
  })
  .controller('cAdLookup', function ($q, $http, $scope, svApiURLs) {
    $scope.searchText = null;

    $scope.adLookup = function (query) {
      return $http.get(svApiURLs.userLookup + query)
        .then(function (response) {
          return $q.resolve(response.data);
        },
        function (response) {
          return $q.reject(response.data);
        }
        );
    };
  });
