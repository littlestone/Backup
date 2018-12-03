'use strict';

describe('Service: prjShortListResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjShortListResource;
  beforeEach(inject(function (_prjShortListResource_) {
    prjShortListResource = _prjShortListResource_;
  }));

  it('should do something', function () {
    expect(!!prjShortListResource).toBe(true);
  });

});
