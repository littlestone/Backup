(
  function (window) {
    window.__env = window.__env || {};

    window.__env.debugMode = true;
    window.__env.defaultTheme = 0;

    window.__env.apiUrls = {
      userInfo: 'http://web4stl:8073/0_1/api/testauthentication',
      ProjectList: 'http://devcpxapi.corpservices.local/PRJ/V1.0/api/data/projects/:userName',
      AliaxisCategories: 'http://web4stl:8072/0_1/api/AliaxisCategories',
      AliaxisType: 'http://web4stl:8072/0_1/api/AliaxisTypes',
      Companies: 'http://web4stl:8072/0_1/api/Companies',
      Locations: 'http://web4stl:8072/0_1/api/Locations',
      Priorities: 'http://web4stl:8072/0_1/api/Priorities',
      Departments: 'http://web4stl:8072/0_1/api/Departments',
      Categories: 'http://web4stl:8071/0_1_v2/api/GetProjectCategories',
      resPrjBudget: 'http://web4stl:8071/0_1_v2/api/GetProjectCategoriesbyProject/:prjID',
      Project: 'http://web4stl:8071/0_1/api/Projects/:id',
      PrjForecast: 'http://web4stl:8071/0_1/api/Forecasts?prjID=:prjId&budgetYear=:budYear',
      PrjBudget: 'http://web4stl:8071/0_1/api/Budgets?prjID=:prjId&budgetYear=:budYear',
      PrjActual: 'http://web4stl:8071/0_1/api/Actuals?prjID=:prjId&actualsYear=:budYear',
      prjListShort: 'http://web4stl:8071/0_1_v2/api/GetUserProjectList',
      budgetOwners: 'http://web4stl:8071/0_1_v2/api/GetuserList',
      projectByAFENumber: 'http://web4stl:8070/0_1_V2/api/GetAfeByNumber/:afeNumber',
      Transactions: 'http://web4stl:8071/0_1/api/ProjectsTransac?prjID=:prjID',
      AFE: 'http://web4stl:8070/0_1/api/AFEs/:Id',
      afeForecast: 'http://web4stl:8070/0_1/api/Forecasts?afeId=:afeID&budgetYear=:afeYear',
      afeActuals: 'http://web4stl:8070/0_1/api/Actuals?afeId=:afeID&budgetYear=:afeYear',
      afeListByProject: 'http://web4stl:8071/0_1/api/listByProject/:prjId,:afeYear',
      afeListShort: 'http://web4stl:8070/0_1/api/AFEsShort?prjId=:prjId'
    };
  }(this)
);
