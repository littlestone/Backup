'use strict';

describe('Controller: AfeBudgetforecastCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeBudgetforecastCtrl,
    scope,
	currentAFEMock,
	appReferencesMock;
	
	appReferencesMock = {
		companies: [{}],
		departments: [{}],
		locations: [{}],
		aliaxisCategories: [{}],
		aliaxisTypes: [{}],
		priorities: [{}]
	};

	currentAFEMock = {id:0};
	
  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeBudgetforecastCtrl = $controller('AfeBudgetforecastCtrl', {
		$scope: scope,
		currentAFE: currentAFEMock,
		appReferences: appReferencesMock
    });
  }));

	it('Set this.testOk to true', function () {
		expect(AfeBudgetforecastCtrl.testOk).toBeTruthy();
  });
});
