'use strict';

angular.module('cpxUiApp')
  .controller('poDisplayCtrl', function($scope, resPoDetails, locals, resCompanies, resLocations, resPoLines, resPoPayments, resPoReceipts,$filter){
    
            
    $scope.statusColor = locals.statusColor;
    $scope.tableColor = locals.tableColor;
    
    $scope.poListLoading = true;
    $scope.poPayLoading = true;
    $scope.poRecLoading = true;
    
    $scope.poLoading = true;
    
    $scope.poPaymentTotalAmount = 0;
    $scope.poReceiptsTotalAmount = 0;
    $scope.poCommitted = 0;

    $scope.loadPoLines = function(){
      resPoLines.query({poNbr: locals.poNbr},function(data){
        $scope.poLines = data;
        $scope.poTotalAmount = 0;

        for(var i=0;i<$scope.poLines.length;i++){
          $scope.poTotalAmount += $scope.poLines[i].purchaseOrderAmount;
        }

        $scope.poTotalAmount = $filter('currency')($scope.poTotalAmount);

        $scope.poListLoading = false;
      });
    };

    $scope.loadPayments = function(){
      resPoPayments.query({poNbr: locals.poNbr}, function(data){
        $scope.poPayments = data;
        
        for(var p=0;p<$scope.poPayments.length;p++){
          $scope.poPaymentTotalAmount += $scope.poPayments[p].paymentAmount;
        };
        $scope.poPaymentTotalAmount = $filter('currency')($scope.poPaymentTotalAmount);

        $scope.poPayLoading = false;
      });
    };

    $scope.loadReceipts = function(){
      resPoReceipts.query({poNbr: locals.poNbr}, function(data){
        $scope.poReceipt = data;
        
        for(var r=0;r<$scope.poReceipt.length;r++){
          $scope.poReceiptsTotalAmount += $scope.poReceipt[r].receiptAmount;
        };

        $scope.poReceiptsTotalAmount = $filter('currency')($scope.poReceiptsTotalAmount);

        $scope.poRecLoading = false;
      });
    };

    $scope.getStatusColor = function(){
      return {color: locals.statusColor};
    };

    $scope.getTableColor = function(){
      return {'border-color': locals.tableColor};
    };
    
    resCompanies.query(function(data){
      $scope.companies = data;
      
      resLocations.query(function(data){
        $scope.locations = data;
        
        resPoDetails.get({poNbr: locals.poNbr}, function(data) {
          $scope.po = data;

          switch($scope.po.status){
            case 'C':
              $scope.poStatus = 'Closed';
              break;
            case 'X':
              $scope.poStatus = 'Cancelled';
              break;
            default:
              $scope.poStatus = 'Open';
          }
          $scope.poCommitted = $filter('currency')($scope.po.committed);

          $scope.loadPoLines();
          $scope.loadPayments();
          $scope.loadReceipts();
          
          $scope.poLoading = false;
        });
      });
    });
  });
