'use strict';

describe('Service: afeActualsResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeActualsResource;
  beforeEach(inject(function (_afeActualsResource_) {
    afeActualsResource = _afeActualsResource_;
  }));

  it('should do something', function () {
    expect(!!afeActualsResource).toBe(true);
  });

});
