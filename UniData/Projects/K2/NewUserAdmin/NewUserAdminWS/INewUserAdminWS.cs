using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Xml.Serialization;

namespace NewUserAdminWS
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface INewUserAdminWS
    {
        [OperationContract]
        string PrepareRequestServiceDataForWorkflow(string requestID);

        [OperationContract]
        string CheckRequestServiceTypeAccessRequired(string requestID, string serviceCategoryID);

        // TODO: Add your service operations here
    }


    // Use a data contract as illustrated in the sample below to add composite types to service operations.
    [DataContract]
    public class RequestService
    {
        [DataMember]
        public string RequestID { get; set; }
        [DataMember]
        public string EmployeeDataID { get; set; }
        [DataMember]
        public string ServiceCategoryID { get; set; }
        [DataMember]
        public string ServiceCategoryName { get; set; }
        [DataMember]
        public string ServiceTypeID { get; set; }
        [DataMember]
        public string ServiceTypeName { get; set; }
        [DataMember]
        public string ServiceID { get; set; }
        [DataMember]
        public string ServiceName { get; set; }
        [DataMember]
        public string ApproverUserID { get; set; }
        [DataMember]
        public int ApproverCount { get; set; }
        [DataMember]
        public string NotifierUserID { get; set; }
        [DataMember]
        public int NotifierCount { get; set; }
        [DataMember]
        public string OperatorUserID { get; set; }
        [DataMember]
        public int OperatorCount { get; set; }
    }
}
