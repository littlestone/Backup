'use strict';

describe('Controller: BreadcrumbsMenuAfeCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var BreadcrumbsMenuAfeCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    BreadcrumbsMenuAfeCtrl = $controller('BreadcrumbsMenuAfeCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(BreadcrumbsMenuAfeCtrl.awesomeThings.length).toBe(3);
  });
});
