'use strict';

describe('Service: res.ref.attachmentTypes', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var res.ref.attachmentTypes;
  beforeEach(inject(function (_res.ref.attachmentTypes_) {
    res.ref.attachmentTypes = _res.ref.attachmentTypes_;
  }));

  it('should do something', function () {
    expect(!!res.ref.attachmentTypes).toBe(true);
  });

});
