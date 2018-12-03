'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svCrumbsInfo
 * @description
 * # svCrumbsInfo
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('svCrumbsInfo', function () {
        var info = {
            project: {
                id: '',
                number: '',
                desc: ''
            },
            afe: {
                id: '',
                number: '',
                desc: ''
            }
        };

        return info;
    });
