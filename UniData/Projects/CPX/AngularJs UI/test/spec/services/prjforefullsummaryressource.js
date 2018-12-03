'use strict';

describe('Service: prjForeFullSummaryRessource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjForeFullSummaryRessource;
  beforeEach(inject(function (_prjForeFullSummaryRessource_) {
    prjForeFullSummaryRessource = _prjForeFullSummaryRessource_;
  }));

  it('should do something', function () {
    expect(!!prjForeFullSummaryRessource).toBe(true);
  });

});
