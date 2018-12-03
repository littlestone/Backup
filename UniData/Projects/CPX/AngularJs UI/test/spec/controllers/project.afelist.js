'use strict';

describe('Controller: ProjectAfelistCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectAfelistCtrl,
    scope,
	currentProjectMoc;
	
	currentProjectMoc = [{id:0}];

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectAfelistCtrl = $controller('ProjectAfelistCtrl', {
      $scope: scope,
	  currentProject: currentProjectMoc
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectAfelistCtrl.awesomeThings.length).toBe(3);
  });
});
