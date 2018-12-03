'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectTransactionsCtrl
 * @description
 * # ProjectTransactionsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectTransactionsCtrl', function ($scope, $mdDialog, resProjectTransactions, resPrjProjects, currentProject, svPrjSummary) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    }
    else {
      $scope.contentStyle = {height: '670px'};
    }

    $scope.curProject = currentProject;
    $scope.curTransactions = resProjectTransactions.query({prjId: currentProject.id});
    if ($scope.curProject.amount + $scope.curProject.transactionAmount - $scope.curProject.afeAmount > 0) {
      $scope.isNewTransferMenuButtonDisabled = false;
    }
    else {
      $scope.isNewTransferMenuButtonDisabled = true;
    }

    // function to show current selected project transaction details as a dialog
    $scope.showDetails = function($event, trs) {
      var parentEl = angular.element(document.body);
      $mdDialog.show({
        parent: parentEl,
        targetEvent: $event,
        scapeToClose: true,
        clickOutsideToClose: true,
        templateUrl: 'views/project.transaction.details.html',
        locals: {
          transaction: trs,
          project: currentProject
        },
        controller: 'ProjectTransactionDetailsCtrl'
      });
    };

    // function to refresh the transaction list
    $scope.refreshTransactionList = function() {
      resPrjProjects.get({id: currentProject.id}, function (data) {
        $scope.curProject = data;
        //Updating Right Panel
        svPrjSummary.prjTransac = data.transactionAmount;
      });

      $scope.curTransactions = resProjectTransactions.query({prjId: currentProject.id});
    };

    // function add a new transfer
    $scope.createNewTransaction = function ($event) {
      var parentEl = angular.element(document.body);
      $mdDialog.show({
        parent: parentEl,
        targetEvent: $event,
        scapeToClose: true,
        clickOutsideToClose: true,
        bindToController: true,
        scope: $scope,        // use parent scope in template
        preserveScope: true,  // do not forget this if use parent scope
        multiple: true,
        templateUrl: 'views/project.transaction.create.html',
        locals: {
          project: $scope.curProject
        },
        controller: 'ProjectTransactionCreateCtrl'
      });
    };
  });
