'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectTransactionCreateCtrl
 * @description
 * # ProjectTransactionCreateCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectTransactionCreateCtrl', function ($scope, $filter,  $mdDialog, $http, svApiURLs, svToast, svDialog, svAppConfig, locals, resProjectList, resCurrentUserInfo) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    /*** Initialization ***/
    // var self = this;

    var projectList = [];
    var currentUserInfo = resCurrentUserInfo.get(function(data) {
      $scope.isFinanceUser(data.userRoles);
      projectList = resProjectList.query({budYear: svAppConfig.currentYear, userName: currentUserInfo.userName});
    });

    $scope.searchText = null;
    $scope.selectedProject = null;
    $scope.remainingAmount = $scope.curProject.amount + $scope.curProject.transactionAmount - $scope.curProject.afeAmount; // TODO: replace afeAmount with approved afeAmount instead
    $scope.isFieldDisabled = true;
    $scope.newTransactionData = {};
    $scope.newTransactionData = {
      fromProjectId: $scope.curProject.id,
      toProjectId: null,
      amount: 0.0,
      rate: 1.0,
      comments: '',
      createdBy: currentUserInfo.userName,
      createdOn: null
    };

    // finance user has access to all projects
    $scope.financeUser = false;
    $scope.isFinanceUser = function(userRoles) {
      var financeRoleIds = [4, 5, 6, 7, 8, 9, 10];
      if (userRoles !== undefined && userRoles !== null) {
        for (var i = 0, len = userRoles.length; i < len; i++) {
          if (financeRoleIds.indexOf(userRoles[i].id) !== -1) {
            $scope.financeUser = true;
            return true;
          }
        }
        return false;
      }
      else {
        return false;
      }
    };

    $scope.querySearch = function(query) {
      // exclude current project from the list
      projectList = projectList.filter(function(prj) {
        return prj.id !== $scope.curProject.id;
      });

      // return search result list
      return projectList.filter(function(prj) {
        if ($scope.financeUser) {
          return (prj.projectNumber.toLowerCase().indexOf(query.toLowerCase()) >= 0 || prj.description.toLowerCase().indexOf(query.toLowerCase()) >= 0);
        }
        else {
          return (prj.projectNumber.toLowerCase().indexOf(query.toLowerCase()) >= 0 || prj.description.toLowerCase().indexOf(query.toLowerCase()) >= 0) && (prj.owner === currentUserInfo.userName || prj.delegate === currentUserInfo.userName);
        }
      });
    };

    // reserved for future
    $scope.searchTextChange = function(text) {
      // console.log('Text changed to ' + text);
    };

    $scope.selectedProjectChange = function(project) {
      if (project !== undefined && project !== null && $scope.remainingAmount > 0)
      {
        $scope.isFieldDisabled = false;
        $scope.newTransactionData.toProjectId = project.id;
      }
      else {
        $scope.newTransactionData.amount = '';
        $scope.newTransactionData.comments = '';
        $scope.isFieldDisabled = true;
      }
    };

    // function to commit new transaction in DB
    function postNewTransaction(newTransactionData) {
      $http({
        url: svApiURLs.prjCreateTransaction,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        },
        method: 'POST',
        data: '=' + JSON.stringify(newTransactionData)
      }).then(function successCallback(response) {  // this callback will be called asynchronously when the response is available
        // curTransactions is derived from parent scope (i.e. transaction list)
        $scope.refreshTransactionList();
        $scope.remainingAmount += newTransactionData.amount;
        svToast.showSimpleToast('Transaction has been saved successfully.');
      }, function errorCallback(error) {
        svDialog.showSimpleDialog($filter('json')(error.data), 'Oops!');
      });
    }

    $scope.showConfirm = function() {
      var confirm = $mdDialog.confirm({onComplete: function afterShowAnimation() {
        var $dialog = angular.element(document.querySelector('md-dialog'));
        var $actionsSection = $dialog.find('md-dialog-actions');
        var $cancelButton = $actionsSection.children()[0];
        var $confirmButton = $actionsSection.children()[1];
        angular.element($confirmButton).removeClass('md-focused');
        angular.element($cancelButton).addClass('md-focused');
        $cancelButton.focus();
      }}) .title('Confirmation')
          .textContent('Are you sure to proceed?')
          .ariaLabel('Lucky day')
          .ok('Yes')
          .cancel('No')
          .multiple(true);
      $mdDialog.show(confirm).then(function() {
        postNewTransaction($scope.newTransactionData);
        $mdDialog.hide();
      }, function() {
        // nop
      });
    };

    $scope.cancel = function() {
      $mdDialog.hide();
    };

    // function to create new transaction
    $scope.save = function() {
      if ($scope.newTransactionForm.$valid) {
        $scope.showConfirm();
      }
    };
  });
