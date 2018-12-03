'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('MainCtrl', function ($scope, appUsers, notAvailableAlertDialog, $mdMedia, svToast, $window, $http, svApiURLs, $state, svDialog, $mdDialog, svAppBusy, svPoDetail, svReferences, svRateSelection) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cMain = this;

    $scope.windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    $scope.windowStyle = {height: $scope.windowHeight + 'px'};
    $scope.panelStyle = {height: ($scope.windowHeight - 500) + 'px'};
    $scope.$mdMedia = $mdMedia;

    // $scope.appBusy = function(){return svAppBusy.state;};

    var user = appUsers;

    $scope.ghhjj = svRateSelection;

    //    //Load the rates async
    //    for(var p=0;p<svRates.length;p++){
    //
    //    }

    $scope.selectedCurr = svRateSelection.selectedRateId;

    $scope.currency = svReferences.currencies;

    $scope.refreshCurrency = function(){
      svRateSelection.selectedRateId = $scope.selectedCurr;
    };
    //Will display the title depending on the language
    ////
    // If language = 'FR'
    //
    //  cMain.userTitle = user.title.substring(user.title.indexOf('***') + 3);
    //else
    cMain.userTitle = user.title.substring(0,user.title.indexOf('***'));

    cMain.find = function(ev){
      $mdDialog.show({
        controller: 'searchSimpleCtrl',
        templateUrl: 'views/templates/search.simple.html',
        parent: angular.element(document.body),
        targetEvent: ev,
        locals: {
          title: 'Search',
          visibleDomain: {
            project:true,
            afe:false,
            po:true
          }
        }
      }).then(function(answer) {
        if (answer.id > 0) {
          // svAppBusy.state = true;

          switch(answer.domain){
            case 0:
              //Search a Project
              $state.go('projectEdit', {prjId: answer.id});
              break;
            case 1:
              //Search an AFE
              // futur
              break;
            case 2:
              //Search a PO
              // svAppBusy.state = false;
              svPoDetail.showPO(answer.id);
          }
        }
      }, function() {
        //cancelled
      });
    };

    cMain.projectList = function() {
      if ($state.current.name === 'project-list') {
        $state.reload();
      } else {
        $state.go('project-list');
      }
    };

    $scope.showNotAvailableAlert = notAvailableAlertDialog;

    $scope.openHamburgerMenu = function($mdMenu, ev) {
      $mdMenu.open(ev);
    };

    $scope.openTM1Menu = function($mdMenu, ev) {
      $mdMenu.open(ev);
    };

    $scope.newProject = function() {
      var newPrj = {prjId: 0};
      $state.go('projectEdit', newPrj);
    };

    /* function DialogController($scope, $mdDialog) {
       $scope.hide = function () {
       $mdDialog.hide();
       };

       $scope.cancel = function () {
       $mdDialog.cancel();
       };

       $scope.answer = function (answer) {
       $mdDialog.hide(answer);
       };
       } */

    $scope.RedirectToURL = function() {
      // $window.location.href = 'http://sql307/Reports_SQL2012/Pages/Report.aspx?ItemPath=%2fCPX%2fTM1DimFileExtract';
      $window.open('http://sql307/Reports_SQL2012/Pages/Report.aspx?ItemPath=%2fCPX%2fTM1DimFileExtract&rs:Command=Render', '_blank');
    };

    $scope.downloadTm1File = function(url) {
      svToast.showSimpleToast('Downloading file. Please wait.');
      $window.location.href = url;
    };
  });
