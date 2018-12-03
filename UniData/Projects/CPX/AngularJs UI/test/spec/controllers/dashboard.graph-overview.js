'use strict';

describe('Controller: GraphOverviewCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var GraphOverviewCtrl,
    scope,
	appUsersMock;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    GraphOverviewCtrl = $controller('GraphOverviewCtrl', {
      $scope: scope,
	  appUsers: appUsersMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(GraphOverviewCtrl.awesomeThings.length).toBe(3);
  });
});
