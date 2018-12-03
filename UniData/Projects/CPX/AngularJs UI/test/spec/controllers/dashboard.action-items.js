'use strict';

describe('Controller: ActionItemsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ActionItemsCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ActionItemsCtrl = $controller('ActionItemsCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ActionItemsCtrl.awesomeThings.length).toBe(3);
  });
});
