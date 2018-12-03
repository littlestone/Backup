'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeprjoverviewCtrl
 * @description
 * # AfeprjoverviewCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeprjoverviewCtrl', function (svAfePrjSummary, $mdExpansionPanel, $scope, currentProject, svAppConfig, resPrjForecastEach, svRates, svRateSelection) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var overview = this;

    $scope.panelsExpanded = true;

    overview.afePrjSummary = svAfePrjSummary;

    $scope.currentRate = function(){
      return svRates[svRateSelection.selectedRateId-1].types[0].to[0];
    };

    

    overview.revisedAmount = function(){return overview.afePrjSummary.originalAmount + overview.afePrjSummary.transactions;};
    overview.unavailable = function(){return overview.afePrjSummary.nextYear + overview.afePrjSummary.prevYear;};
    overview.yrlForecast = function(){return overview.afePrjSummary.forecast + overview.afePrjSummary.currentActuals + overview.afePrjSummary.currentForecast;};
    //overview.available = function(){return overview.afePrjSummary.originalAmount + overview.afePrjSummary.transactions - overview.afePrjSummary.nextYear - overview.afePrjSummary.prevYear - overview.afePrjSummary.forecast - overview.afePrjSummary.currentActuals - overview.afePrjSummary.currentForecast;};
    
    // Get phasing for the project
    var prjForecastData = {};
    var amt = 0;
    resPrjForecastEach.query({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function (data) {
      prjForecastData = data;

      amt = prjForecastData[1].january;
      amt +=  prjForecastData[1].february;
      amt +=  prjForecastData[1].march;
      amt +=  prjForecastData[1].april;
      amt +=  prjForecastData[1].may;
      amt +=  prjForecastData[1].june;
      amt +=  prjForecastData[1].july;
      amt +=  prjForecastData[1].august;
      amt +=  prjForecastData[1].september;
      amt +=  prjForecastData[1].october;
      amt +=  prjForecastData[1].november;
      amt +=  prjForecastData[1].december;

      svAfePrjSummary.forecast = amt;
    });

    $scope.negative = function(){
      return (svAfePrjSummary.originalAmount + svAfePrjSummary.transactions - svAfePrjSummary.nextYear - svAfePrjSummary.prevYear - svAfePrjSummary.forecast - svAfePrjSummary.currentActuals - svAfePrjSummary.currentForecast) < 0;
    };

    overview.collapsePanel = function ($panel) {
      $panel.collapse();
    };

    $scope.expandOVPanel = function (expand) {
      if (expand) {
        $mdExpansionPanel('prjRevisedAmount').expand();
        $mdExpansionPanel('prjCommitedAmount').expand();
        $mdExpansionPanel('prjPhasingAmount').expand();
      } else {
        $mdExpansionPanel('prjRevisedAmount').collapse();
        $mdExpansionPanel('prjCommitedAmount').collapse();
        $mdExpansionPanel('prjPhasingAmount').collapse();
      }
    };

    $mdExpansionPanel().waitFor('prjRevisedAmount').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjCommitedAmount').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjPhasingAmount').then(function (instance) {
      instance.expand();
    });

    $mdExpansionPanel().waitFor('prjAvailableToForecast').then(function (instance) {
      instance.expand();
    });
  });
