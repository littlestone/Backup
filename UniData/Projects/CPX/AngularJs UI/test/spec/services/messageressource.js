'use strict';

describe('Service: messageRessource', function () {

  // load the service's module
  beforeEach(module('cpxUiApp'));

  // instantiate service
  var messageRessource;
  beforeEach(inject(function (_messageRessource_) {
    messageRessource = _messageRessource_;
  }));

  it('should do something', function () {
    expect(!!messageRessource).toBe(true);
  });

});
