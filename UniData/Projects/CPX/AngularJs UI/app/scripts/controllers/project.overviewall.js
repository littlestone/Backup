'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectOverviewallCtrl
 * @description
 * # ProjectOverviewallCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectOverviewallCtrl', function (svPrjSummary, currentPrjSummary, $mdExpansionPanel, $scope, svAppConfig) {

    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cProjectOverviewAll = this;

    cProjectOverviewAll.prjSummary = svPrjSummary;
    $scope.budgetYear = svAppConfig.currentYear;

    $scope.panelsExpanded = true;

    //            cProjectOverviewAll.prjSummary.prjAmount = currentPrjSummary.prjAmount;
    //            cProjectOverviewAll.prjSummary.prjTransac = currentPrjSummary.prjTransac;
    //            cProjectOverviewAll.prjSummary.prjPrevYear = currentPrjSummary.prjPrevYear;
    //            cProjectOverviewAll.prjSummary.prjNextYear = currentPrjSummary.prjNextYear;
    //            cProjectOverviewAll.prjSummary.afePrevYear = currentPrjSummary.afePrevYear;
    //            cProjectOverviewAll.prjSummary.afeNextYear = currentPrjSummary.afeNextYear;
    //            cProjectOverviewAll.prjSummary.actualsYTD = currentPrjSummary.actualsYTD;
    //            cProjectOverviewAll.prjSummary.actuals = currentPrjSummary.actuals;
    //            cProjectOverviewAll.prjSummary.prjForecast = currentPrjSummary.prjForecast;
    //            cProjectOverviewAll.prjSummary.afeForecast = currentPrjSummary.afeForecast;
    //            cProjectOverviewAll.prjSummary.commited = currentPrjSummary.commited;
    //            cProjectOverviewAll.prjSummary.poReceipt = currentPrjSummary.poReceipt;


    cProjectOverviewAll.collapsePanel = function ($panel) {
      $panel.collapse();
    };

    $scope.expandOVPanel = function (expand) {
      if (expand) {
        //                 $mdExpansionPanel('prjRevisedAmount').expand();
        //                 $mdExpansionPanel('prjCommitedAmount').expand();
        $mdExpansionPanel('prjBudget').expand();
        $mdExpansionPanel('prjPhasingAmount').expand();
      } else {
        //                 $mdExpansionPanel('prjRevisedAmount').collapse();
        //                 $mdExpansionPanel('prjCommitedAmount').collapse();
        $mdExpansionPanel('prjBudget').collapse();
        $mdExpansionPanel('prjPhasingAmount').collapse();
      }
    };

    //         $mdExpansionPanel().waitFor('prjRevisedAmount').then(function (instance) {
    //             instance.expand();
    //         });
    //
    //         $mdExpansionPanel().waitFor('prjCommitedAmount').then(function (instance) {
    //             instance.expand();
    //         });

    $mdExpansionPanel().waitFor('prjBudget').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjPhasingAmount').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjAvailableToForecast').then(function (instance) {
      instance.expand();
    });

  });
