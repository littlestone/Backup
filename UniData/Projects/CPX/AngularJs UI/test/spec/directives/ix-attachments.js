'use strict';

describe('Directive: ixAttachments', function () {

  // load the directive's module
  beforeEach(module('cpxUiApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<ix-attachments></ix-attachments>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the ixAttachments directive');
  }));
});
