'use strict';

describe('Service: departmentsResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var departmentsResource;
  beforeEach(inject(function (_departmentsResource_) {
    departmentsResource = _departmentsResource_;
  }));

  it('should do something', function () {
    expect(!!departmentsResource).toBe(true);
  });

});
