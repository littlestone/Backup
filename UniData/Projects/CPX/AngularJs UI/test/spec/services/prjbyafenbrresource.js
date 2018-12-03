'use strict';

describe('Service: prjByAfeNbrResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjByAfeNbrResource;
  beforeEach(inject(function (_prjByAfeNbrResource_) {
    prjByAfeNbrResource = _prjByAfeNbrResource_;
  }));

  it('should do something', function () {
    expect(!!prjByAfeNbrResource).toBe(true);
  });

});
