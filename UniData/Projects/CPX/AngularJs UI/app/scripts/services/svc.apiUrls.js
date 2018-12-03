'use strict';

angular.module('cpxUiApp')
  .service('svApiURLs', function (apiPath) {
    var url = {
      //-- User --
      currentUserInfo: apiPath + '/User/api/data/userinfo',
      userInfo: apiPath + '/User/api/data/userinfo/:userName',
      users: apiPath + '/User/api/data/users',
      roleInfo: apiPath + '/User/api/data/role',
      userRoles: apiPath + '/User/api/data/role/:userName',
      // Save roles for a user
      roleUser: apiPath + '/User/api/data/roleuser',

      //-- Attachment --
      Attachment: apiPath + '/REF/api/data/attachment/',
      AttachmentTypes: apiPath + '/REF/api/data/attachmentTypes',

      //-- Projects --
      Project: apiPath + '/PRJ/api/data/project/:id',
      saveProject: apiPath + '/PRJ/api/data/project/',
      newProject: apiPath + '/PRJ/api/data/project',
      ProjectList: apiPath + '/PRJ/api/data/projects/:budYear/:userName',
      resPrjBudget: apiPath + '/PRJ/api/data/categories/:prjID',
      PrjBudget: apiPath + '/PRJ/api/data/budget/:prjId/:budYear',
      PrjActual: apiPath + '/PRJ/api/data/actual/:prjId/:budYear',
      prjListShort: apiPath + '/PRJ/api/data/projects/currentUser',
      budgetOwners: apiPath + '/PRJ/api/data/projects/users',
      prjForecastEach: apiPath + '/PRJ/api/data/forecast/:prjId/:budYear',
      prjUpdateForecast: apiPath + '/PRJ/api/data/forecast/',
      Transactions: apiPath + '/PRJ/api/data/transactions/:prjId',
      prjCreateTransaction: apiPath + '/PRJ/api/data/transactions',
      projectSummary: apiPath + '/PRJ/api/data/informations/:userName/:budYear',
      projectStatus: apiPath + '/PRJ/api/data/projectStatus',
      prjForecastYearAvailable: apiPath + '/PRJ/api/data/projectYears/:prjId',
      prjRPanelSummary: apiPath + '/PRJ/api/data/informations/:prjId/:budYear',

      //-- AFEs --
      AFE: apiPath + '/AFE/api/data/afe/:Id',
      saveAFE: apiPath + '/AFE/api/data/afe/',
      projectByAFENumber: apiPath + '/AFE/api/data/afe/afeNumber/:afeNumber',
      afeForecast: apiPath + '/AFE/api/data/forecast/:afeID/:afeYear',
      afeActuals: apiPath + '/AFE/api/data/actual/:afeID/:afeYear',
      afeListByProject: apiPath + '/AFE/api/data/afes/:prjId/:afeYear',
      afeListShort: apiPath + '/AFE/api/data/afes/:prjId',
      afeSummary: apiPath + '/AFE/api/data/informations/:prjId/:afeID/:afeYear',
      afePrjSummary: apiPath + '/AFE/api/data/Projectinformations/:prjId/:afeID/:afeYear',
      afeUpdateForecast: apiPath + '/AFE/api/data/forecast/',
      afeDelegate: apiPath + '/AFE/api/data/delegate',
      afeStatus: apiPath + '/AFE/api/data/afeStatus',
      afeSla: apiPath + '/AFE/api/data/SlaByAfeId/:afeId',

      // -- SLA --
      SLA: apiPath + '/SLA/api/data/initialize/',
      slaApprove: apiPath + '/SLA/api/data/approve/',
      slaReject: apiPath + '/SLA/api/data/reject/',
      slaRework: apiPath + '/SLA/api/data/rework/',
      slaResend: apiPath + '/SLA/api/data/resend/:afeId/:slaId',

      // --- Infoflo Integration ---
      INFOFLO: apiPath + '/Infoflo/api/data/integration/inbound/',

      //-- Assets --
      assetByAfe: apiPath + '/AFE/api/data/AssetListByAfeId/:afeId',
      asset: apiPath + '/AFE/api/data/AssetByAssetId/:assetId',
      updateAsset: apiPath + '/AFE/api/data/Asset',

      // -- PO --
      poListByAfe: apiPath + '/AFE/api/data/PurchaseOrderByAfeId/:afeId',
      poHeader: apiPath + '/AFE/api/data/PurchaseOrderHeaderByPoNumber/:poNbr',
      poLines: apiPath + '/AFE/api/data/PurchaseOrderLineDetailsByPoNumber/:poNbr',
      poPayments: apiPath + '/AFE/api/data/PurchaseOrderPaymentsByPoNumber/:poNbr',
      poReceipts: apiPath + '/AFE/api/data/PurchaseOrderReceiptsByPoNumber/:poNbr',
      poListByAsset: apiPath + '/AFE/api/data/PurchaseOrderByAssetId/:assetId',

      //-- References --
      AliaxisCategories: apiPath + '/REF/api/data/aliaxis/categories',
      AliaxisType: apiPath + '/REF/api/data/aliaxis/types',
      Companies: apiPath + '/REF/api/data/companies',
      Locations: apiPath + '/REF/api/data/locations',
      Departments: apiPath + '/REF/api/data/departments',
      Priorities: apiPath + '/REF/api/data/priorities',
      Currencies: apiPath + '/REF/api/data/currency',
      userLookup: apiPath + '/REF/api/data/userslookup/',
      currencyRate: apiPath + '/REF/api/data/currencyRate/:year/:month/:budgetTypeId/:baseCurrencyId/:targetCurrencyId',
      analysis:  apiPath + '/REF/api/data/analysis',
      categories: apiPath + '/REF/api/data/categories',
      subCategories:  apiPath + '/REF/api/data/subCategories',

      //-- Graph --
      PhasingGraph: apiPath + '/GRAPHS/api/data/project/:prjId/:budYear',
      AfePhasingGraph: apiPath + '/GRAPHS/api/data/afe/:afeId/:budYear'
    };

    return url;
  });
