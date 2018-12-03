'use strict';

describe('Service: prjForecastResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjForecastResource;
  beforeEach(inject(function (_prjForecastResource_) {
    prjForecastResource = _prjForecastResource_;
  }));

  it('should do something', function () {
    expect(!!prjForecastResource).toBe(true);
  });

});
