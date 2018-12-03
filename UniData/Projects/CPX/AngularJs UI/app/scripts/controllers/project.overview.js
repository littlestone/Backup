'use strict';

/**
 * @ngdoc function
 * @name capexUiApp.controller:PrjoverviewCtrl
 * @description
 * # PrjoverviewCtrl
 * Controller of the capexUiApp
 */
angular.module('cpxUiApp')
  .controller('PrjoverviewCtrl', function (svPrjSummary, currentPrjSummary, $mdExpansionPanel, $scope, svAppConfig, $mdColors, svRates, svRateSelection) {

    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cProjectOverview = this;

    cProjectOverview.prjSummary = svPrjSummary;
    $scope.budgetYear = svAppConfig.currentYear;

    $scope.panelsExpanded = true;

    $scope.ppp = $mdColors.getThemeColor('warn');

    $scope.currentRate = function(){
      return svRates[svRateSelection.selectedRateId-1].types[0].to[0];
    };

    cProjectOverview.prjSummary.revisedAmount = function(){return cProjectOverview.prjSummary.prjAmount + cProjectOverview.prjSummary.prjTransac;};
    cProjectOverview.prjSummary.unavailable = function(){return cProjectOverview.prjSummary.nextYear + cProjectOverview.prjSummary.prevYear;};
    cProjectOverview.prjSummary.yrlPhasing =  function(){return cProjectOverview.prjSummary.forecast + cProjectOverview.prjSummary.currentActuals + cProjectOverview.prjSummary.currentForecast;};

    //            cProjectOverview.prjSummary.prjAmount = currentPrjSummary.prjAmount;
    //            cProjectOverview.prjSummary.prjTransac = currentPrjSummary.prjTransac;
    //            cProjectOverview.prjSummary.prjPrevYear = currentPrjSummary.prjPrevYear;
    //            cProjectOverview.prjSummary.prjNextYear = currentPrjSummary.prjNextYear;
    //            cProjectOverview.prjSummary.afePrevYear = currentPrjSummary.afePrevYear;
    //            cProjectOverview.prjSummary.afeNextYear = currentPrjSummary.afeNextYear;
    //            cProjectOverview.prjSummary.actualsYTD = currentPrjSummary.actualsYTD;
    //            cProjectOverview.prjSummary.actuals = currentPrjSummary.actuals;
    //            cProjectOverview.prjSummary.prjForecast = currentPrjSummary.prjForecast;
    //            cProjectOverview.prjSummary.afeForecast = currentPrjSummary.afeForecast;
    //            cProjectOverview.prjSummary.commited = currentPrjSummary.commited;
    //            cProjectOverview.prjSummary.poReceipt = currentPrjSummary.poReceipt;

    cProjectOverview.collapsePanel = function ($panel) {
      $panel.collapse();
    };

    $scope.expandOVPanel = function (expand) {
      if (expand) {
        $mdExpansionPanel('prjBudget').expand();
        $mdExpansionPanel('prjPhasingAmount').expand();
        $mdExpansionPanel('prjCommitedAmount').expand();
      } else {
        $mdExpansionPanel('prjBudget').collapse();
        $mdExpansionPanel('prjPhasingAmount').collapse();
        $mdExpansionPanel('prjCommitedAmount').collapse();
      }
    };

    $mdExpansionPanel().waitFor('prjBudget').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjPhasingAmount').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjCommitedAmount').then(function (instance) {
      instance.expand();
    });

  });
