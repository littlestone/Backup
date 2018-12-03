'use strict';

describe('Service: aliaxisCategoriesResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var aliaxisCategoriesResource;
  beforeEach(inject(function (_aliaxisCategoriesResource_) {
    aliaxisCategoriesResource = _aliaxisCategoriesResource_;
  }));

  it('should do something', function () {
    expect(!!aliaxisCategoriesResource).toBe(true);
  });

});
