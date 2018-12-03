'use strict';

describe('Controller: AfeDetailsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeDetailsCtrl,
    scope,
	currentAFEMock;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeDetailsCtrl = $controller('AfeDetailsCtrl', {
      $scope: scope,
	  currentAFE: currentAFEMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeDetailsCtrl.awesomeThings.length).toBe(3);
  });
});
