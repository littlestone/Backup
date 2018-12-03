'use strict';

describe('Service: prjForecastEachResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjForecastEachResource;
  beforeEach(inject(function (_prjForecastEachResource_) {
    prjForecastEachResource = _prjForecastEachResource_;
  }));

  it('should do something', function () {
    expect(!!prjForecastEachResource).toBe(true);
  });

});
