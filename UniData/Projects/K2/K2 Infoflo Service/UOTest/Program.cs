using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using U2.Data.Client;
using U2.Data.Client.UO;

namespace UOTest
{
    class Program
    {
        static void Main(string[] args)
        {
            U2Connection con = null;
            try
            {
                ///
                /// Establish connection to UniData
                ///
                U2ConnectionStringBuilder conn_str = new U2ConnectionStringBuilder();
                conn_str.UserID = "webusr";
                conn_str.Password = "userws";
                conn_str.Server = "erp.corpservices.local";
                conn_str.Database = "DEV";
                conn_str.ServerType = "UNIDATA";
                conn_str.AccessMode = "Native";     // FOR UO
                conn_str.RpcServiceType = "udcs";   // FOR UO UniData (Universe=uvcs)
                conn_str.Pooling = false;
                string s = conn_str.ToString();
                con = new U2Connection();
                con.ConnectionString = s;
                con.Open();
                Console.WriteLine("Connected.........................");

                /*
                UniSession uSession = con.UniSession;
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list SYSTBL WITH @ID LIKE ""I13*..."" F4");
                DataSet dsSalesOffice = cmd.GetDataSet();
                string response_str = cmd.XMLString;
                Console.WriteLine("UniCommand Output" + response_str + Environment.NewLine);
                foreach (DataRow row in dsSalesOffice.Tables[0].Rows)
                {
                    response_str = row["_ID"].ToString() + "\t" + row["F4"].ToString();
                    Console.WriteLine(response_str + Environment.NewLine);
                }
                */

                /*
                // open UniFile SYSCON
                UniSession uSession = con.UniSession;
                UniFile fileSYSCON = uSession.CreateUniFile("SYSCON");
                fileSYSCON.Open();

                // read SYSCON table SHP.DBT.CONSTANTS to retrieve SD company code list
                UniDynArray udArray = fileSYSCON.ReadField("SHP.DBT.CONSTANTS", 2);
                string[] ar_companyCode = udArray.ToString().Split(';')[0].Trim().Split(Convert.ToChar(253));

                // get corresponding SD company description list from COMPMST
                UniFile fileCOMPMST = uSession.CreateUniFile("COMPMST");
                fileCOMPMST.Open();
                UniDataSet uSet = fileCOMPMST.ReadRecords(ar_companyCode);
                string[] ar_companyDesc = new string[] {};
                foreach (UniRecord item in uSet)
                {
                    Console.WriteLine(item.Record.Extract(1).StringValue);
                }
                 * */

                // Get session object
                UniSession uSession = con.UniSession;

                // Retrieve SELECT list of SD distributor ship to # from CUSTMST file
                UniCommand cmd = uSession.CreateUniCommand();
                cmd.Command = @"select CUSTMST WITH @ID LIKE ""16*3295200...""";
                cmd.Execute();

                // Build list of distributor
                UniXML cmdXML = uSession.CreateUniXML();
                cmdXML.GenerateXML(@"list CUSTMST DF_SHIP_TO CONTACT SHIPTO_CONTACT_EMAIL");
                Console.WriteLine(cmdXML.XMLString);
                ///
                /// Clean up
                ///
                con.Close();
            }
            catch (Exception ex)
            {
                //some error, display it 
                Console.WriteLine(ex.Message);
            }
            finally
            {
                // no error
                if (con != null)
                {
                    con.Close();
                    con = null;
                }
                Console.WriteLine("Enter to exit:");
                Console.ReadKey();
            }
        }
    }
}
