'use strict';

'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.resProjectForecast
 * @description
 * # resProjectForecast
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
        .factory('resPrjForecastYearAvailable', ['$resource', 'svApiURLs', function ($resource, svApiURLs) {
                return $resource(svApiURLs.prjForecastYearAvailable);
        }]);

//angular.module('cpxUiApp')
//  .service('resPrjForecastYearAvailable', function ($timeout) {
//    
//    //Simulating a request to the API
//    this.query = function(){
////      var deferred;
//      var years = [
//        {
//          id: 0,
//          year: 2016,
//          isCurrent: false
//        },
//        {
//          id: 1,
//          year: 2017,
//          isCurrent: false
//        },
//        {
//          id: 2,
//          year: 2018,
//          isCurrent: true
//        },
//        {
//          id: 3,
//          year: 2019,
//          isCurrent: false
//        }
//      ];
//
//      return $timeout(function(){return years;}, Math.random() * 1000);
//
//    };
//  });
