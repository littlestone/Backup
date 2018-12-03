'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfeDetailsCtrl
 * @description
 * # AfeDetailsCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfeDetailsCtrl', function ($scope, $mdDialog, currentAFE, appUsers, $http, svApiURLs, svToast, svDialog) {
    var cAfeDetails = this;

    cAfeDetails.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647)
    {
      cAfeDetails.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      cAfeDetails.contentStyle = {height: '670px'};
    }

 

    cAfeDetails.afe = currentAFE;
    cAfeDetails.notes = '';
    cAfeDetails.executiveSummary = '';
    cAfeDetails.appUsers = appUsers;

    $scope.secmsk = {
      readOnly: 64,
      visible: 4
    };
    //Set R-O if status is higher that CREATION
    //..patch, a better solution needed
    if(true){
      //$scope.secmsk.readOnly = 1023;
      $scope.secmsk.readOnly = 0;
    }

    cAfeDetails.saveData = function(){
      var data;

      data = {
        'id':cAfeDetails.afe.id,
        'proposal':cAfeDetails.afe.proposal,
        'background':cAfeDetails.afe.background,
        'assumption':cAfeDetails.afe.assumption,
        'benefits':cAfeDetails.afe.benefits,
        'alternative':cAfeDetails.afe.alternative,
        'payback':cAfeDetails.afe.payback,
        'justification':cAfeDetails.afe.justification,
        'costSummary':cAfeDetails.afe.costSummary,
        'executiveSummary': cAfeDetails.afe.executiveSummary,
        'notes': cAfeDetails.afe.notes
      };


      $http({
        method: (cAfeDetails.afe.id>0?'PUT':'POST'),
        url: svApiURLs.saveAFE + (cAfeDetails.afe.id>0?cAfeDetails.afe.id:''),
        data: JSON.stringify(data),
        headers: {'Content-Type': 'application/json'}
      }).then(function (data)
        {

          $scope.test = data.data;

          svToast.showSimpleToast('Data Saved');
          $scope.reset();
        },
        function (response)
        {

          $scope.test = response;

          var msg = response.data;
          svDialog.showSimpleDialog('Error - ' + msg);
        }
      );

    };

    // function to show attachments utility
    $scope.showAttachmentUtility = function(entityTypeId) {
      var parentEl = angular.element(document.body);
      $mdDialog.show({
        parent: parentEl,
        escapeToClose: true,
        clickOutsideToClose: true,
        bindToController: true,
        scope: $scope,             // use parent scope in template
        preserveScope: true,       // do not forget this if use parent scope
        multiple: true,
        template: '<md-dialog aria-label="Attachment utility dialog" style="width:580px;">' +
                  '  <ix-attachments upload-enabled="true" download-enabled="true" delete-enabled="true" entity-type-id="'+ entityTypeId  +'" entity-record-id="{{entityTypeId}}" attachment-type-id="" userid="{{cAfeDetails.appUsers.userName}}">' +
                  '  </ix-attachments>' +
                  '</md-dialog>'
      });
    };
  });
