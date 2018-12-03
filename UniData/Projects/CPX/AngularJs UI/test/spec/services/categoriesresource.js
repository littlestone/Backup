'use strict';

describe('Service: categoriesResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var categoriesResource;
  beforeEach(inject(function (_categoriesResource_) {
    categoriesResource = _categoriesResource_;
  }));

  it('should do something', function () {
    expect(!!categoriesResource).toBe(true);
  });

});
