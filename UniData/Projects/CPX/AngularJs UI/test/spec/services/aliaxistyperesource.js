'use strict';

describe('Service: aliaxisTypeResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var aliaxisTypeResource;
  beforeEach(inject(function (_aliaxisTypeResource_) {
    aliaxisTypeResource = _aliaxisTypeResource_;
  }));

  it('should do something', function () {
    expect(!!aliaxisTypeResource).toBe(true);
  });

});
