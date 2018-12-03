'use strict';

describe('Service: companiesResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var companiesResource;
  beforeEach(inject(function (_companiesResource_) {
    companiesResource = _companiesResource_;
  }));

  it('should do something', function () {
    expect(!!companiesResource).toBe(true);
  });

});
