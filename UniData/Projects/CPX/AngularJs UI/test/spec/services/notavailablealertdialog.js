'use strict';

describe('Service: notAvailableAlertDialog', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var notAvailableAlertDialog;
  beforeEach(inject(function (_notAvailableAlertDialog_) {
    notAvailableAlertDialog = _notAvailableAlertDialog_;
  }));

  it('should do something', function () {
    expect(!!notAvailableAlertDialog).toBe(true);
  });

});
