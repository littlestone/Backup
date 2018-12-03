'use strict';

describe('Service: afeForecastResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeForecastResource;
  beforeEach(inject(function (_afeForecastResource_) {
    afeForecastResource = _afeForecastResource_;
  }));

  it('should do something', function () {
    expect(!!afeForecastResource).toBe(true);
  });

});
