'use strict';

describe('Controller: DashboardCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var DashboardCtrl,
    scope,
	appUsersMock;

	appUsersMock = {id:0};
	
  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    DashboardCtrl = $controller('DashboardCtrl', {
      $scope: scope,
	  appUsers: appUsersMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(DashboardCtrl.awesomeThings.length).toBe(3);
  });
});
