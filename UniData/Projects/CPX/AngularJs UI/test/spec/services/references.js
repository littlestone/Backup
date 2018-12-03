'use strict';

describe('Service: references', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var references;
  beforeEach(inject(function (_references_) {
    references = _references_;
  }));

  it('should do something', function () {
    expect(!!references).toBe(true);
  });

});
