'use strict';

describe('Controller: AfeEditCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeEditCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeEditCtrl = $controller('AfeEditCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeEditCtrl.awesomeThings.length).toBe(3);
  });
});
