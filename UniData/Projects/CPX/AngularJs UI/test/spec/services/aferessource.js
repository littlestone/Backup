'use strict';

describe('Service: afeRessource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var afeRessource;
  beforeEach(inject(function (_afeRessource_) {
    afeRessource = _afeRessource_;
  }));

  it('should do something', function () {
    expect(!!afeRessource).toBe(true);
  });

});
