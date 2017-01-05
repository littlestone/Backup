using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Linq;
using System.Xml.Linq;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Web.Configuration;
using SourceCode.Hosting.Client.BaseAPI;
using SourceCode.SmartObjects.Client;
using SourceCode.SmartObjects.Client.Filters;
using SourceCode.Data.SmartObjectsClient;


namespace NewUserAdminWS
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "NewUserAdminWS" in code, svc and config file together.
    // NOTE: In order to launch WCF Test Client for testing this service, please select NewUserAdminWS.svc or NewUserAdminWS.svc.cs at the Solution Explorer and start debugging.
    public class NewUserAdminWS : INewUserAdminWS
    {
        public string PrepareRequestServiceDataForWorkflow(string requestID)
        {
            try
            {
                #region Connect to K2 server
                SmartObjectClientServer server = new SmartObjectClientServer();
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());
                #endregion

                using (server.Connection)
                {
                    try
                    {
                        #region Setup SmartObject

                        SmartObject ipexADUserRoleSO = server.GetSmartObject("IPEX_AD_GetUserRole");
                        SmartListMethod ipexADUserRoleList = ipexADUserRoleSO.ListMethods["List"];
                        ipexADUserRoleSO.MethodToExecute = ipexADUserRoleList.Name;

                        SmartObject ipexADUserSO = server.GetSmartObject("IPEX_AD_GetUsers");
                        SmartListMethod ipexADUserList = ipexADUserSO.ListMethods["List"];
                        ipexADUserSO.MethodToExecute = ipexADUserList.Name;
                        Equals ipexADUserEqual = new Equals();

                        SmartObject approverRoleSO = server.GetSmartObject("IPEX_NewUserAdmin_ApproverRoleSO");
                        SmartListMethod approverRoleList = approverRoleSO.ListMethods["GetList"];
                        approverRoleSO.MethodToExecute = approverRoleList.Name;
                        Equals approverRoleEqual = new Equals();

                        SmartObject serviceRequestHeaderSO = server.GetSmartObject("IPEX_NewUserAdmin_ServiceRequestHeaderSO");
                        serviceRequestHeaderSO.MethodToExecute = "Load";

                        SmartObject employeeDataSO = server.GetSmartObject("IPEX_NewUserAdmin_EmployeeDataSO");
                        employeeDataSO.MethodToExecute = "Load";

                        SmartObject serviceCategorySO = server.GetSmartObject("IPEX_NewUserAdmin_ServiceCategorySO");
                        serviceCategorySO.MethodToExecute = "Load";

                        SmartObject serviceTypeSO = server.GetSmartObject("IPEX_NewUserAdmin_ServiceTypeSO");
                        serviceTypeSO.MethodToExecute = "Load";

                        SmartObject serviceSO = server.GetSmartObject("IPEX_NewUserAdmin_ServiceSO");
                        serviceSO.MethodToExecute = "Load";

                        SmartObject workflowCheckListSO = server.GetSmartObject("IPEX_NewUserAdmin_WorkflowCheckListSO");
                        workflowCheckListSO.MethodToExecute = "Create";

                        SmartObject approvalCheckListSO = server.GetSmartObject("IPEX_NewUserAdmin_ApprovalCheckListSO");
                        approvalCheckListSO.MethodToExecute = "Create";

                        SmartObject notificationCheckListSO = server.GetSmartObject("IPEX_NewUserAdmin_NotificationCheckListSO");
                        notificationCheckListSO.MethodToExecute = "Create";

                        SmartObject implementationCheckListSO = server.GetSmartObject("IPEX_NewUserAdmin_ImplementationCheckListSO");
                        implementationCheckListSO.MethodToExecute = "Create";

                        #endregion

                        #region Load IPEX_NewUserAdmin_ServiceRequestHeaderSO Data

                        serviceRequestHeaderSO.Properties["ID"].Value = requestID;                                                  // Set key property
                        serviceRequestHeaderSO = server.ExecuteScalar(serviceRequestHeaderSO);                                      // Call the scalar method load the request data
                        string employeeDataID = serviceRequestHeaderSO.Properties["IPEX_NewUserAdmin_EmployeeDataSO_ID"].Value;     // Read EmployeeDataID
                        string xmlServiceAccessRequired = serviceRequestHeaderSO.Properties["ServiceAccessRequired"].Value;         // Read ServiceAccessRequired XML data string

                        #endregion

                        #region Load IPEX_NewUserAdmin_EmployeeDataSO Data

                        // Get Employee Data
                        employeeDataSO.Properties["ID"].Value = employeeDataID;                             // Set key property
                        employeeDataSO = server.ExecuteScalar(employeeDataSO);                              // Call the scalar method load the request data
                        string employeeUserID = employeeDataSO.Properties["UserId"].Value;                  // Get employee's UserId (AD)
                        string directManagerUserID = employeeDataSO.Properties["ImmediateManager"].Value;   // Get immediate manager userID

                        #endregion

                        #region Retrieve Each Request Service Item From The XML Document
                        List<RequestService> requestServiceList = new List<RequestService>();
                        List<String> serviceRequiredList = new List<String>();
                        string[] requestServiceHierachy = { };
                        string serviceCategoryID = "", serviceTypeID = "", serviceID = "";
                        string serviceCategoryName = "", serviceTypeName = "", serviceName = "";
                        string approverUserIDList = "", notifierUserIDList = "", operatorUserIDList = "";
                        string xmlApproverRoleCode = "", approverRoleCode = "", approverRoleUserId = "";
                        string subElementString = "";
                        int approverCount = 0, notifierCount = 0, operatorCount = 0, level = 0, approverRoleXrfId = 0;

                        // Parse ServcieAccessRequired xml document to get unique service access required element list
                        XDocument docService = XDocument.Parse(xmlServiceAccessRequired);
                        {
                            // first pass for accumulating level 3 element(s)
                            foreach (XElement serviceElement in docService.Descendants("field")) 
                            {
                                // Tree node level parser
                                requestServiceHierachy = serviceElement.Value.Split('|');

                                // Skip node with only ServiceCategory
                                level = requestServiceHierachy.Count();
                                if (level == 1 || level == 2)
                                    continue;
                                else if (level == 3)
                                    subElementString = requestServiceHierachy[0] + "|" + requestServiceHierachy[1] + "|" + requestServiceHierachy[2];

                                // Build service element list with unique ServiceType                            
                                if (level == 3 && !serviceRequiredList.Any(str => str.Contains(subElementString)))
                                    serviceRequiredList.Add(serviceElement.Value);
                                else
                                    continue;
                            }

                            // second pass for accumulating level 2 element(s)
                            foreach (XElement serviceElement in docService.Descendants("field")) 
                            {
                                // Tree node level parser
                                requestServiceHierachy = serviceElement.Value.Split('|');

                                // Skip node with only ServiceCategory
                                level = requestServiceHierachy.Count();
                                if (level == 1 || level == 3)
                                    continue;
                                else if (level == 2)
                                    subElementString = requestServiceHierachy[0] + "|" + requestServiceHierachy[1];

                                // Build service element list with unique ServiceType                            
                                if (!serviceRequiredList.Any(str => str.Contains(subElementString)))
                                    serviceRequiredList.Add(serviceElement.Value);
                                else
                                    continue;
                            }
                        }

                        // Populate Approval Process Data
                        foreach (String serviceElement in serviceRequiredList)
                        {
                            // Tree node level parser
                            requestServiceHierachy = serviceElement.Split('|');
                            level = requestServiceHierachy.Count();

                            // Get ServiceCategory SmartObject Data
                            serviceCategoryID = requestServiceHierachy[0].Split(',')[0];
                            serviceCategorySO.Properties["ID"].Value = serviceCategoryID;
                            serviceCategorySO = server.ExecuteScalar(serviceCategorySO);
                            serviceCategoryName = serviceCategorySO.Properties["ServiceCategoryName"].Value;

                            // [TODO] bypass mobile device throught parameter 
                            if (serviceCategoryID == "3") continue; // (patch for demo purpose)

                            // Get ServiceType SmartObject Data                            
                            serviceTypeID = requestServiceHierachy[1].Split(',')[0];
                            serviceTypeSO.Properties["ID"].Value = serviceTypeID;
                            serviceTypeSO = server.ExecuteScalar(serviceTypeSO);
                            serviceTypeName = serviceTypeSO.Properties["serviceTypeName"].Value;

                            #region Get Approver(s)/Notifier(s)/Operator(s)
                            if (level >= 2)
                            {
                                // For the approver(s) with special role assigned, logic to determine the role based on given employee userid through AD hierachy
                                xmlApproverRoleCode = serviceTypeSO.Properties["ApproverRoleCode"].Value;
                                XDocument docApproverRoleCode = XDocument.Parse(xmlApproverRoleCode);
                                foreach (XElement approverRoleCodeElement in docApproverRoleCode.Descendants("field"))
                                {
                                    // Get approver role cross reference id (K2 SQL Server: [K2Dev_Content].[IPEX].[Role] table)
                                    approverRoleCode = approverRoleCodeElement.Value;
                                    approverRoleEqual.Left = new PropertyExpression("ApproverRoleCode", PropertyType.Number);
                                    approverRoleEqual.Right = new ValueExpression(approverRoleCode, PropertyType.Number);
                                    approverRoleList.Filter = approverRoleEqual;
                                    SmartObjectList approverRoleSOList = server.ExecuteList(approverRoleSO);
                                    approverRoleXrfId = Int32.Parse(approverRoleSOList.SmartObjectsList[0].Properties[3].Value);

                                    // Get approver role userid from AD
                                    ipexADUserRoleSO.AllMethods[0].InputProperties["ad_name"].Value = employeeUserID;
                                    ipexADUserRoleSO.AllMethods[0].InputProperties["role_id"].Value = approverRoleXrfId.ToString();
                                    SmartObjectList ipexADUserRoleSOList = server.ExecuteList(ipexADUserRoleSO);
                                    if (ipexADUserRoleSOList.SmartObjectsList.Count == 0)
                                        throw new Exception("Unable to resolve the approver userid { " + approverRoleCode + " : " + employeeUserID + ", " + approverRoleXrfId + " }");
                                    approverRoleUserId = ipexADUserRoleSOList.SmartObjectsList[0].Properties[2].Value;

                                    // Build approver userid list
                                    if (approverUserIDList == "")
                                        approverUserIDList = approverRoleUserId;
                                    else
                                        approverUserIDList += ";" + approverRoleUserId;
                                    continue;
                                }

                                // For specific approver(s) without special role assigned
                                if (approverUserIDList == "")
                                    approverUserIDList = serviceTypeSO.Properties["ApproverUserID"].Value;
                                else if (serviceTypeSO.Properties["ApproverUserID"].Value != "")
                                    approverUserIDList += ";" + serviceTypeSO.Properties["ApproverUserID"].Value;
                                if (approverUserIDList == "")
                                    approverCount = 0;
                                else
                                    approverCount = approverUserIDList.Split(';').Count();

                                // Get Notifier(s)
                                notifierUserIDList = serviceTypeSO.Properties["NotifierUserID"].Value;
                                if (notifierUserIDList == "")
                                    notifierCount = 0;
                                else
                                    notifierCount = notifierUserIDList.Split(';').Count();

                                // Get Operator(s)
                                operatorUserIDList = serviceTypeSO.Properties["OperatorUserID"].Value;
                                if (operatorUserIDList == "")
                                    operatorCount = 0;
                                else
                                    operatorCount = operatorUserIDList.Split(';').Count();
                            }
                            #endregion

                            // Populate RequestService Data: ServiceCategory -> ServiceType
                            if (level == 2)
                            {
                                requestServiceList.Add(new RequestService
                                {
                                    RequestID = requestID,
                                    EmployeeDataID = employeeDataID,
                                    ServiceCategoryID = serviceCategoryID,
                                    ServiceCategoryName = serviceCategoryName,
                                    ServiceTypeID = serviceTypeID,
                                    ServiceTypeName = serviceTypeName,
                                    ServiceID = "",
                                    ServiceName = "",
                                    ApproverUserID = approverUserIDList,
                                    ApproverCount = approverCount,
                                    NotifierUserID = notifierUserIDList,
                                    NotifierCount = notifierCount,
                                    OperatorUserID = operatorUserIDList,
                                    OperatorCount = operatorCount
                                });

                                // Reset
                                approverUserIDList = "";
                                notifierUserIDList = "";
                                operatorUserIDList = "";
                            }

                            // Populate RequestService Data: ServiceCategory -> ServiceType -> Service
                            if (level == 3)
                            {
                                // Populate Service Item(s)
                                serviceID = requestServiceHierachy[2].Split(',')[0];
                                serviceSO.Properties["ID"].Value = serviceID;
                                serviceSO = server.ExecuteScalar(serviceSO);
                                serviceName = serviceSO.Properties["serviceName"].Value;
                                requestServiceList.Add(new RequestService
                                {
                                    RequestID = requestID,
                                    EmployeeDataID = employeeDataID,
                                    ServiceCategoryID = serviceCategoryID,
                                    ServiceCategoryName = serviceCategoryName,
                                    ServiceTypeID = serviceTypeID,
                                    ServiceTypeName = serviceTypeName,
                                    ServiceID = serviceID,
                                    ServiceName = serviceName,
                                    ApproverUserID = approverUserIDList,
                                    ApproverCount = approverCount,
                                    NotifierUserID = notifierUserIDList,
                                    NotifierCount = notifierCount,
                                    OperatorUserID = operatorUserIDList,
                                    OperatorCount = operatorCount
                                });

                                // Reset
                                approverUserIDList = "";
                                notifierUserIDList = "";
                                operatorUserIDList = "";
                            }
                        }
                        #endregion

                        #region Populate NewUserAdmin Workflow CheckList
                        string[] approverList = { }, notifierList = { }, operatorList = { };
                        string approverUserID = "", notifierUserID = "", operatorUserID = "";
                        string approverName = "", notifierName = "", operatorName = "";
                        string approverEmail = "", notifierEmail = "", operatorEmail = "";
                        string approverEmailList = "";

                        foreach (RequestService item in requestServiceList)
                        {
                            #region Populate IPEX.NewUserAdmin.WorkflowCheckListSO SmartObject
                            workflowCheckListSO.Properties["ID"].Value = null;
                            workflowCheckListSO.Properties["RequestID"].Value = requestID;
                            workflowCheckListSO.Properties["EmployeeDataID"].Value = employeeDataID;
                            workflowCheckListSO.Properties["ServiceCategoryID"].Value = item.ServiceCategoryID;
                            workflowCheckListSO.Properties["ServiceCategoryName"].Value = item.ServiceCategoryName;
                            workflowCheckListSO.Properties["ServiceTypeID"].Value = item.ServiceTypeID;
                            workflowCheckListSO.Properties["ServiceTypeName"].Value = item.ServiceTypeName;
                            workflowCheckListSO.Properties["ServiceID"].Value = item.ServiceID;
                            workflowCheckListSO.Properties["ServiceName"].Value = item.ServiceName;
                            workflowCheckListSO.Properties["ApproverUserID"].Value = item.ApproverUserID;
                            workflowCheckListSO.Properties["ApproverCount"].Value = item.ApproverCount.ToString();
                            workflowCheckListSO.Properties["NotifierUserID"].Value = item.NotifierUserID;
                            workflowCheckListSO.Properties["NotifierCount"].Value = item.NotifierCount.ToString();
                            workflowCheckListSO.Properties["OperatorUserID"].Value = item.OperatorUserID;
                            workflowCheckListSO.Properties["OperatorCount"].Value = item.OperatorCount.ToString();
                            server.ExecuteScalar(workflowCheckListSO);
                            #endregion

                            #region Populate IPEX.NewUserAdmin.ApprovalCheckListSO SmartObject
                            // populate approver check list
                            if (item.ApproverUserID != "")
                            {
                                approverList = item.ApproverUserID.Split(';');
                                for (int i = 0; i < approverList.Count(); i++)
                                {
                                    approverUserID = approverList[i];
                                    if (approverUserID != "")
                                    {
                                        // Get per approver email from AD
                                        ipexADUserEqual.Left = new PropertyExpression("FQN", PropertyType.Number);
                                        ipexADUserEqual.Right = new ValueExpression(approverList[i], PropertyType.Number);
                                        ipexADUserList.Filter = ipexADUserEqual;
                                        SmartObjectList ipexADUserSOList = server.ExecuteList(ipexADUserSO);
                                        approverName = ipexADUserSOList.SmartObjectsList[0].Properties[3].Value + " " + ipexADUserSOList.SmartObjectsList[0].Properties[4].Value;
                                        approverEmail = ipexADUserSOList.SmartObjectsList[0].Properties[7].Value;
                                        if (approverEmailList == "")
                                            approverEmailList = approverEmail;
                                        else
                                        {
                                            if (!approverEmailList.Contains(approverEmail))
                                                approverEmailList += ";" + approverEmail;
                                        }

                                        // Create per ApprovalCheckListSO record
                                        approvalCheckListSO.Properties["ID"].Value = null;
                                        approvalCheckListSO.Properties["CreatedTime"].Value = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt");
                                        approvalCheckListSO.Properties["ApproverUserID"].Value = approverUserID;
                                        approvalCheckListSO.Properties["ApproverName"].Value = approverName;
                                        approvalCheckListSO.Properties["ApproverEmail"].Value = approverEmail;
                                        approvalCheckListSO.Properties["ApproverCount"].Value = approverList.Count().ToString();
                                        approvalCheckListSO.Properties["ApprovalStatus"].Value = "W";
                                        approvalCheckListSO.Properties["ApprovedTime"].Value = null;
                                        approvalCheckListSO.Properties["ApproverComment"].Value = "";
                                        approvalCheckListSO.Properties["ServiceCategoryID"].Value = item.ServiceCategoryID;
                                        approvalCheckListSO.Properties["ServiceTypeID"].Value = item.ServiceTypeID;
                                        approvalCheckListSO.Properties["ServiceID"].Value = item.ServiceID;
                                        approvalCheckListSO.Properties["EmployeeDataID"].Value = item.EmployeeDataID;
                                        approvalCheckListSO.Properties["RequestID"].Value = requestID;
                                        server.ExecuteScalar(approvalCheckListSO);
                                    }
                                }
                            }
                            #endregion

                            #region Populate IPEX.NewUserAdmin.NotificationListSO SmartObject
                            // [TODO] populate notification check list
                            if (item.NotifierUserID != "")
                            {
                                notifierList = item.NotifierUserID.Split(';');
                                for (int i = 0; i < notifierList.Count(); i++)
                                {
                                    notifierUserID = notifierList[i];
                                    if (notifierUserID != "")
                                    {
                                        // Get per notifer email from AD
                                        ipexADUserEqual.Left = new PropertyExpression("FQN", PropertyType.Number);
                                        ipexADUserEqual.Right = new ValueExpression(notifierList[i], PropertyType.Number);
                                        ipexADUserList.Filter = ipexADUserEqual;
                                        SmartObjectList ipexADUserSOList = server.ExecuteList(ipexADUserSO);
                                        notifierName = ipexADUserSOList.SmartObjectsList[0].Properties[3].Value + " " + ipexADUserSOList.SmartObjectsList[0].Properties[4].Value;
                                        notifierEmail = ipexADUserSOList.SmartObjectsList[0].Properties[7].Value;

                                        // Create per NotificationCheckListSO record
                                        notificationCheckListSO.Properties["ID"].Value = null;
                                        notificationCheckListSO.Properties["CreatedTime"].Value = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt");
                                        notificationCheckListSO.Properties["NotifierUserID"].Value = notifierUserID;
                                        notificationCheckListSO.Properties["NotifierName"].Value = notifierName;
                                        notificationCheckListSO.Properties["NotifierEmail"].Value = notifierEmail;
                                        notificationCheckListSO.Properties["NotifierCount"].Value = notifierList.Count().ToString();
                                        notificationCheckListSO.Properties["NotificationStatus"].Value = "W";
                                        notificationCheckListSO.Properties["NotifiedTime"].Value = "";
                                        notificationCheckListSO.Properties["ServiceCategoryID"].Value = item.ServiceCategoryID;
                                        notificationCheckListSO.Properties["ServiceTypeID"].Value = item.ServiceTypeID;
                                        notificationCheckListSO.Properties["ServiceID"].Value = item.ServiceID;
                                        notificationCheckListSO.Properties["EmployeeDataID"].Value = item.EmployeeDataID;
                                        notificationCheckListSO.Properties["RequestID"].Value = requestID;
                                        server.ExecuteScalar(notificationCheckListSO);
                                    }
                                }
                            }
                            #endregion

                            #region Populate IPEX.NewUserAdmin.ImplementationCheckListSO SmartObject
                            // [TODO] populate implementation check list
                            if (item.OperatorUserID != "")
                            {
                                operatorList = item.OperatorUserID.Split(';');
                                for (int i = 0; i < operatorList.Count(); i++)
                                {
                                    operatorUserID = operatorList[i];
                                    if (operatorUserID != "")
                                    {
                                        // Get per operator email from AD
                                        ipexADUserEqual.Left = new PropertyExpression("FQN", PropertyType.Number);
                                        ipexADUserEqual.Right = new ValueExpression(operatorList[i], PropertyType.Number);
                                        ipexADUserList.Filter = ipexADUserEqual;
                                        SmartObjectList ipexADUserSOList = server.ExecuteList(ipexADUserSO);
                                        operatorName = ipexADUserSOList.SmartObjectsList[0].Properties[3].Value + " " + ipexADUserSOList.SmartObjectsList[0].Properties[4].Value;
                                        operatorEmail = ipexADUserSOList.SmartObjectsList[0].Properties[7].Value;

                                        // Create per ImplementationCheckListSO record
                                        implementationCheckListSO.Properties["ID"].Value = null;
                                        implementationCheckListSO.Properties["CreatedTime"].Value = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt");
                                        implementationCheckListSO.Properties["OperatorUserID"].Value = operatorUserID;
                                        implementationCheckListSO.Properties["OperatorName"].Value = operatorName;
                                        implementationCheckListSO.Properties["OperatorEmail"].Value = operatorEmail;
                                        implementationCheckListSO.Properties["OperatorCount"].Value = operatorList.Count().ToString();
                                        implementationCheckListSO.Properties["OperationStatus"].Value = "W";
                                        implementationCheckListSO.Properties["OperatedTime"].Value = null;
                                        implementationCheckListSO.Properties["ServiceCategoryID"].Value = item.ServiceCategoryID;
                                        implementationCheckListSO.Properties["ServiceTypeID"].Value = item.ServiceTypeID;
                                        implementationCheckListSO.Properties["ServiceID"].Value = item.ServiceID;
                                        implementationCheckListSO.Properties["EmployeeDataID"].Value = item.EmployeeDataID;
                                        implementationCheckListSO.Properties["RequestID"].Value = requestID;
                                        server.ExecuteScalar(implementationCheckListSO);
                                    }
                                }
                            }
                            #endregion
                        }
                        #endregion

                        // Succeed -> save & return approver email list
                        serviceRequestHeaderSO.MethodToExecute = "Save";
                        serviceRequestHeaderSO.Properties["ID"].Value = requestID;
                        serviceRequestHeaderSO.Properties["RequestDestinationUserEmails"].Value = approverEmailList;
                        serviceRequestHeaderSO = server.ExecuteScalar(serviceRequestHeaderSO); 
                        return "OK|" + approverEmailList;
                    }
                    #region K2 SmartObjectException Handler
                    catch (SmartObjectException soe)
                    {
                        StringBuilder errorMessage = new StringBuilder();
                        foreach (SmartObjectExceptionData smartobjectExceptionData in soe.BrokerData)
                        {
                            string message = smartobjectExceptionData.Message;
                            string service = smartobjectExceptionData.ServiceName;
                            string serviceGuid = smartobjectExceptionData.ServiceGuid;
                            string severity = smartobjectExceptionData.Severity.ToString();
                            string innermessage = smartobjectExceptionData.InnerExceptionMessage;

                            errorMessage.AppendLine("Service: " + service);
                            errorMessage.AppendLine("Service Guid: " + serviceGuid);
                            errorMessage.AppendLine("Severity: " + severity);
                            errorMessage.AppendLine("Error Message: " + message);
                            errorMessage.AppendLine("InnerException Message: " + innermessage);
                        }
                        return "ERROR|" + errorMessage.ToString();
                    }
                    #endregion
                }
            }
            catch (Exception ex)
            {
                // Failed -> return detail error message
                return "ERROR|" + ex.Message;
            }
        }

        public string CheckRequestServiceTypeAccessRequired(string requestID, string serviceCategoryID)
        {
            try
            {
                #region Connect to K2 server
                SmartObjectClientServer server = new SmartObjectClientServer();
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());
                #endregion

                using (server.Connection)
                {
                    try
                    {
                        SmartObject serviceRequestHeaderSO = server.GetSmartObject("IPEX_NewUserAdmin_ServiceRequestHeaderSO");
                        serviceRequestHeaderSO.MethodToExecute = "Load";
                        serviceRequestHeaderSO.Properties["ID"].Value = requestID;  
                        serviceRequestHeaderSO = server.ExecuteScalar(serviceRequestHeaderSO);
                        string xmlServiceAccessRequired = serviceRequestHeaderSO.Properties["ServiceAccessRequired"].Value;

                        string[] requestServiceHierachy = { };
                        string requestServiceCategoryID = "";
                        int level = 0;
                        XDocument docService = XDocument.Parse(xmlServiceAccessRequired);
                        foreach (XElement serviceElement in docService.Descendants("field"))
                        {
                            // Tree node level parser
                            requestServiceHierachy = serviceElement.Value.Split('|');
                            level = requestServiceHierachy.Count();

                            // Get ServiceCategoryID in XML
                            requestServiceCategoryID = requestServiceHierachy[0].Split(',')[0];

                            // Verfiy if the given ServiceCategoryID is required
                            if (requestServiceCategoryID == serviceCategoryID) 
                                return "OK|true";
                        }
                        return "OK|false";  // not requried
                    }
                    #region K2 SmartObjectException Handler
                    catch (SmartObjectException soe)
                    {
                        StringBuilder errorMessage = new StringBuilder();
                        foreach (SmartObjectExceptionData smartobjectExceptionData in soe.BrokerData)
                        {
                            string message = smartobjectExceptionData.Message;
                            string service = smartobjectExceptionData.ServiceName;
                            string serviceGuid = smartobjectExceptionData.ServiceGuid;
                            string severity = smartobjectExceptionData.Severity.ToString();
                            string innermessage = smartobjectExceptionData.InnerExceptionMessage;

                            errorMessage.AppendLine("Service: " + service);
                            errorMessage.AppendLine("Service Guid: " + serviceGuid);
                            errorMessage.AppendLine("Severity: " + severity);
                            errorMessage.AppendLine("Error Message: " + message);
                            errorMessage.AppendLine("InnerException Message: " + innermessage);
                        }
                        return "ERROR|" + errorMessage.ToString();
                    }
                    #endregion
                }
            }
            catch (Exception ex)
            {
                // Failed -> return detail error message
                return "ERROR|" + ex.Message;
            }
        }
    }
}
