'use strict';

describe('Controller: PhasingamountCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var PhasingamountCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    PhasingamountCtrl = $controller('PhasingamountCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(PhasingamountCtrl.awesomeThings.length).toBe(3);
  });
});
