'use strict';

/**
 * @ngdoc overview
 * @name cpxUiApp
 * @description
 * # cpxUiApp
 *
 * Main module of the application.
 */

angular
  .module('cpxUiApp', [
    'ngAnimate',
    'ngAria',
    'ngCookies',
    'ngMessages',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngMaterial',
    'ui.router',
    'material.components.expansionPanels',
    'ng-fusioncharts',
    'ngFileSaver',
    'lfNgMdFileInput',
    'angular-loading-bar'
  ])

//-- Path localhost ---------------------------------------------
// .constant('apiPath', 'http://localhost:8078')
// --------------------------------------------------------------

//-- Path Dev ---------------------------------------------------
  .constant('apiPath', 'http://devcpxapi.corpservices.local')
// --------------------------------------------------------------

//-- Path QA ----------------------------------------------------
//.constant('apiPath', 'http://qacpxapi.corpservices.local')
//---------------------------------------------------------------

//-- Path Staging -----------------------------------------------
//.constant('apiPath', 'http://stagingcpxapi.corpservices.local')
//---------------------------------------------------------------

  .constant('colorPhasing', {
    budget: '#735096',
    forecast: '#4A667F',
    actuals: '#50966D'
  })

  .config(function ($stateProvider, $urlRouterProvider, $mdThemingProvider, $httpProvider, $mdAriaProvider) {

    // Globally disables all ARIA warnings.
    $mdAriaProvider.disableWarnings();

    $httpProvider.defaults.withCredentials = true;

    var currYear = 2018;

    $stateProvider
      .state('root', {
        abstract: true,
        templateUrl: 'index.html',
        // template: 'Test Template <img src="views/pic.png"/>',
        url: '/',
        data: {
          settings: {
            displayName: 'app',
            showBreadcrumb: false
          }
        }
      })
      .state('app', {
        parent: 'root',
        templateUrl: 'views/main.html',
        url: '',
        resolve: {
          appReferences: function (svReferences,
                                   resCompanies,
                                   resDepartments,
                                   resLocations,
                                   resAliaxisCategories,
                                   resAliaxisType,
                                   resPriorities,
                                   resCategories,
                                   resCurrencies,
                                   resProjectStatus,
                                   resAnalysis,
                                   resSubCategories) {

            var ref = svReferences;

            var objParamsFilter = {companyId: null, locationId: null, categoryId: null};

            ref.companies = resCompanies.query(objParamsFilter);
            ref.locations = resLocations.query(objParamsFilter);
            ref.categories = resCategories.query(objParamsFilter);
            ref.departments = resDepartments.query();
            ref.aliaxisCategories = resAliaxisCategories.query();
            ref.aliaxisTypes = resAliaxisType.query();
            ref.priorities = resPriorities.query();
            ref.currencies = resCurrencies.query();
            ref.projectStatus = resProjectStatus.query();
            ref.analysis = resAnalysis.query();
            ref.subCategories = resSubCategories.query();

            return ref;
          },
          appUsers: function (resCurrentUserInfo) {
            return resCurrentUserInfo.get().$promise;
          }
        },
        controller: 'MainCtrl as cMain',
        data: {
          settings: {
            displayName: 'CPX',
            showBreadcrumb: true,
            crumbsTargetState: 'app'
          }
        }
      })
      .state('dashboard', {
        parent: 'app',
        templateUrl: 'views/dashboard.html',
        url: 'dashboard',
        controller: 'DashboardCtrl as dashboardCtrl',
        views: {
          '': {templateUrl: 'views/dashboard.html'},
          'messages@dashboard': {
            templateUrl: 'views/dashboard.messages.html',
            controller: 'MessagesCtrl as messagesCtrl'
          },
          'action-items@dashboard': {
            templateUrl: 'views/dashboard.action-items.html',
            controller: 'ActionItemsCtrl as actionItemsCtrl'
          },
          'approval-list@dashboard': {
            templateUrl: 'views/dashboard.approval-list.html',
            controller: 'ApprovalListCtrl as approvalListCtrl'
          },
          'graph-overview@dashboard': {
            templateUrl: 'views/dashboard.graph-overview.html',
            controller: 'GraphOverviewCtrl as graphOverviewCtrl'
          }
        },
        data: {
          settings: {
            displayName: 'Dashboard',
            showBreadcrumb: true,
            crumbsTargetState: 'dashboard'
          }
        }
      })
      .state('project-list', {
        parent: 'app',
        templateUrl: 'views/project.list.html',
        controller: 'ProjectListCtrl as cPrjList',
        url: 'projects',
        data: {
          settings: {
            displayName: 'Project List',
            showBreadcrumb: true,
            crumbsTargetState: 'project-list'
          }
        }
      })
      .state('project', {
        abstract: true,
        parent: 'app',
        template: '<div ui-view>Loading</div>',
        url: 'projects/{prjId:[0-9]{1,8}}',
        resolve: {
          currentProject: function (resPrjProjects, $stateParams) {
            var pjId = $stateParams.prjId;

            return resPrjProjects.get({id: pjId}).$promise;
          },
          pjCrumbsInfo: function (currentProject, svCrumbsInfo, resAfeShortList, resProjectShortList) {
            var info = svCrumbsInfo;
            var project = currentProject;

            info.project.id = project.id;
            info.project.number = project.projectNumber;
            info.project.desc = project.description;

            info.project.afeShortList = resAfeShortList.query({prjId: project.id});
            info.project.shortList = resProjectShortList.query();

            return info.project;
          },
          currentPrjSummary: function (resProjectSummary, appUsers) {
            return resProjectSummary.get({userName: appUsers.userName, budYear: currYear}).$promise;
          },
          currentPrjAFE: function() {

          },
          currentTransactions: function(resProjectTransactions, currentProject) {
            return resProjectTransactions.query({prjId: currentProject.id}).$promise;
          }
        },
        data: {
          settings: {
            displayName: 'Project',
            showBreadcrumb: true,
            crumbsTargetState: 'projectEdit({prjId: *prjId*})'
          }
        }
      })
      .state('projectEdit', {
        parent: 'project',
        templateUrl: 'views/project.edit.html',
        url: '',
        views: {
          '': {
            templateUrl: 'views/project.edit.html',
            controller: 'ProjectEditCtrl as cProjectEdit'
          },
          'projectDetails@projectEdit': {
            templateUrl: 'views/project.details.html',
            controller: 'ProjectDetailsCtrl as cProjectDetails'
          },
          'budgetForecast@projectEdit': {
            templateUrl: 'views/phasing.html',
            controller: 'ProjectPhasingCtrl as cPhasing'
          },
          'projectTransactions@projectEdit': {
            templateUrl: 'views/project.transactions.html',
            controller: 'ProjectTransactionsCtrl as cProjectTransactions'
          },
          'projectTransactionDetails@projectEdit': {
            templateUrl: 'views/project.transaction.details.html',
            controller: 'ProjectTransactionDetailsCtrl as cTransactionDetails'
          },
          'projectTransactionCreate@projectEdit': {
            templateUrl: 'views/project.transaction.create.html',
            controller: 'ProjectTransactionCreateCtrl as cTransactionCreate'
          },
          'projectAfeList@projectEdit': {
            templateUrl: 'views/project.afelist.html',
            controller: 'ProjectAfelistCtrl as cPrjAfeList'
          },
          'prjoverview@projectEdit': {
            templateUrl: 'views/project.overview.html',
            controller: 'PrjoverviewCtrl as cProjectOverview'
          },
          'prjoverviewall@projectEdit': {
            templateUrl: 'views/project.overviewAll.html',
            controller: 'ProjectOverviewallCtrl as cProjectOverviewAll'
          },
          //          //**debug
          //          'currency@projectEdit': {
          //            templateUrl: 'views/settings.currencies.html',
          //            controller: 'CurrenciesCtrl as cCurrencies'
          //          },
          //          'userAdmin@projectEdit': {
          //            templateUrl: 'views/user.admin.html',
          //            controller: 'UserAdminCtrl as cUserAdmin'
          //          }
          //          //**debug
        },
        data: {
          settings: {
            displayName: 'Project Details',
            showBreadcrumb: false
          }
        }
      })
      .state('projectAfeList', {
        parent: 'project',
        templateUrl: 'views/afe.list.html',
        controller: 'AfeListCtrl as cAfeList',
        url: '/afes',
        data: {
          settings: {
            displayName: 'AFE List',
            showBreadcrumb: true,
            crumbsTargetState: 'projectAfeList'
          }
        }
      })
      .state('afe', {
        abstract: true,
        parent: 'project',
        template: '<div ui-view>Loading...</div>',
        url: '/afes/{afeId:[0-9]{1,8}}',
        resolve: {
          currentAFE: function (resAfeAfe, $stateParams) {
            var afeId = $stateParams.afeId;
            return resAfeAfe.get({Id: afeId}).$promise;
          },
          afeCrumbsInfo: function (currentAFE, svCrumbsInfo) {
            var info = svCrumbsInfo;
            var afe = currentAFE;

            info.afe.id = afe.id;
            info.afe.number = afe.afeNumber;
            info.afe.desc = afe.title;

            return info.afe;
          }
        },
        data: {
          settings: {
            displayName: 'AFE',
            showBreadcrumb: true,
            crumbsTargetState: 'afeEdit({prjId: *prjId*, afeId: *afeId*})'
          }
        }
      })
      .state('afeEdit', {
        parent: 'afe',
        templateUrl: 'views/afe.edit.html',
        url: '',
        views: {
          '': {
            templateUrl: 'views/afe.edit.html',
            controller: 'AfeEditCtrl as cAfeEdit'
          },
          'afeHeader@afeEdit': {
            templateUrl: 'views/afe.header.html',
            controller: 'AfeHeaderCtrl as cAfeHeader'
          },
          'afeDetails@afeEdit': {
            templateUrl: 'views/afe.details.html',
            controller: 'AfeDetailsCtrl as cAfeDetails'
          },
          'afeBudgetForecast@afeEdit': {
            templateUrl: 'views/phasing.html',
            controller: 'AfePhasingCtrl as cPhasing'
          },
          'afePos@afeEdit': {
            templateUrl: 'views/afe.assets.html',
            controller: 'AfeAssetsCtrl as cAfeAssets'
          },
          'afeoverview@afeEdit': {
            templateUrl: 'views/afe.overview.html',
            controller: 'AfeoverviewCtrl as cAfeOverview'
          },
          'afeprjoverview@afeEdit': {
            templateUrl: 'views/afe.prjOverview.html',
            controller: 'AfeprjoverviewCtrl as cAfeProjectOverview'
          },
          'afeAction@afeEdit': {
            templateUrl: 'views/afe.action.html',
            controller: 'AfeActionCtrl as cAfeAction'
          }
        },
        data: {
          settings: {
            displayName: 'AFE Details',
            showBreadcrumb: false
          }
        }
      })
      .state('about', {
        parent: 'app',
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl as cAbout',
        url: 'release',
        data: {
          settings: {
            displayName: 'Release Notes',
            showBreadcrumb: true,
            crumbsTargetState: 'about'
          }
        }
      })
      .state('appSettings', {
        parent: 'app',
        templateUrl: 'views/settings.edit.html',
        controller: 'SettingsEditCtrl as cEdit',
        url: 'settings',

        //        views: {
        //          //**debug
        //          'currency@appSettings': {
        //            templateUrl: 'views/settings.currencies.html',
        //            controller: 'CurrenciesCtrl as cCurrencies'
        //          },
        //          'userAdmin@appSettings': {
        //            templateUrl: 'views/user.admin.html',
        //            controller: 'UserAdminCtrl as cUserAdmin'
        //          }},
        //          //**debug
        data: {
          settings: {
            displayName: 'Settings',
            showBreadcrumb: true,
            crumbsTargetState: 'settings'
          }
        }
      })
      .state('roles', {
        parent: 'app',
        templateUrl: 'views/user.admin.html',
        controller: 'UserAdminCtrl as cUserAdmin',
        url: 'roles',
        data: {
          settings: {
            displayName: 'Role Management',
            showBreadcrumb: true,
            crumbsTargetState: 'roles'
          }
        }
      });

    $urlRouterProvider.otherwise('/');

    var ipexBlueMap = $mdThemingProvider.extendPalette('blue', {
      '50': '#ebf3f9',
      '100': '#d3d9de', //'#c7ccd1',
      '500': '#265a88',
      '300': '#3987CC',
      '800': '#4A667F',
      'A100': '#47A9FF'
    });

    var ipexOrangeMap = $mdThemingProvider.extendPalette('orange', {
      '50': '#fa9800',
      '100': '#ffa314',
      '200': '#ffad2e',
      '300': '#e4b267',
      '400': '#ffc161',
      '500': '#d99126',
      '600': '#ffdfad',
      '700': '#ffe9c7',
      '800': '#cc6f24',
      '900': '#fffdfa',
      'A100': '#fff6e6',
      'A200': '#ffd399',
      'A400': '#ffbd66',
      'A700': '#ffa866'
    });

    var ipexRedMap = $mdThemingProvider.extendPalette('red', {
      '500': '#883126',
      '300': '#7F504A',
      '800': '#FF5C47',
      'A100': '#FFA094'
    });

    $mdThemingProvider.definePalette('ipexBlue', ipexBlueMap);
    $mdThemingProvider.definePalette('ipexOrange', ipexOrangeMap);
    $mdThemingProvider.definePalette('ipexRed', ipexRedMap);

    //        $mdThemingProvider.theme('default')
    //            .primaryPalette('ipexBlue')
    //            .accentPalette('ipexOrange')
    //            .warnPalette('ipexRed');

    var cpxThemes = [
      {
        name: 'default',
        primary: 'ipexBlue',
        accent: 'ipexOrange',
        warn: 'ipexRed'
      },
      {
        name: 'theme1',
        primary: 'red',
        accent: 'grey',
        warn: 'red'
      },
      {
        name: 'theme2',
        primary: 'purple',
        accent: 'pink',
        warn: 'red'
      },
      {
        name: 'theme3',
        primary: 'indigo',
        accent: 'blue',
        warn: 'red'
      },
      {
        name: 'theme4',
        primary: 'light-blue',
        accent: 'blue',
        warn: 'red'
      },
      {
        name: 'theme5',
        primary: 'teal',
        accent: 'green',
        warn: 'red'
      },
      {
        name: 'theme6',
        primary: 'light-green',
        accent: 'green',
        warn: 'red'
      },
      {
        name: 'theme7',
        primary: 'orange',
        accent: 'amber',
        warn: 'red'
      },
      {
        name: 'theme8',
        primary: 'brown',
        accent: 'amber',
        warn: 'red'
      },
      {
        name: 'theme9',
        primary: 'green',
        accent: 'brown',
        warn: 'orange'
      },
      {
        name: 'theme10',
        primary: 'blue-grey',
        accent: 'blue',
        warn: 'red'
      },
      {
        name: 'theme11',
        primary: 'grey',
        accent: 'light-blue',
        warn: 'red'
      }
    ];

    var i = 0;
    //        var i = conf.theme;

    $mdThemingProvider.theme('default')
      .primaryPalette(cpxThemes[i].primary)
      .accentPalette(cpxThemes[i].accent)
      .warnPalette(cpxThemes[i].warn);

  });
