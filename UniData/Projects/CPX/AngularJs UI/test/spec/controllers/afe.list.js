'use strict';

describe('Controller: AfeListCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfeListCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfeListCtrl = $controller('AfeListCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfeListCtrl.awesomeThings.length).toBe(3);
  });
});
