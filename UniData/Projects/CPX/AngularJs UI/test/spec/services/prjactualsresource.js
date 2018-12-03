'use strict';

describe('Service: prjActualsResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjActualsResource;
  beforeEach(inject(function (_prjActualsResource_) {
    prjActualsResource = _prjActualsResource_;
  }));

  it('should do something', function () {
    expect(!!prjActualsResource).toBe(true);
  });

});
