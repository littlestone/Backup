'use strict';

describe('Service: locationsResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var locationsResource;
  beforeEach(inject(function (_locationsResource_) {
    locationsResource = _locationsResource_;
  }));

  it('should do something', function () {
    expect(!!locationsResource).toBe(true);
  });

});
