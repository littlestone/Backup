'use strict';

describe('Controller: BudgetForecast2Ctrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var BudgetForecastCtrl,
    scope,
	currentProjectMock,
	appReferencesMock;
	
	appReferencesMock = {
		companies: [{}],
		departments: [{}],
		locations: [{}],
		aliaxisCategories: [{}],
		aliaxisTypes: [{}],
		priorities: [{}]
	};
	
	currentProjectMock = {id:0};
	
  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    BudgetForecastCtrl = $controller('BudgetForecastCtrl', {
		$scope: scope,
		currentProject: currentProjectMock,
		appReferences: appReferencesMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(BudgetForecastCtrl.awesomeThings.length).toBe(3);
  });
});
