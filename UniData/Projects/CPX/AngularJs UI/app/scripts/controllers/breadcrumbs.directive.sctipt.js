'use strict';

angular.module('cpxUiApp')
  .controller('BreadcrumbsDirectiveSctiptCtrl', ['$scope', '$state', '$stateParams', 'svCrumbsInfo', '$mdPanel', function ($scope, $state, $stateParams, svCrumbsInfo, $mdPanel) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var panelRef;

    var buildCrumbs = function (state) {
      var displayName = '';

      if (state.name === 'project') {
        displayName = svCrumbsInfo.project.number;
      } else if (state.name === 'afe') {
        displayName = svCrumbsInfo.afe.number;
      } else {
        displayName = state.data.settings.displayName || state.name;
      }

      return displayName;
    };

    var isCurrent = function (state) {
      return $state.$current.name === state.name;
    };

    var showBreadcrumbs = function (state) {
      return state.data.settings.showBreadcrumb;
    };

    var gotoState = function (state) {
      return state.data.settings.crumbsTargetState.replace('*prjId*', svCrumbsInfo.project.id).replace('*afeId*', svCrumbsInfo.afe.id);
    };

    var setNavigationState = function () {
      $scope.$navigationState = {
        currentState: $state.$current,
        params: $stateParams,
        getDisplayName: function (state) {
          return buildCrumbs(state);
        },
        isCurrent: function (state) {
          return isCurrent(state);
        },
        showBreadcrumbs: function (state) {
          return showBreadcrumbs(state);
        },
        gotoState: function (state) {
          return gotoState(state);
        }
      };
    };

    $scope.showProjectPanel = function ($event) {
      var position = $mdPanel.newPanelPosition()
          .relativeTo('.projectButton')
          .addPanelPosition($mdPanel.xPosition.ALIGN_END, $mdPanel.yPosition.BELOW);

      var config = {
        attachTo: angular.element(document.body),
        position: position,
        targetEvent: $event,
        templateUrl: 'views/breadcrumbs.menu.project.html',
        panelClass: 'bc-menu',
        clickOutsideToClose: true,
        escapeToClose: true,
        trapFocus: true,
        zIndex: 99,
        focusOnOpen: true
      };

      $mdPanel.open(config)
        .then(function (result) {
          panelRef = result;
        });
    };
    $scope.showAfePanel = function ($event) {
      var position = $mdPanel.newPanelPosition()
          .relativeTo('.afeButton')
          .addPanelPosition($mdPanel.xPosition.ALIGN_END, $mdPanel.yPosition.BELOW);

      var config = {
        attachTo: angular.element(document.body),
        position: position,
        targetEvent: $event,
        templateUrl: 'views/breadcrumbs.menu.afe.html',
        panelClass: 'bc-menu',
        clickOutsideToClose: true,
        escapeToClose: true,
        trapFocus: true,
        zIndex: 99,
        focusOnOpen: true
      };

      $mdPanel.open(config)
        .then(function (result) {
          panelRef = result;
        });
    };

    $scope.$on('$stateChangeSuccess', function () {
      setNavigationState();
    });

    setNavigationState();
  }]);
