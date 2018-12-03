'use strict';

describe('Controller: PrjoverviewCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var PrjoverviewCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    PrjoverviewCtrl = $controller('PrjoverviewCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(PrjoverviewCtrl.awesomeThings.length).toBe(3);
  });
});
