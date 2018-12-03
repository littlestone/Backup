'use strict';

describe('Service: res.ref.status', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var res.ref.status;
  beforeEach(inject(function (_res.ref.status_) {
    res.ref.status = _res.ref.status_;
  }));

  it('should do something', function () {
    expect(!!res.ref.status).toBe(true);
  });

});
