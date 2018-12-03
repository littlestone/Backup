'use strict';

describe('Service: projectsResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var projectsResource;
  beforeEach(inject(function (_projectsResource_) {
    projectsResource = _projectsResource_;
  }));

  it('should do something', function () {
    expect(!!projectsResource).toBe(true);
  });

});
