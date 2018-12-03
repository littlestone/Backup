'use strict';

angular.module('cpxUiApp')
  .directive('ixPoList', function () {

    return {
      templateUrl: 'views/templates/po.list.html',
      restrict: 'E',
      scope: {
        ngModel: '=',
        afeid: '@',
        jumpToPo: '&'
      },
      controller: 'ixPoListCtrl'
    };
  })
  .controller('ixPoListCtrl', function ($scope, resPoListByAfe, svPoDetail) {

    $scope.poListLoading = true;
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

    $scope.accumulators = {
      amount:0,
      committed:0,
      received:0,
      payments:0
    };

    $scope.poList = resPoListByAfe.query({afeId: $scope.afeid}, function () {
      for(var i=0;i<$scope.poList.length;i++){
        $scope.accumulators.amount += $scope.poList[i].amount;
        $scope.accumulators.committed += $scope.poList[i].committed;
        $scope.accumulators.received += $scope.poList[i].received;
        $scope.accumulators.payments += $scope.poList[i].payments;
      }

      $scope.poListLoading = false;
    });

    $scope.jumpToPo = function(_poNumber) {
      svPoDetail.showPO(_poNumber);
    };
  });
