'use strict';

describe('Controller: BreadcrumbsMenuProjectCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var BreadcrumbsMenuProjectCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    BreadcrumbsMenuProjectCtrl = $controller('BreadcrumbsMenuProjectCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(BreadcrumbsMenuProjectCtrl.awesomeThings.length).toBe(3);
  });
});
