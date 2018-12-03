'use strict';

describe('Controller: AfeHeaderCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeHeaderCtrl,
    scope,
	currentAFEMock,
	appReferencesMock,
	currentProjectMock;

	currentProjectMock = {projectNumber:0};
	
	currentAFEMock = {estimatedCompletionDate: new Date()};
	
	
	appReferencesMock = {
		companies: [{}],
		departments: [{}],
		locations: [{}],
		aliaxisCategories: [{}],
		aliaxisTypes: [{}],
		priorities: [{}]
	};
	
  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeHeaderCtrl = $controller('AfeHeaderCtrl', {
      $scope: scope,
	  currentAFE: currentAFEMock,
	  currentProject: currentProjectMock,
	  appReferences: appReferencesMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeHeaderCtrl.awesomeThings.length).toBe(3);
  });
});
