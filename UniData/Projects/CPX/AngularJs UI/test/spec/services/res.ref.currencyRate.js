'use strict';

describe('Service: res.ref.currencyRate', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var res.ref.currencyRate;
  beforeEach(inject(function (_res.ref.currencyRate_) {
    res.ref.currencyRate = _res.ref.currencyRate_;
  }));

  it('should do something', function () {
    expect(!!res.ref.currencyRate).toBe(true);
  });

});
