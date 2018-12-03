'use strict';

describe('Service: prjListAccumulators', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjListAccumulators;
  beforeEach(inject(function (_prjListAccumulators_) {
    prjListAccumulators = _prjListAccumulators_;
  }));

  it('should do something', function () {
    expect(!!prjListAccumulators).toBe(true);
  });

});
