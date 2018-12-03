'use strict';

describe('Controller: AboutCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AboutCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AboutCtrl = $controller('AboutCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('Set this.testOk to true', function () {
    expect(AboutCtrl.testOk).toBe(true);
  });
  
});
