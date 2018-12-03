'use strict';

describe('Controller: AfeActionCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeActionCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeActionCtrl = $controller('AfeActionCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeActionCtrl.awesomeThings.length).toBe(3);
  });
});
