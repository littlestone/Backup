'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeHeaderCtrl
 * @description
 * # AfeHeaderCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeHeaderCtrl', function (currentAFE, appReferences, svCrumbsInfo, currentProject, currentTransactions, $scope, $state, svToast, appUsers, svApiURLs, $http, svDialog, svAfePrjSummary, resPrjRPanel, svAppConfig, svAfeSummary, $filter) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cAfeHeader = this;

    cAfeHeader.hidden = false;
    cAfeHeader.closed = false;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647) {
      cAfeHeader.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      cAfeHeader.contentStyle = {height: '670px'};
    }

    cAfeHeader.afe = currentAFE;
    cAfeHeader.project = currentProject;
    cAfeHeader.companies = appReferences.companies;
    cAfeHeader.depts = appReferences.departments;
    cAfeHeader.locations = appReferences.locations;
    cAfeHeader.aliaxisCategory = appReferences.aliaxisCategories;
    cAfeHeader.aliaxisType = appReferences.aliaxisTypes;
    cAfeHeader.capexPriorities = appReferences.priorities;
    cAfeHeader.categories = appReferences.categories;
    cAfeHeader.cpmAliaxisCode = '';
    cAfeHeader.projectsList = svCrumbsInfo.project.shortList;
    
    if (cAfeHeader.afe.id === 0) {
      cAfeHeader.estComplDate = new Date();
      cAfeHeader.estComplDateDisabled = false;
    } else {
      cAfeHeader.estComplDate = currentAFE.estimatedCompletionDate;
      cAfeHeader.estComplDateDisabled = true;
    }

    //debug
    cAfeHeader.estComplDateDisabled = false;
    //debug

    svAfePrjSummary.originalAmount = currentProject.amount;
    svAfePrjSummary.transactions = currentProject.transactionAmount;

    if (currentAFE.owner !== undefined && currentAFE.owner !== null) {
      cAfeHeader.owner = {userName: currentAFE.owner, displayName: currentAFE.ownerDisplayName};
    }

    if (currentAFE.delegate !== undefined && currentAFE.delegate !== null && currentAFE.delegate !== '') {
      cAfeHeader.delegate = {userName: currentAFE.delegate, displayName: currentAFE.delegateDisplayName};
    }
