'use strict';

angular.module('cpxUiApp')
  .controller('AfeAssetsCtrl', function ($scope, currentAFE, resAfeAssets, resAfeAsset, appReferences, resPoByAsset, svPoDetail, $http, svToast, svDialog, svApiURLs) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var windowHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if ((windowHeight - 327) < 647) {
      $scope.contentStyle = {height: (windowHeight - 137) + 'px'};
    } else {
      $scope.contentStyle = {height: '670px'};
    }


    var cAfeAssets = this;

    cAfeAssets.loadingAssets = true;
    cAfeAssets.addingAsset = false;
    cAfeAssets.loadingPO = false;

    cAfeAssets.subCategories = appReferences.subCategories;
    cAfeAssets.subCategoriesFiltered = cAfeAssets.subCategories;
    cAfeAssets.categories = appReferences.categories;
    cAfeAssets.analysis = appReferences.analysis;
    cAfeAssets.locations = appReferences.locations;

    cAfeAssets.newAssetNumber = 'New';



    cAfeAssets.accumulators = {
      amount:0,
      committed:0,
      received:0,
      payments:0
    };

    cAfeAssets.isSubCatetoryDisabled = true;
    cAfeAssets.filterSubCategory = function(catId) {
      var cat = cAfeAssets.categories.find(function (obj) { return obj.id === catId; });
      cAfeAssets.subCategoriesFiltered = cAfeAssets.subCategories.filter(function(subCat) {
        if (subCat.subCategoryCode.indexOf(cat.categoryCode) >= 0) {
          return true;
        } else {
          return false;
        }
      });
      cAfeAssets.isSubCatetoryDisabled = false;
    };


    //Create a new asset
    cAfeAssets.newAsset = function(){
      var newAsset = {
        'id':-1,
        'assetNumber':'new',
        'assetName':'',
        'workOrderNumber':'',
        'cerNumber':'',
        'afeId':currentAFE.id,
        'projectId':currentAFE.projectId,
        'locationId':null,
        'serialNumber':'',
        'manufacturer':'',
        'modelNumber':'',
        'modelName':'',
        'newUsed':'',
        'categoryId':null,
        'subCategoryId':null,
        'analysisId':null,
        'statusId':0,
        'assetCost':0,
        'replacementValue':0,
        'purchaseDate':null,
        'depreciationStartDate': null
      };
      cAfeAssets.addingAsset = true;
      cAfeAssets.asset = newAsset;
    };

    //Get a single asset
    cAfeAssets.getAsset = function(_assetId){
      resAfeAsset.get({assetId: _assetId}, function(data) {
        cAfeAssets.asset = data;
        //Get the Pos
        cAfeAssets.getPO(_assetId);
      });
    };

    //Get all the assets for this AFE
    var getAssets = function() {
      resAfeAssets.query({afeId: currentAFE.id}, function(data) {
        cAfeAssets.assets = data;

        cAfeAssets.totalCost = 0;

        if(cAfeAssets.assets.length > 0){
          //Load the first record
          cAfeAssets.getAsset(cAfeAssets.assets[0].id);

          for(var i=0;i<cAfeAssets.assets.length;i++){
            cAfeAssets.totalCost += cAfeAssets.assets[i].assetCost;
          }
        }
        cAfeAssets.loadingAssets = false;
      });
    };

    cAfeAssets.getPO = function(_assetId){
      cAfeAssets.loadingPO = true;

      cAfeAssets.accumulators.amount = 0;
      cAfeAssets.accumulators.committed = 0;
      cAfeAssets.accumulators.received = 0;
      cAfeAssets.accumulators.payments = 0;

      resPoByAsset.query({assetId: _assetId}, function(data) {
        cAfeAssets.po = data;

        for(var i=0;i<cAfeAssets.po.length;i++){
          cAfeAssets.accumulators.amount += cAfeAssets.po[i].amount;
          cAfeAssets.accumulators.committed += cAfeAssets.po[i].committed;
          cAfeAssets.accumulators.received += cAfeAssets.po[i].received;
          cAfeAssets.accumulators.payments += cAfeAssets.po[i].payments;
        }

        cAfeAssets.loadingPO = false;
      });
    };

    cAfeAssets.jumpToPo = function(_poNumber) {
      svPoDetail.showPO(_poNumber);
    };

    cAfeAssets.saveAsset = function(){
      var data;

      data = {
        'id':cAfeAssets.asset.id,
        'assetNumber':cAfeAssets.asset.assetNumber,
        'assetName':cAfeAssets.asset.assetName,
        'workOrderNumber':cAfeAssets.asset.workOrderNumber,
        'cerNumber':cAfeAssets.asset.cerNumber,
        'afeId':currentAFE.id,
        'projectId':currentAFE.projectId,
        'locationId':cAfeAssets.asset.locationId,
        'serialNumber':cAfeAssets.asset.serialNumber,
        'manufacturer':cAfeAssets.asset.manufacturer,
        'modelNumber':cAfeAssets.asset.modelNumber,
        'modelName':cAfeAssets.asset.modelName,
        'newUsed':cAfeAssets.asset.newUsed,
        'categoryId':cAfeAssets.asset.categoryId,
        'subCategoryId':cAfeAssets.asset.subCategoryId,
        'analysisId':cAfeAssets.asset.analysisId,
        'statusId':cAfeAssets.asset.statusId,
        'assetCost':cAfeAssets.asset.assetCost,
        'replacementValue':cAfeAssets.asset.replacementValue,
        'purchaseDate':cAfeAssets.asset.purchaseDate,
        'depreciationStartDate':cAfeAssets.asset.depreciationStartDate
      };
      console.log(data);

      var url = '';
      var method = 'POST';
      if (cAfeAssets.asset.id < 0){
        //New Asset
        url = svApiURLs.updateAsset;
      }
      else{
        //Update an existing asset
        method = 'PUT';
        url = svApiURLs.updateAsset + '/' + cAfeAssets.asset.id.toString();
      }

      $http({
        method: method,
        url: url,
        data: JSON.stringify(data),
        headers: {'Content-Type': 'application/json'}
      }).then(function (data)
        {
          cAfeAssets.asset = data.data;
          cAfeAssets.addingAsset = false;
          cAfeAssets.form.$setPristine();
          svToast.showSimpleToast('Data Saved');
          getAssets();
          // $scope.reset();
        },
        function (response)
        {
          var msg = response.data;

          svDialog.showSimpleDialog(
            msg.substring(msg.indexOf(':') + 1),
            'Error - ' + msg.substring(0, msg.indexOf(':'))
          );

          //cAfeAssets.addingAsset = false;
          svToast.showSimpleToast('Data NOT Saved');
        }
      );
    };

    cAfeAssets.cancelSave = function(){
      cAfeAssets.getAsset(cAfeAssets.assets[0].id);
      cAfeAssets.addingAsset = false;
      cAfeAssets.form.$setPristine();
      svToast.showSimpleToast('Cancelled');
    };

    cAfeAssets.cancelDisabled = function(){
      var isEnabled = false;
      
      isEnabled = isEnabled || cAfeAssets.form.$dirty;
      //isEnabled = isEnabled || (cAfeAssets.asset.id < 0);
      
      return !isEnabled;
    };

    //Load the assets for this AFE
    getAssets();
  });
