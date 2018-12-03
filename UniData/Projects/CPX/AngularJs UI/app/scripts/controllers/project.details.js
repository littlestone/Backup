'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectDetailsCtrl
 * @description
 * # ProjectDetailsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectDetailsCtrl', [
    'currentProject',
    'appReferences',
    'resPrjBudgetOwners',
    '$scope',
    'svToast',
    'svApiURLs',
    '$http',
    '$state',
    '$filter',
    '$mdDialog',
    'appUsers',
    'svDialog',
    'currentTransactions',
    'svPrjSummary',
    'svAppConfig',
    function (currentProject,
              appReferences,
              resPrjBudgetOwners,
              $scope,
              svToast,
              svApiURLs,
              $http,
              $state,
              $filter,
              $mdDialog,
              appUsers,
              svDialog,
              currentTransactions,
              svPrjSummary,
              svAppConfig) {

      this.awesomeThings = [
        'HTML5 Boilerplate',
        'AngularJS',
        'Karma'
      ];

      var cProjectDetails = this;

      var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

      if ((windowHeight - 327) < 647) {
        $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
      } else {
        $scope.contentStyle = {height: '670px'};
      }

      cProjectDetails.hidden = false;
      cProjectDetails.closed = false;
      cProjectDetails.key = (currentProject.amount >= 200000);
      cProjectDetails.nonBudgeted = true;
      cProjectDetails.newProjectNumber = 'New';

      cProjectDetails.currProject = currentProject;
      if (cProjectDetails.currProject.id === 0) {
        cProjectDetails.currProject.owner = appUsers.userName;
      }

      $scope.secmsk = {
        readOnly: 2061,
        visible: 4
      };
      //Set R-O if status is higher that CREATION
      //..patch, a better solution needed
      if(cProjectDetails.currProject.status >= 0){
        // $scope.secmsk.readOnly = 196515;
        $scope.secmsk.readOnly = 0;
      }




      cProjectDetails.disableOk = function(){
//        var retVal = true;
//
//
//        if(cProjectDetails.form.$valid ){}
//
//
//        if(!cProjectDetails.form.$dirty){
//          retVal = true;
//        }
//        else{
//          retVal = cProjectDetails.delegate === null;
//        }
//
//        return retVal;

        var retVal = cProjectDetails.form.$dirty && cProjectDetails.form.$valid;
        return !retVal;
      };

      var totay = new Date();
        cProjectDetails.minDate = new Date(
        totay.getFullYear(),
        totay.getMonth(),
        totay.getDate() + 1
      );

      if (currentProject.amount === 0){
        if (currentTransactions.length > 0){
          cProjectDetails.status = 'Non-Budgeted';
        }
        else {
          cProjectDetails.status = 'Initial';
        }
      }
      else{
        cProjectDetails.status = 'Approved';
      }

      cProjectDetails.hasTransaction = (currentTransactions.length > 0);

      if (currentProject.status > 0){
        cProjectDetails.estComplDate = new Date();
        cProjectDetails.estComplDate.setTime(Date.parse(currentProject.estimatedCompletionDt));
      }
      else {
        cProjectDetails.estComplDate = '';
      }

      cProjectDetails.project = currentProject;
      cProjectDetails.companies = appReferences.companies;
      cProjectDetails.depts = appReferences.departments;
      cProjectDetails.locations = appReferences.locations;
      cProjectDetails.aliaxisCategory = appReferences.aliaxisCategories;
      cProjectDetails.aliaxisType = appReferences.aliaxisTypes;
      cProjectDetails.capexPriorities = appReferences.priorities;
      cProjectDetails.categories = appReferences.categories;
      cProjectDetails.budgetOwners = resPrjBudgetOwners.query();
      cProjectDetails.delegate = currentProject.delegate;

      //Sun of the projects transactions
      cProjectDetails.totalTransactions = 0;
      for (var i = 0; i < currentTransactions.length; i++){
        cProjectDetails.totalTransactions += currentTransactions[i].amount;
      }

      //-- Update right panel (project overview)
      svPrjSummary.prjAmount = currentProject.amount;
      svPrjSummary.prjTransac = cProjectDetails.totalTransactions;

      if (currentProject.delegate !== undefined && currentProject.delegate !== null && currentProject.delegate !== '') {
        cProjectDetails.delegate = {userName: currentProject.delegate, displayName: currentProject.delegateDisplayName};
      }

      $scope.validDelegate = function () {
        if (cProjectDetails.delegate.userName.length === 0 && cProjectDetails.delegate.displayName.length > 0) {
          cProjectDetails.form.delegate.$error.invalidSelection = true;
        } else {
          cProjectDetails.form.delegate.$error.invalidSelection = false;
          //cHeader.form.delegate.$setUntouched();
        }

        if (cProjectDetails.delegate.userName.length > 0 && cProjectDetails.delegate.displayName.length === 0) {
          cProjectDetails.delegate.userName = '';
          cProjectDetails.delegate.displayName = '';
          cProjectDetails.form.delegate.$error.invalidSelection = false;
          //cHeader.form.delegate.$setUntouched();
        }
      };

      // TODO: reset form value
      $scope.reset = function () {
        if (cProjectDetails.form) {
          cProjectDetails.form.$setPristine();
          cProjectDetails.form.$setUntouched();
        }
      };

      $scope.cancelEdit = function () {
        if (currentProject.delegate.length > 0) {
          cProjectDetails.delegate = {userName: currentProject.delegate, displayName: currentProject.delegateDisplayName};
        } else {
          cProjectDetails.delegate = null;
        }
        $scope.reset();
        svToast.showSimpleToast('Cancelled');
      };

      $scope.toggleHide = function(){
        cProjectDetails.hidden = !cProjectDetails.hidden;
      };

      $scope.toggleClosed = function(){
        cProjectDetails.closed = !cProjectDetails.closed;
      };

      // function to show attachment utility
      $scope.appUsers = appUsers;
      $scope.currentProject = currentProject;
      $scope.showAttachmentUtility = function($event) {
        var parentEl = angular.element(document.body);
        $mdDialog.show({
          parent: parentEl,
          targetEvent: $event,
          escapeToClose: true,
          clickOutsideToClose: true,
          bindToController: true,
          scope: $scope,        // use parent scope in template
          preserveScope: true,  // do not forget this if use parent scope
          multiple: true,
          template: '<md-dialog aria-label="Attachment utility dialog" style="width:580px;">' +
                    '  <ix-attachments upload-enabled="true" download-enabled="true" delete-enabled="true" entity-type-id="1" entity-record-id="{{currentProject.id}}" attachment-type-id="" userid="{{appUsers.userName}}">' +
                    '  </ix-attachments>' +
                    '</md-dialog>'
        });
      };

      var CreateNonBudgetedProject = function(data) {
        $http({
          method: 'POST',
          url: svApiURLs.newProject,
          data: JSON.stringify(data),
          headers: {'Content-Type': 'application/json'}
        }).then(
          function(response) {
            var newPrj = response.data;
            console.log(newPrj);
            $state.go('projectEdit', {prjId: newPrj.id});
            svToast.showSimpleToast('Data Saved');
          },
          function(error) {
            svToast.showSimpleToast('Data NOT Saved');
            svDialog.showSimpleDialog(angular.toJson(error.data), 'Error');
          }
        );
      };

      var SaveProject = function(data) {
        $http({
          method: 'PUT',
          url: svApiURLs.saveProject + cProjectDetails.currProject.id,
          // parms: {id: cProjectDetails.currProject.id},
          data: JSON.stringify(data),
          headers: {'Content-Type': 'application/json'}
        }).then(
          function(response) {
            $scope.reset();
            svToast.showSimpleToast('Data Saved');
          },
          function(error) {
            svToast.showSimpleToast('Data NOT Saved');
            svDialog.showSimpleDialog(angular.toJson(error.data), 'Error');
          }
        );
      };

      $scope.SaveData = function() {
        var currentDateTime = $filter('date')(Date.now(), 'yyyy-MM-dd HH:mm:ss');

        // Build project data to save
        var data = {
          'id': cProjectDetails.currProject.id,
          'currentYear': svAppConfig.currentYear,
          'projectNumber': cProjectDetails.project.projectNumber,
          'description': cProjectDetails.project.description,
          'companyId': cProjectDetails.project.companyId,
          'locationId': cProjectDetails.project.locationId,
          'departmentId': cProjectDetails.project.departmentId,
          'categoryId': cProjectDetails.project.categoryId,
          'priorityLvelId': cProjectDetails.project.priorityLevelId,
          'aliaxisTypeId': cProjectDetails.project.aliaxisTypeId,
          'aliaxisCategoryId': cProjectDetails.project.aliaxisCategoryId,
          'aliaxisCode': cProjectDetails.project.aliaxisCode,
          //'estimatedCompletionDt': cProjectDetails.project.estimatedCompletionDt,
          
          'estimatedCompletionDt': cProjectDetails.estComplDate,
          
          'amount': cProjectDetails.project.amount === null ? 0 : cProjectDetails.project.amount,
          'status': cProjectDetails.project.id === 0 ? 1 : cProjectDetails.project.status,
          'closed': false,
          'hidden': false,
          'keyProject': cProjectDetails.key,
          'owner': cProjectDetails.project.owner,
          'delegate': (typeof cProjectDetails.delegate === 'undefined') || cProjectDetails.delegate === null ? null : cProjectDetails.delegate.userName,
          'comments': cProjectDetails.project.comments,
          'createdBy': appUsers.userName,
          'createdOn': currentDateTime,
          'modifiedBy': appUsers.userName,
          'modifiedOn': currentDateTime
        };
        console.log(JSON.stringify(data));

        if (cProjectDetails.currProject.id === 0) {
          CreateNonBudgetedProject(data);
        }
        else {
          SaveProject(data);
        }
      };
    }]);
