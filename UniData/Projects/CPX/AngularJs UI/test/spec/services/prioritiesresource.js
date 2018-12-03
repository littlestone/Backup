'use strict';

describe('Service: prioritiesResource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prioritiesResource;
  beforeEach(inject(function (_prioritiesResource_) {
    prioritiesResource = _prioritiesResource_;
  }));

  it('should do something', function () {
    expect(!!prioritiesResource).toBe(true);
  });

});
