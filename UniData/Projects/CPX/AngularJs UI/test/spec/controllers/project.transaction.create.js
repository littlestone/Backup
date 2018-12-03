'use strict';

describe('Controller: ProjectTransactionCreateCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectTransactionCreateCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProjectTransactionCreateCtrl = $controller('ProjectTransactionCreateCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ProjectTransactionCreateCtrl.awesomeThings.length).toBe(3);
  });
});
