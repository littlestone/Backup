'use strict';

describe('Service: actionItemressource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var actionItemressource;
  beforeEach(inject(function (_actionItemressource_) {
    actionItemressource = _actionItemressource_;
  }));

  it('should do something', function () {
    expect(!!actionItemressource).toBe(true);
  });

});
