'use strict';

describe('Controller: ProjectTransactionsCtrl', function () {

  // load the controller's module
  beforeEach(module('cpxUiApp'));

  var ProjectTransactionsCtrl,
    scope,
	currentProjectMock;

  // Initialize the controller and a mock scope
  currentProjectMock = {id:0};

	// beforeEach(function(){
	  // module(function($provide){
		// $provide.service('prjTransactions', function(){
		  // this.query = jasmine.createSpy('query');
		// });
	  // });
	// });
 
	beforeEach(inject(function ($controller, $rootScope) {
		scope = $rootScope.$new();

		ProjectTransactionsCtrl = $controller('ProjectTransactionsCtrl', {
			$scope: scope, 
			currentProject: currentProjectMock
			});
		}));

		it('should attach a list of awesomeThings to the scope', function () {
		expect(ProjectTransactionsCtrl.awesomeThings.length).toBe(3);
	});
});
