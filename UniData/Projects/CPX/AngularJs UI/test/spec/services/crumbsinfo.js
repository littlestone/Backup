'use strict';

describe('Service: crumbsInfo', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var crumbsInfo;
  beforeEach(inject(function (_crumbsInfo_) {
    crumbsInfo = _crumbsInfo_;
  }));

  it('should do something', function () {
    expect(!!crumbsInfo).toBe(true);
  });

});
