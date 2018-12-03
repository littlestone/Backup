'use strict';

describe('Controller: MessagesCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var MessagesCtrl,
    scope,
	appUsersMock;

	appUsersMock = {id:0};

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    MessagesCtrl = $controller('MessagesCtrl', {
      $scope: scope,
	  appUsers: appUsersMock
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(MessagesCtrl.awesomeThings.length).toBe(3);
  });
});
