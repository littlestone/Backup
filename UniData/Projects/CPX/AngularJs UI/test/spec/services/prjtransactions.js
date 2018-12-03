'use strict';

describe('Service: prjTransactions', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var prjTransactions;
  beforeEach(inject(function (_prjTransactions_) {
    prjTransactions = _prjTransactions_;
  }));

  it('should do something', function () {
    expect(!!prjTransactions).toBe(true);
  });

});
