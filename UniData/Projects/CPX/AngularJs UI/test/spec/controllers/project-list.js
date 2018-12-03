'use strict';

describe('Controller: ProjectListCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectListCtrl,
    scope,
	appReferencesMock,
	appUsersMock;

	appUsersMock = {id:0, userName: 'CORP\abcdef'};
	
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
    ProjectListCtrl = $controller('ProjectListCtrl', {
      $scope: scope,
	  appReferences: appReferencesMock,
	  appUsers: appUsersMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectListCtrl.awesomeThings.length).toBe(3);
  });
});
