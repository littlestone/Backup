'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svReferences
 * @description
 * # svReferences
 * Service in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('svReferences', function () {

        var references = {
            companies: [],
            locations: [],
            departments: [],
            aliaxisTypes: [],
            aliaxisCategories: [],
            priorities: [],
            categories: [],
            currencies: [],
            afeCategories: [],
            subCategories: [],
            analysis: []
        };

        return references;
    });
