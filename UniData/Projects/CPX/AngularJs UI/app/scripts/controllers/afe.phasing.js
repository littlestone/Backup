'use strict';

/**
 * @ngdoc function
 * @name cpxUiApp.controller:AfePhasingCtrl
 * @description
 * # AfePhasingCtrl
 * Controller of the cpxUiApp
 */
angular.module('cpxUiApp')
  .controller('AfePhasingCtrl', function (
    currentAFE,
    currentProject,
    resAfeForecast,
    resAfeActuals,
    appReferences,
    resGraphAfePhasing,
    $scope,
    $http,
    svApiURLs,
    appUsers,
    svAfeSummary,
    svAfePrjSummary,
    svToast,
    svDialog,
    svAppConfig,
    resPrjForecastYearAvailable,
    resPrjForecastEach) {

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
    $scope.displayTypeValue = 0;
    $scope.categoryId = 1;
    $scope.showCategory = false;
    $scope.showDisplay = false;

    $scope.forecastReadOnly = true;

    cPhasing.selectedYearId = 0;
    $scope.loadingForecast = false;

    cPhasing.currentYrIndex = -1;
    cPhasing.nextYrIndex = -1;

    // currency & exchange rate
    $scope.currentAfeId = currentAFE.id;
    $scope.currencies = appReferences.currencies;
    $scope.selectedCurrencyId = currentProject.companyCurrencyId;
    $scope.baseCurrencyId = currentProject.companyCurrencyId;
    $scope.budgetTypeId = $scope.displayTypeValue === 1 ? 1 : 2;  // 1 = Budget, 2 = Forecast

    //Populate years dropdown
    cPhasing.yearsAvail = [
      {
        id: 0,
        label: svAppConfig.currentYear,
        current: true
      },
      {
        id: 1,
        label: svAppConfig.currentYear + 1,
        current: false
      }
    ];

    //debug
    cPhasing.departments = appReferences.departments;

    $scope.lastActualsMonth = -11;

    $scope.graphData = {};

    $scope.chartConfig = {
      'chart':
      {
        'caption': '60-042-001-16 - MES FOREXTRUSION',
        'subcaption': 'Phasing + Actuals YTD',
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

    var loadGraph = function ()
    {
      var chartConfigData;
      var categoriesData = [];
      var afeData = [];
      var afeDataset = [];
      var forecastPrjDataset = [];
      var actualsData = [];
      var actualsDataset = [];
      var lastActualsMonth;
      var ytdAcc = [0];
      var forecastAcc = [];

      var dataset = [];

      var graphData;

      graphData = $scope.graphData;

      for (var i = 0; i < 12; i++)
      {
        ytdAcc[i] = 0;
        forecastAcc[i] = 0;
      }

      lastActualsMonth = 0;

      chartConfigData =
        {
          'caption': currentAFE.afeNumber + ' - ' + currentAFE.title,
          'subcaption': 'Phasing + Actuals YTD',
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


      //cPhasing.forecastDataset[cPhasing.selectedYearId].data
      var index = 0;

      if(cPhasing.forecastDataset !== undefined && cPhasing.forecastDataset[cPhasing.selectedYearId].data.length > 0){
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].janActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january};
          afeData[index] = {'value': ''};
          ytdAcc[index] = (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january));
        }

        index = 1;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].febActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february));
        }

        index = 2;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].marActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march));
        }

        index = 3;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].aprActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april));
        }

        index = 4;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].mayActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may));
        }

        index = 5;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].junActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june));
        }

        index = 6;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].julActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july));
        }

        index = 7;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].augActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august));
        }

        index = 8;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].septActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september));
        }

        index = 9;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].octActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october));
        }

        index = 10;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].novActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november));
        }

        index = 11;
        if(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].decActual){
          actualsData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december};
          afeData[index] = {'value': ''};
          ytdAcc[index] = parseFloat(ytdAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december));
          lastActualsMonth = index;
        }
        else {
          afeData[index] = {'value': cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december};
          actualsData[index] = {'value': ''};
          forecastAcc[index] = parseFloat(forecastAcc[index-1]) + (isNaN(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december) ? 0 : parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december));
        }
      }

      actualsDataset[0] =
        {
          'seriesname': 'Actuals',
          'data': actualsData
        };

      afeDataset[afeDataset.length] =
        {
          'seriesname': 'Forecast',
          'data': afeData
        };

      $scope.lastActualsMonth = lastActualsMonth;

      dataset = actualsDataset.concat(afeDataset.concat(forecastPrjDataset));

      $scope.chartConfig =
        {
          'chart': chartConfigData,
          'categories': categoriesData,
          'dataset': [
            {
              'dataset': dataset
            }
          ]
        };
    };


    $scope.reset = function () {
      if (cPhasing.form) {
        cPhasing.form.$setPristine();
        cPhasing.form.$setUntouched();
      }
    };

    $scope.SaveData = function () {

      if ($scope.amountTooHigh()){
        svDialog.showSimpleDialog(
          'Validation',
          'Error - Amount too high',
          true
        );
        svToast.showSimpleToast('Data NOT Saved');

        //Get out
        return;
      }
      var afeData = [];

      //Current Year
      var data = {
        PHASING: {
          'id': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].id,
          'projectId': currentProject.id,     //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].projectId,
          'budgetTypeId': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].budgetTypeId,
          'categoryId': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].categoryId,
          'afeId': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].afeId,
          'status': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].statusId,
          'year': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].year,
          'budgetedAmount': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].budgetedAmount,
          'january': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].january,
          'february': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].february,
          'march': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].march,
          'april': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].april,
          'may': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].may,
          'june': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].june,
          'july': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].july,
          'august': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].august,
          'september': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].september,
          'october': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].october,
          'november': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].november,
          'december': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].december,
          'nextYear': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].nextYear,
          'previousYear': cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].previousYear,
          'budgetTypeId': 2
        }
      };
      afeData.push(data);
      //Next Year
      data = {
        PHASING: {
          'id': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].id,
          'projectId': currentProject.id,     //cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].projectId,
          'budgetTypeId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].budgetTypeId,
          'categoryId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].categoryId,
          'afeId': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].afeId,
          'status': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].statusId,
          'year': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].year,
          'budgetedAmount': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].budgetedAmount,
          'january': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].january,
          'february': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].february,
          'march': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].march,
          'april': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].april,
          'may': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].may,
          'june': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].june,
          'july': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].july,
          'august': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].august,
          'september': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].september,
          'october': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].october,
          'november': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].november,
          'december': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].december,
          'nextYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].nextYear,
          'previousYear': cPhasing.forecastDataset[cPhasing.nextYrIndex].data[0].previousYear,
          'budgetTypeId': 2
        }
      };
      afeData.push(data);

      $http({
        method: 'POST',
        url: svApiURLs.afeUpdateForecast,
        data: JSON.stringify(afeData),
        headers: {'Content-Type': 'application/json'}
      }).then(function ()
              {
                svToast.showSimpleToast('Data Saved');
                $scope.reset();
              },
              function (response)
              {
                svDialog.showSimpleDialog(response.data, 'Error', true);
                svToast.showSimpleToast('Data NOT Saved');
              }
             );
    };

    $scope.refreshChartData = function (month, value) {
      $scope.chartConfig.dataset[0].dataset[1].data[month].value = value;
    };

    $scope.phasingReadOnly = function () {

      var retVal = false;

      retVal = cPhasing.form.$pristine || !cPhasing.form.$valid;

      return retVal;
    };

    var refreshOverviewAmounts = function () {

      var actual = 0;
      var forecast = 0;
      var prevYr = 0;
      var nextYear = 0;

      var dataset = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0];

      if(dataset.janActual){
        actual += parseFloat(dataset.january);
      }
      else{
        forecast += parseFloat(dataset.january);
      }

      if(dataset.febActual){
        actual += parseFloat(dataset.february);
      }
      else{
        forecast += parseFloat(dataset.february);
      }

      if(dataset.marActual){
        actual += parseFloat(dataset.march);
      }
      else{
        forecast += parseFloat(dataset.march);
      }

      if(dataset.aprActual){
        actual += parseFloat(dataset.april);
      }
      else{
        forecast += parseFloat(dataset.april);
      }

      if(dataset.mayActual){
        actual += parseFloat(dataset.may);
      }
      else{
        forecast += parseFloat(dataset.may);
      }

      if(dataset.junActual){
        actual += parseFloat(dataset.june);
      }
      else{
        forecast += parseFloat(dataset.june);
      }

      if(dataset.julActual){
        actual += parseFloat(dataset.july);
      }
      else{
        forecast += parseFloat(dataset.july);
      }

      if(dataset.augActual){
        actual += parseFloat(dataset.august);
      }
      else{
        forecast += parseFloat(dataset.august);
      }

      if(dataset.sepActual){
        actual += parseFloat(dataset.september);
      }
      else{
        forecast += parseFloat(dataset.september);
      }

      if(dataset.octActual){
        actual += parseFloat(dataset.october);
      }
      else{
        forecast += parseFloat(dataset.october);
      }

      if(dataset.novActual){
        actual += parseFloat(dataset.november);
      }
      else{
        forecast += parseFloat(dataset.november);
      }

      if(dataset.decActual){
        actual += parseFloat(dataset.december);
      }
      else{
        forecast += parseFloat(dataset.december);
      }

      prevYr = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].previousYear;

      nextYear = cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].nextYear;
      //                    for(var j=0;j<cPhasing.forecastDataset[cPhasing.nextYrIndex].data.length;j++){
      //
      //
      //                      nextYear += cPhasing.forecastDataset[cPhasing.nextYrIndex].data[j].yearlyAmount;
      //                    }

      svAfeSummary.afeCurrentYrForecast = forecast;
      svAfeSummary.afeActual = actual;

      svAfeSummary.afePrevYear = prevYr;
      svAfeSummary.afeTotalAmt = currentAFE.afeAmount;
      svAfeSummary.afeNextYrPhasing = nextYear;


      resPrjForecastEach.query({prjId: currentAFE.projectId, budYear: svAppConfig.currentYear}, function (data) {

        //                        svAfePrjSummary.originalAmount = currentProject.amount;
        //                        svAfePrjSummary.transactions = currentProject.transactionAmount;
        //                        svAfePrjSummary.prevYear = data[0].previousYear;
        //                        svAfePrjSummary.nextYear = data[0].nextYear;

        var prjForecast = 0;
        var afeActual = 0;
        var afeForecast = 0;

        var prjData = data[1];
        var afeData = data[2];

        prjForecast += parseFloat(prjData.january);
        if(afeData.janActual){
          afeActual += parseFloat(afeData.january);
        }
        else{
          afeForecast += parseFloat(afeData.january);
        }

        prjForecast += parseFloat(prjData.february);
        if(afeData.febActual){
          afeActual += parseFloat(afeData.february);
        }
        else{
          afeForecast += parseFloat(afeData.february);
        }

        prjForecast += parseFloat(prjData.march);
        if(afeData.marActual){
          afeActual += parseFloat(afeData.march);
        }
        else{
          afeForecast += parseFloat(afeData.march);
        }

        prjForecast += parseFloat(prjData.april);
        if(afeData.aprActual){
          afeActual += parseFloat(afeData.april);
        }
        else{
          afeForecast += parseFloat(afeData.april);
        }

        prjForecast += parseFloat(prjData.may);
        if(afeData.mayActual){
          afeActual += parseFloat(afeData.may);
        }
        else{
          afeForecast += parseFloat(afeData.may);
        }

        prjForecast += parseFloat(prjData.june);
        if(afeData.junActual){
          afeActual += parseFloat(afeData.june);
        }
        else{
          afeForecast += parseFloat(afeData.june);
        }

        prjForecast += parseFloat(prjData.july);
        if(afeData.julActual){
          afeActual += parseFloat(afeData.july);
        }
        else{
          afeForecast += parseFloat(afeData.july);
        }

        prjForecast += parseFloat(prjData.august);
        if(afeData.augActual){
          afeActual += parseFloat(afeData.august);
        }
        else{
          afeForecast += parseFloat(afeData.august);
        }

        prjForecast += parseFloat(prjData.september);
        if(afeData.sepActual){
          afeActual += parseFloat(afeData.september);
        }
        else{
          afeForecast += parseFloat(afeData.september);
        }

        prjForecast += parseFloat(prjData.october);
        if(afeData.octActual){
          afeActual += parseFloat(afeData.october);
        }
        else{
          afeForecast += parseFloat(afeData.october);
        }

        prjForecast += parseFloat(prjData.november);
        if(afeData.novActual){
          afeActual += parseFloat(afeData.november);
        }
        else{
          afeForecast += parseFloat(afeData.november);
        }

        prjForecast += parseFloat(prjData.december);
        if(afeData.decActual){
          afeActual += parseFloat(afeData.december);
        }
        else{
          afeForecast += parseFloat(afeData.december);
        }

        svAfePrjSummary.forecast = prjForecast;

        svAfePrjSummary.currentForecast = afeForecast;
        svAfePrjSummary.currentActuals = afeActual;


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
          resAfeForecast.query({afeID: currentAFE.id, afeYear: svAppConfig.currentYear}, function (data) {

            cPhasing.forecastDataset[cPhasing.currentYrIndex].data = data;
            cPhasing.selectedYearId = cPhasing.currentYrIndex;
            $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.currentYrIndex].data;

            if (cPhasing.nextYrIndex > 0){
              //-- Get Data for next year
              resAfeForecast.query({afeID: currentAFE.id, afeYear: svAppConfig.currentYear + 1}, function (data) {
                cPhasing.forecastDataset[cPhasing.nextYrIndex].data = data;
                refreshOverviewAmounts();
              });

              $scope.loadingForecast = false;
            }
            else {
              refreshOverviewAmounts();
              $scope.loadingForecast = false;
            }

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
      $scope.selectedYear = cPhasing.forecastDataset[cPhasing.selectedYearId].year;
      console.log($scope.selectedYear);
      console.log($scope.selectedCurrencyId);
      console.log($scope.currentAfeId);

      if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length === 0){

        resAfeForecast.query({afeID: currentAFE.id, afeYear: cPhasing.forecastDataset[cPhasing.selectedYearId].year}, function (data) {
          //Data not present. Fetch it.
          $scope.loadingForecast = true;
          cPhasing.forecastDataset[cPhasing.selectedYearId].data = data;

          $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.selectedYearId].data;
          loadGraph();
          $scope.loadingForecast = false;
        }, function(){
          //No data
          cPhasing.selectedYearId = cPhasing.currentYrIndex;
          if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length > 0){
            $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.selectedYearId].data;
            loadGraph();
          }
          svToast.showSimpleToast('No data for the selected year.');
          $scope.loadingForecast = false;
        });
      }

      if(cPhasing.forecastDataset[cPhasing.selectedYearId].data.length > 0){
        $scope.displayedForecast = cPhasing.forecastDataset[cPhasing.selectedYearId].data;
        loadGraph();
      }

    };

    $scope.IniChart = function () {
      resGraphAfePhasing.query({afeId: currentAFE.id, budYear: svAppConfig.currentYear}, function (data) {
        $scope.graphData = data;
        loadGraph();
      });
    };

    $scope.cancelEdit = function () {
      $scope.RefreshForecast();
      $scope.IniChart();
      svToast.showSimpleToast('Cancelled');
    };

    $scope.ytdPhasing = function () {

      var retVal = 0;

      if ($scope.currentForecast !== undefined && $scope.currentForecast !== null)
      {
        retVal = parseFloat($scope.currentForecast[0].january) +
          parseFloat($scope.currentForecast[0].february) +
          parseFloat($scope.currentForecast[0].march) +
          parseFloat($scope.currentForecast[0].april) +
          parseFloat($scope.currentForecast[0].may) +
          parseFloat($scope.currentForecast[0].june) +
          parseFloat($scope.currentForecast[0].july) +
          parseFloat($scope.currentForecast[0].august) +
          parseFloat($scope.currentForecast[0].september) +
          parseFloat($scope.currentForecast[0].october) +
          parseFloat($scope.currentForecast[0].november) +
          parseFloat($scope.currentForecast[0].december);
      }

      return retVal;
    };

    $scope.amountTooHigh = function () {
      return (svAfeSummary.available() < 0);
    };

    $scope.isAuthorized = function () {
      var retVal = false;

      retVal = (appUsers.userName === currentAFE.owner || appUsers.userName === currentAFE.delegate || appUsers.userName === currentProject.owner || appUsers.userName === currentProject.delegate);

      return retVal;
    };

    $scope.refreshUI = function (id, amount) {
      var nextYearAcc = 0;

      if (cPhasing.selectedYearId === cPhasing.nextYrIndex){

        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].january);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].february);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].march);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].april);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].may);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].june);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].july);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].august);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].september);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].october);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].november);
        nextYearAcc += parseFloat(cPhasing.forecastDataset[cPhasing.selectedYearId].data[0].december);

        cPhasing.forecastDataset[cPhasing.currentYrIndex].data[0].nextYear = nextYearAcc;
      }

      refreshOverviewAmounts();


      $scope.refreshChartData(id, amount);

    };

    //                $scope.RefreshForecast();
    //                $scope.displayedForecast = $scope.currentForecast;



    resAfeActuals.query({afeID: currentAFE.id, afeYear: svAppConfig.currentYear}, function (data) {
      $scope.currentActuals = data;
    });

    $scope.afeID = currentAFE.id;

    $scope.RefreshForecast();
    $scope.displayedForecast = $scope.currentForecast;
    $scope.IniChart();
  });
