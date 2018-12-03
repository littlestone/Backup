'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:ProjectPhasingCtrl
 * @description
 * # ProjectPhasingCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('ProjectPhasingCtrl', function (
    currentProject,
    resPrjBudget,
    prjActualsResource,
    $scope,
    resCategories,
    resPrjForecastEach,
    resGraphProjectPhasing,
    $http,
    svApiURLs,
    appUsers,
    svToast,
    svDialog,
    svAppConfig,
    svPrjSummary,
    $mdDialog,
    appReferences,
    resPrjForecastYearAvailable) {

    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var cPhasing = this;

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647)
    {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else
    {
      $scope.contentStyle = {height: '670px'};
    }

    $scope.year = svAppConfig.currentYear;
    $scope.selectedYear = svAppConfig.currentYear;
    $scope.categoryId = 1;
    $scope.displayBudgetId = 0;
    $scope.displayType = [{id: 0, display: 'Forecast'}, {id: 1, display: 'Budget'}];
    $scope.displayTypeValue = 0;
    $scope.showCategory = true;
    $scope.showDisplay = true;

    $scope.loadingForecast = false;
    $scope.forecastReadOnly = true;

    cPhasing.currentYrIndex = -1;
    cPhasing.nextYrIndex = -1;
    cPhasing.selectedYearId = 0;

    // currency & exchange rate
    $scope.currencies = appReferences.currencies;
    $scope.selectedCurrencyId = currentProject.companyCurrencyId;
    $scope.baseCurrencyId = currentProject.companyCurrencyId;
    $scope.budgetTypeId = $scope.displayTypeValue === 1 ? 1 : 2;  // 1 = Budget, 2 = Forecast
    $scope.getSelectedBudgetTypeId = function() {
      $scope.budgetTypeId = $scope.displayTypeValue === 1 ? 1 : 2;
      console.log($scope.budgetTypeId);
    };

    $scope.monthStyle = function () {
      return {'color': 'blue'};
    };

    $scope.lastActualsMonth = -11;

    $scope.graphData = {};

    $scope.chartConfig = {
      'chart':
      {
        'caption': '60-042-001-16 - MES FOREXTRUSION',
        'subcaption': 'Phasing + Actuals LTD',
        'xAxisName': 'Month',
        'pYAxisName': 'Phasing ($)',
        'sYAxisName': 'Actuals YTD ($)',
        'numberPrefix': '$',
        'sNumberPrefix': '$',
        'paletteColors': '#50966D,#4A667F,#ffa866,#E87C51',
        'baseFontColor': '#333333',
        'baseFont': 'Helvetica Neue,Arial',
        'captionFontSize': '14',
        'subcaptionFontSize': '14',
        'subcaptionFontBold': '0',
        'showBorder': '0',
        'canvasBgAlpha': '0',
        'bgColor': 'EEEEEE,CCCCCC',
        'bgratio': '60,40',
        'bgAlpha': '70,80',
        'showShadow': '0',
        'canvasBgColor': '#ffffff',
        'canvasBorderAlpha': '0',
        'divlineAlpha': '80',
        'divlineColor': '#cccccc',
        'divlineThickness': '1',
        'divLineDashed': '0',
        'divLineDashLen': '1',
        'usePlotGradientColor': '0',
        'showplotborder': '0',
        'placeValuesInside': '1',
        'showXAxisLine': '1',
        'xAxisLineThickness': '1',
        'xAxisLineColor': '#999999',
        'showAlternateHGridColor': '0',
        'legendBgAlpha': '0',
        'legendBorderAlpha': '0',
        'legendShadow': '0',
        'legendItemFontSize': '10',
        'legendItemFontColor': '#666666',
        'rotateValues': '0',
        'valueFontSize': '10',
        'valueFontColor': '#ffffff',
        'drawCrossLine': '0',
        'crossLineColor': '#9E9E9E',
        'crossLineAlpha': '50',
        'plotBorderColor': '#757575',
        'showPrintMenuItem': '0',
        'showHoverEffect': '1',
        'valueBgColor': '#4A667F',
        'valueBgAlpha': '50',
        'valueBorderRadius': '5'
      },
      'categories':
      [
        {
          'category':
          [
            {'label': 'January'},
            {'label': 'February'},
            {'label': 'March'},
            {'label': 'April'},
            {'label': 'May'},
            {'label': 'June'},
            {'label': 'July'},
            {'label': 'August'},
            {'label': 'September'},
            {'label': 'October'},
            {'label': 'November'},
            {'label': 'December'}
          ]
        }
      ]
    };



    $scope.loadChart = function(){
      var chartConfigData;
      var categoriesData = [];
      var budgetData = [];
      var budgetDataset = [];
      var budgetAmountData;
      var afeData = [];
      var afeDataset = [];
      var forecastPrjData = [];
      var forecastPrjDataset = [];
      var actualsData = [];
      var actualsDataset = [];
      var ytdAcc = [0];
      var forecastAcc = [];

      var dataset = [];

      for (var i = 0; i < 12; i++){
        ytdAcc[i] = 0;
        forecastAcc[i] = 0;
      }

      chartConfigData =
        {
          'caption': currentProject.projectNumber + ' - ' + currentProject.description,
          'subcaption': 'Phasing + Actuals LTD (' + $scope.displayedForecast[0].year.toString() + ')',
          'xAxisName': 'Month',
          'pYAxisName': 'Phasing ($)',
          'sYAxisName': 'Actuals YTD ($)',
          'numberPrefix': '$',
          'sNumberPrefix': '$',
          'paletteColors': '#714a7f,#50966D,#4A667F,#B27556,#2A2AE5',
          'baseFontColor': '#333333',
          'baseFont': 'Helvetica Neue,Arial',
          'captionFontSize': '14',
          'subcaptionFontSize': '14',
          'subcaptionFontBold': '0',
          'showBorder': '0',
          'canvasBgAlpha': '0',
          'bgColor': 'EEEEEE,CCCCCC',
          'bgratio': '60,40',
          'bgAlpha': '70,80',
          'showShadow': '0',
          'canvasBgColor': '#ffffff',
          'canvasBorderAlpha': '0',
          'divlineAlpha': '80',
          'divlineColor': '#cccccc',
          'divlineThickness': '1',
          'divLineDashed': '0',
          'divLineDashLen': '1',
          'usePlotGradientColor': '0',
          'showplotborder': '0',
          'placeValuesInside': '1',
          'showXAxisLine': '1',
          'xAxisLineThickness': '1',
          'xAxisLineColor': '#999999',
          'showAlternateHGridColor': '0',
          'legendBgAlpha': '0',
          'legendBorderAlpha': '0',
          'legendShadow': '0',
          'legendItemFontSize': '10',
          'legendItemFontColor': '#666666',
          'rotateValues': '0',
          'valueFontSize': '10',
          'valueFontColor': '#ffffff',
          'drawCrossLine': '0',
          'crossLineColor': '#9E9E9E',
          'crossLineAlpha': '50',
          'plotBorderColor': '#757575',
          'showPrintMenuItem': '1',
          'showHoverEffect': '1',
          'valueBgColor': '#4A667F',
          'valueBgAlpha': '50',
          'valueBorderRadius': '5'
        };

      categoriesData[0] =
        {
          'category':
          [
            {'label': 'January'},
            {'label': 'February'},
            {'label': 'March'},
            {'label': 'April'},
            {'label': 'May'},
            {'label': 'June'},
            {'label': 'July'},
            {'label': 'August'},
            {'label': 'September'},
            {'label': 'October'},
            {'label': 'November'},
            {'label': 'December'}
          ]
        };

      //Loading Budget Data
      if(typeof $scope.displayedBudget !== 'undefined'){
        budgetData[0] = {'value': $scope.displayedBudget[0].january};
        budgetData[1] = {'value': $scope.displayedBudget[0].february};
        budgetData[2] = {'value': $scope.displayedBudget[0].march};
        budgetData[3] = {'value': $scope.displayedBudget[0].april};
        budgetData[4] = {'value': $scope.displayedBudget[0].may};
        budgetData[5] = {'value': $scope.displayedBudget[0].june};
        budgetData[6] = {'value': $scope.displayedBudget[0].july};
        budgetData[7] = {'value': $scope.displayedBudget[0].august};
        budgetData[8] = {'value': $scope.displayedBudget[0].september};
        budgetData[9] = {'value': $scope.displayedBudget[0].october};
        budgetData[10] = {'value': $scope.displayedBudget[0].november};
        budgetData[11] = {'value': $scope.displayedBudget[0].december};

        budgetDataset[0] =
          {
            'seriesname': 'Budget',
            'data': budgetData
          };
        budgetAmountData = $scope.displayedBudget[0].budgetedAmount;
      }

      //Loading forecast
      if(typeof $scope.displayedForecast !== 'undefined'){
        for(i=0; i<$scope.displayedForecast.length; i++){
          //Find the AFE summary
          if($scope.displayedForecast[i].forecastId === -1){

            if($scope.displayedForecast[i].janActual){
              actualsData[0] = {'value': $scope.displayedForecast[i].january};
              ytdAcc[0] = ytdAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].january) ? 0 : parseFloat($scope.displayedForecast[i].january)));
              afeData[0] = {'value': ''};
            }
            else{
              actualsData[0] = {'value': ''};
              afeData[0] = {'value': $scope.displayedForecast[i].january};
              forecastAcc[0] = forecastAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].january) ? 0 : parseFloat($scope.displayedForecast[i].january)));
            }

            if($scope.displayedForecast[i].febActual){
              actualsData[1] = {'value': $scope.displayedForecast[i].february};
              ytdAcc[1] = ytdAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].february) ? 0 : parseFloat($scope.displayedForecast[i].february)));
              afeData[1] = {'value': ''};
            }
            else{
              actualsData[1] = {'value': ''};
              afeData[1] = {'value': $scope.displayedForecast[i].february};
              forecastAcc[1] = forecastAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].february) ? 0 : parseFloat($scope.displayedForecast[i].february)));
            }

            if($scope.displayedForecast[i].marActual){
              actualsData[2] = {'value': $scope.displayedForecast[i].march};
              ytdAcc[2] = ytdAcc[1] + parseFloat((isNaN($scope.displayedForecast[i].march) ? 0 : parseFloat($scope.displayedForecast[i].march)));
              afeData[2] = {'value': ''};
            }
            else{
              actualsData[2] = {'value': ''};
              afeData[2] = {'value': $scope.displayedForecast[i].march};
              forecastAcc[2] = forecastAcc[1] + parseFloat((isNaN($scope.displayedForecast[i].march) ? 0 : parseFloat($scope.displayedForecast[i].march)));
            }

            if($scope.displayedForecast[i].aprActual){
              actualsData[3] = {'value': $scope.displayedForecast[i].april};
              ytdAcc[3] = ytdAcc[2] + parseFloat((isNaN($scope.displayedForecast[i].april) ? 0 : parseFloat($scope.displayedForecast[i].april)));
              afeData[3] = {'value': ''};
            }
            else{
              actualsData[3] = {'value': ''};
              afeData[3] = {'value': $scope.displayedForecast[i].april};
              forecastAcc[3] = forecastAcc[2] + parseFloat((isNaN($scope.displayedForecast[i].april) ? 0 : parseFloat($scope.displayedForecast[i].april)));
            }

            if($scope.displayedForecast[i].mayActual){
              actualsData[4] = {'value': $scope.displayedForecast[i].may};
              ytdAcc[4] = ytdAcc[3] + parseFloat((isNaN($scope.displayedForecast[i].may) ? 0 : parseFloat($scope.displayedForecast[i].may)));
              afeData[4] = {'value': ''};
            }
            else{
              actualsData[4] = {'value': ''};
              afeData[4] = {'value': $scope.displayedForecast[i].may};
              forecastAcc[4] = forecastAcc[3] + parseFloat((isNaN($scope.displayedForecast[i].may) ? 0 : parseFloat($scope.displayedForecast[i].may)));
            }

            if($scope.displayedForecast[i].junActual){
              actualsData[5] = {'value': $scope.displayedForecast[i].june};
              ytdAcc[5] = ytdAcc[4] + parseFloat((isNaN($scope.displayedForecast[i].june) ? 0 : parseFloat($scope.displayedForecast[i].june)));
              afeData[5] = {'value': ''};
            }
            else{
              actualsData[5] = {'value': ''};
              afeData[5] = {'value': $scope.displayedForecast[i].june};
              forecastAcc[5] = forecastAcc[4] + parseFloat((isNaN($scope.displayedForecast[i].june) ? 0 : parseFloat($scope.displayedForecast[i].june)));
            }

            if($scope.displayedForecast[i].julActual){
              actualsData[6] = {'value': $scope.displayedForecast[i].july};
              ytdAcc[6] = ytdAcc[5] + parseFloat((isNaN($scope.displayedForecast[i].july) ? 0 : parseFloat($scope.displayedForecast[i].july)));
              afeData[6] = {'value': ''};
            }
            else{
              actualsData[6] = {'value': ''};
              afeData[6] = {'value': $scope.displayedForecast[i].july};
              forecastAcc[6] = forecastAcc[5] + parseFloat((isNaN($scope.displayedForecast[i].july) ? 0 : parseFloat($scope.displayedForecast[i].july)));
            }

            if($scope.displayedForecast[i].augActual){
              actualsData[7] = {'value': $scope.displayedForecast[i].august};
              ytdAcc[7] = ytdAcc[6] + parseFloat((isNaN($scope.displayedForecast[i].august) ? 0 : parseFloat($scope.displayedForecast[i].august)));
              afeData[7] = {'value': ''};
            }
            else{
              actualsData[7] = {'value': ''};
              afeData[7] = {'value': $scope.displayedForecast[i].august};
              forecastAcc[7] = forecastAcc[6] + parseFloat((isNaN($scope.displayedForecast[i].august) ? 0 : parseFloat($scope.displayedForecast[i].august)));
            }

            if($scope.displayedForecast[i].sepActual){
              actualsData[8] = {'value': $scope.displayedForecast[i].september};
              ytdAcc[8] = ytdAcc[7] + parseFloat((isNaN($scope.displayedForecast[i].september) ? 0 : parseFloat($scope.displayedForecast[i].september)));
              afeData[8] = {'value': ''};
            }
            else{
              actualsData[8] = {'value': ''};
              afeData[8] = {'value': $scope.displayedForecast[i].september};
              forecastAcc[8] = forecastAcc[7] + parseFloat((isNaN($scope.displayedForecast[i].september) ? 0 : parseFloat($scope.displayedForecast[i].september)));
            }

            if($scope.displayedForecast[i].octActual){
              actualsData[9] = {'value': $scope.displayedForecast[i].october};
              ytdAcc[9] = ytdAcc[8] + parseFloat((isNaN($scope.displayedForecast[i].october) ? 0 : parseFloat($scope.displayedForecast[i].october)));
              afeData[9] = {'value': ''};
            }
            else{
              actualsData[9] = {'value': ''};
              afeData[9] = {'value': $scope.displayedForecast[i].october};
              forecastAcc[9] = forecastAcc[8] + parseFloat((isNaN($scope.displayedForecast[i].october) ? 0 : parseFloat($scope.displayedForecast[i].october)));
            }

            if($scope.displayedForecast[i].novActual){
              actualsData[10] = {'value': $scope.displayedForecast[i].november};
              ytdAcc[10] = ytdAcc[9] + parseFloat((isNaN($scope.displayedForecast[i].november) ? 0 : parseFloat($scope.displayedForecast[i].november)));
              afeData[10] = {'value': ''};
            }
            else{
              actualsData[10] = {'value': ''};
              afeData[10] = {'value': $scope.displayedForecast[i].november};
              forecastAcc[10] = forecastAcc[9] + parseFloat((isNaN($scope.displayedForecast[i].november) ? 0 : parseFloat($scope.displayedForecast[i].november)));
            }

            if($scope.displayedForecast[i].decActual){
              actualsData[11] = {'value': $scope.displayedForecast[i].december};
              ytdAcc[11] = ytdAcc[10] + parseFloat((isNaN($scope.displayedForecast[i].december) ? 0 : parseFloat($scope.displayedForecast[i].december)));
              afeData[11] = {'value': ''};
            }
            else{
              actualsData[11] = {'value': ''};
              afeData[11] = {'value': $scope.displayedForecast[i].december};
              forecastAcc[11] = forecastAcc[10] + parseFloat((isNaN($scope.displayedForecast[i].december) ? 0 : parseFloat($scope.displayedForecast[i].december)));
            }

            actualsDataset[0] =
              {
                'seriesname': 'Actuals',
                'data': actualsData
              };

            afeDataset[0] =
              {
                'seriesname': 'Forecast AFE',
                'data': afeData
              };

            if($scope.displayedForecast[i].forecastId >= 0){
              break;
            }
          }

          //Find the Categories summary
          if($scope.displayedForecast[i].forecastId === -2){

            forecastPrjData[0] = {'value': $scope.displayedForecast[i].january};
            if(!$scope.displayedForecast[i].janActual){
              forecastAcc[0] = forecastAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].january) ? 0 : parseFloat($scope.displayedForecast[i].january)));
            }

            forecastPrjData[1] = {'value': $scope.displayedForecast[i].february};
            if($scope.displayedForecast[i].febActual){
              forecastAcc[1] = forecastAcc[0] + parseFloat((isNaN($scope.displayedForecast[i].february) ? 0 : parseFloat($scope.displayedForecast[i].february)));
            }

            forecastPrjData[2] = {'value': $scope.displayedForecast[i].march};
            if($scope.displayedForecast[i].marActual){
              forecastAcc[2] = forecastAcc[1] + parseFloat((isNaN($scope.displayedForecast[i].march) ? 0 : parseFloat($scope.displayedForecast[i].march)));
            }

            forecastPrjData[3] = {'value': $scope.displayedForecast[i].april};
            if($scope.displayedForecast[i].aprActual){
              forecastAcc[3] = forecastAcc[2] + parseFloat((isNaN($scope.displayedForecast[i].april) ? 0 : parseFloat($scope.displayedForecast[i].april)));
            }

            forecastPrjData[4] = {'value': $scope.displayedForecast[i].may};
            if($scope.displayedForecast[i].mayActual){
              forecastAcc[4] = forecastAcc[3] + parseFloat((isNaN($scope.displayedForecast[i].may) ? 0 : parseFloat($scope.displayedForecast[i].may)));
            }

            forecastPrjData[5] = {'value': $scope.displayedForecast[i].june};
            if($scope.displayedForecast[i].junActual){
              forecastAcc[5] = forecastAcc[4] + parseFloat((isNaN($scope.displayedForecast[i].june) ? 0 : parseFloat($scope.displayedForecast[i].june)));
            }

            forecastPrjData[6] = {'value': $scope.displayedForecast[i].july};
            if($scope.displayedForecast[i].julActual){
              forecastAcc[6] = forecastAcc[5] + parseFloat((isNaN($scope.displayedForecast[i].july) ? 0 : parseFloat($scope.displayedForecast[i].july)));
            }

            forecastPrjData[7] = {'value': $scope.displayedForecast[i].august};
            if($scope.displayedForecast[i].augActual){
              forecastAcc[7] = forecastAcc[6] + parseFloat((isNaN($scope.displayedForecast[i].august) ? 0 : parseFloat($scope.displayedForecast[i].august)));
            }

            forecastPrjData[8] = {'value': $scope.displayedForecast[i].september};
            if($scope.displayedForecast[i].sepActual){
              forecastAcc[8] = forecastAcc[7] + parseFloat((isNaN($scope.displayedForecast[i].september) ? 0 : parseFloat($scope.displayedForecast[i].september)));
            }

            forecastPrjData[9] = {'value': $scope.displayedForecast[i].october};
            if($scope.displayedForecast[i].octActual){
              forecastAcc[9] = forecastAcc[8] + parseFloat((isNaN($scope.displayedForecast[i].october) ? 0 : parseFloat($scope.displayedForecast[i].october)));
            }

            forecastPrjData[10] = {'value': $scope.displayedForecast[i].november};
            if($scope.displayedForecast[i].novActual){
              forecastAcc[10] = forecastAcc[9] + parseFloat((isNaN($scope.displayedForecast[i].november) ? 0 : parseFloat($scope.displayedForecast[i].november)));
            }

            forecastPrjData[11] = {'value': $scope.displayedForecast[i].december};
            if($scope.displayedForecast[i].decActual){
              forecastAcc[11] = forecastAcc[10] + parseFloat((isNaN($scope.displayedForecast[i].december) ? 0 : parseFloat($scope.displayedForecast[i].december)));
            }

            forecastPrjDataset[0] =
              {
                'seriesname': 'Forecast Categories',
                'data': forecastPrjData
              };

            if($scope.displayedForecast[i].forecastId >= 0){
              break;
            }
          }
        }

        dataset = actualsDataset.concat(afeDataset.concat(forecastPrjDataset));

        $scope.chartConfig =
          {
            'chart': chartConfigData,
            'categories': categoriesData,
            'dataset': [
              {
                'dataset': budgetDataset
              },
              {
                'dataset': dataset
              }
            ]
          };
      }
    };


    var refreshOverviewAmounts = function () {

      var prjData = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[1];
      var afeData = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[2];

      var afeActual = 0;
      var afeForecast = 0;
      var prjForecast = 0;
      var prevYr = 0;
      var nextYear = 0;

      prjForecast += parseFloat(prjData.january);
      prjForecast += parseFloat(prjData.february);
      prjForecast += parseFloat(prjData.march);
      prjForecast += parseFloat(prjData.april);
      prjForecast += parseFloat(prjData.may);
      prjForecast += parseFloat(prjData.june);
      prjForecast += parseFloat(prjData.july);
      prjForecast += parseFloat(prjData.august);
      prjForecast += parseFloat(prjData.september);
      prjForecast += parseFloat(prjData.october);
      prjForecast += parseFloat(prjData.november);
      prjForecast += parseFloat(prjData.december);

      if(typeof afeData !== 'undefined'){
        if(afeData.janActual){
          afeActual += parseFloat(afeData.january);
        }
        else{
          afeForecast += parseFloat(afeData.january);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].january = parseFloat(prjData.january) + parseFloat((afeData.janActual?afeData.january:afeData.january));

        if(afeData.febActual){
          afeActual += parseFloat(afeData.february);
        }
        else{
          afeForecast += parseFloat(afeData.february);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].february = parseFloat(prjData.february) + parseFloat((afeData.febActual?afeData.february:afeData.february));

        if(afeData.marActual){
          afeActual += parseFloat(afeData.march);
        }
        else{
          afeForecast += parseFloat(afeData.march);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].march = parseFloat(prjData.march) + parseFloat((afeData.marActual?afeData.march:afeData.march));

        if(afeData.aprActual){
          afeActual += parseFloat(afeData.april);
        }
        else{
          afeForecast += parseFloat(afeData.april);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].april = parseFloat(prjData.april) + parseFloat((afeData.aprActual?afeData.april:afeData.april));

        if(afeData.mayActual){
          afeActual += parseFloat(afeData.may);
        }
        else{
          afeForecast += parseFloat(afeData.may);
        }
        ///cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].may = parseFloat(prjData.may) + parseFloat((afeData.mayActual?afeData.may:afeData.may));

        if(afeData.junActual){
          afeActual += parseFloat(afeData.june);
        }
        else{
          afeForecast += parseFloat(afeData.june);
        }
        // cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].june = parseFloat(prjData.june) + parseFloat((afeData.junActual?afeData.june:afeData.june));

        if(afeData.julActual){
          afeActual += parseFloat(afeData.july);
        }
        else{
          afeForecast += parseFloat(afeData.july);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].july = parseFloat(prjData.july) + parseFloat((afeData.julActual?afeData.july:afeData.july));

        if(afeData.augActual){
          afeActual += parseFloat(afeData.august);
        }
        else{
          afeForecast += parseFloat(afeData.august);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].august = parseFloat(prjData.august) + parseFloat((afeData.augActual?afeData.august:afeData.august));

        if(afeData.sepActual){
          afeActual += parseFloat(afeData.september);
        }
        else{
          afeForecast += parseFloat(afeData.september);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].september = parseFloat(prjData.september) + parseFloat((afeData.sepActual?afeData.september:afeData.september));

        if(afeData.octActual){
          afeActual += parseFloat(afeData.october);
        }
        else{
          afeForecast += parseFloat(afeData.october);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].october = parseFloat(prjData.october) + parseFloat((afeData.octActual?afeData.october:afeData.october));

        if(afeData.novActual){
          afeActual += parseFloat(afeData.november);
        }
        else{
          afeForecast += parseFloat(afeData.november);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].november = parseFloat(prjData.november) + parseFloat((afeData.novActual?afeData.november:afeData.november));

        if(afeData.decActual){
          afeActual += parseFloat(afeData.december);
        }
        else{
          afeForecast += parseFloat(afeData.december);
        }
        //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].december = parseFloat(prjData.december) + parseFloat((afeData.decActual?afeData.december:afeData.december));
      }

      prevYr = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].previousYear;

      svPrjSummary.forecast = prjForecast;
      svPrjSummary.currentActuals = afeActual;
      svPrjSummary.currentForecast = afeForecast;
      svPrjSummary.prevYear = prevYr;

      if(cPhasing.nextYrIndex>0){
        var rec = {};
        for(var n=0;n<cPhasing.forecastDataset[cPhasing.nextYrIndex].data.length;n++){
          if(cPhasing.forecastDataset[cPhasing.nextYrIndex].data[n].forecastId>0){
            rec = cPhasing.forecastDataset[cPhasing.nextYrIndex].data[n];
            nextYear += (parseFloat(rec.january) +
                         parseFloat(rec.february) +
                         parseFloat(rec.march) +
                         parseFloat(rec.april) +
                         parseFloat(rec.may) +
                         parseFloat(rec.june) +
                         parseFloat(rec.july) +
                         parseFloat(rec.august) +
                         parseFloat(rec.september) +
                         parseFloat(rec.october) +
                         parseFloat(rec.november) +
                         parseFloat(rec.december));
          }
        }
      }

      //nextYear = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].nextYear;
      svPrjSummary.nextYear = nextYear;
    };

    $scope.phasingReadOnly = function () {
      return (cPhasing.form.$pristine || !cPhasing.form.$valid) || ($scope.displayedForecast[$scope.categoryId - 1].forecastId < 0);
    };

    var newCatCtrl = function($scope){
      $scope.newCategories = appReferences.categories;
      $scope.selectedCat = -1;

      $scope.answer = function(answer){
        $mdDialog.hide(answer);
      };
    };

    $scope.addNewCat = function(ev){
      $mdDialog.show({
        controller: newCatCtrl,
        templateUrl: 'views/templates/ref.categories.html',
        parent: angular.element(document.body),
        targetEvent: ev
      })
        .then(function(answer) {

          if (answer.id < 0){
            $scope.categoryId = 1;
            //$scope.RefreshForecast();
          }
          else{
            var duplicateCat = false;

            for(var t=0;t>cPhasing.forecastDataset[cPhasing.currentYrIndex].data.length;t++){
              duplicateCat = duplicateCat || (cPhasing.forecastDataset[cPhasing.currentYrIndex].data[t].id === answer.id);
              if(duplicateCat){break;}
            }

            if(duplicateCat){
              svDialog.showSimpleDialog('This category is already present in the list', 'Error', true);
            }
            else{
              //Clone the last element as a template to the new category
              var lastElement = cPhasing.forecastDataset[cPhasing.currentYrIndex].data.length - 1;
              var newCat = JSON.parse(JSON.stringify(cPhasing.forecastDataset[cPhasing.currentYrIndex].data[lastElement]));

              //Update amounts. leave the monthActual flag alone
              newCat.id = (newCat.id + 1);
              //newCat.id = -1;
              newCat.forecastId = null;
              newCat.categoryId = answer.id;
              newCat.categoryDesc = answer.desc;
              newCat.budgetedAmount = 0;
              newCat.january = 0;
              newCat.february = 0;
              newCat.march = 0;
              newCat.april = 0;
              newCat.may = 0;
              newCat.june = 0;
              newCat.july= 0;
              newCat.august = 0;
              newCat.september = 0;
              newCat.october = 0;
              newCat.november = 0;
              newCat.december = 0;
              newCat.nextYear = 0;
              newCat.previousYear = 0;

              //Add the new category to Current Year
              cPhasing.forecastDataset[cPhasing.currentYrIndex].data.push(JSON.parse(JSON.stringify(newCat)));

              //Add the new category to Next Year
              newCat.year = newCat.year + 1;
              cPhasing.forecastDataset[cPhasing.nextYrIndex].data.push(JSON.parse(JSON.stringify(newCat)));

              //Set the dropdown to the new element
              $scope.categoryId = newCat.id; // lastElement + 2;
            }
          }

        }, function() {
          $scope.categoryId = 1;
          //$scope.RefreshForecast();
        });
    };

    $scope.reset = function () {
      if ($scope.categoryId < 0){
        //notAvailableAlertDialog();
        $scope.addNewCat();
      }
      else{
        if (cPhasing.form) {
          cPhasing.form.$setPristine();
          cPhasing.form.$setUntouched();
        }
      }
    };

    $scope.getMonthValue = function (month) {

      var maxIndex = 0;
      var tmpVal;
      var retVal = 0;

      if ($scope.chartConfig.dataset !== undefined) {

        maxIndex = $scope.chartConfig.dataset[1].dataset.length;
        var dataSet = $scope.chartConfig.dataset[1].dataset;


        for (var i = 0; i < maxIndex; i++) {
          tmpVal = dataSet[i].data[month].value;

          if (tmpVal !== '' && tmpVal !== null) {
            retVal = retVal + parseFloat(tmpVal);
          }
        }
      }

      return retVal;
    };

    $scope.refreshChartData = function (month, value) {

      $scope.chartConfig.dataset[1].dataset[2].data[month].value = value;


      //                if (cPhasing.selectedYearId === 0) {
      //                    //Only if Current Year
      //                    $scope.chartConfig.dataset[1].dataset[2].data[month].value = value;
      //
      //                    for (var t = month; t < 12; t++)
      //                    {
      //                        $scope.chartConfig.lineset[0].data[t].value = parseFloat($scope.chartConfig.lineset[0].data[t - 1].value) + $scope.getMonthValue(t);
      //                    }
      //                }
    };

    $scope.IniChart = function () {
      resGraphProjectPhasing.query({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function (data) {
        $scope.graphData = data;
        //loadGraph();
        $scope.loadChart();
      });
    };

    $scope.RefreshForecast = function () {

      $scope.loadingForecast = true;
      resPrjForecastYearAvailable.query({prjId: currentProject.id}, function(data) {
        //Success

        cPhasing.forecastDataset = [];

        var max = data.length;
        var struct;

        for (var i = 0; i<max; i++){
          struct = {
            id: data[i].id,
            year: data[i].year,
            label: data[i].year.toString(),
            current: data[i].year === svAppConfig.currentYear,
            data: []
          };

          cPhasing.forecastDataset.push(struct);

          if (data[i].year === svAppConfig.currentYear){
            cPhasing.currentYrIndex = i;
          }

          if (data[i].year === svAppConfig.currentYear + 1){
            cPhasing.nextYrIndex = i;
          }
        }

        if (cPhasing.currentYrIndex >= 0){

          resPrjForecastEach.query({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function (data) {

            cPhasing.forecastDataset[cPhasing.currentYrIndex].data = data;
            cPhasing.selectedYearId = cPhasing.currentYrIndex;

            if (cPhasing.nextYrIndex > 0){
              //-- Get Data for next year

              resPrjForecastEach.query({prjId: currentProject.id, budYear: svAppConfig.currentYear + 1}, function (data) {
                cPhasing.forecastDataset[cPhasing.nextYrIndex].data = data;
                refreshOverviewAmounts();
              });

              $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.currentYrIndex].data;

              $scope.loadingForecast = false;
            }
            else {
              refreshOverviewAmounts();
              $scope.loadingForecast = false;
            }
            $scope.toggleForecastDisplay();
            $scope.IniChart();
          });
        }
        else {
          //Current year did not load.
          svToast.showSimpleToast('Error retreiving the current year of forecast.');
        }

      });
      //              , function(data){
      //                //failed
      //                svToast.showSimpleToast('Error retreiving the forecast data.');
      //              };

      $scope.reset();
    };

    $scope.toggleForecastDisplay = function () {

      // get user selected year
      $scope.selectedYear = cPhasing.budgetDataset[cPhasing.selectedYearId].year;

      if(cPhasing.budgetDataset[cPhasing.selectedYearId].data.length === 0){
        //Data not present. Fetch it.
        $scope.loadingForecast = true;
        resPrjBudget.query({prjId: currentProject.id, budYear: cPhasing.forecastDataset[cPhasing.selectedYearId].year}, function (data) {

          cPhasing.budgetDataset[cPhasing.selectedYearId].data = data;

          $scope.displayedBudget = cPhasing.budgetDataset[cPhasing.selectedYearId].data;

          $scope.loadingForecast = false;
        }, function(){
          svToast.showSimpleToast('Error loading budget');
        });
      }

      if(cPhasing.budgetDataset[cPhasing.selectedYearId].data.length > 0){
        $scope.displayedBudget = cPhasing.budgetDataset[cPhasing.selectedYearId].data;
      }

      if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length === 0){
        //Data not present. Fetch it.
        $scope.loadingForecast = true;
        resPrjForecastEach.query({prjId: currentProject.id, budYear: cPhasing.forecastDataset[cPhasing.selectedYearId].year}, function (data) {

          if(data.length > 0){
            cPhasing.forecastDataset[cPhasing.selectedYearId].data = data;
            $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.selectedYearId].data;
            $scope.loadChart();
          }
          else{
            svToast.showSimpleToast('No data for the selected year.');
            cPhasing.selectedYearId = cPhasing.currentYrIndex;
          }

          if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length < $scope.categoryId){
            //Index out of bound
            //Set Category dropdown to the last element
            $scope.categoryId = cPhasing.forecastDataset[cPhasing.selectedYearId].data.length;
          }

          $scope.loadingForecast = false;
        }, function(){
          svToast.showSimpleToast('Error loading forecast');
        });
      }

      //Any data to show?
      if (cPhasing.forecastDataset[cPhasing.selectedYearId].data.length > 0){
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length < $scope.categoryId){
          //Index out of bound
          //Set Category dropdown to the last element
          $scope.categoryId = cPhasing.forecastDataset[cPhasing.selectedYearId].data.length;
        }
      }

      if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length > 0){
        $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.selectedYearId].data;
        $scope.loadChart();
      }
    };

    $scope.cancelEdit = function () {
      $scope.RefreshForecast();
      $scope.categoryId = 1;
      //$scope.IniChart();
      svToast.showSimpleToast('Cancelled');
    };

    $scope.LoadBudget = function () {

      $scope.loadingForecast = true;
      resPrjForecastYearAvailable.query({prjId: currentProject.id}, function(data) {
        //Success

        cPhasing.budgetDataset = [];

        var max = data.length;
        var struct;

        for (var i = 0; i<max; i++){
          struct = {
            id: data[i].id,
            year: data[i].year,
            label: data[i].year.toString(),
            current: data[i].year === svAppConfig.currentYear,
            data: []
          };

          cPhasing.budgetDataset.push(struct);

          if (data[i].year === svAppConfig.currentYear){
            cPhasing.currentYrIndex = i;
          }

          if (data[i].year === svAppConfig.currentYear + 1){
            cPhasing.nextYrIndex = i;
          }
        }

        if (cPhasing.currentYrIndex >= 0){
          resPrjBudget.query({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function (data) {

            cPhasing.budgetDataset[cPhasing.currentYrIndex].data = data;

            if (cPhasing.nextYrIndex > 0){
              //-- Get Data for next year
              resPrjBudget.query({prjId: currentProject.id, budYear: svAppConfig.currentYear + 1}, function (data) {

                cPhasing.budgetDataset[cPhasing.nextYrIndex].data = data;
              });

              $scope.displayedBudget = cPhasing.budgetDataset[cPhasing.currentYrIndex].data;
              $scope.loadingForecast = false;
            }
            else {
              $scope.loadingForecast = false;
            }
          });
        }
        else {
          //Current year did not load.
          svToast.showSimpleToast('Error retreiving the current year of forecast.');
        }

      });
      //              , function(data){
      //                //failed
      //                svToast.showSimpleToast('Error retreiving the forecast data.');
      //              };
    };

    $scope.YearlyBudget = function () {
      var retVal = 0;
      var max = 0;

      if ($scope.graphData !== undefined) {
        max = $scope.graphData.length;

        for (var z = 0; z < max; z++) {
          if ($scope.graphData[z].budgetTypeId === 1) {
            retVal = $scope.graphData[z].totalBudget;
            break;
          }
        }
      }

      return retVal;
    };

    $scope.ytdPhasing = function () {

      var tot = 0;

      for (var t = 0; t < 12; t++)
      {
        tot = tot + $scope.getMonthValue(t);
      }

      return tot;
    };

    $scope.amountTooHigh = function () {
      //                return ($scope.ytdPhasing() > $scope.YearlyBudget());

      //                var availableToForecast = (svPrjSummary.prjAmount + svPrjSummary.prjTransac - svPrjSummary.nextYear - svPrjSummary.prevYear - svPrjSummary.forecast - svPrjSummary.currentActuals - svPrjSummary.currentForecast);
      //
      //                return (availableToForecast < 0);

      return (svPrjSummary.available() < 0);
    };

    $scope.SaveData = function () {

      var prjData = [];
      var data;

      //Current Year
      if(cPhasing.currentYrIndex >= 0){
        var maxIndex = cPhasing.forecastDataset[cPhasing.currentYrIndex].data.length;

        if (!$scope.amountTooHigh()) {

          for (var i = 0; i < maxIndex; i++) {
            if (cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].forecastId >= 0) {
              data = {
                PHASING: {
                  'id': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].forecastId,
                  'projectId': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].projectId,
                  'categoryId': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].categoryId,
                  'year': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].year,
                  'budgetedAmount': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].budgetedAmount,
                  'january': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].january,
                  'february': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].february,
                  'march': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].march,
                  'april': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].april,
                  'may': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].may,
                  'june': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].june,
                  'july': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].july,
                  'august': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].august,
                  'september': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].september,
                  'october': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].october,
                  'november': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].november,
                  'december': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].december,
                  'nextYear': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].nextYear,
                  'previousYear': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].previousYear,
                  'budgetTypeId': 2
                }
              };
              prjData.push(data);
            }
          }

          //Next Year
          maxIndex = cPhasing.forecastDataset[cPhasing.nextYrIndex].data.length;

          for (i = 0; i < maxIndex; i++) {
            if (cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].forecastId >= 0) {
              data = {
                PHASING: {
                  'id': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].forecastId,
                  'projectId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].projectId,
                  'categoryId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].categoryId,
                  'year': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].year,
                  'budgetedAmount': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].budgetedAmount,
                  'january': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].january,
                  'february': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].february,
                  'march': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].march,
                  'april': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].april,
                  'may': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].may,
                  'june': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].june,
                  'july': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].july,
                  'august': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].august,
                  'september': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].september,
                  'october': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].october,
                  'november': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].november,
                  'december': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].december,
                  'nextYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].nextYear,
                  'previousYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[i].previousYear,
                  'budgetTypeId': 2
                }
              };
              prjData.push(data);
            }
          }

          $http({
            method: 'PUT',
            url: svApiURLs.prjUpdateForecast,
            data: JSON.stringify(prjData),
            headers: {'Content-Type': 'application/json'}
          }).then(function ()
                  {
                    svToast.showSimpleToast('Data Saved');
                    $scope.reset();
                  },
                  function (response) {
                    svDialog.showSimpleDialog(response.data, 'Error', true);
                  }
                 );
        }
      }

      //Next Year
      //                if(cPhasing.nextYrIndex > 0){
      //                  var maxI = cPhasing.forecastDataset[cPhasing.nextYrIndex].data.length;
      //
      //                  if (!$scope.amountTooHigh()) {
      //
      //                    data = [];
      //
      //                    for (var p = 0; p < maxI; p++) {
      //                      if (cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].forecastId >= 0) {
      //                        data = {
      //                          PHASING:  {
      //                            'id': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].forecastId === undefined ? -1 : cPhasing.forecastDataset[cPhasing.currentYrIndex].data[i].forecastId,
      //                            'projectId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].projectId,
      //                            'categoryId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].categoryId,
      //                            'year': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].year,
      //                            'budgetedAmount': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].budgetedAmount,
      //                            'january': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].january,
      //                            'february': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].february,
      //                            'march': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].march,
      //                            'april': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].april,
      //                            'may': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].may,
      //                            'june': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].june,
      //                            'july': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].july,
      //                            'august': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].august,
      //                            'september': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].september,
      //                            'october': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].october,
      //                            'november': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].november,
      //                            'december': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].december,
      //                            'nextYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].nextYear,
      //                            'previousYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[p].previousYear,
      //                            'budgetTypeId': 2
      //                          }
      //                        };
      //                        prjData.push(data);
      //                      }
      //                    }
      //
      //                    $http({
      //                      method: 'PUT',
      //                      url: svApiURLs.prjUpdateForecast,
      //                      data: JSON.stringify(prjData),
      //                      headers: {'Content-Type': 'application/json'}
      //                    }).then(function ()
      //                    {
      //                      svToast.showSimpleToast('Data Saved');
      //                      $scope.reset();
      //                    },
      //                      function (response) {
      //                        svDialog.showSimpleDialog(response.data,'Error',true);
      //                      }
      //                    );
      //                  }
      //                }
    };

    $scope.isAuthorized = function () {
      return (appUsers.userName === currentProject.owner || appUsers.userName === currentProject.delegate);
    };

    $scope.refreshUI = function (id, amount) {
      //The param "amount" is not used here but is needed to preserve comptability between
      //   - project.phasing.js
      //   - afe.phasing.js
      //   - phasing.html
      //------------------------------------------------------------------------------------

      var len = cPhasing.forecastDataset[cPhasing.selectedYearId].data.length;

      var foreAcc =[0,0,0,0,0,0,0,0,0,0,0,0];

      for(var a=3; a<len; a++){

        foreAcc[0] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].january);
        foreAcc[1] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].february);
        foreAcc[2] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].march);
        foreAcc[3] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].april);
        foreAcc[4] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].may);
        foreAcc[5] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].june);
        foreAcc[6] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].july);
        foreAcc[7] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].august);
        foreAcc[8] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].september);
        foreAcc[9] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].october);
        foreAcc[10] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].november);
        foreAcc[11] += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[a].december);
      }


      if(cPhasing.selectedYearId === cPhasing.currentYrIndex){
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].january = foreAcc[0];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].february = foreAcc[1];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].march = foreAcc[2];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].april = foreAcc[3];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].may = foreAcc[4];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].june = foreAcc[5];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].july = foreAcc[6];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].august = foreAcc[7];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].september = foreAcc[8];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].october = foreAcc[9];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].november = foreAcc[10];
        cPhasing.forecastDataset[cPhasing.selectedYearId].data[1].december = foreAcc[11];
      }

      if(cPhasing.selectedYearId === cPhasing.nextYrIndex){

        var nextYearAcc = 0;

        //NextYear Categories
        for(var idx=0;idx<12;idx++){
          nextYearAcc += foreAcc[idx];
        }

        //NextYear AFE
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].january;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].february;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].march;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].april;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].may;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].june;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].july;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].august;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].september;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].october;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].november;
        nextYearAcc += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[2].december;

        cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].nextYear = nextYearAcc;
      }

      refreshOverviewAmounts();

      $scope.refreshChartData(id, foreAcc[id]);
    };

    resCategories.query({prjID: currentProject.id}, function (data) {
      $scope.categories = data;
    });

    prjActualsResource.query({prjId: currentProject.id, budYear: svAppConfig.currentYear}, function (data) {
      $scope.currentActuals = data;
    });

    $scope.LoadBudget();

    $scope.RefreshForecast();
  });
