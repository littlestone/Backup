'use strict';

describe('Controller: AfeAssetsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeAssetsCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeAssetsCtrl = $controller('AfeAssetsCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeAssetsCtrl.awesomeThings.length).toBe(3);
  });
});