//    else {
//      cAfeHeader.delegate = {};
//    }

    //New AFE
    if (cAfeHeader.afe.id===0){
      //Default values
      cAfeHeader.owner = {userName: appUsers.userName, displayName: appUsers.displayName};
      cAfeHeader.afe.companyId = currentProject.companyId;
      cAfeHeader.afe.locationId = currentProject.locationId;
      cAfeHeader.afe.departmentId = currentProject.departmentId;
      cAfeHeader.afe.aliaxisCategoryId = currentProject.aliaxisCategoryId;
      cAfeHeader.afe.aliaxisTypeId = currentProject.aliaxisTypeId;
    }

    $scope.secmsk = {
      readOnly: 90253,
      visible: 4
    };
    //Set R-O if status is higher that CREATION
    //..patch, a better solution needed
    if(true){
      // $scope.secmsk.readOnly = 130803;
      $scope.secmsk.readOnly = 0;
    }

    var updatePrjPanel = function(){
      
      resPrjRPanel.get({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function(data){
        svAfePrjSummary.nextYear = data.projNextYear;
        svAfePrjSummary.prevYear = data.projPrevYear;
        //svAfePrjSummary.forecast = data.
        //svAfeSummary.
      });
      
      
      
    };

    updatePrjPanel();
    
    $scope.validDelegate = function () {
      if (cAfeHeader.delegate.userName.length === 0 && cAfeHeader.delegate.displayName.length > 0) {
        cAfeHeader.form.delegate.$error.invalidSelection = true;
      } else {
        cAfeHeader.form.delegate.$error.invalidSelection = false;
        //cAfeHeader.form.delegate.$setUntouched();
      }

      if (cAfeHeader.delegate.userName.length > 0 && cAfeHeader.delegate.displayName.length === 0) {
        cAfeHeader.delegate.userName = '';
        cAfeHeader.delegate.displayName = '';
        cAfeHeader.form.delegate.$error.invalidSelection = false;
        //cAfeHeader.form.delegate.$setUntouched();
      }
    };

    $scope.reset = function () {
      if (cAfeHeader.form) {
        cAfeHeader.form.$setPristine();
        cAfeHeader.form.$setUntouched();
      }
    };

    $scope.cancelEdit = function () {
      if (currentProject.delegate !== undefined && currentProject.delegate !== null) {
        cAfeHeader.delegate = {userName: currentAFE.delegate, displayName: currentAFE.delegateDisplayName};
      } else {
        cAfeHeader.delegate = null;
      }
      $scope.reset();
      svToast.showSimpleToast('Cancelled');
    };
    
    var isValid = function(){
      var retVal = true;

      //AFE amount should be lower or equal to the available project amount
      if(cAfeHeader.afe.afeAmount > svAfePrjSummary.available()){
        retVal = false;
        svDialog.showSimpleDialog('The AFE amount should be lower or equal to the available project amount (' + $filter('currency')(svAfePrjSummary.available()) + ')', 'Validation');
      }

      return retVal;
    };

    $scope.SaveData = function () {

      if(isValid()){
        var data = {
          'id':cAfeHeader.afe.id,
          'afeNumber':cAfeHeader.afe.afeNumber,
          'companyId':cAfeHeader.afe.companyId,
          'locationId':cAfeHeader.afe.locationId,
          'locationTypeId':cAfeHeader.afe.locationTypeId,
          'departmentId':cAfeHeader.afe.departmentId,
          'title':cAfeHeader.afe.title,
          'owner':cAfeHeader.owner.userName,
          'ownerDisplayName':cAfeHeader.owner.displayName,
          'delegate':cAfeHeader.delegate !== undefined && cAfeHeader.delegate !== null ? cAfeHeader.delegate.userName : '',
          'delegateDisplayName':cAfeHeader.delegate !== undefined && cAfeHeader.delegate !== null ? cAfeHeader.delegate.displayName : '',
          'purpose':cAfeHeader.afe.purpose,
          'afeAmount':cAfeHeader.afe.afeAmount,
          'budgetAmount':cAfeHeader.afe.budgetAmount,
          'nonDiscountedPayback':cAfeHeader.afe.nonDiscountedPayback,
          'irrRequired':cAfeHeader.afe.irrRequired,
          'irrOriginal':cAfeHeader.afe.irrOriginal,
          'irrCurrent':cAfeHeader.afe.irrCurrent,
          'estimatedCompletionDate':cAfeHeader.estComplDate,
          'stageGate':cAfeHeader.afe.stageGate,
          'sgProject_number':cAfeHeader.afe.sgProject_number,
          'aliaxisTypeId':cAfeHeader.afe.aliaxisTypeId,
          'aliaxisCategoryId':cAfeHeader.afe.aliaxisCategoryId,
          'projectId':currentProject.id,
          'currencyId':cAfeHeader.project.currencyId,
          'supplementalTo':cAfeHeader.afe.supplementalTo,
          'needProofReading':cAfeHeader.afe.needProofReading,
          'date':cAfeHeader.afe.date,
          'statusId':cAfeHeader.afe.statusId,
          'statusName':cAfeHeader.afe.statusName,
          'aliaxisCode':cAfeHeader.afe.aliaxisCode,
          'level0':cAfeHeader.afe.level0
        };

        $http({
          method: (cAfeHeader.afe.id > 0 ? 'PUT':'POST'),
          url: svApiURLs.saveAFE + (cAfeHeader.afe.id>0?cAfeHeader.afe.id: ''),
          data: JSON.stringify(data),
          headers: {'Content-Type': 'application/json'}
        }).then(
          function (response) {
            var newAfe = response.data;
            $state.go('afeEdit', {afeId: newAfe.id});
            svToast.showSimpleToast('Data Saved');
          },
          function (response) {
            var msg = response.data;
            svDialog.showSimpleDialog('Error - ' + msg);
          }
        );
      }
    };
  });
