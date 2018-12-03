'use strict';

describe('Service: afeShortListResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeShortListResource;
  beforeEach(inject(function (_afeShortListResource_) {
    afeShortListResource = _afeShortListResource_;
  }));

  it('should do something', function () {
    expect(!!afeShortListResource).toBe(true);
  });

});
