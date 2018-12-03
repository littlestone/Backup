'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:SettingsEditCtrl
 * @description
 * # SettingsEditCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('SettingsEditCtrl', function ($scope, appReferences, resPoDetails, svPoDetail) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: '670px'};
    }


    //-->>
    
//    $scope.companies = appReferences.companies;
//    $scope.locations = appReferences.locations;
//
//    resPoDetails.query({poId: 1}, function(data) {
//      $scope.po = data[0];
//      
//      switch($scope.po.status){
//        case 'C':
//          $scope.poStatus = 'Closed';
//          break;
//        case 'X':
//          $scope.poStatus = 'Cancelled';
//          break;
//        default:
//          $scope.poStatus = 'Open';
//      }
//      
//    });
    
    $scope.showThePO = function(){
      svPoDetail.showPO(457931);
    };
    
    
    //<<--









    //--> debug

    $scope.currModel = 100;

    $scope.amount = 100;
    $scope.selectedCurr = 0;
    $scope.currency = [
      {
        id: 0,
        label: 'CAD',
        to: [1],
        from: [1]
      },
      {
        id: 1,
        label: 'USD',
        to: [0.70],
        from: [1.30]
      }
    ];

    //----------------------------------------------------------
    $scope.title = 'erigau';
    $scope.listId = 0;
    $scope.mask = {
      readOnly: 0,
      visible: 4
    };
    $scope.testRo = function(){return true;};
    //<-- debug


    $scope.fields = [];

    for (var i=0; i<14; i++){
      $scope.fields[i] = false;
    }

    $scope.bitMask = 0;

    $scope.updateMask = function(index){
      if (!$scope.fields[index]){
        $scope.bitMask = $scope.bitMask + Math.pow(2,index);
        $scope.mask.readOnly = $scope.bitMask;
      }
      else {
        $scope.bitMask = $scope.bitMask - Math.pow(2,index);
      }
    };
  });
