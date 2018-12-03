'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeoverviewCtrl
 * @description
 * # AfeoverviewCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeoverviewCtrl', function (svAfeSummary, $mdExpansionPanel, $scope, svAppConfig, svRates, svRateSelection) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var overview = this;

    $scope.panelsExpanded = true;
    $scope.budgetYear = svAppConfig.currentYear;

    $scope.currentRate = function(){
       return svRates[svRateSelection.selectedRateId-1].types[0].to[0];
     };



    overview.afeSummary = svAfeSummary;

    //            overview.afeSummary.prjTotalAmt = currentAfeSummary.projectTotalAmount;
    //            overview.afeSummary.prjRemaining = currentAfeSummary.projectRemainingAmount;
    //            overview.afeSummary.afeTotalAmt = currentAfeSummary.afeTotalAmount;
    //            overview.afeSummary.afeRemaining = currentAfeSummary.afeRemainingAmount;
    //            overview.afeSummary.afePrevYear = currentAfeSummary.afePreviousYears;

    overview.afeSummary.afePoCommited = 0; // DEBUG

    //            overview.afeSummary.afeCommitedAmt = currentAfeSummary.afeCommitedAmount;
    //            overview.afeSummary.afePoReceived = currentAfeSummary.afePoReceived;
    //            overview.afeSummary.afeCurrentYrPhasing = currentAfeSummary.afeCurrentYearPhasing;
    //            overview.afeSummary.afeNextYrPhasing = currentAfeSummary.afeNextYearForecast;
    //            overview.afeSummary.afeActualYTD = currentAfeSummary.afeActualYearToDate;
    //            overview.afeSummary.afeCurrentYrForecast = currentAfeSummary.afeCurentYearForecast;
    //            overview.afeSummary.afeAvailableForecast = currentAfeSummary.availableToForecast;

    overview.afeSummary.revisedMinusCommitted = (overview.afeSummary.afeTotalAmt + overview.afeSummary.afeSupplementals) - (overview.afeSummary.afePrevYear + overview.afeSummary.afeNextYrPhasing);


    overview.afeSummary.bud = function(){return (overview.afeSummary.afeTotalAmt + overview.afeSummary.afeSupplementals) - (overview.afeSummary.afeNextYrPhasing + overview.afeSummary.afePrevYear);};
    overview.afeSummary.yrlPhasing = function(){return overview.afeSummary.afeActual + overview.afeSummary.afeCurrentYrForecast;};


    overview.collapsePanel = function ($panel) {
      $panel.collapse();
    };

    $scope.expandOVPanel = function (expand) {
      if (expand) {
        $mdExpansionPanel('PhasingAmount').expand();
        $mdExpansionPanel('budget').expand();
        $mdExpansionPanel('poAmount').expand();
      } else {
        $mdExpansionPanel('PhasingAmount').collapse();
        $mdExpansionPanel('budget').collapse();
        $mdExpansionPanel('poAmount').collapse();
      }
    };

    $mdExpansionPanel().waitFor('PhasingAmount').then(function (instance) {
      instance.expand();
    });

//    $mdExpansionPanel().waitFor('availableToForecast').then(function (instance) {
//      instance.expand();
//    });

    $mdExpansionPanel().waitFor('budget').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('poAmount').then(function (instance) {
      instance.expand();
    });
  });
