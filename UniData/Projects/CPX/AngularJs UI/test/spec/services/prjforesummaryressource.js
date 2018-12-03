'use strict';

describe('Service: prjForeSummaryRessource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjForeSummaryRessource;
  beforeEach(inject(function (_prjForeSummaryRessource_) {
    prjForeSummaryRessource = _prjForeSummaryRessource_;
  }));

  it('should do something', function () {
    expect(!!prjForeSummaryRessource).toBe(true);
  });

});
