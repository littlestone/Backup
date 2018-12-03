'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeActionCtrl
 * @description
 * # AfeActionCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeActionCtrl', function ($scope, svDialog, resAfeSla, currentAFE, $mdColors, $mdDialog, $http, svApiURLs, svToast, appUsers) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cAfeAction = this;

    cAfeAction.loadingSla = false;

    cAfeAction.afe = currentAFE;
    cAfeAction.currentSLAItem = -1;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: '670px'};
    }

    $scope.showNotAvailableAlert = function () {
      svDialog.showSimpleDialog(
        'This function will be available soon. Please try again later.',
        'Development');
    };

    var loadSLA = function(_afeId){
      cAfeAction.loadingSla = true;
      resAfeSla.query({afeId:_afeId}, function(data){

        cAfeAction.slaList = data;
        cAfeAction.isMyApproval = false;
        
        for(var q=0;q<cAfeAction.slaList.length;q++){
          if(cAfeAction.slaList[q].statusCode==1){
            //Waiting for approval
            cAfeAction.currentSLAItem = cAfeAction.slaList[q].id;
            cAfeAction.isMyApproval = (cAfeAction.slaList[q].userId === 'CORP\\' + appUsers.userName);
            break;
          }
        }
      });
    };

    cAfeAction.refreshSla = function(){
      loadSLA(currentAFE.id);
    };

    cAfeAction.warnColor = function(){
      return {color: $mdColors.getThemeColor('warn')};
    };

    cAfeAction.validForSubmit = function(_afe){
      var isValid = true;


      //debug
      return isValid;
      //debug


//      if(typeof _afe === 'undefined'){
//        //If no param, default to the current AFE
//        _afe = cAfeAction.afe;
//      }
//
//      //Validate if mandatory fields are populated
//      isValid = isValid && (_afe.companyId !== null);
//      isValid = isValid && (_afe.locationId !== null);
//      isValid = isValid && (_afe.departmentId !== null);
//      isValid = isValid && (_afe.title.length > 0);
//      isValid = isValid && (_afe.owner !== null && _afe.owner.length > 0);
//      isValid = isValid && (_afe.afeAmount !== null);
//
//      if (_afe.stageGate){
//        isValid = isValid && (_afe.sgProject_number !== null && _afe.sgProject_number.length > 0);
//      }
//
//      isValid = isValid && (_afe.aliaxisTypeId !== null);
//      isValid = isValid && (_afe.aliaxisCategoryId !== null);
//      isValid = isValid && (_afe.proposal !== null && _afe.proposal.length > 0);
//      isValid = isValid && (_afe.background !== null && _afe.sgProject_number.length > 0);
//      isValid = isValid && (_afe.assumption !== null && _afe.assumption.length > 0);
//      isValid = isValid && (_afe.benefits !== null && _afe.benefits.length > 0);
//      isValid = isValid && (_afe.alternative !== null && _afe.alternative.length > 0);
//      isValid = isValid && (_afe.payback !== null && _afe.payback.length > 0);
//      isValid = isValid && (_afe.justification !== null && _afe.justification.length > 0);
//      isValid = isValid && (_afe.costSummary !== null && _afe.costSummary.length > 0);
//      isValid = isValid && (_afe.executiveSummary !== null && _afe.executiveSummary.length > 0);
//
//      return isValid;
    };

    loadSLA(currentAFE.id);
    //$scope.loadSLA();

    var submitForApproval = function() {
      
      $http({
        method: 'POST',
        url: svApiURLs.SLA + currentAFE.id,
        headers: {'Content-Type': 'application/json'}
      }).then(
        function(response) {
          //loadSLA(currentAFE.id);
          svToast.showSimpleToast('The approval request has been submited successfully.');
          loadSLA(currentAFE.id);
        },
        function(error) {
          svDialog.showSimpleDialog(angular.toJson(error.data), 'Error');
        }
      );
    };

    $scope.submitForInfofloIntegration = function () {
      console.log(svApiURLs.INFOFLO + currentAFE.id);
      $http({
        method: 'POST',
        url: svApiURLs.INFOFLO + currentAFE.id,
        headers: {'Content-Type': 'application/json'}
      }).then(
        function(response) {
          $scope.loadSLA();
          svToast.showSimpleToast('The approval request has been submited successfully.');
        },
        function(error) {
          svDialog.showSimpleDialog(angular.toJson(error.data), 'Oops!');
        }
      );
    };

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
        submitForApproval();
        $mdDialog.hide();
      }, function() {
        // nop
      });
    };
    
    
    
    cAfeAction.approve = function(){
      if(cAfeAction.currentSLAItem>0){
        var confirm = $mdDialog.confirm({onComplete: function afterShowAnimation() {
          var $dialog = angular.element(document.querySelector('md-dialog'));
          var $actionsSection = $dialog.find('md-dialog-actions');
          var $cancelButton = $actionsSection.children()[0];
          var $confirmButton = $actionsSection.children()[1];
          angular.element($confirmButton).removeClass('md-focused');
          angular.element($cancelButton).addClass('md-focused');
          $cancelButton.focus();
        }}) .title('Approve')
            .textContent('Are you sure to proceed?')
            .ariaLabel('approve')
            .ok('Yes')
            .cancel('No')
            .multiple(true);
        $mdDialog.show(confirm).then(function() {
          $mdDialog.hide();

          $http({
            method:'PUT',
            url: svApiURLs.slaApprove + cAfeAction.currentSLAItem.toString(),
            //data: JSON.stringify(data),
            headers: {'Content-Type': 'application/json'}
          }).then(function (data)
            {
              $scope.test = data.data;
              svToast.showSimpleToast('Request approved');
              //$scope.reset();
              loadSLA(currentAFE.id);
            },
            function (response)
            {
              $scope.test = response;

              var msg = response.data;
              svDialog.showSimpleDialog('Error - ' + msg);
            }
          );
        }, function() {
          // nope
        });
      }
    };
    
    cAfeAction.reject = function(){
      if(cAfeAction.currentSLAItem>0){
        var confirm = $mdDialog.confirm({onComplete: function afterShowAnimation() {
          var $dialog = angular.element(document.querySelector('md-dialog'));
          var $actionsSection = $dialog.find('md-dialog-actions');
          var $cancelButton = $actionsSection.children()[0];
          var $confirmButton = $actionsSection.children()[1];
          angular.element($confirmButton).removeClass('md-focused');
          angular.element($cancelButton).addClass('md-focused');
          $cancelButton.focus();
        }}) .title('Reject')
            .textContent('Are you sure to proceed?')
            .ariaLabel('reject')
            .ok('Yes')
            .cancel('No')
            .multiple(true);
        $mdDialog.show(confirm).then(function() {
          $mdDialog.hide();

          $http({
            method:'PUT',
            url: svApiURLs.slaReject + cAfeAction.currentSLAItem.toString(),
            //data: JSON.stringify(data),
            headers: {'Content-Type': 'application/json'}
          }).then(function (data)
            {
              $scope.test = data.data;
              svToast.showSimpleToast('Request rejected');
              loadSLA(currentAFE.id);
              //$scope.reset();
            },
            function (response)
            {
              $scope.test = response;

              var msg = response.data;
              svDialog.showSimpleDialog('Error - ' + msg);
            }
          );
        }, function() {
          // nope
        });
      }
    };
    
    cAfeAction.rework = function(){
      if(cAfeAction.currentSLAItem>0){
        var confirm = $mdDialog.confirm({onComplete: function afterShowAnimation() {
          var $dialog = angular.element(document.querySelector('md-dialog'));
          var $actionsSection = $dialog.find('md-dialog-actions');
          var $cancelButton = $actionsSection.children()[0];
          var $confirmButton = $actionsSection.children()[1];
          angular.element($confirmButton).removeClass('md-focused');
          angular.element($cancelButton).addClass('md-focused');
          $cancelButton.focus();
        }}) .title('Send for Rework')
            .textContent('Are you sure to proceed?')
            .ariaLabel('rework')
            .ok('Yes')
            .cancel('No')
            .multiple(true);
        $mdDialog.show(confirm).then(function() {
          $mdDialog.hide();

          $http({
            method:'PUT',
            url: svApiURLs.slaRework + cAfeAction.currentSLAItem.toString(),
            //data: JSON.stringify(data),
            headers: {'Content-Type': 'application/json'}
          }).then(function (data)
            {
              $scope.test = data.data;
              svToast.showSimpleToast('Request sent for rework');
              loadSLA(currentAFE.id);
              //$scope.reset();
            },
            function (response)
            {
              $scope.test = response;

              var msg = response.data;
              svDialog.showSimpleDialog('Error - ' + msg);
            }
          );
        }, function() {
          // nope
        });
      }
    };

  });
