'use strict';

/**
 * @ngdoc function
 * @name capexUiApp.controller:PrjoverviewCtrl
 * @description
 * # PrjoverviewCtrl
 * Controller of the capexUiApp
 */
angular.module('cpxUiApp')
        .controller('PrjoverviewCtrl', function (svPrjSummary, currentPrjSummary, $mdExpansionPanel, $scope, svAppConfig) {

            this.awesomeThings = [
                'HTML5 Boilerplate',
                'AngularJS',
                'Karma'
            ];

            var overview = this;

            overview.prjSummary = svPrjSummary;
            $scope.budgetYear = svAppConfig.currentYear;

            $scope.panelsExpanded = true;

//            overview.prjSummary.prjAmount = currentPrjSummary.prjAmount;
//            overview.prjSummary.prjTransac = currentPrjSummary.prjTransac;
//            overview.prjSummary.prjPrevYear = currentPrjSummary.prjPrevYear;
//            overview.prjSummary.prjNextYear = currentPrjSummary.prjNextYear;
//            overview.prjSummary.afePrevYear = currentPrjSummary.afePrevYear;
//            overview.prjSummary.afeNextYear = currentPrjSummary.afeNextYear;
//            overview.prjSummary.actualsYTD = currentPrjSummary.actualsYTD;
//            overview.prjSummary.actuals = currentPrjSummary.actuals;
//            overview.prjSummary.prjForecast = currentPrjSummary.prjForecast;
//            overview.prjSummary.afeForecast = currentPrjSummary.afeForecast;
//            overview.prjSummary.commited = currentPrjSummary.commited;
//            overview.prjSummary.poReceipt = currentPrjSummary.poReceipt;


            overview.collapsePanel = function ($panel) {
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
