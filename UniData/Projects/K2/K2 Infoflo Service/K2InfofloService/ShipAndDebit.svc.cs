using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Web.Configuration;
using System.Text;
using U2.Data.Client;
using U2.Data.Client.UO;
using SourceCode.SmartObjects.Client;
using SourceCode.SmartObjects.Client.Filters;
using SourceCode.Hosting.Client.BaseAPI;
using SourceCode.Data.SmartObjectsClient;
using System.Xml.Linq;
using System.Diagnostics;

namespace K2InfofloService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "ShipAndDebit" in code, svc and config file together.
    public class ShipAndDebit : IShipAndDebit
    {
        private U2Connection GetConnection()
        {
            U2ConnectionStringBuilder conn_str = new U2ConnectionStringBuilder();
            conn_str.UserID = WebConfigurationManager.AppSettings["UD_USERID"];
            conn_str.Password = WebConfigurationManager.AppSettings["UD_PASSWORD"];
            conn_str.Server = WebConfigurationManager.AppSettings["UD_HOSTNAME"];
            conn_str.Database = WebConfigurationManager.AppSettings["UD_ACCOUNT"];
            conn_str.ServerType = WebConfigurationManager.AppSettings["SERVER_TYPE"];
            conn_str.AccessMode = WebConfigurationManager.AppSettings["ACCESS_MODE"];           // For UO
            conn_str.RpcServiceType = WebConfigurationManager.AppSettings["RPC_SERVICE_TYPE"];  // For UO UniData (Universe=uvcs)
            conn_str.Pooling = false;
            string s = conn_str.ToString();
            U2Connection con = new U2Connection();
            con.ConnectionString = s;
            con.Open();

            return con;
        }

        #region SD Distributor

        public List<SdUserSecurity> GetSdUserSecurityList(string userid)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SDUSRMST WITH @ID = """ + userid.ToUpper() + @""" DIST_MAINT_ACCESS CONT_MAINT_ACCESS AGREEMENT_MAINT_ACCESS");
                DataSet dsSdUserSecurity = cmd.GetDataSet();

                // Build SD user security setup list
                List<SdUserSecurity> sdUserSecurityList = new List<SdUserSecurity>();
                if (dsSdUserSecurity.Tables.Count > 0)
                {
                    foreach (DataRow row in dsSdUserSecurity.Tables[0].Rows)
                    {
                        sdUserSecurityList.Add(new SdUserSecurity { Userid = userid.ToUpper(), DistributorMaintenanceAccess = row["DIST_MAINT_ACCESS"].ToString(), ContractorMaintenanceAccess = row["CONT_MAINT_ACCESS"].ToString(), AgreementMaintenanceAccess = row["AGREEMENT_MAINT_ACCESS"].ToString() });
                    }
                }
                else
                {
                    cmd.GenerateXML(@"list SDUSRMST WITH @ID = """ + userid.ToLower() + @""" DIST_MAINT_ACCESS CONT_MAINT_ACCESS AGREEMENT_MAINT_ACCESS");
                    dsSdUserSecurity = cmd.GetDataSet();
                    if (dsSdUserSecurity.Tables.Count > 0)
                    {
                        foreach (DataRow row in dsSdUserSecurity.Tables[0].Rows)
                        {
                            sdUserSecurityList.Add(new SdUserSecurity { Userid = userid.ToLower(), DistributorMaintenanceAccess = row["DIST_MAINT_ACCESS"].ToString(), ContractorMaintenanceAccess = row["CONT_MAINT_ACCESS"].ToString(), AgreementMaintenanceAccess = row["AGREEMENT_MAINT_ACCESS"].ToString() });
                        }
                    }
                }

                return sdUserSecurityList;
            }
        }

        public SdConstant GetSdConstant()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Open UniFile SYSCON
                UniFile fileSYSCON = uSession.CreateUniFile("SYSCON");
                fileSYSCON.Open();

                // Build list of company
                SdConstant sdConstant = new SdConstant();

                // Read SYSCON table SHP.DBT.CONSTANTS and COMPMST to get company code/description 
                UniDynArray udArray = fileSYSCON.ReadField("SHP.DBT.CONSTANTS", 12);
                sdConstant.DefaultNoticeDays = udArray.ToString().Split(';')[0].Trim();

                return sdConstant;
            }
        }

        public List<Distributor> GetDistributorList(string companyCode, string sdQueryFlag = "")
        {
            if (companyCode == ".")  // special character for returning empty list
            {
                return new List<Distributor>();
            }
            else
            {
                using (U2Connection con = GetConnection())
                {
                    // Get session object
                    UniSession uSession = con.UniSession;

                    // Get command object
                    UniCommand cmd = uSession.CreateUniCommand();


                    if (sdQueryFlag.ToUpper() == "SD")
                    {
                        cmd.Command = @"select SDDMST WITH DF_COMPANY = """ + companyCode + @"""";
                        cmd.Execute();
                    }
                    else
                    {
                        // Retrieve SELECT list of SD distributor bill to # from CUSTMST file and also exclude any exists in SDDMST file
                        cmd.Command = @"select CUSTMST WITH DF_COMPANY = """ + companyCode + @""" AND WITH DF_BILL_TO_FLAG = ""7""";
                        cmd.Execute();
                        cmd.Command = @"nselect SDDMST FROM 0 TO 0";  // exclude those distributor record that already exists
                        cmd.Execute();
                    }

                    // Build list of distributor
                    UniXML cmdXML = uSession.CreateUniXML();
                    cmdXML.GenerateXML(@"list CUSTMST NAME");
                    DataSet dsDistributor = cmdXML.GetDataSet();
                    List<Distributor> distributorList = new List<Distributor>();
                    if (dsDistributor.Tables.Count > 0)
                    {
                        foreach (DataRow row in dsDistributor.Tables[0].Rows)
                        {
                            distributorList.Add(new Distributor { DistributorNumber = row["_ID"].ToString().Split('*')[1], DistributorName = row["NAME"].ToString() });
                        }
                    }

                    return distributorList;
                }
            }
        }

        public List<DistributorShipTo> GetDistributorShipToList(string companyCode, string distributorNumber)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Retrieve SELECT list of SD distributor ship to # from CUSTMST file
                UniCommand cmd = uSession.CreateUniCommand();
                cmd.Command = @"select CUSTMST WITH @ID LIKE """ + companyCode + "*" + distributorNumber + @"...""";
                cmd.Execute();

                // Build list of distributor
                UniXML cmdXML = uSession.CreateUniXML();
                cmdXML.GenerateXML(@"list CUSTMST DF_BILL_TO_FLAG DF_SHIP_TO NAME CONTACT SHIPTO_CONTACT_EMAIL");
                DataSet dsDistributorShipTo = cmdXML.GetDataSet();

                List<DistributorShipTo> DistributorShipToList = new List<DistributorShipTo>();
                int foreignKey = 0;
                string shipToNumber = "", shipToName = "", contact = "", email = "";
                if (dsDistributorShipTo.Tables.Count > 0)
                {
                    foreach (DataRow row in dsDistributorShipTo.Tables[0].Rows)
                    {
                        // CUSTMST_SHIP_TO
                        if (row["DF_BILL_TO_FLAG"].ToString() == "7")
                        {
                            shipToNumber = "000";  // bill to number 7 digits long
                            shipToName = row["NAME"].ToString();
                            foreignKey = 0;
                        }
                        else
                        {
                            shipToNumber = row["DF_SHIP_TO"].ToString();  // ship to number 10 digits long
                            shipToName = row["NAME"].ToString();
                            foreignKey = Int32.Parse(shipToNumber);
                        }

                        // CUSTMST CONTACT_MV
                        for (int i = 0; i < dsDistributorShipTo.Tables.Count; i++)
                        {
                            if (dsDistributorShipTo.Tables[i].TableName == "CONTACT_MV")
                            {
                                foreach (DataRow dr in dsDistributorShipTo.Tables[i].Rows)
                                {
                                    if (foreignKey == Int32.Parse(dr["CUSTMST_Id"].ToString()) + 1)
                                    {
                                        contact = dr["CONTACT"].ToString();
                                        break;
                                    }
                                    else
                                        contact = "";
                                }
                                break;
                            }
                            else
                                contact = "";
                        }

                        // CUSTMST EMAIL_MV
                        for (int i = 0; i < dsDistributorShipTo.Tables.Count; i++)
                        {
                            if (dsDistributorShipTo.Tables[i].TableName == "SHIPTO_CONTACT_EMAIL_MV")
                            {
                                foreach (DataRow dr in dsDistributorShipTo.Tables[i].Rows)
                                {
                                    if (foreignKey == Int32.Parse(dr["CUSTMST_Id"].ToString()) + 1)
                                    {
                                        email = dr["SHIPTO_CONTACT_EMAIL"].ToString();
                                        break;
                                    }
                                    else
                                        email = "";
                                }
                                break;
                            }
                            else
                                email = "";
                        }

                        DistributorShipToList.Add(new DistributorShipTo { ShipToNumber = shipToNumber, ShipToName = shipToName, Contact = contact, Email = email });
                    }
                }

                return DistributorShipToList;
            }
        }

        public List<RequestSalesOffice> GetRequestSalesOfficeList(string requestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();

                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the agreementDistributor SmartObject definition
                    SmartObject agreementDistributor = server.GetSmartObject("DistributorHeader");

                    // Get the List Method
                    SmartListMethod getagreementDistributorList = agreementDistributor.ListMethods["GetList"];
                    agreementDistributor.MethodToExecute = getagreementDistributorList.Name;

                    // Find all Distributors for a specified request
                    Equals agreementDistributorEqual = new Equals();
                    agreementDistributorEqual.Left = new PropertyExpression("RequestID", PropertyType.Number);
                    agreementDistributorEqual.Right = new ValueExpression(requestID, PropertyType.Number);

                    // Apply the filter
                    getagreementDistributorList.Filter = agreementDistributorEqual;

                    // Get the data                                                                                      
                    SmartObjectList distributorRequest = server.ExecuteList(agreementDistributor);

                    // Write out values
                    List<RequestSalesOffice> slsOffList = new List<RequestSalesOffice>();

                    // Retrieve each sales office code from the XML document
                    XDocument doc = XDocument.Parse(distributorRequest.SmartObjectsList[0].Properties[3].Value);
                    string slsOffChecked = "";
                    foreach (XElement element in doc.Descendants("field"))
                    {
                        slsOffList.Add(new RequestSalesOffice { SalesOfficeCode = element.Value, SalesOfficeName = "", SalesOfficeCodeChecked = "" });
                        slsOffChecked += element.Value + ";";
                    }

                    // Update for sales office name
                    using (U2Connection con = GetConnection())
                    {
                        // Get session object
                        UniSession uSession = con.UniSession;

                        // Execute UniQuery command, return result in XML then convert to DataSet
                        UniXML cmd = uSession.CreateUniXML();
                        cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I13*..."" DESC");
                        DataSet dsSalesOffice = cmd.GetDataSet();

                        // Build sales office list
                        if (dsSalesOffice.Tables.Count > 0)
                        {
                            foreach (DataRow row in dsSalesOffice.Tables[0].Rows)
                            {
                                for (int i = 0; i < slsOffList.Count; i++)
                                {
                                    if (slsOffList[i].SalesOfficeCode == row["_ID"].ToString().Split('*')[1])
                                    {
                                        slsOffList[i].SalesOfficeName = row["DESC"].ToString();
                                        slsOffList[i].SalesOfficeCodeChecked = slsOffChecked;
                                    }
                                }
                            }
                        }
                    }

                    return slsOffList;

                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<ProductCrossReference> GetProductCrossReferenceList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I05*..."" DESC");
                DataSet dsProductCrossReference = cmd.GetDataSet();

                // Build product cross reference code/desc list
                List<ProductCrossReference> prodXrfList = new List<ProductCrossReference>();
                if (dsProductCrossReference.Tables.Count > 0)
                {
                    foreach (DataRow row in dsProductCrossReference.Tables[0].Rows)
                    {
                        if (!row["_ID"].ToString().Contains("ALL") && !row["DESC"].ToString().ToUpper().Contains("NOT USED"))
                            prodXrfList.Add(new ProductCrossReference { ProductCrossReferenceCode = row["_ID"].ToString().Split('*')[1], ProductCrossReferenceName = row["DESC"].ToString() });
                    }
                }

                return prodXrfList;
            }
        }

        public DistributorHeader GetDistributorHeaderListFirstItem(string requestID)
        {
            // K2 DAL
            SmartObjectClientServer server = new SmartObjectClientServer();
            try
            {
                //Make the server connection
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());

                //Get the DistributorBranch SmartObject definition
                SmartObject distributorHeader = server.GetSmartObject("DistributorHeader");

                //Get the List Method
                SmartListMethod getList = distributorHeader.ListMethods["GetList"];
                distributorHeader.MethodToExecute = getList.Name;

                //Find all distributor branches for a specified request
                Equals distributorHeaderEqual = new Equals();
                distributorHeaderEqual.Left = new PropertyExpression("RequestID", PropertyType.Number);
                distributorHeaderEqual.Right = new ValueExpression(requestID, PropertyType.Number);

                //Apply the filter
                getList.Filter = distributorHeaderEqual;

                //Get the data
                SmartObjectList distributorHeaderList = server.ExecuteList(distributorHeader);

                //Write out values
                DistributorHeader distributorHeaderItem = new DistributorHeader();
                if (distributorHeaderList.SmartObjectsList.Count > 0)
                {
                    distributorHeaderItem.RequestID = requestID;
                    distributorHeaderItem.CompanyCode = distributorHeaderList.SmartObjectsList[0].Properties[1].Value;
                    distributorHeaderItem.DistributorNumber = distributorHeaderList.SmartObjectsList[0].Properties[2].Value;
                    distributorHeaderItem.SalesOfficeCode = distributorHeaderList.SmartObjectsList[0].Properties[3].Value;
                    distributorHeaderItem.ProductCrossReferenceCode = distributorHeaderList.SmartObjectsList[0].Properties[4].Value;
                    distributorHeaderItem.AlternateProductCrossReferenceCode = distributorHeaderList.SmartObjectsList[0].Properties[5].Value;
                    distributorHeaderItem.DefaultNoticeDays = distributorHeaderList.SmartObjectsList[0].Properties[6].Value;
                    distributorHeaderItem.OverrideNoticeDays = distributorHeaderList.SmartObjectsList[0].Properties[7].Value;
                    distributorHeaderItem.SalesPerson = distributorHeaderList.SmartObjectsList[0].Properties[8].Value;
                    distributorHeaderItem.AdminContact = distributorHeaderList.SmartObjectsList[0].Properties[9].Value;
                    distributorHeaderItem.AdminEmailAddress = distributorHeaderList.SmartObjectsList[0].Properties[10].Value;
                    distributorHeaderItem.CreditAdminContact = distributorHeaderList.SmartObjectsList[0].Properties[11].Value;
                    distributorHeaderItem.CreditAdminEmailAddress = distributorHeaderList.SmartObjectsList[0].Properties[12].Value;
                    distributorHeaderItem.AllCustomerFlag = distributorHeaderList.SmartObjectsList[0].Properties[13].Value;
                    distributorHeaderItem.TransferHistoryToCustomer = distributorHeaderList.SmartObjectsList[0].Properties[14].Value;
                    distributorHeaderItem.SpecialTermsConditionsEnglish = distributorHeaderList.SmartObjectsList[0].Properties[15].Value;
                    distributorHeaderItem.SpecialTermsConditionsFrench = distributorHeaderList.SmartObjectsList[0].Properties[16].Value;
                    distributorHeaderItem.ProgramExceptionsEnglish = distributorHeaderList.SmartObjectsList[0].Properties[17].Value;
                    distributorHeaderItem.ProgramExceptionsFrench = distributorHeaderList.SmartObjectsList[0].Properties[18].Value;
                    distributorHeaderItem.Comment = distributorHeaderList.SmartObjectsList[0].Properties[19].Value;
                    distributorHeaderItem.UserID = distributorHeaderList.SmartObjectsList[0].Properties[20].Value;
                }

                return distributorHeaderItem;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                server.Connection.Close();
            }
        }

        public DistributorBranch GetDistributorBranchListFirstItem(string requestID)
        {
            // K2 DAL
            SmartObjectClientServer server = new SmartObjectClientServer();
            try
            {
                //Make the server connection
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());

                //Get the DistributorBranch SmartObject definition
                SmartObject distributorBranch = server.GetSmartObject("DistributorBranch");

                //Get the List Method
                SmartListMethod getList = distributorBranch.ListMethods["GetList"];
                distributorBranch.MethodToExecute = getList.Name;

                //Find all distributor branches for a specified request
                Equals distributorBranchEqual = new Equals();
                distributorBranchEqual.Left = new PropertyExpression("RequestID", PropertyType.Number);
                distributorBranchEqual.Right = new ValueExpression(requestID, PropertyType.Number);

                //Apply the filter
                getList.Filter = distributorBranchEqual;

                //Get the data
                SmartObjectList distributorBranchList = server.ExecuteList(distributorBranch);

                //Write out values
                DistributorBranch distributorBranchItem = new DistributorBranch();
                if (distributorBranchList.SmartObjectsList.Count > 0)
                {
                    distributorBranchItem.RequestID = requestID;
                    distributorBranchItem.BranchCode = distributorBranchList.SmartObjectsList[0].Properties[1].Value;
                    distributorBranchItem.BranchName = distributorBranchList.SmartObjectsList[0].Properties[2].Value;
                    distributorBranchItem.ShipToNumber = distributorBranchList.SmartObjectsList[0].Properties[3].Value;
                    distributorBranchItem.ContactName = distributorBranchList.SmartObjectsList[0].Properties[4].Value;
                    distributorBranchItem.EmailAddress = distributorBranchList.SmartObjectsList[0].Properties[5].Value;
                    distributorBranchItem.CreditContactName = distributorBranchList.SmartObjectsList[0].Properties[6].Value;
                    distributorBranchItem.CreditEmailAddress = distributorBranchList.SmartObjectsList[0].Properties[7].Value;
                    distributorBranchItem.SalesPerson = distributorBranchList.SmartObjectsList[0].Properties[8].Value;
                }

                return distributorBranchItem;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                server.Connection.Close();
            }
        }

        public String DeleteDistributorHeader(string requestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;
                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the DistributorBranch SmartObject definition
                    SmartObject distributorHeader = server.GetSmartObject("DistributorHeader");

                    // Get the List Method
                    SmartListMethod distributorHeaderList = distributorHeader.ListMethods["GetList"];
                    distributorHeader.MethodToExecute = distributorHeaderList.Name;

                    // Find all distributor branches for a specified request
                    Equals distributorHeaderEqual = new Equals();
                    distributorHeaderEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                    distributorHeaderEqual.Right = new ValueExpression(requestID, PropertyType.Text);

                    // Apply the filter
                    distributorHeaderList.Filter = distributorHeaderEqual;

                    // Get the data                                                                                      
                    SmartObjectList distributor = server.ExecuteList(distributorHeader);

                    // Delete all branches for the given requestID
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    foreach (SmartObject item in distributor.SmartObjectsList)
                    {
                        cmd.CommandText = "DELETE FROM [DistributorHeader] " +
                                          "WHERE [RequestID]='" + requestID + "' " +
                                          "AND [SalesOfficeCode]='" + item.Properties[3].Value + "'";
                        cmd.ExecuteNonQuery();
                    }

                    return "";
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public String DeleteDistributorBranch(string requestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;
                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the DistributorBranch SmartObject definition
                    SmartObject distributorBranch = server.GetSmartObject("DistributorBranch");

                    // Get the List Method
                    SmartListMethod distributorBranchList = distributorBranch.ListMethods["GetList"];
                    distributorBranch.MethodToExecute = distributorBranchList.Name;

                    // Find all distributor branches for a specified request
                    Equals distributorBranchEqual = new Equals();
                    distributorBranchEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                    distributorBranchEqual.Right = new ValueExpression(requestID, PropertyType.Text);

                    // Apply the filter
                    distributorBranchList.Filter = distributorBranchEqual;

                    // Get the data                                                                                      
                    SmartObjectList branches = server.ExecuteList(distributorBranch);

                    // Delete all branches for the given requestID
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    foreach (SmartObject branch in branches.SmartObjectsList)
                    {
                        cmd.CommandText = "DELETE FROM [DistributorBranch] " +
                                          "WHERE [RequestID]='" + requestID + "' " +
                                          "AND [BranchCode]='" + branch.Properties[1].Value + "'";
                        cmd.ExecuteNonQuery();
                    }

                    return "";
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public String CloneDistributorBranch(string cloneRequestID, string newRequestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;
                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the DistributorBranch SmartObject definition
                    SmartObject distributorBranch = server.GetSmartObject("DistributorBranch");

                    // Get the List Method
                    SmartListMethod getDistributorBranchList = distributorBranch.ListMethods["GetList"];
                    distributorBranch.MethodToExecute = getDistributorBranchList.Name;

                    // Find all distributor branches for a specified request
                    Equals distributorBranchEqual = new Equals();
                    distributorBranchEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                    distributorBranchEqual.Right = new ValueExpression(cloneRequestID, PropertyType.Text);

                    // Apply the filter
                    getDistributorBranchList.Filter = distributorBranchEqual;

                    // Get the data                                                                                      
                    SmartObjectList branches = server.ExecuteList(distributorBranch);

                    // Delete all branches for the given requestID
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    foreach (SmartObject branch in branches.SmartObjectsList)
                    {
                        cmd.CommandText = "INSERT INTO [DistributorBranch] " +
                                          "VALUES ('" + newRequestID + "'," +
                                                  "'" + branch.Properties["BranchCode"].Value + "'," +
                                                  "'" + branch.Properties["BranchName"].Value + "'," +
                                                  "'" + branch.Properties["ShipToNumber"].Value + "'," +
                                                  "'" + branch.Properties["ContactName"].Value + "'," +
                                                  "'" + branch.Properties["EmailAddress"].Value + "'," +
                                                  "'" + branch.Properties["CreditContactName"].Value + "'," +
                                                  "'" + branch.Properties["CreditEmailAddress"].Value + "'," +
                                                  "'" + branch.Properties["SalesPerson"].Value + "')";
                        cmd.ExecuteNonQuery();
                    }

                    return "";
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public string CallInfofloNewDistributorRequestProcess(string requestID, string actionCode)
        {
            try
            {
                String in_data = "";
                string returnMsg = "0";
                string AM = Char.ConvertFromUtf32(254);   // UniData Attribute Mark Delimiter Symbol @AM
                string VM = Char.ConvertFromUtf32(253);   // UniData Value Mark Delimiter Symbol @VM
                string SM = Char.ConvertFromUtf32(252);   // UniData Subvalue Mark Delimiter Symbol @SM

                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;

                // Make the server connection
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());
                try
                {
                    if (actionCode == "A")
                    {
                        // Get the agreementDistributor/DistributorBranch SmartObject definition
                        SmartObject distributorHeader = server.GetSmartObject("DistributorHeader");
                        SmartObject distributorBranch = server.GetSmartObject("DistributorBranch");

                        // Get the List Method
                        SmartListMethod getdistributorHeaderList = distributorHeader.ListMethods["GetList"];
                        distributorHeader.MethodToExecute = getdistributorHeaderList.Name;
                        SmartListMethod getDistributorBranchList = distributorBranch.ListMethods["GetList"];
                        distributorBranch.MethodToExecute = getDistributorBranchList.Name;

                        // Query for the given distributor requestID
                        Equals distributorHeaderEqual = new Equals();
                        distributorHeaderEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                        distributorHeaderEqual.Right = new ValueExpression(requestID, PropertyType.Text);
                        Equals distributorBranchEqual = new Equals();
                        distributorBranchEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                        distributorBranchEqual.Right = new ValueExpression(requestID, PropertyType.Text);

                        // Apply the filter
                        getdistributorHeaderList.Filter = distributorHeaderEqual;
                        getDistributorBranchList.Filter = distributorBranchEqual;

                        // Get the data                                                                                      
                        SmartObjectList distributor = server.ExecuteList(distributorHeader);
                        SmartObjectList branch = server.ExecuteList(distributorBranch);

                        // Build request data structure
                        int recordCounter = 0, fieldCounter = 0;
                        foreach (SmartObject distributorHeaderRecord in distributor.SmartObjectsList)
                        {
                            foreach (SmartProperty property in distributor.SmartObjectsList[recordCounter].Properties)
                            {
                                fieldCounter += 1;
                                if (fieldCounter == 1)
                                    in_data += property.Value;
                                else
                                    in_data += SM + property.Value;
                            }

                            recordCounter += 1;
                            if (recordCounter < distributor.SmartObjectsList.Count)
                            {
                                in_data += VM;
                                fieldCounter = 0;
                            }
                        }

                        recordCounter = 0;
                        fieldCounter = 0;
                        in_data += AM;

                        foreach (SmartObject distributorBranchRecord in branch.SmartObjectsList)
                        {
                            foreach (SmartProperty property in branch.SmartObjectsList[recordCounter].Properties)
                            {
                                fieldCounter += 1;
                                if (fieldCounter == 1)
                                    in_data += property.Value;
                                else
                                    in_data += SM + property.Value;
                            }

                            recordCounter += 1;
                            if (recordCounter < branch.SmartObjectsList.Count)
                            {
                                in_data += VM;
                                fieldCounter = 0;
                            }
                        }

                        if (in_data != "")
                        {
                            // Infoflo DAL
                            using (U2Connection con = GetConnection())
                            {
                                // Get session object
                                UniSession uSession = con.UniSession;

                                // Get SDC UniBasic program name and its number of parameters
                                string subName = WebConfigurationManager.AppSettings["SDC_DISTRIBUTOR"].ToString().Split('|')[0];
                                int paramsCount = Convert.ToInt32(WebConfigurationManager.AppSettings["SDC_DISTRIBUTOR"].ToString().Split('|')[1]);

                                // UniBasic Subroutine Call
                                UniSubroutine uniSub = uSession.CreateUniSubroutine(subName, paramsCount);
                                uniSub.SetArg(0, in_data);      // new distributor request data
                                uniSub.SetArg(1, "");           // return message
                                uniSub.Call();

                                // Last parameter is return status
                                returnMsg = uniSub.GetArg(paramsCount - 1);
                            }
                        }
                        else
                            throw new Exception("Error: no data found for the new distributor request id # " + requestID);
                    }

                    // Update status
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    cmd.CommandText = "UPDATE [DistributorRequest] " +
                                      "SET [Status]='" + actionCode + "', " +
                                      "[DateTimeReplied]='" + DateTime.Now.ToString("dd/MM/yyyy hh:mm tt") + "', " +
                                      "[ReturnMessage]='" + returnMsg + "' " +
                                      "WHERE [ID]='" + requestID + "'";
                    cmd.ExecuteNonQuery();

                    return returnMsg;
                }
                catch (SmartObjectException soEx)
                {
                    StringBuilder sb = new StringBuilder();
                    foreach (SmartObjectExceptionData soExData in soEx.BrokerData)
                    {
                        sb.Append("Service: ");
                        sb.AppendLine(soExData.ServiceName);
                        sb.Append("Service Guid: ");
                        sb.AppendLine(soExData.ServiceGuid);
                        sb.Append("Severity: ");
                        sb.AppendLine(soExData.Severity.ToString());
                        sb.Append("Error Message: ");
                        sb.AppendLine(soExData.Message);
                        sb.Append("InnerException Message: ");
                    }
                    throw new Exception(sb.ToString());
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        #endregion

        #region SD Contractor Agreement

        public List<AgreementDistributor> GetAgreementDistributorList(string companyCode)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                //cmd.GenerateXML(@"list SDDMST WITH @ID LIKE """ + companyCode + @"*..."" DF_COMPANY DF_CUSTOMER DF_CUSTOMER_NAME DF_CUSTOMER_BILL_TO DF_CUSTOMER_BILL_TO_NAME SALES_PERSON DF_SALES_PERSON_NAME DF_CUSTOMER_DEFAULT_PRICE_LIST");
                cmd.GenerateXML(@"list SDDMST WITH @ID LIKE """ + companyCode + @"*..."" DF_COMPANY DF_CUSTOMER DF_CUSTOMER_NAME DF_CUSTOMER_DEFAULT_PRICE_LIST");
                DataSet dsAgreementDistributor = cmd.GetDataSet();

                // Build AgreementDistributor list
                List<AgreementDistributor> agreementDistributorList = new List<AgreementDistributor>();
                if (dsAgreementDistributor.Tables.Count > 0)
                {
                    foreach (DataRow row in dsAgreementDistributor.Tables[0].Rows)
                    {
                        //agreementDistributorList.Add(new AgreementDistributor { CompanyCode = row["DF_COMPANY"].ToString(), DistributorNumber = row["DF_CUSTOMER"].ToString(), DistributorName = row["DF_CUSTOMER_NAME"].ToString(), BillToNumber = row["DF_CUSTOMER_BILL_TO"].ToString(), BillToName = row["DF_CUSTOMER_BILL_TO_NAME"].ToString(), SalesPersonUserid = row["SALES_PERSON"].ToString(), SalesPersonName = row["DF_SALES_PERSON_NAME"].ToString(), DefaultTradePriceList = row["DF_CUSTOMER_DEFAULT_PRICE_LIST"].ToString() });
                        agreementDistributorList.Add(new AgreementDistributor { CompanyCode = row["DF_COMPANY"].ToString(), DistributorNumber = row["DF_CUSTOMER"].ToString(), DistributorName = row["DF_CUSTOMER_NAME"].ToString(), BillToNumber = "TODO: MV", BillToName = "TODO: MV", SalesPersonUserid = "TODO: MV", SalesPersonName = "TODO: MV", DefaultTradePriceList = row["DF_CUSTOMER_DEFAULT_PRICE_LIST"].ToString() });
                    }
                }

                return agreementDistributorList;
            }
        }

        public List<AgreementSalesOffice> GetAgreementSalesOfficeList(string companyCode, string distributorNumber)
        {
            if (companyCode == "." && distributorNumber == ".")
            {
                return new List<AgreementSalesOffice>();
            }
            else
            {
                using (U2Connection con = GetConnection())
                {
                    // Get session object
                    UniSession uSession = con.UniSession;

                    // Execute UniQuery command, return result in XML then convert to DataSet
                    UniXML cmd = uSession.CreateUniXML();
                    cmd.GenerateXML(@"list SDDMST WITH DF_COMPANY = """ + companyCode + @""" AND WITH DF_CUSTOMER = """ + distributorNumber + @""" SALES_OFFICE DF_SALES_OFF_DESC");
                    DataSet dsAgreementSalesOffice = cmd.GetDataSet();

                    // Build AgreementSalesOffice list
                    List<AgreementSalesOffice> agreementSalesOfficeList = new List<AgreementSalesOffice>();
                    string slsOffCode = "";
                    string slsOffName = "";
                    if (dsAgreementSalesOffice.Tables.Count > 0)
                    {
                        // SDDMST SALES_OFFICE_MV / DF_SALES_OFF_DESC_MV
                        for (int i = 0; i < dsAgreementSalesOffice.Tables[1].Rows.Count; i++)
                        {
                            slsOffCode = dsAgreementSalesOffice.Tables[1].Rows[i]["SALES_OFFICE"].ToString();
                            slsOffName = dsAgreementSalesOffice.Tables[2].Rows[i]["DF_SALES_OFF_DESC"].ToString(); ;
                            agreementSalesOfficeList.Add(new AgreementSalesOffice { SalesOfficeCode = slsOffCode, SalesOfficeName = slsOffName });
                        }
                    }

                    return agreementSalesOfficeList;
                }
            }
        }

        public List<AgreementDistributorBranch> GetAgreementDistributorBranchList(string companyCode, string distributorNumber)
        {
            if (companyCode == "." && distributorNumber == ".")
            {
                return new List<AgreementDistributorBranch>();
            }
            else
            {
                using (U2Connection con = GetConnection())
                {
                    // Get session object
                    UniSession uSession = con.UniSession;

                    // Execute UniQuery command, return result in XML then convert to DataSet
                    UniXML cmd = uSession.CreateUniXML();
                    cmd.GenerateXML(@"list SDDMST WITH @ID = """ + companyCode + "*" + distributorNumber + @""" BRANCH_CODES BRANCH_NAME SHIP_TO");
                    DataSet dsAgreementDistributorBranch = cmd.GetDataSet();

                    // Build AgreementDistributorBranch list
                    List<AgreementDistributorBranch> agreementDistributorBranchList = new List<AgreementDistributorBranch>();
                    string branchCode = "";
                    string branchName = "";
                    string shipToNumber = "";
                    if (dsAgreementDistributorBranch.Tables.Count > 0)
                    {
                        // SDDMST BRANCH_CODES_MV / BRANCH_NAME_MV / SHIP_TO_MV
                        for (int i = 0; i < dsAgreementDistributorBranch.Tables[1].Rows.Count; i++)
                        {
                            branchCode = dsAgreementDistributorBranch.Tables[1].Rows[i]["BRANCH_CODES"].ToString();
                            branchName = dsAgreementDistributorBranch.Tables[2].Rows[i]["BRANCH_NAME"].ToString();
                            shipToNumber = dsAgreementDistributorBranch.Tables[3].Rows[i]["SHIP_TO"].ToString();
                            agreementDistributorBranchList.Add(new AgreementDistributorBranch { CompanyCode = companyCode, DistributorNumber = distributorNumber, BranchCode = branchCode, BranchName = branchName, ShipToNumber = shipToNumber });
                        }
                    }

                    return agreementDistributorBranchList;
                }
            }
        }

        public String DeleteAgreementDistributorBranch(string agreementRequestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;
                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the AgreementDistributorBranch SmartObject definition
                    SmartObject AgreementDistributorBranch = server.GetSmartObject("AgreementDistributorBranch");

                    // Get the List Method
                    SmartListMethod getAgreementDistributorBranchList = AgreementDistributorBranch.ListMethods["GetList"];
                    AgreementDistributorBranch.MethodToExecute = getAgreementDistributorBranchList.Name;

                    // Find all distributor branches for a specified request
                    Equals AgreementDistributorBranchEqual = new Equals();
                    AgreementDistributorBranchEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                    AgreementDistributorBranchEqual.Right = new ValueExpression(agreementRequestID, PropertyType.Text);

                    // Apply the filter
                    getAgreementDistributorBranchList.Filter = AgreementDistributorBranchEqual;

                    // Get the data                                                                                      
                    SmartObjectList branches = server.ExecuteList(AgreementDistributorBranch);

                    // Delete all branches for the given requestID
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    foreach (SmartObject branch in branches.SmartObjectsList)
                    {
                        cmd.CommandText = "DELETE FROM [AgreementDistributorBranch] " +
                                          "WHERE [RequestID]='" + agreementRequestID + "' " +
                                          "AND [BranchCode]='" + branch.Properties[1].Value + "'";
                        cmd.ExecuteNonQuery();
                    }

                    return "";
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public String DeleteAgreementDetails(string agreementRequestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;
                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the AgreementDistributorBranch SmartObject definition
                    SmartObject AgreementDetails = server.GetSmartObject("AgreementDetails");

                    // Get the List Method
                    SmartListMethod getAgreementDetailsList = AgreementDetails.ListMethods["GetList"];
                    AgreementDetails.MethodToExecute = getAgreementDetailsList.Name;

                    // Find all distributor branches for a specified request
                    Equals AgreementDetailsEqual = new Equals();
                    AgreementDetailsEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                    AgreementDetailsEqual.Right = new ValueExpression(agreementRequestID, PropertyType.Text);

                    // Apply the filter
                    getAgreementDetailsList.Filter = AgreementDetailsEqual;

                    // Get the data                                                                                      
                    SmartObjectList agreements = server.ExecuteList(AgreementDetails);

                    // Delete all branches for the given requestID
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    foreach (SmartObject item in agreements.SmartObjectsList)
                    {
                        cmd.CommandText = "DELETE FROM [AgreementDetails] " +
                                          "WHERE [RequestID]='" + agreementRequestID + "' " +
                                          "AND [ItemNumber]='" + item.Properties[2].Value + "' " +
                                          "AND [PriceType]='" + item.Properties[4].Value + "' " +
                                          "AND [TradePriceList]='" + item.Properties[6].Value + "'";
                        cmd.ExecuteNonQuery();
                    }

                    return "";
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public List<AgreementItemType> GetAgreementItemTypeList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I288*..."" SPEC_CODE8 DESC");
                DataSet dsItemTypeList = cmd.GetDataSet();

                // Build ItemType list
                List<AgreementItemType> sdItemTypeList = new List<AgreementItemType>();
                if (dsItemTypeList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsItemTypeList.Tables[0].Rows)
                    {
                        if (dsItemTypeList.Tables[0].Columns.Contains("DESC"))
                            sdItemTypeList.Add(new AgreementItemType { ItemTypeCode = row["SPEC_CODE8"].ToString(), ItemTypeName = row["DESC"].ToString() });
                        else
                            sdItemTypeList.Add(new AgreementItemType { ItemTypeCode = row["SPEC_CODE8"].ToString(), ItemTypeName = "" });
                    }
                }

                return sdItemTypeList;
            }
        }

        public List<AgreementItemUnitOfMeasure> GetAgreementItemUnitOfMeasureList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""UOM*..."" SPEC_CODE8 DESC");
                DataSet dsItemUnitOfMeasureList = cmd.GetDataSet();

                // Build ItemUnitOfMeasure list
                List<AgreementItemUnitOfMeasure> sdItemUnitOfMeasureList = new List<AgreementItemUnitOfMeasure>();
                if (dsItemUnitOfMeasureList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsItemUnitOfMeasureList.Tables[0].Rows)
                    {
                        if (dsItemUnitOfMeasureList.Tables[0].Columns.Contains("DESC"))
                            sdItemUnitOfMeasureList.Add(new AgreementItemUnitOfMeasure { ItemUnitOfMeasureCode = row["SPEC_CODE8"].ToString(), ItemUnitOfMeasureName = row["DESC"].ToString() });
                        else
                            sdItemUnitOfMeasureList.Add(new AgreementItemUnitOfMeasure { ItemUnitOfMeasureCode = row["SPEC_CODE8"].ToString(), ItemUnitOfMeasureName = "" });
                    }
                }

                return sdItemUnitOfMeasureList;
            }
        }

        public List<AgreementItem> GetAgreementItemList(string itemTypeCode, string itemNumber = "")
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                switch (itemTypeCode.ToUpper())
                {
                    case "PN":  // Product Number
                        cmd.GenerateXML(@"list ITMMST WITH PART.NBR = """ + itemNumber + @""" PART.NBR DESCRIPTION");
                        break;
                    case "PC":  // Price Class
                        if (itemNumber == ".")  // special character for returning all
                            cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""PPC*..."" SPEC_CODE8 DESC");
                        else
                            cmd.GenerateXML(@"list SYSTBL WITH @ID = ""PPC*" + itemNumber + @""" SPEC_CODE8 DESC");
                        break;
                    case "PL":  // Product Line
                        if (itemNumber == ".")
                            cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I03*..."" SPEC_CODE8 DESC");
                        else
                            cmd.GenerateXML(@"list SYSTBL WITH @ID = ""I03*" + itemNumber + @""" SPEC_CODE8 DESC");
                        break;
                    case "PG":  // Product Group
                        if (itemNumber == ".")
                            cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I29*..."" SPEC_CODE8 DESC");
                        else
                            cmd.GenerateXML(@"list SYSTBL WITH @ID = ""I29*" + itemNumber + @""" SPEC_CODE8 DESC");
                        break;
                }
                DataSet dsItemList = cmd.GetDataSet();

                // Build Item list
                List<AgreementItem> sdItemList = new List<AgreementItem>();
                if (dsItemList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsItemList.Tables[0].Rows)
                    {
                        if (itemTypeCode.ToUpper() == "PN")
                        {
                            if (dsItemList.Tables[0].Columns.Contains("DESCRIPTION"))
                                sdItemList.Add(new AgreementItem { ItemType = itemTypeCode.ToUpper(), ItemNumber = row["PART.NBR"].ToString(), ItemDescription = row["DESCRIPTION"].ToString() });
                            else
                                sdItemList.Add(new AgreementItem { ItemType = itemTypeCode.ToUpper(), ItemNumber = row["PART.NBR"].ToString(), ItemDescription = "" });
                        }
                        else
                        {
                            if (dsItemList.Tables[0].Columns.Contains("DESC"))
                                sdItemList.Add(new AgreementItem { ItemType = itemTypeCode.ToUpper(), ItemNumber = row["SPEC_CODE8"].ToString(), ItemDescription = row["DESC"].ToString() });
                            else
                                sdItemList.Add(new AgreementItem { ItemType = itemTypeCode.ToUpper(), ItemNumber = row["SPEC_CODE8"].ToString(), ItemDescription = "" });
                        }
                    }
                }

                return sdItemList;
            }
        }

        public AgreementItem GetAgreementDetailListFirstItem(string agreementRequestID)
        {
            // K2 DAL
            SmartObjectClientServer server = new SmartObjectClientServer();
            try
            {
                //Make the server connection
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());

                //Get the AgreementDetails SmartObject definition
                SmartObject agreementDetails = server.GetSmartObject("AgreementDetails");

                //Get the List Method
                SmartListMethod getList = agreementDetails.ListMethods["GetList"];
                agreementDetails.MethodToExecute = getList.Name;

                //Find all AgreementDetails item list for the given requestID
                Equals agreementDetailsEqual = new Equals();
                agreementDetailsEqual.Left = new PropertyExpression("RequestID", PropertyType.Number);
                agreementDetailsEqual.Right = new ValueExpression(agreementRequestID, PropertyType.Number);

                //Apply the filter
                getList.Filter = agreementDetailsEqual;

                //Get the data
                SmartObjectList agreementDetailsList = server.ExecuteList(agreementDetails);

                //Write out values
                AgreementItem agreementItem = new AgreementItem();
                if (agreementDetailsList.SmartObjectsList.Count > 0)
                {
                    agreementItem.RequestID = agreementRequestID;
                    agreementItem.ItemType = agreementDetailsList.SmartObjectsList[0].Properties[1].Value;
                    agreementItem.ItemNumber = agreementDetailsList.SmartObjectsList[0].Properties[2].Value;
                    agreementItem.ItemDescription = agreementDetailsList.SmartObjectsList[0].Properties[3].Value;
                    agreementItem.PriceType = agreementDetailsList.SmartObjectsList[0].Properties[4].Value;
                    agreementItem.SpecialPrice = agreementDetailsList.SmartObjectsList[0].Properties[5].Value;
                    agreementItem.TradePriceList = agreementDetailsList.SmartObjectsList[0].Properties[6].Value;
                    agreementItem.PricePer = agreementDetailsList.SmartObjectsList[0].Properties[7].Value;
                    agreementItem.UnitOfMeasure = agreementDetailsList.SmartObjectsList[0].Properties[8].Value;
                }

                return agreementItem;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                server.Connection.Close();
            }
        }

        public List<AgreementPriceType> GetAgreementPriceTypeList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I289*..."" SPEC_CODE8 DESC");
                DataSet dsPriceTypeList = cmd.GetDataSet();

                // Build PriceTypelist
                List<AgreementPriceType> sdPriceTypeList = new List<AgreementPriceType>();
                if (dsPriceTypeList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsPriceTypeList.Tables[0].Rows)
                    {
                        if (dsPriceTypeList.Tables[0].Columns.Contains("DESC"))
                            sdPriceTypeList.Add(new AgreementPriceType { PriceTypeCode = row["SPEC_CODE8"].ToString(), PriceTypeName = row["DESC"].ToString() });
                        else
                            sdPriceTypeList.Add(new AgreementPriceType { PriceTypeCode = row["SPEC_CODE8"].ToString(), PriceTypeName = "" });
                    }
                }

                return sdPriceTypeList;
            }
        }

        public List<AgreementPricePer> GetAgreementPricePerList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I19*..."" SPEC_CODE8 DESC");
                DataSet dsPricePerList = cmd.GetDataSet();

                // Build PricePer list
                List<AgreementPricePer> sdPricePerList = new List<AgreementPricePer>();
                if (dsPricePerList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsPricePerList.Tables[0].Rows)
                    {
                        if (dsPricePerList.Tables[0].Columns.Contains("DESC"))
                            sdPricePerList.Add(new AgreementPricePer { PricePerCode = row["SPEC_CODE8"].ToString(), PricePerName = row["DESC"].ToString() });
                        else
                            sdPricePerList.Add(new AgreementPricePer { PricePerCode = row["SPEC_CODE8"].ToString(), PricePerName = "" });
                    }
                }

                return sdPricePerList;
            }
        }

        public List<AgreementTradePrice> GetAgreementTradePriceList(string companyCode, string distributorNumber)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list CUSTMST WITH DF_COMPANY = """ + companyCode + @""" AND WITH DF_CUSTOMER LIKE """ + distributorNumber + @"..."" PRICE_LIST");
                DataSet dsTradePriceList = cmd.GetDataSet();

                // Build TradePrice list
                List<string> tradePriceList = new List<string>();
                if (dsTradePriceList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsTradePriceList.Tables[0].Rows)
                    {
                        if (!tradePriceList.Contains(row["PRICE_LIST"].ToString()))
                        {
                            tradePriceList.Add(row["PRICE_LIST"].ToString());
                        }
                    }
                }

                // Execute UniQuery command, return result in XML then convert to DataSet
                cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SDTPL TPL REGIONAL_PRICELIST");
                dsTradePriceList = cmd.GetDataSet();

                // Build TradePrice list
                List<AgreementTradePrice> sdTradePriceList = new List<AgreementTradePrice>();
                bool found = false;
                if (dsTradePriceList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsTradePriceList.Tables[0].Rows)
                    {
                        // REGIONAL_PRICELIST_MV
                        for (int i = 0; i < dsTradePriceList.Tables[1].Rows.Count; i++)
                        {
                            if (tradePriceList.Contains(dsTradePriceList.Tables[1].Rows[i]["REGIONAL_PRICELIST"].ToString()))
                            {
                                found = true;
                                break;
                            }
                        }
                        if (found)
                        {
                            sdTradePriceList.Add(new AgreementTradePrice { TradePriceCode = row["TPL"].ToString() });
                            found = false;
                        }
                    }
                }

                return sdTradePriceList;
            }
        }

        public List<AgreementProvinceState> GetAgreementProvinceStateList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""TAX*..."" SPEC_CODE8 DESC");
                DataSet dsProvinceStateList = cmd.GetDataSet();

                // Build ProvinceStatelist
                List<AgreementProvinceState> sdProvinceStateList = new List<AgreementProvinceState>();
                if (dsProvinceStateList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsProvinceStateList.Tables[0].Rows)
                    {
                        if (dsProvinceStateList.Tables[0].Columns.Contains("DESC"))
                            sdProvinceStateList.Add(new AgreementProvinceState { ProvinceStateCode = row["SPEC_CODE8"].ToString(), ProvinceStateName = row["DESC"].ToString() });
                        else
                            sdProvinceStateList.Add(new AgreementProvinceState { ProvinceStateCode = row["SPEC_CODE8"].ToString(), ProvinceStateName = "" });
                    }
                }

                return sdProvinceStateList;
            }
        }

        public List<AgreementCountry> GetAgreementCountryList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""ECC*..."" SPEC_CODE8 DESC");
                DataSet dsCountryList = cmd.GetDataSet();

                // Build Countrylist
                List<AgreementCountry> sdCountryList = new List<AgreementCountry>();
                if (dsCountryList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsCountryList.Tables[0].Rows)
                    {
                        if (dsCountryList.Tables[0].Columns.Contains("DESC"))
                            sdCountryList.Add(new AgreementCountry { CountryCode = row["SPEC_CODE8"].ToString(), CountryName = row["DESC"].ToString() });
                        else
                            sdCountryList.Add(new AgreementCountry { CountryCode = row["SPEC_CODE8"].ToString(), CountryName = "" });
                    }
                }

                return sdCountryList;
            }
        }

        public List<AgreementCategory> GetAgreementCategoryList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I301*..."" SPEC_CODE8 DESC");
                DataSet dsCategoryList = cmd.GetDataSet();

                // Build Countrylist
                List<AgreementCategory> sdCategoryList = new List<AgreementCategory>();
                if (dsCategoryList.Tables.Count > 0)
                {
                    foreach (DataRow row in dsCategoryList.Tables[0].Rows)
                    {
                        if (dsCategoryList.Tables[0].Columns.Contains("DESC"))
                            sdCategoryList.Add(new AgreementCategory { CategoryCode = row["SPEC_CODE8"].ToString(), CategoryName = row["DESC"].ToString() });
                        else
                            sdCategoryList.Add(new AgreementCategory { CategoryCode = row["SPEC_CODE8"].ToString(), CategoryName = "" });
                    }
                }

                return sdCategoryList;
            }
        }

        public List<RequestDistributorBranch> GetRequestDistributorBranchList(string requestID)
        {
            try
            {
                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();

                try
                {
                    // Make the server connection
                    SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                    cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                    cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                    cb.Integrated = true;
                    cb.IsPrimaryLogin = true;
                    server.CreateConnection();
                    server.Connection.Open(cb.ToString());

                    // Get the agreementContractor SmartObject definition
                    SmartObject agreementContractor = server.GetSmartObject("AgreementContractor");

                    // Get the List Method
                    SmartListMethod getagreementContractorList = agreementContractor.ListMethods["GetList"];
                    agreementContractor.MethodToExecute = getagreementContractorList.Name;

                    // Find all Distributors for a specified request
                    Equals agreementContractorEqual = new Equals();
                    agreementContractorEqual.Left = new PropertyExpression("RequestID", PropertyType.Number);
                    agreementContractorEqual.Right = new ValueExpression(requestID, PropertyType.Number);

                    // Apply the filter
                    getagreementContractorList.Filter = agreementContractorEqual;

                    // Get the data                                                                                      
                    SmartObjectList agreementRequest = server.ExecuteList(agreementContractor);

                    // Write out values
                    List<RequestDistributorBranch> branchList = new List<RequestDistributorBranch>();

                    // Retrieve each sales office code from the XML document
                    string companyCode = agreementRequest.SmartObjectsList[0].Properties[1].Value;
                    string distributorNumber = agreementRequest.SmartObjectsList[0].Properties[2].Value;
                    XDocument doc = XDocument.Parse(agreementRequest.SmartObjectsList[0].Properties[4].Value);
                    string branchChecked = "";
                    foreach (XElement element in doc.Descendants("field"))
                    {
                        branchList.Add(new RequestDistributorBranch { BranchCode = element.Value, BranchName = "", BranchCodeChecked = "" });
                        branchChecked += element.Value + ";";
                    }

                    // Update for sales office name
                    using (U2Connection con = GetConnection())
                    {
                        // Get session object
                        UniSession uSession = con.UniSession;

                        // Execute UniQuery command, return result in XML then convert to DataSet
                        UniXML cmd = uSession.CreateUniXML();
                        cmd.GenerateXML(@"list SDDMST WITH @ID = """ + companyCode + "*" + distributorNumber + @""" BRANCH_CODES BRANCH_NAME");
                        DataSet dsDistributorBranch = cmd.GetDataSet();

                        // Build distributor branch list
                        if (dsDistributorBranch.Tables.Count > 0)
                        {
                            for (int i = 0; i < branchList.Count; i++)
                            {
                                if (branchList[i].BranchCode == "ALL")
                                {
                                    branchList[i].BranchName = "ALL BRANCHES";
                                    branchList[i].BranchCodeChecked = branchChecked;
                                }
                                else
                                {
                                    // BRANCH_CODES_MV & BRANCH_NAME_MV
                                    for (int j = 0; j < dsDistributorBranch.Tables[1].Rows.Count; j++)
                                    {
                                        if (branchList[i].BranchCode == dsDistributorBranch.Tables[1].Rows[j]["BRANCH_CODES"].ToString())
                                        {
                                            branchList[i].BranchName = dsDistributorBranch.Tables[2].Rows[j]["BRANCH_NAME"].ToString();
                                            branchList[i].BranchCodeChecked = branchChecked;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    return branchList;

                }
                catch (SmartObjectException soEx)
                {
                    StringBuilder sb = new StringBuilder();
                    foreach (SmartObjectExceptionData soExData in soEx.BrokerData)
                    {
                        sb.Append("Service: ");
                        sb.AppendLine(soExData.ServiceName);
                        sb.Append("Service Guid: ");
                        sb.AppendLine(soExData.ServiceGuid);
                        sb.Append("Severity: ");
                        sb.AppendLine(soExData.Severity.ToString());
                        sb.Append("Error Message: ");
                        sb.AppendLine(soExData.Message);
                        sb.Append("InnerException Message: ");
                    }
                    throw new Exception(sb.ToString());
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public string CallInfofloNewContractorAgreementRequestProcess(string requestID, string actionCode)
        {
            try
            {
                String in_data = "";
                string returnMsg = "";
                string AM = Char.ConvertFromUtf32(254);   // UniData Attribute Mark Delimiter Symbol @AM
                string VM = Char.ConvertFromUtf32(253);   // UniData Value Mark Delimiter Symbol @VM
                string SM = Char.ConvertFromUtf32(252);   // UniData Subvalue Mark Delimiter Symbol @SM

                // K2 DAL
                SmartObjectClientServer server = new SmartObjectClientServer();
                SOConnection conn = null;
                SOCommand cmd = null;

                // Make the server connection
                SCConnectionStringBuilder cb = new SCConnectionStringBuilder();
                cb.Host = WebConfigurationManager.AppSettings["K2_HOSTNAME"];
                cb.Port = Convert.ToUInt32(WebConfigurationManager.AppSettings["K2_PORT"]);
                cb.Integrated = true;
                cb.IsPrimaryLogin = true;
                server.CreateConnection();
                server.Connection.Open(cb.ToString());

                try
                {
                    if (actionCode == "A")
                    {
                        // Get the SmartObject definition
                        SmartObject agreementHeader = server.GetSmartObject("AgreementHeader");
                        SmartObject agreementDetails = server.GetSmartObject("AgreementDetails");
                        SmartObject agreementContractor = server.GetSmartObject("AgreementContractor");

                        // Get the List Method
                        SmartListMethod getAgreementHeaderList = agreementHeader.ListMethods["GetList"];
                        agreementHeader.MethodToExecute = getAgreementHeaderList.Name;
                        SmartListMethod getAgreementDetailsList = agreementDetails.ListMethods["GetList"];
                        agreementDetails.MethodToExecute = getAgreementDetailsList.Name;
                        SmartListMethod getAgreementContractorList = agreementContractor.ListMethods["GetList"];
                        agreementContractor.MethodToExecute = getAgreementContractorList.Name;

                        // Query for the given agreement requestID
                        Equals agreementHeaderEqual = new Equals();
                        agreementHeaderEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                        agreementHeaderEqual.Right = new ValueExpression(requestID, PropertyType.Text);
                        Equals agreementDetailsEqual = new Equals();
                        agreementDetailsEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                        agreementDetailsEqual.Right = new ValueExpression(requestID, PropertyType.Text);
                        Equals agreementContractorEqual = new Equals();
                        agreementContractorEqual.Left = new PropertyExpression("RequestID", PropertyType.Text);
                        agreementContractorEqual.Right = new ValueExpression(requestID, PropertyType.Text);

                        // Apply the filter
                        getAgreementHeaderList.Filter = agreementHeaderEqual;
                        getAgreementDetailsList.Filter = agreementDetailsEqual;
                        getAgreementContractorList.Filter = agreementContractorEqual;

                        // Get the data                                                                                      
                        SmartObjectList contractor = server.ExecuteList(agreementContractor);
                        SmartObjectList aHeader = server.ExecuteList(agreementHeader);
                        SmartObjectList aDetails = server.ExecuteList(agreementDetails);

                        int recordCounter = 0, propertyCounter = 0, counter = 0;
                        bool allBranchFlag = true;

                        // Build AgreementHeader record
                        foreach (SmartProperty property in aHeader.SmartObjectsList[0].Properties)
                        {
                            propertyCounter += 1;

                            if (property.Name == "AllBranchFlag")
                            {
                                allBranchFlag = (property.Value == "True") ? true : false;
                                continue;
                            }

                            if (property.Name == "BranchCode")
                            {
                                if (allBranchFlag)
                                {
                                    in_data += "ALL";
                                }
                                else
                                {
                                    // Retrieve each sales office code from the XML document
                                    XDocument doc = XDocument.Parse(property.Value);
                                    foreach (XElement element in doc.Descendants("field"))
                                    {
                                        counter += 1;
                                        if (counter == 1)
                                            in_data += element.Value;
                                        else
                                            in_data += SM + element.Value;
                                    }
                                }
                                in_data += VM;
                            }
                            else
                            {
                                if (propertyCounter < aHeader.SmartObjectsList[0].Properties.Count)
                                    in_data += property.Value + VM;
                                else
                                    in_data += property.Value + AM;
                            }
                        }

                        // Build AgreementDetail record(s)
                        recordCounter = 0;
                        foreach (SmartObject agreementDetailRecord in aDetails.SmartObjectsList)
                        {
                            recordCounter += 1;
                            propertyCounter = 0;
                            foreach (SmartProperty property in agreementDetailRecord.Properties)
                            {
                                propertyCounter += 1;
                                if (property.Name == "RequestID")
                                    continue;
                                else
                                {
                                    if (propertyCounter < agreementDetailRecord.Properties.Count)
                                        in_data += property.Value + SM;
                                    else
                                        in_data += property.Value;
                                }
                            }

                            if (recordCounter < aDetails.SmartObjectsList.Count)
                                in_data += VM;
                            else
                                in_data += AM;
                        }

                        // Build AggrementContractor record
                        propertyCounter = 0;
                        foreach (SmartProperty property in contractor.SmartObjectsList[0].Properties)
                        {
                            propertyCounter += 1;
                            if (property.Name == "RequestID")
                                continue;
                            else
                            {
                                if (property.Name == "BranchCode")
                                {
                                    // Retrieve each sales office code from the XML document
                                    XDocument doc = XDocument.Parse(property.Value);
                                    if (doc.Descendants("field").Count() == 0)
                                    {
                                        in_data += "ALL";
                                    }
                                    else
                                    {
                                        counter = 0;
                                        foreach (XElement element in doc.Descendants("field"))
                                        {
                                            counter += 1;
                                            if (counter < doc.Descendants("field").Count())
                                                in_data += element.Value + SM;
                                            else
                                                in_data += element.Value + VM;
                                        }
                                    }
                                }
                                else
                                {
                                    if (propertyCounter < contractor.SmartObjectsList[0].Properties.Count)
                                        in_data += property.Value + VM;
                                    else
                                        in_data += property.Value;
                                }
                            }
                        }

                        // Infoflo DAL
                        using (U2Connection con = GetConnection())
                        {
                            // Get session object
                            UniSession uSession = con.UniSession;

                            // Get SDC UniBasic program name and its number of parameters
                            string subName = WebConfigurationManager.AppSettings["SDC_CONTRACTOR_AGREEMENT"].ToString().Split('|')[0];
                            int paramsCount = Convert.ToInt32(WebConfigurationManager.AppSettings["SDC_CONTRACTOR_AGREEMENT"].ToString().Split('|')[1]);

                            // UniBasic Subroutine Call
                            UniSubroutine uniSub = uSession.CreateUniSubroutine(subName, paramsCount);
                            uniSub.SetArg(0, in_data);      // new contractor agreement request data
                            uniSub.SetArg(1, "");           // return message
                            uniSub.Call();

                            // Last parameter is return status
                            returnMsg = uniSub.GetArg(paramsCount - 1);
                        }
                    }

                    // Update status
                    conn = new SOConnection(cb.ToString());
                    cmd = new SOCommand();
                    cmd.Connection = conn;
                    cmd.CommandText = "UPDATE [AgreementRequest] " +
                                      "SET [Status]='" + actionCode + "', " +
                                      "[DateTimeReplied]='" + DateTime.Now.ToString("dd/MM/yyyy hh:mm tt") + "', " +
                                      "[ReturnMessage]='" + returnMsg + "' " +
                                      "WHERE [ID]='" + requestID + "'";
                    cmd.ExecuteNonQuery();
                    return returnMsg;
                }
                catch (SmartObjectException soEx)
                {
                    StringBuilder sb = new StringBuilder();
                    foreach (SmartObjectExceptionData soExData in soEx.BrokerData)
                    {
                        sb.Append("Service: ");
                        sb.AppendLine(soExData.ServiceName);
                        sb.Append("Service Guid: ");
                        sb.AppendLine(soExData.ServiceGuid);
                        sb.Append("Severity: ");
                        sb.AppendLine(soExData.Severity.ToString());
                        sb.Append("Error Message: ");
                        sb.AppendLine(soExData.Message);
                        sb.Append("InnerException Message: ");
                    }
                    throw new Exception(sb.ToString());
                }
                finally
                {
                    server.Connection.Close();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        #endregion
    }
}