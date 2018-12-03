'use strict';

describe('Controller: AfePosCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var AfePosCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    AfePosCtrl = $controller('AfePosCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(AfePosCtrl.awesomeThings.length).toBe(3);
  });
});
