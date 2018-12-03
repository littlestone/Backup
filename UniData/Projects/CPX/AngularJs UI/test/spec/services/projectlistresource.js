'use strict';

describe('Service: projectListResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var projectListResource;
  beforeEach(inject(function (_projectListResource_) {
    projectListResource = _projectListResource_;
  }));

  it('should do something', function () {
    expect(!!projectListResource).toBe(true);
  });

});
