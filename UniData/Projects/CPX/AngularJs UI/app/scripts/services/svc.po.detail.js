'use strict';

angular.module('cpxUiApp')
  .service('svPoDetail', function($mdDialog, $mdColors) {
    
    this.showPO = function(_poNbr, $event){
      var parentEl = angular.element(document.body);
      
      $mdDialog.show({
        parent: parentEl,
        targetEvent: $event,
        scapeToClose: true,
        clickOutsideToClose: true,
        templateUrl: 'views/templates/po.display.html',
        locals: {
          poNbr: _poNbr,
          statusColor: $mdColors.getThemeColor('warn'),
          tableColor: $mdColors.getThemeColor('primary-100')
        },
        controller: 'poDisplayCtrl'
      });
    };
  });