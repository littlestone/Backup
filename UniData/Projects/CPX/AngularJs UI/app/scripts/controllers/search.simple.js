'use strict';

angular.module('cpxUiApp')
  .controller('searchSimpleCtrl', function ($scope, $mdDialog, locals) {

    $scope.selectedProject = null;
    $scope.selectedDomain = 0;
    $scope.poNumber = '';
    
     $scope.answer = function(answer){
      
        $mdDialog.hide(answer);
    };
    
    $scope.title = locals.title;
    $scope.visibleDomain = locals.visibleDomain;
 
    $scope.enableOk = function(){
      
      var retVal = false;
      
      switch($scope.selectedDomain){
        case 0:
          //Search projects
          retVal = ($scope.selectedProject !== null);
          break;
        case 1:
          //Search AFE
          
          break;
        case 2:
          retVal = $scope.poNumber.length > 0;
          break;
      };
      return retVal;
    };
    
    $scope.searchPo = function(){
      switch($scope.selectedDomain){
        case 0:
          //Search projects
          if ($scope.selectedProject !== null){
            $scope.answer({id: $scope.selectedProject.id, domain:$scope.selectedDomain});
          }
          
          break;
        case 1:
          //Search AFE
          
          break;
        case 2:
          //Search PO
          if($scope.poNumber.length > 0){
            $scope.answer({id: $scope.poNumber, domain:$scope.selectedDomain});
          }
          break;
      };
    };

  });
