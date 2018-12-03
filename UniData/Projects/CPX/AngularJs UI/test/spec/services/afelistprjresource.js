'use strict';

describe('Service: afeListPrjResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeListPrjResource;
  beforeEach(inject(function (_afeListPrjResource_) {
    afeListPrjResource = _afeListPrjResource_;
  }));

  it('should do something', function () {
    expect(!!afeListPrjResource).toBe(true);
  });

});
