'use strict';

angular.module('cpxUiApp')
  .controller('ProjectAfelistCtrl', function ($scope, notAvailableAlertDialog, resAfeListByProject, currentProject, svAppConfig, svAppBusy, $state) {

    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    // skip it for new non-budgeted project creation or existing non-budgeted with $0 amount
    //if (currentProject.id === 0 || currentProject.amount === 0) return;

    var cPrjAfeList = this;
    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647)
    {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: '670px'};
    }

    $scope.showNotAvailableAlert = notAvailableAlertDialog;

    $scope.afeLoading = true;
    cPrjAfeList.afeList = resAfeListByProject.query({prjId: currentProject.id, afeYear: svAppConfig.currentYear}, function () {
      $scope.afeLoading = false;
    });

    cPrjAfeList.jumpTo = function(_prjId, _afeId){
      svAppBusy.state = true;
      $state.go('afeEdit', {prjId: _prjId, afeId: _afeId});
    };

    $scope.createNewAfe = function() {
      var newAfe = {afeId: 0};
      $state.go('afeEdit', newAfe);
    };
  });
