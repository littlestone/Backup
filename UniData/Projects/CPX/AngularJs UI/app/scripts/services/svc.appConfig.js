'use strict';

/**
 * @ngdoc service
 * @name cpxUiApp.svAppConfig
 * @description
 * # svAppConfig
 * Factory in the cpxUiApp.
 */
angular.module('cpxUiApp')
    .service('svAppConfig', function () {
        var appConfig = {
            currentYear: 2018,
            exchange: {
                budget: {
                    CAD: 1.0,
                    USD: 1.0,
                    EUR: 1.0
                },
                forecast: {
                    jan: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    feb: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    mar: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    apr: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    may: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    jun: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    jul: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    aug: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    sep: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    oct: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    nov: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    dec: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    }

                },
                actuals: {
                    jan: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    feb: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    mar: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    apr: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    may: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    jun: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    jul: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    aug: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    sep: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    oct: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    nov: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    },
                    dec: {
                        CAD: 1.0,
                        USD: 1.0,
                        EUR: 1.0
                    }

                }
            },
        };

        return appConfig;
    });






//    .factory('svAppConfig', function ($resource) {
//        return $resource('./config.json');
//    });
