'use strict';

describe('Service: prjBudgetResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjBudgetResource;
  beforeEach(inject(function (_prjBudgetResource_) {
    prjBudgetResource = _prjBudgetResource_;
  }));

  it('should do something', function () {
    expect(!!prjBudgetResource).toBe(true);
  });

});
