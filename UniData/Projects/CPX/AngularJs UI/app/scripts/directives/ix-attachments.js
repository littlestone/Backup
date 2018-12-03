'use strict';

/**
 * @ngdoc directive
 * @name cpxUiApp.directive:ixAttachments
 * @description
 * # ixAttachments
 */
angular.module('cpxUiApp')
  .directive('ixAttachments', function() {
    return {
      // templateUrl: 'views/templates/test.html',
      templateUrl: 'views/templates/attachments.html',
      controller: 'ixAttachmentsCtrl',
      restrict: 'E',
      replace: true,
      scope: {
        entityTypeId: '@',
        entityRecordId: '@',
        attachmentTypeId: '@',
        userid: '@',
        uploadEnabled: '=',
        downloadEnabled: '=',
        deleteEnabled: '=',
        ngModel: '='
      },
      link: function postLink(scope, element, attrs) {
        // scope.$watch('files.lfFileName', function(newVal, oldVal) {
        //   if (scope.files !== undefined) {
        //     console.log(scope.files);
        //     console.log(scope.files.lfFileName);
        //   }
        // }, true);
      }
    };
  })
  .controller('ixAttachmentsCtrl', function($q, $http, $resource, $timeout, $scope, $filter, $mdDialog, FileSaver, Blob, svDialog, svToast, svApiURLs, resAttachmentTypes) {
    $scope.selectedAttachmentTypeId = 1;
    // $scope.attachmentType = [
    //   {id: 1, description: 'General Attachment'},
    //   {id: 2, description: 'Financial Attachment'},
    //   {id: 3, description: 'Business Cases / Project Updates Attachment'}
    // ];
    $scope.attachmentType = resAttachmentTypes.query();

    var fileName = '';
    $scope.fileDescription = '';
    $scope.showAttach = false;
    $scope.inProgress = false;
    $scope.isReady = false;
    $scope.isEmpty = false;

    // get attachments info by current entity type id
    function getAttachmentsByEntityTypeId(id) {
      var url = svApiURLs.Attachment + id;
      return $resource(
        url,
        {isEntityTypeId:true},
        {'query':  {method:'GET', isArray:true}}
      ).query(function() {  // GET: /attachment/3?isEntityTypeId=true
      }, function(error) {  // error handler
        svDialog.showSimpleDialog($filter('json')(error.data), 'Error');
        $mdDialog.hide();
      });
    }
    $scope.curAttachments = getAttachmentsByEntityTypeId($scope.entityTypeId);

    // function to upload attachment to SQL server through Web API
    function uploadAttachment() {
      $scope.inProgress = true;

      var formData = new FormData();
      formData.append('EntityTypeId', $scope.entityTypeId || '');
      formData.append('EntityRecordId', $scope.entityRecordId || '');
      formData.append('AttachmentId', null);
      formData.append('AttachmentTypeId', $scope.selectedAttachmentTypeId || '');
      formData.append('FileDescription', $scope.fileDescription || '');
      formData.append('UserId', $scope.userid || '');
      angular.forEach($scope.files, function(obj) {
        if (!obj.isRemote) {
          fileName = obj.lfFileName;
          formData.append('attachments', obj.lfFile);
        }
      });

      var deferred = $q.defer();
      var url = svApiURLs.Attachment;
      var request = {
        'url': url,
        'method': 'POST',
        'data': formData,
        'headers': {
          'Content-Type' : undefined // important
        }
      };

      $http(request).then(function successCallback(response) {
        $scope.curAttachments = getAttachmentsByEntityTypeId($scope.entityTypeId);
        $scope.fileDescription = '';
        $scope.inProgress = false;
        deferred.resolve(response);
        svToast.showSimpleToast('Attachment "' + fileName + '" has been saved successfully.');
      }, function errorCallback(error) {
        $scope.inProgress = false;
        svDialog.showSimpleDialog($filter('json')(error.data), 'Error');
        $mdDialog.hide();
      });

      return deferred.promise;
    }

    // function to download attachment from SQL server through Web API
    function downloadAttachment(id) {
      $scope.inProgress = true;

      var deferred = $q.defer();
      var url = svApiURLs.Attachment + id;
      // url = 'http://localhost:56466/api/data/attachment/' + id;
      $http.get(url, {responseType:'blob'}).then(function successCallback(response) {
        $scope.inProgress = false;
        deferred.resolve(response);

        var contentDispositionHeader = response.headers('Content-Disposition');
        var contentType = response.headers('Content-Type');
        var fileName = response.headers('x-filename');
        var data = new Blob([response.data], {type: contentType + ';charset=UTF-8'});

        FileSaver.saveAs(data, fileName);
        svToast.showSimpleToast('Attachment "' + fileName + '" has been downloaded successfully.');
      }, function errorCallback(error) {
        $scope.inProgress = false;
        svDialog.showSimpleDialog($filter('json')(error.data), 'Error');
        $mdDialog.hide();
      });

      return deferred.promise;
    }

    // function to delete attachment on SQL server through Web API
    function deleteAttachment(id) {
      $scope.inProgress = true;

      var deferred = $q.defer();
      var url = svApiURLs.Attachment;
      var fileName = function() {
        for (var i = 0; i < $scope.curAttachments.length; i++) {
          if ($scope.curAttachments[i].id === id) {
            return $scope.curAttachments[i].fileName;
          }
          return null;
        }
      }();
      // var fileName = $scope.curAttachments.find(x => x.id === id).fileName;  // ES6

      // $http.delete(url, {params: {id: id, userid: $scope.userid}}).then(function successCallback(response) {
      $http.delete(url + id + '/' + $scope.userid, null).then(function successCallback(response) {
        $scope.curAttachments = getAttachmentsByEntityTypeId($scope.entityTypeId);
        $scope.inProgress = false;
        deferred.resolve(response);
        svToast.showSimpleToast('Attachment "' + fileName + '" has been deleted successfully.');
      }, function errorCallback(error) {
        $scope.inProgress = false;
        svDialog.showSimpleDialog($filter('json')(error.data), 'Error');
        $mdDialog.hide();
      });
    }

    $scope.upload = function() {
      if ($scope.attachmentsForm.$valid) {
        $scope.showConfirm('upload');
      }
    };

    $scope.download = function(id) {
      $scope.showConfirm('download', id);
    };

    $scope.delete = function(id) {
      $scope.showConfirm('delete', id);
    };

    $scope.showConfirm = function(action, id) {
      var confirm = $mdDialog.confirm({onComplete: function afterShowAnimation() {
        // var $dialog = angular.element(document.querySelector('md-dialog'));
        // var $actionsSection = $dialog.find('md-dialog-actions');
        // var $cancelButton = $actionsSection.children()[0];
        // var $confirmButton = $actionsSection.children()[1];
        // angular.element($confirmButton).removeClass('md-focused');
        // angular.element($cancelButton).addClass('md-focused');
        // $cancelButton.focus();
      }})
          .title('Confirmation')
          .textContent('Are you sure to proceed?')
          .ariaLabel('Lucky day')
          .ok('Yes')
          .cancel('No')
          .multiple(true);
      $mdDialog.show(confirm).then(function() {
        switch(action) {
          case 'upload':
            uploadAttachment();
            break;
          case 'download':
            downloadAttachment(id);
            break;
          case 'delete':
            deleteAttachment(id);
            break;
        }
        $scope.lfApi.removeAll();  // reset the contents of file input
      }, function() {
        // nop
      });
    };
  });

// angular.module('cpxUiApp')
//   .directive('draggable', function() {
//     return {
//       // A = attribute, E = Element, C = Class and M = HTML Comment
//       restrict: 'A',
//       //The link function is responsible for registering DOM listeners as well as updating the DOM.
//       link: function(scope, element, attrs) {
//         element.draggable({
//           stop: function(event, ui) {
//             // console.log("Check if its printing")
//             event.stopPropagation();
//           }
//         });
//       }
//     };
//   });
