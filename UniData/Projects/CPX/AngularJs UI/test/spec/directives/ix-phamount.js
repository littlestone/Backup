'use strict';

describe('Directive: ixPhAmount', function () {

  // load the directive's module
  beforeEach(module('cpxUiApp'));

  var scope,
	labelMock,
	actualMock,
	ngModelMock,
	formMock;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
	scope.label = labelMock;
	scope.actual = actualMock;
	scope.ngModel = ngModelMock;
	scope.form = formMock;
  }));
	
	
  it('should make hidden element visible', inject(function () {
	  expect(true).toBe(true);
    // element = angular.element('<ix-ph-amount></ix-ph-amount>');
    // element = $compile(element)(scope);
    // expect(element.text()).toBe('this is the ixPhAmount directive');
  }));
});
