'use strict';

describe('Controller: BreadcrumbsDirectiveSctiptCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var BreadcrumbsDirectiveSctiptCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    BreadcrumbsDirectiveSctiptCtrl = $controller('BreadcrumbsDirectiveSctiptCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(BreadcrumbsDirectiveSctiptCtrl.awesomeThings.length).toBe(3);
  });
});
