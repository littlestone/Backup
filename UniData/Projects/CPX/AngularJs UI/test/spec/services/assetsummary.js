'use strict';

describe('Service: assetsummary', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var assetsummary;
  beforeEach(inject(function (_assetsummary_) {
    assetsummary = _assetsummary_;
  }));

  it('should do something', function () {
    expect(!!assetsummary).toBe(true);
  });

});
