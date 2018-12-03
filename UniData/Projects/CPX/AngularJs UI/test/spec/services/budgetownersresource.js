'use strict';

describe('Service: budgetOwnersResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var budgetOwnersResource;
  beforeEach(inject(function (_budgetOwnersResource_) {
    budgetOwnersResource = _budgetOwnersResource_;
  }));

  it('should do something', function () {
    expect(!!budgetOwnersResource).toBe(true);
  });

});
