'use strict';

angular.module('cpxUiApp')
  .directive('ixProjectLookup', function () {
    return {
      templateUrl: 'views/templates/search.lookup.html',
      restrict: 'E',
      controller: 'cSearchLookup',
      scope: {
        label: '@',
        ngReadonly: '=',
        form: '=',
        ngChange: '&',
        selectedItem: '=',
        filterByUser: '='
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
  .controller('cSearchLookup', function ($scope, resProjectList, svAppConfig) {

    $scope.searchText = null;
    $scope.selectedItem = null;
    
    $scope.foatingLabel = 'Find a project';
    $scope.placeholder = 'Search projects...';
    $scope.notFound = 'No project(s) were found.';
    $scope.required = 'You <b>must</b> select a project';
    $scope.requiredMatch = 'Please select an existing project';
    
    var projectList = resProjectList.query({budYear: svAppConfig.currentYear, userName: $scope.filterByUser});
    
    $scope.querySearch = function(query) {
      return projectList.filter(function(project) {
        
        if(typeof $scope.filterByUser === 'undefined'){
          $scope.filterByUser = '';
        }
        
        if ($scope.filterByUser.length > 0) {
          return (project.projectNumber.toLowerCase().indexOf(query.toLowerCase()) >= 0 || project.description.toLowerCase().indexOf(query.toLowerCase()) >= 0) && (project.owner === $scope.filterByUser || project.delegate === $scope.filterByUser);
        }
        else {
          return (project.projectNumber.toLowerCase().indexOf(query.toLowerCase()) >= 0 || project.description.toLowerCase().indexOf(query.toLowerCase()) >= 0);
        }
      });
    };

  });
