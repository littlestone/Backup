using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.IO;
using System.Web;
using System.Web.Configuration;

namespace WebServiceRepository
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "InfofloService" in code, svc and config file together.
    public partial class InfofloService : IInfofloService
    {
        #region IInfofloService Members

        /// <summary>
        /// This function performs the initial PIC request handling as the following:
        /// 1. Retrieve the encrypted PIC parameters string form query string on URI.
        /// 2. Call Infoflo Encrypt / Decrypt program to get the decrypted PIC parameters string.
        /// 3. If PIC user security is on, display PIC User Authentication HTML web page and wait for user to enter their domain login credential.
        /// 4. On user submit, post entered username and password along with the encrypted PIC parameters string in the hidden input field as a form.
        /// 5. Display various PIC response messages on HTML web page through data stream.
        /// </summary>
        public Stream DeserializePicGetRequest(string picParamsEncrypted)
        {
            try
            {
                // Secure the URI resource
                if (picParamsEncrypted == "" || picParamsEncrypted == null)
                {
                    throw new Exception(WebConfigurationManager.AppSettings["INVALID_ENDPOINT"].ToString());
                }

                var picInfo = CallPicDecryptProcess(picParamsEncrypted);
                if (picInfo == null || picInfo.Item2.ToString() != "")
                {
                    // PIC parameters decryption process failed.
                    throw new Exception(picInfo.Item2);
                }

                // Turn On / Off PIC User Security
                bool picUserSecuritySwitch = Convert.ToBoolean(Convert.ToInt16(picInfo.Item1[1]));
                if (picUserSecuritySwitch == true)
                {
                    // Display PIC Approver Authentication Page in HTML
                    System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                    MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlLoginPage(picParamsEncrypted)));
                    WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";
                    MemoryStream stream = new MemoryStream();

                    return ms;
                }
                else
                {
                    // Call PIC Process Without User Security
                    System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                    MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlResponsePage(CallPicProcess(picInfo.Item1, ""))));
                    WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                    return ms;
                }

            }
            catch (Exception ex)
            {
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlResponsePage(ex.Message)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
        }

        /// <summary>
        /// This function handles the PIC request received from PIC User Authentication html web page as the following:
        /// 1. Retrieve PIC user login credential and encrypted parameters from query string in the posted HTML form.
        /// 2. Validate the username and password against active directory and PIC approver userid for user security check.
        /// 3. Call Infoflo program to perform PIC process and display various response messages in HTML web page through stream.
        /// </summary>
        public Stream DeserializePicPostRequest(Stream request)
        {
            try
            {
                // Get http post stream from HTML form 
                StreamReader reader = new StreamReader(request);

                // Parse the query string variables into a NameValueCollection.
                string queryString = reader.ReadToEnd();
                NameValueCollection qscoll = HttpUtility.ParseQueryString(queryString);
                string domainUserName = qscoll["userid"];    // IPEX domain user credential (AD Username)
                string domainPassword = qscoll["password"];  // IPEX domain user credential (AD Password)
                string picParamsEncrypted = qscoll["picParms"];
                string picReturnMsg = "";

                // Common Subroutines
                CommonServiceLibrary commonServiceLibrary = new CommonServiceLibrary();

                // Authenticate Requester's Login Credential with Active Directory
                if (commonServiceLibrary.IsAuthenticated(domainUserName, domainPassword))
                {
                    var picInfo = CallPicDecryptProcess(picParamsEncrypted);
                    picReturnMsg = CallPicProcess(picInfo.Item1, domainUserName);
                }
                else
                {
                    picReturnMsg = WebConfigurationManager.AppSettings["INVALID_LOGIN"].ToString();
                }

                // Display response text message in HTML
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlResponsePage(picReturnMsg)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
            catch (Exception ex)
            {
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlResponsePage(ex.Message)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
        }

        /// <summary>
        /// This function performs the following 3 actions:
        /// 1. Decrypt the encrypted PIC parameters string.
        /// 2. Parse decrypted PIC parameters string.
        /// 3. Build a tuple to return a list of decrypted PIC parameters and decryption error message if there is any.
        /// </summary>
        private Tuple<List<string>, string> CallPicDecryptProcess(string picParamsEncrypted)
        {
            string picReturnMsg = "";
            string FM = Char.ConvertFromUtf32(254);     // UniData Delimiter Symbol @FM

            // Common Subroutines
            CommonServiceLibrary commonServiceLibrary = new CommonServiceLibrary();

            // Establish Infoflo session for PIC
            Infoflo pic = new Infoflo();

            // Decrypt the encrypted PIC parameters
            string bpEncryptName = WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[0];
            int bpEncryptParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[1]);
            string picParamsDecrypted = pic.CallUniBasicProgram(bpEncryptName, bpEncryptParmsNum, commonServiceLibrary.GetEncryptedParmsList(picParamsEncrypted));

            // Explicitly release UniObject.Net resource before GC kicks in
            pic.Disconnect();

            // Unable to decrypt, display detail error message returned from Infoflo PIC program.
            if (picParamsDecrypted.Contains(FM) || picParamsDecrypted.Contains("ErrorCode"))
            {
                picReturnMsg = picParamsDecrypted.Replace(FM, "");
                return new Tuple<List<string>, string>(null, picReturnMsg);
            }
            else
            {
                try
                {
                    // Parse and build the decrypted PIC parameters list
                    List<string> decryptedPicParamsList = new List<string>()
                    {
                        picParamsDecrypted.Split('|')[0],   // Infoflo Account (D, P or A)
                        picParamsDecrypted.Split('|')[1],   // User Security Switch ("0" or "1")
                        picParamsDecrypted.Split('|')[2],   // PO Number
                        picParamsDecrypted.Split('|')[3],   // Approver User ID
                        picParamsDecrypted.Split('|')[4],   // PIC Action (A, X or B)
                        picParamsDecrypted.Split('|')[5],   // PIC $Amount Approval Level
                        picParamsDecrypted.Split('|')[6],   // Last PIC Request Email Timestamp
                        ""                                  // PIC Process Return Message
                    };
                    return new Tuple<List<string>, string>(decryptedPicParamsList, picReturnMsg);
                }
                catch (Exception ex)
                {
                    throw new Exception(WebConfigurationManager.AppSettings["ERROR_DECRYPT"].ToString() + " (" + ex.Message + ")");
                }
            }
        }

        /// <summary>
        /// This function performs the Infoflo PIC process as the following:
        /// 1. Determine which Infoflo account to connect.
        /// 2. Call Infoflo PIC process based on the user security switch value and return PIC response message as a string.
        /// </summary>
        private string CallPicProcess(List<string> decryptedPicParamsList, string domainUserName)
        {
            // Determine Infoflo Account
            string picInfofloAccount = "";
            switch (decryptedPicParamsList[0])
            {
                case "D":
                    picInfofloAccount = "DEV";
                    break;
                case "P":
                    picInfofloAccount = "PREP";
                    break;
                case "A":
                    picInfofloAccount = "ACCT";
                    break;
            }
            Infoflo pic = new Infoflo(picInfofloAccount);

            string picReturnMsg = "";

            // Get PIC UniBasic program name and its number of parameters
            string picProgramName = WebConfigurationManager.AppSettings["PIC_PROGRAM"].ToString().Split('|')[0];
            int picProgramParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["PIC_PROGRAM"].ToString().Split('|')[1]);

            // PIC User Security Check Turned Off
            if (domainUserName == "")
            {
                // Call PIC Process
                decryptedPicParamsList.RemoveRange(0, 2);   // remove Infoflo account and security switch parameters, not need anymore
                picReturnMsg = pic.CallUniBasicProgram(picProgramName, picProgramParmsNum, decryptedPicParamsList);
            }
            else
            {
                // Verify requester's domain identity name (AD) versus the approver's userid
                if (decryptedPicParamsList[3].ToLower() == domainUserName.ToLower())
                {
                    // Call PIC Process
                    decryptedPicParamsList.RemoveRange(0, 2);   // remove Infoflo account and security switch parameters, not need anymore
                    picReturnMsg = pic.CallUniBasicProgram(picProgramName, picProgramParmsNum, decryptedPicParamsList);
                }
                else
                {
                    picReturnMsg = WebConfigurationManager.AppSettings["INVALID_APPROVER"].ToString();
                }
            }

            // Explicitly release UniObject.Net resource before GC kicks in
            pic.Disconnect();

            return picReturnMsg;
        }

        /// <summary>
        /// This function generates the PIC html response web page and return as a string.
        /// </summary>
        private string BuildPicHtmlResponsePage(string responseText)
        {
            string htmlResponsePage = "";
            htmlResponsePage = "<!DOCTYPE html>";
            htmlResponsePage += "<head>";
            htmlResponsePage += "<title>PIC Return Message.</title>";
            htmlResponsePage += @"<style type=""text/css"">";
            htmlResponsePage += "<!--";
            htmlResponsePage += "body{margin:0;font-size:.7em;font-family:Verdana, Arial, Helvetica, sans-serif;background:#EEEEEE;}";
            htmlResponsePage += "fieldset{padding:0 15px 10px 15px;}";
            htmlResponsePage += "h1{font-size:2.4em;margin:0;color:#FFF;}";
            htmlResponsePage += "h2{font-size:1.7em;margin:0;color:#CC0000;}";
            htmlResponsePage += "h3{font-size:1.2em;margin:10px 0 0 0;color:#0000A0;}";
            htmlResponsePage += @"#header{width:96%;margin:0 0 0 0;padding:6px 2% 6px 2%;font-family:""trebuchet MS"", Verdana, sans-serif;color:#FFF;";
            htmlResponsePage += "background-color:#555555;}";
            htmlResponsePage += "#content{margin:0 0 0 2%;position:relative;}";
            htmlResponsePage += ".content-container{background:#FFF;width:96%;margin-top:8px;padding:10px;position:relative;}";
            htmlResponsePage += "-->";
            htmlResponsePage += "</style>";
            htmlResponsePage += "<body>";
            htmlResponsePage += @"<div id=""header""><h1>PO Internal Controls Response Message / Message de Controles Internes de BC</h1></div>";
            htmlResponsePage += @"<div id=""content"">";
            htmlResponsePage += @" <div class=""content-container""><fieldset>";
            htmlResponsePage += "  <h3>" + responseText + "</h3>";
            htmlResponsePage += " </fieldset></div>";
            htmlResponsePage += "</div>";
            htmlResponsePage += "</body>";
            htmlResponsePage += "</html>";

            return htmlResponsePage;
        }

        /// <summary>
        /// This function generates the PIC html user authentication html web page and return as a string.
        /// </summary>
        private string BuildPicHtmlLoginPage(string picParamsEncrypted)
        {
            string wsURI = WebConfigurationManager.AppSettings["WS_URI_PIC"].ToString();
            string htmlResponsePage = "";
            htmlResponsePage = "<!DOCTYPE html>";
            htmlResponsePage += "<head>";
            htmlResponsePage += "<title>Login</title>";
            htmlResponsePage += @"<meta http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"">";
            htmlResponsePage += "</head>";
            htmlResponsePage += @"<body bgcolor=""#FFFFFF"" text=""#000000"">";
            htmlResponsePage += "<tr>";
            htmlResponsePage += @"<td valign=""middle"" height=""700"">";
            htmlResponsePage += @"<form name=""form1"" method=""post"" action=""" + wsURI + @""">";
            htmlResponsePage += @"<input type=""hidden"" name=""picParms"" value=""" + picParamsEncrypted + @"""/>";
            htmlResponsePage += @"<table width=""300"" border=""0"" align=""center"">";
            htmlResponsePage += @"<tr bgcolor=""#CCCCCC"">";
            htmlResponsePage += @"<td colspan=""2"">";
            htmlResponsePage += @"<div align=""center""><b>PIC User Authentication</b></div>";
            htmlResponsePage += "</td>";
            htmlResponsePage += "</tr>";
            htmlResponsePage += "<tr>";
            htmlResponsePage += @"<td><b><font color=""#660000"">Username:</font></b></td>";
            htmlResponsePage += "<td>";
            htmlResponsePage += @"<input type=""text"" name=""userid"" autofocus=""autofocus"" required/>";
            htmlResponsePage += "</td>";
            htmlResponsePage += "</tr>";
            htmlResponsePage += "<tr>";
            htmlResponsePage += @"<td><b><font color=""#660000"">Password:</font></b></td>";
            htmlResponsePage += "<td>";
            htmlResponsePage += @"<input type=""password"" name=""password"" required/>";
            htmlResponsePage += "</td>";
            htmlResponsePage += "</tr>";
            htmlResponsePage += "<tr>";
            htmlResponsePage += "<td> </td>";
            htmlResponsePage += "<td>";
            htmlResponsePage += @"<input type=""submit"" name=""Submit"" value=""Submit"">";
            htmlResponsePage += "</td>";
            htmlResponsePage += "</tr>";
            htmlResponsePage += "</table>";
            htmlResponsePage += "</form>";
            htmlResponsePage += "</body>";
            htmlResponsePage += "</html>";

            return htmlResponsePage;
        }

        #endregion
    }
}