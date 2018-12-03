'use strict';

describe('Controller: ProjectAttachementsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectAttachementsCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectAttachementsCtrl = $controller('ProjectAttachementsCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectAttachementsCtrl.awesomeThings.length).toBe(3);
  });
});
