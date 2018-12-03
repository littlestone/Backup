'use strict';

describe('Service: prjCategories', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjCategories;
  beforeEach(inject(function (_prjCategories_) {
    prjCategories = _prjCategories_;
  }));

  it('should do something', function () {
    expect(!!prjCategories).toBe(true);
  });

});
