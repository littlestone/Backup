'use strict';

angular.module('cpxUiApp')
  .controller('UserAdminCtrl', function(resUserRoles, svToast, resUserInfo, $mdDialog, resUsers, svDialog, svApiURLs, $http) {
    var cUserAdmin = this;

    cUserAdmin.fetching = false;
    cUserAdmin.editMode = false;
    cUserAdmin.roles = [];

    cUserAdmin.newUserData = null;

    var getUsers = function() {
      resUsers.query(function(data) {
        cUserAdmin.CPXUsers = data;
        cUserAdmin.selectedUser = cUserAdmin.CPXUsers[0];
        cUserAdmin.fetchUserData(cUserAdmin.selectedUser.userName);
        refreshRoles();
      });
    };

    getUsers();

    var refreshRoles = function() {

      var userRoles = 0;
      var rMax = cUserAdmin.selectedUser.userRoles.length;

      if (rMax > 60){
        //Maximum of 60 roles
        rMax = 60;
      }

      if (rMax>0){
        for (var r=0; r<rMax; r++) {
          userRoles = userRoles + Math.pow(2,parseInt(cUserAdmin.selectedUser.userRoles[r].id));
        }
      }

      var max = 0;
      var i = 0;

      if ((typeof cUserAdmin.allRoles === 'undefined')) {
        resUserRoles.query(function (data) {
          cUserAdmin.allRoles = data;

          max = cUserAdmin.allRoles.length;

          for (i=0; i<max; i++) {
            cUserAdmin.roles[i] = {
              id: cUserAdmin.allRoles[i].id,
              name: cUserAdmin.allRoles[i].name,
              selected: ((parseInt(userRoles) & Math.pow(2,parseInt(cUserAdmin.allRoles[i].id))) === Math.pow(2,parseInt(cUserAdmin.allRoles[i].id)))
            };
          }
        });
      }
      else {
        //No need to fetch from the backend. Just update the selected roles
        max = cUserAdmin.allRoles.length;
        for (i=0; i<max; i++) {
          cUserAdmin.roles[i].selected =((parseInt(userRoles) & Math.pow(2,parseInt(cUserAdmin.allRoles[i].id))) === Math.pow(2,parseInt(cUserAdmin.allRoles[i].id)));
        }
      }
    };

    cUserAdmin.fetchUserData = function(userName) {
      cUserAdmin.fetching = true;

      resUserInfo.get({userName: userName}, function(data) {
        cUserAdmin.selectedUser = data;
        refreshRoles();
        cUserAdmin.fetching = false;
      });
    };

    cUserAdmin.addUser = function() {
      cUserAdmin.selectedUser = {
        id: '',
        displayName: '',
        title: '',
        userName: '',
        managerAccountName: '',
        managerDisplayName: '',
        managerUserName: '',
        userRoles: [{id: 0, name: 'Guest'}]
      };

      refreshRoles();
      cUserAdmin.editMode = true;
    };

    cUserAdmin.cancel = function() {
      if (cUserAdmin.CPXUsers.length>0) {
        cUserAdmin.fetchUserData(cUserAdmin.CPXUsers[0].userName);
      }
      else {
        cUserAdmin.selectedUser = {
          id: '',
          displayName: '',
          title: '',
          userName: '',
          managerAccountName: '',
          managerDisplayName: '',
          managerUserName: '',
          userRoles: [{id: 0, name: 'Guest'}]
        };
      }
      refreshRoles();
      cUserAdmin.editMode = false;
      svToast.showSimpleToast('Cancelled');
    };

    cUserAdmin.findUser = function(ev) {
      cUserAdmin.selectedUser = {
        id: '',
        displayName: '',
        title: '',
        userName: '',
        managerAccountName: '',
        managerDisplayName: '',
        managerUserName: '',
        userRoles: [{id: 0, name: 'Guest'}]
      };

      refreshRoles();

      cUserAdmin.editMode = true;

      $mdDialog.show({
        controller: 'newUserDialogCtrl',
        templateUrl: 'views/templates/users.new.dialog.html',
        parent: angular.element(document.body),
        targetEvent: ev
      }) .then(function(answer) {
        if(answer.userName.length > 0){
          cUserAdmin.fetchUserData(answer.userName);
        }
      }, function() {
        //cancelled
      });
    };

    cUserAdmin.setEditMode = function() {
      cUserAdmin.editMode = true;
    };

    cUserAdmin.save = function() {
      var max = cUserAdmin.allRoles.length;
      var selectedRoles = [];

      for (var i=0; i<max; i++) {
        if(cUserAdmin.roles[i].selected) {
          selectedRoles.push(cUserAdmin.roles[i].id);
        }
      }

      var data = {
        'userName': cUserAdmin.selectedUser.userName,
        'roles': selectedRoles
      };

      $http({
        method: 'PUT',
        url: svApiURLs.roleUser,
        data: JSON.stringify(data),
        headers: {'Content-Type': 'application/json'}
      }).then(
        function () {
          svToast.showSimpleToast('Data Saved');
        }, function (response) {
          var tmsg = response.data;
          var msg = tmsg.substring(tmsg.indexOf('!ERRORMESSAGE!') + 15, tmsg.indexOf('!/ERRORMESSAGE!') - 1);

          svDialog.showSimpleDialog(
            msg.substring(msg.indexOf(':') + 1),
            'Error - ' + msg.substring(0, msg.indexOf(':'))
          );
        }
      );
      cUserAdmin.editMode = false;
    };
  });
