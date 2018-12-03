'use strict';

describe('Controller: ProjectDetailsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectDetailsCtrl,
    scope,
	currentProjectMock,
	appReferencesMock;

	currentProjectMock = {estimatedCompletionDt: new Date()};
	
	appReferencesMock = {
		companies: [{}],
		departments: [{}],
		locations: [{}],
		aliaxisCategories: [{}],
		aliaxisTypes: [{}],
		priorities: [{}]
	};
	
  //Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectDetailsCtrl = $controller('ProjectDetailsCtrl', {
      $scope: scope,
	  currentProject: currentProjectMock,
	  appReferences: appReferencesMock
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectDetailsCtrl.awesomeThings.length).toBe(3);
  });
});
