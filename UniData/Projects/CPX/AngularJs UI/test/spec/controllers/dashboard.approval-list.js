'use strict';

describe('Controller: ApprovalListCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ApprovalListCtrl,
    scope,
	appUsersMock;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ApprovalListCtrl = $controller('ApprovalListCtrl', {
      $scope: scope,
	  appUsers: appUsersMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ApprovalListCtrl.awesomeThings.length).toBe(3);
  });
});
