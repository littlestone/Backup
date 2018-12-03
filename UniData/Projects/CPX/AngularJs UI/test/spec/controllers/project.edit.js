'use strict';

describe('Controller: ProjectEditCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectEditCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectEditCtrl = $controller('ProjectEditCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectEditCtrl.awesomeThings.length).toBe(3);
  });
});
