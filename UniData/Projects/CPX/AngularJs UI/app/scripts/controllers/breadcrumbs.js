'use strict';


angular.module('cpxUiApp')
  .controller('BreadcrumbsCtrl', function ($scope, $state, $stateParams, svCrumbsInfo, $mdPanel, notAvailableAlertDialog, $mdDialog) {
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


    $scope.isNewProject = function(){return (svCrumbsInfo.project.id===0);};
    $scope.isNewAFE = function(){return svCrumbsInfo.afe.id===0;};



    var isCurrent = function (state) {
      return $state.$current.name === state.name;
    };

    var showBreadcrumbs = function (state) {
      return state.data.settings.showBreadcrumb;
    };

    var gotoState = function (state) {
      return state.data.settings.crumbsTargetState.replace('*prjId*', svCrumbsInfo.project.id).replace('*afeId*', svCrumbsInfo.afe.id);
    };

    var afePanelCtrl = function () {
      var cBCAfeMenu = this;

      cBCAfeMenu.afeList = svCrumbsInfo.project.afeShortList;
      cBCAfeMenu.showNotAvailableAlert = notAvailableAlertDialog;
    };
    
    var prjListPanelCtrl = function () {
      var cBCPrjListMenu = this;

      cBCPrjListMenu.newProject = function(){
        $state.go('projectEdit', {prjId: 0});
        panelRef.close();
      };


      cBCPrjListMenu.newAFE = function(ev){
        panelRef.close();
        $mdDialog.show({
          controller: 'searchSimpleCtrl',
          templateUrl: 'views/templates/search.simple.html',
          parent: angular.element(document.body),
          targetEvent: ev,
          locals: {
            title: 'Select a Project for the new AFE',
            visibleDomain: {
              project:true,
              afe:false,
              po:false
            }
          }
        }).then(function(answer) {
          if (answer.id > 0) {
            
            switch(answer.domain){
              case 0:
                //Add a new AFE to the selected Project
                $state.go('afeEdit', {prjId: answer.id, afeId: 0});
                break;
              case 1:
                //Search an AFE
                // futur
                break;
              case 2:
                //Search a PO
                // svAppBusy.state = false;
                //svPoDetail.showPO(answer.id);
            }
          }
        }, function() {
          //cancelled
        });
      };

    };
    
    var prjPanelCtrl = function () {
      var cBCPrjMenu = this;

      cBCPrjMenu.shortList = svCrumbsInfo.project.shortList;
      cBCPrjMenu.showNotAvailableAlert = notAvailableAlertDialog;
      
      cBCPrjMenu.newProject = function(){
        $state.go('projectEdit', {prjId: 0});
        panelRef.close();
      };
      
      cBCPrjMenu.newAFE = function(){
        $state.go('afeEdit', {prjId: svCrumbsInfo.project.id, afeId: 0});
        panelRef.close();
      };

      cBCPrjMenu.createNewTransaction = function ($event) {
        var parentEl = angular.element(document.body);
        $mdDialog.show({
          parent: parentEl,
          //targetEvent: $event,
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
        controller: prjPanelCtrl,
        controllerAs: 'cBCPrjMenu',
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
        controller: afePanelCtrl,
        controllerAs: 'cBCAfeMenu',
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
    
    
    $scope.showProjectListPanel = function($event){
      var position = $mdPanel.newPanelPosition()
          .relativeTo('.prjListButton')
          .addPanelPosition($mdPanel.xPosition.ALIGN_END, $mdPanel.yPosition.BELOW);

      var config = {
        attachTo: angular.element(document.body),
        position: position,
        targetEvent: $event,
        controller: prjListPanelCtrl,
        controllerAs: 'cBCPrjListMenu',
        templateUrl: 'views/breadcrumbs.menu.projectList.html',
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
  });
