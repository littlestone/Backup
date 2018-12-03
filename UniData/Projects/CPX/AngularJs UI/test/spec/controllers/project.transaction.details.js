'use strict';

describe('Controller: ProjectTransactionDetailsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectTransactionDetailsCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectTransactionDetailsCtrl = $controller('ProjectTransactionDetailsCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectTransactionDetailsCtrl.awesomeThings.length).toBe(3);
  });
});
