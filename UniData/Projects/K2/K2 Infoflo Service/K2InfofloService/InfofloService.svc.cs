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
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service1" in code, svc and config file together.
    public class InfofloService : IInfofloService
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

        // ************************************************************************************************* //

        #region Infoflo Common Functions

        public List<Addressbook> GetAddressbookList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list ADDRESSBOOK KEY NAME EMAIL_ADDRESS");
                DataSet dsAddressbook = cmd.GetDataSet();

                // Build product cross reference code/desc list
                List<Addressbook> addressbookList = new List<Addressbook>();
                if (dsAddressbook.Tables.Count > 0)
                {
                    foreach (DataRow row in dsAddressbook.Tables[0].Rows)
                    {
                        addressbookList.Add(new Addressbook { Userid = row["_ID"].ToString(), Name = row["NAME"].ToString(), Email = row["EMAIL_ADDRESS"].ToString() });
                    }
                }

                return addressbookList;
            }
        }

        public List<Company> GetCompanyList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Open UniFile SYSCON
                UniFile fileSYSCON = uSession.CreateUniFile("SYSCON");
                fileSYSCON.Open();

                // Read SYSCON table SHP.DBT.CONSTANTS and COMPMST to get company code/description 
                UniDynArray udArray = fileSYSCON.ReadField("SHP.DBT.CONSTANTS", 2);
                string[] ar_companyCode = udArray.ToString().Split(';')[0].Trim().Split(Convert.ToChar(253));
                UniFile fileCOMPMST = uSession.CreateUniFile("COMPMST");
                fileCOMPMST.Open();
                UniDataSet uSet = fileCOMPMST.ReadRecords(ar_companyCode);

                // Build list of company
                List<Company> companyList = new List<Company>();
                for (int i = 0; i < ar_companyCode.Count(); i++)
                {
                    companyList.Add(new Company { CompanyCode = ar_companyCode[i], CompanyName = fileCOMPMST.ReadField(ar_companyCode[i], 1).ToString() });
                }

                return companyList;
            }
        }

        public List<SalesOffice> GetSalesOfficeList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I13*..."" DESC");
                DataSet dsSalesOffice = cmd.GetDataSet();

                // Build sales office list
                List<SalesOffice> slsOffList = new List<SalesOffice>();
                if (dsSalesOffice.Tables.Count > 0)
                {
                    foreach (DataRow row in dsSalesOffice.Tables[0].Rows)
                    {
                        if (!row["DESC"].ToString().ToUpper().Contains("NOT USED"))
                            slsOffList.Add(new SalesOffice { SalesOfficeCode = row["_ID"].ToString().Split('*')[1], SalesOfficeName = row["DESC"].ToString() });
                    }
                }

                return slsOffList;
            }
        }

        public List<Warehouse> GetWarehouseList()
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""WHS*..."" DESC");
                DataSet dsWarehouse = cmd.GetDataSet();

                // Build sales office list
                List<Warehouse> warehouseList = new List<Warehouse>();
                if (dsWarehouse.Tables.Count > 0)
                {
                    foreach (DataRow row in dsWarehouse.Tables[0].Rows)
                    {
                        if (!row["DESC"].ToString().ToUpper().Contains("NOT USED"))
                            warehouseList.Add(new Warehouse { WarehouseCode = row["_ID"].ToString().Split('*')[1], WarehouseName = row["DESC"].ToString() });
                    }
                }

                return warehouseList;
            }
        }

        #endregion
    }
}
