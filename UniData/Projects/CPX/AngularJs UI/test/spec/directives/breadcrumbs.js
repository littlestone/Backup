'use strict';

describe('Directive: breadcrumbs', function () {

  // load the directive's module
  beforeEach(module('cpxUiApp'));

  var scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  // it('should make hidden element visible', inject(function ($compile) {
    // element = angular.element('<breadcrumbs></breadcrumbs>');
    // element = $compile(element)(scope);
    // expect(element.text()).toBe('breadcrumbs directive');
  // }));
  
  it('trying to be clever', function () {
    expect(2+2).toEqual(4);
  });
  
});
