'use strict';

describe('Service: ApiURLs', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var ApiURLs;
  beforeEach(inject(function (_ApiURLs_) {
    ApiURLs = _ApiURLs_;
  }));

  it('should do something', function () {
    expect(!!ApiURLs).toBe(true);
  });

});
