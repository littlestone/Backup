'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectListCtrl
 * @description
 * # ProjectListCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectListCtrl', function ($scope, appReferences, resProjectList, resAfeListByProject, resPoListByAfe, notAvailableAlertDialog, filterFilter, colorPhasing, resPrjBudgetOwners, resPrjByAfeNbr, appUsers, svAppConfig, svAppBusy, $state, svRates, svRateSelection) {

    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cPrjList = this;

    $scope.listFilter = {};
    $scope.prjListLoading = true;
    $scope.afeListLoading = false;
    $scope.poListLoading = false;
    $scope.showWithAFE = false;
    $scope.owner = appUsers.userName;
    $scope.colorActual = colorPhasing.actuals;
    $scope.showNotAvailableAlert = notAvailableAlertDialog;

    //cPrjList.year = svAppConfig.currentYear;

    //cPrjList.budgetOwners = resPrjBudgetOwners.query();  //({}, function(){cPrjList.clearFilter(); cPrjList.applyFilter();});

    cPrjList.budgetOwners = resPrjBudgetOwners.query({}, function () {
      cPrjList.clearFilter();
    });

    cPrjList.poList = [];
    cPrjList.afeList = [];
    cPrjList.projectList = resProjectList.query({budYear: svAppConfig.currentYear, userName: appUsers.userName},
                                                //Success
                                                function () {
                                                  $scope.prjListLoading = false;
                                                  cPrjList.applyFilter();
                                                  cPrjList.RefreshAccumulators();
                                                }
                                               );

    $scope.windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    $scope.windowStyle = {height: ($scope.windowHeight - 300) + 'px'};
    $scope.contentStyle = {height: ($scope.windowHeight - 416) + 'px'};

    $scope.projectStatus = appReferences.projectStatus;
    $scope.locations = appReferences.locations;
    $scope.depts = appReferences.departments;
    $scope.locationId = -1;
    $scope.departmentId = -1;
    $scope.projectStatusId = -1;
    $scope.panelExpanded = false;

    $scope.filterPrjNumber = '';
    $scope.filterPrjDescription = '';

    $scope.filterAFE = '';
    $scope.filterAfePrjNumber = -1;

    cPrjList.index = 0;
    cPrjList.currentPage = 1;
    cPrjList.pageSize = 9;
    cPrjList.displayList = [];
    cPrjList.pageMax = 1;

    cPrjList.poListIndex = 0;
    cPrjList.poCurrentPage = 1;
    cPrjList.poPageSize = 9;
    cPrjList.poDisplayList = [];
    cPrjList.poPageMax = 1;

    cPrjList.currencies = [
      {"code": "CAD"},
      {"code": "USD"}
    ];

    $scope.currentRate = function(){
      return svRates[svRateSelection.selectedRateId-1].types[0].to[0];
    };

    cPrjList.accumulators = {
      originalProjectCost: 0,
      transaction: 0,
      revisedCost: 0,
      prevYear: 0,
      currentYBudget: 0,
      commited: 0,
      poReceipt: 0,
      actuals: 0,
      forecast: 0,
      actualYTD: 0,
      nextYear: 0,
      available: 0,
      count: 0
    };

    // reserve for future use
    // function isObjectEmpty(obj) {
    //   var retVal = true;

    //   for (var key in obj) {
    //     if (obj.hasOwnProperty(key)) {
    //       retVal = false;
    //       break;
    //     }
    //   }

    //   return retVal;
    // }

    cPrjList.IsFiltered = function () {
      return Object.keys($scope.listFilter).length > 0 || $scope.owner !== appUsers.userName;
    };

    var projects;
    cPrjList.RefreshAccumulators = function () {
      if ($scope.owner === '-1') {  // All
        projects = filterFilter(cPrjList.projectList, $scope.listFilter, true);
      } else {
        projects = filterFilter(cPrjList.projectList, $scope.listFilter, true).filter(function(prj) {
          return (prj.owner === $scope.owner || prj.delegate === $scope.owner);
        });
      }

      cPrjList.accumulators = {
        originalProjectCost: 0,
        transaction: 0,
        revisedCost: 0,
        prevYear: 0,
        currentYBudget: 0,
        commited: 0,
        poReceipt: 0,
        actuals: 0,
        forecast: 0,
        actualYTD: 0,
        nextYear: 0,
        available: 0,
        count: 0
      };

      for (var i = 0; i < projects.length; i++) {
        var prj = projects[i];

        cPrjList.accumulators.originalProjectCost = cPrjList.accumulators.originalProjectCost + prj.Original;
        cPrjList.accumulators.transaction = cPrjList.accumulators.transaction + prj.Transactions;
        cPrjList.accumulators.revisedCost = cPrjList.accumulators.revisedCost + prj.Revised;
        cPrjList.accumulators.prevYear = cPrjList.accumulators.prevYear + prj.prevYear;
        cPrjList.accumulators.currentYBudget = cPrjList.accumulators.currentYBudget + prj.currentYBudget;
        cPrjList.accumulators.commited = cPrjList.accumulators.commited + prj.commited;
        cPrjList.accumulators.poReceipt = cPrjList.accumulators.poReceipt + prj.poReceipt;
        cPrjList.accumulators.actuals = cPrjList.accumulators.actuals + prj.Actuals;
        cPrjList.accumulators.forecast = cPrjList.accumulators.forecast + prj.Forecast;
        cPrjList.accumulators.remaining = cPrjList.accumulators.remaining + 0;
        cPrjList.accumulators.actualYTD = cPrjList.accumulators.actualYTD + prj.actualsYTD;
        cPrjList.accumulators.nextYear = cPrjList.accumulators.nextYear + prj.nextYear;
        cPrjList.accumulators.available = cPrjList.accumulators.available + prj.available;

      }
      cPrjList.accumulators.count = projects.length;
      cPrjList.pageMax = Math.ceil(cPrjList.accumulators.count / cPrjList.pageSize);
      cPrjList.displayList = projects.slice(cPrjList.index, cPrjList.pageSize);
    };

    cPrjList.applyFilter = function () {
      var wkFilter = {};

      if ($scope.locationId > 0) {
        wkFilter.locationId = $scope.locationId;
      }

      if ($scope.departmentId > 0) {
        wkFilter.departmentId = $scope.departmentId;
      }

//      if ($scope.departmentId > 0) {
//        wkFilter.departmentId = $scope.departmentId;
//      }

      if ($scope.projectStatusId > 0) {
        wkFilter.status = $scope.projectStatusId;
      }

      if ($scope.filterPrjNumber !== '') {
        wkFilter.projectNumber = $scope.filterPrjNumber;
      }

      if ($scope.filterPrjDescription !== '') {
        wkFilter.description = $scope.filterPrjDescription;
      }

      if ($scope.filterAfePrjNumber > 0) {
        wkFilter.id = $scope.filterAfePrjNumber;
      }

      if ($scope.showWithAFE === true) {
        wkFilter.qtyAFE = 1;
      }

      $scope.listFilter = wkFilter;

      cPrjList.index = 0;
      cPrjList.currentPage = 1;
      cPrjList.RefreshAccumulators();
    };

    cPrjList.clearFilter = function () {
      var temp = [];
      temp = filterFilter(cPrjList.budgetOwners, {userName: appUsers.userName}, true);
      if (temp.length > 0) {
        $scope.owner = temp[0].userName;
      } else {
        $scope.owner = '-1';
      }

      $scope.locationId = -1;
      $scope.departmentId = -1;
      $scope.projectStatusId = -1;
      $scope.filterPrjNumber = '';
      $scope.filterPrjDescription = '';
      $scope.filterAFE = '';
      $scope.filterAfePrjNumber = -1;
      $scope.showWithAFE = false;
      cPrjList.applyFilter();
    };

    cPrjList.filterByAFE = function () {
      var afe;

      if ($scope.filterAFE !== '') {
        afe = resPrjByAfeNbr.query({afeNumber: $scope.filterAFE}, function () {
          $scope.filterAfePrjNumber = afe[0].projectId;
          cPrjList.applyFilter();
        });
      }
    };

    cPrjList.nextPage = function () {
      if ((cPrjList.index + cPrjList.pageSize) <= projects.length) {
        cPrjList.currentPage = cPrjList.currentPage + 1;
        cPrjList.index = cPrjList.index + cPrjList.pageSize;
        cPrjList.displayList = projects.slice(cPrjList.index, (cPrjList.pageSize * cPrjList.currentPage));
      }
    };

    cPrjList.prevPage = function () {
      if (cPrjList.index > 0) {
        cPrjList.currentPage = cPrjList.currentPage - 1;
        cPrjList.index = cPrjList.index - (cPrjList.pageSize);
        cPrjList.displayList = projects.slice(cPrjList.index, (cPrjList.pageSize * cPrjList.currentPage));
      }
    };

    cPrjList.nextPoPage = function () {
      if ((cPrjList.poListIndex + cPrjList.poPageSize) <= cPrjList.poList.length) {
        cPrjList.poCurrentPage += 1;
        cPrjList.poListIndex = cPrjList.poListIndex + cPrjList.poPageSize;
        cPrjList.poDisplayList = cPrjList.poList.slice(cPrjList.poListIndex, (cPrjList.poPageSize * cPrjList.poCurrentPage));
      }
    };

    cPrjList.prevPoPage = function () {
      if (cPrjList.poListIndex > 0) {
        cPrjList.poCurrentPage -= 1;
        cPrjList.poListIndex = cPrjList.poListIndex - (cPrjList.poPageSize);
        cPrjList.poDisplayList = cPrjList.poList.slice(cPrjList.poListIndex, (cPrjList.poPageSize * cPrjList.poCurrentPage));
      }
    };

    cPrjList.collapseAfePanel = function ($panel) {
      $scope.afeListLoading = false;
      $panel.collapse();
    };

    cPrjList.expandAfePanel = function ($panel, _prjId, _year) {
      $scope.afeListLoading = true;
      $panel.expand();
      cPrjList.afeList = resAfeListByProject.query({prjId: _prjId, afeYear: _year}, function () {
        $scope.afeListLoading = false;
      });
    };
    cPrjList.collapsePoPanel = function ($panel) {
      $scope.poListLoading = false;
      $panel.collapse();
    };

    cPrjList.expandPoPanel = function ($panel, _afeId) {
      $scope.poListLoading = true;
      $panel.expand();
      cPrjList.poList = resPoListByAfe.query({afeId: _afeId}, function () {
        $scope.poListLoading = false;
      });
      cPrjList.poDisplayList = cPrjList.poList;
    };

    cPrjList.jumpToPrj = function(_prjId){
      svAppBusy.state = true;
      $state.go('projectEdit', {prjId: _prjId});
    };

    cPrjList.jumpToAfe = function(_prjId, _afeId){
      svAppBusy.state = true;
      $state.go('afeEdit', {prjId: _prjId, afeId: _afeId});
    };

    $scope.newProject = function() {
      svAppBusy.state = true;

      var newPrj = {prjId: 0};
      $state.go('projectEdit', newPrj);
    };

    svAppBusy.state = false;
  });
