'use strict';

describe('Service: userInfoRessource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var userInfoRessource;
  beforeEach(inject(function (_userInfoRessource_) {
    userInfoRessource = _userInfoRessource_;
  }));

  it('should do something', function () {
    expect(!!userInfoRessource).toBe(true);
  });

});
