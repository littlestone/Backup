'use strict';

describe('Service: afeBudgetResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeBudgetResource;
  beforeEach(inject(function (_afeBudgetResource_) {
    afeBudgetResource = _afeBudgetResource_;
  }));

  it('should do something', function () {
    expect(!!afeBudgetResource).toBe(true);
  });

});
