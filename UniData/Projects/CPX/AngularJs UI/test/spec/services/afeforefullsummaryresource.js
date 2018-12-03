'use strict';

describe('Service: afeForeFullSummaryResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeForeFullSummaryResource;
  beforeEach(inject(function (_afeForeFullSummaryResource_) {
    afeForeFullSummaryResource = _afeForeFullSummaryResource_;
  }));

  it('should do something', function () {
    expect(!!afeForeFullSummaryResource).toBe(true);
  });

});
