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
        /// This function performs the initial SDC request handling as the following:
        /// 1. Retrieve the encrypted SDC parameters string form query string on URI.
        /// 2. Call Infoflo Encrypt / Decrypt program to get the decrypted SDC parameters string.
        /// 3. If SDC user security is on, display SDC User Authentication HTML web page and wait for user to enter their domain login credential.
        /// 4. On user submit, post entered username and password along with the encrypted SDC parameters string in the hidden input field as a form.
        /// 5. Display various SDC response messages on HTML web page through data stream.
        /// </summary>
        public Stream DeserializeSdcGetRequest(string sdcParamsEncrypted)
        {
            try
            {
                // Secure the URI resource
                if (sdcParamsEncrypted == "" || sdcParamsEncrypted == null)
                {
                    throw new Exception(WebConfigurationManager.AppSettings["INVALID_ENDPOINT"].ToString());
                }

                var sdcInfo = CallSdcDecryptProcess(sdcParamsEncrypted);
                if (sdcInfo == null || sdcInfo.Item2.ToString() != "")
                {
                    // SDC parameters decryption process failed.
                    throw new Exception(sdcInfo.Item2);
                }

                // Turn On / Off SDC User Security
                bool sdcUserSecuritySwitch = Convert.ToBoolean(Convert.ToInt16(sdcInfo.Item1[1]));
                if (sdcUserSecuritySwitch == true)
                {
                    // Display SDC Approver Authentication Page in HTML
                    System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                    MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildSdcHtmlLoginPage(sdcParamsEncrypted)));
                    WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";
                    MemoryStream stream = new MemoryStream();

                    return ms;
                }
                else
                {
                    // Call SDC Process Without User Security
                    System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                    MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildSdcHtmlResponsePage(CallSdcProcess(sdcInfo.Item1, ""))));
                    WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                    return ms;
                }

            }
            catch (Exception ex)
            {
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildSdcHtmlResponsePage(ex.Message)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
        }

        /// <summary>
        /// This function handles the SDC request received from SDC User Authentication html web page as the following:
        /// 1. Retrieve SDC user login credential and encrypted parameters from query string in the posted HTML form.
        /// 2. Validate the username and password against active directory and SDC approver userid for user security check.
        /// 3. Call Infoflo program to perform SDC process and display various response messages in HTML web page through stream.
        /// </summary>
        public Stream DeserializeSdcPostRequest(Stream request)
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
                string sdcParamsEncrypted = qscoll["sdcParms"];
                string sdcReturnMsg = "";

                // Common Subroutines
                CommonServiceLibrary commonServiceLibrary = new CommonServiceLibrary();

                // Authenticate Requester's Login Credential with Active Directory
                if (commonServiceLibrary.IsAuthenticated(domainUserName, domainPassword))
                {
                    var sdcInfo = CallSdcDecryptProcess(sdcParamsEncrypted);
                    sdcReturnMsg = CallSdcProcess(sdcInfo.Item1, domainUserName);
                }
                else
                {
                    sdcReturnMsg = WebConfigurationManager.AppSettings["INVALID_LOGIN"].ToString();
                }

                // Display response text message in HTML
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildSdcHtmlResponsePage(sdcReturnMsg)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
            catch (Exception ex)
            {
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildSdcHtmlResponsePage(ex.Message)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
        }

        /// <summary>
        /// This function performs the following 3 actions:
        /// 1. Decrypt the encrypted SDC parameters string.
        /// 2. Parse decrypted SDC parameters string.
        /// 3. Build a tuple to return a list of decrypted SDC parameters and decryption error message if there is any.
        /// </summary>
        private Tuple<List<string>, string> CallSdcDecryptProcess(string sdcParamsEncrypted)
        {
            string sdcReturnMsg = "";
            string FM = Char.ConvertFromUtf32(254);     // UniData Delimiter Symbol @FM

            // Common Subroutines
            CommonServiceLibrary commonServiceLibrary = new CommonServiceLibrary();

            // Establish Infoflo session for SDC
            Infoflo sdc = new Infoflo();

            // Decrypt the encrypted SDC parameters
            string bpEncryptName = WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[0];
            int bpEncryptParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[1]);
            string sdcParamsDecrypted = sdc.CallUniBasicProgram(bpEncryptName, bpEncryptParmsNum, commonServiceLibrary.GetEncryptedParmsList(sdcParamsEncrypted));

            // Explicitly release UniObject.Net resource before GC kicks in
            sdc.Disconnect();

            // Unable to decrypt, display detail error message returned from Infoflo SDC program.
            if (sdcParamsDecrypted.Contains(FM) || sdcParamsDecrypted.Contains("ErrorCode"))
            {
                sdcReturnMsg = sdcParamsDecrypted.Replace(FM,"");
                return new Tuple<List<string>, string>(null, sdcReturnMsg);
            }
            else
            {
                try
                {
                    // Parse and build the decrypted SDC parameters list
                    List<string> decryptedSdcParamsList = new List<string>()
                    {
                        sdcParamsDecrypted.Split('|')[0],   // Infoflo Account (D, P or A)
                        sdcParamsDecrypted.Split('|')[1],   // User Security Switch ("0" or "1")
                        sdcParamsDecrypted.Split('|')[2],   // SDCAUDIT Key (Company*Distributor*ClaimNumber)
                        sdcParamsDecrypted.Split('|')[3],   // Approver Userid
                        sdcParamsDecrypted.Split('|')[4],   // SDC Action (A, X or B)
                        sdcParamsDecrypted.Split('|')[5],   // SLA Level Cnt
                        sdcParamsDecrypted.Split('|')[6],   // Last SDC Request Email Timestamp
                        ""                                  // SDC Process Return Message
                    };
                    return new Tuple<List<string>, string>(decryptedSdcParamsList, sdcReturnMsg);
                }
                catch (Exception ex)
                {
                    throw new Exception(WebConfigurationManager.AppSettings["ERROR_DECRYPT"].ToString() + " (" + ex.Message + ")");
                }
            }
        }

        /// <summary>
        /// This function performs the Infoflo SDC process as the following:
        /// 1. Determine which Infoflo account to connect.
        /// 2. Call Infoflo SDC process based on the user security switch value and return SDC response message as a string.
        /// </summary>
        private string CallSdcProcess(List<string> decryptedSdcParamsList, string domainUserName)
        {
            // Determine Infoflo Account
            string sdcInfofloAccount = "";
            switch (decryptedSdcParamsList[0])
            {
                case "D":
                    sdcInfofloAccount = "DEV";
                    break;
                case "P":
                    sdcInfofloAccount = "PREP";
                    break;
                case "A":
                    sdcInfofloAccount = "ACCT";
                    break;
            }
            Infoflo sdc = new Infoflo(sdcInfofloAccount);

            string sdcReturnMsg = "";

            // Get SDC UniBasic program name and its number of parameters
            string sdcProgramName = WebConfigurationManager.AppSettings["SDC_PROGRAM"].ToString().Split('|')[0];
            int sdcProgramParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["SDC_PROGRAM"].ToString().Split('|')[1]);

            // SDC User Security Check Turned Off
            if (domainUserName == "")
            {
                // Call SDC Process
                decryptedSdcParamsList.RemoveRange(0, 2);   // remove Infoflo account and security switch parameters, not need anymore
                sdcReturnMsg = sdc.CallUniBasicProgram(sdcProgramName, sdcProgramParmsNum, decryptedSdcParamsList);
            }
            else
            {
                // Verify requester's domain identity name (AD) versus the approver's userid
                if (decryptedSdcParamsList[3].ToLower() == domainUserName.ToLower())
                {
                    // Call SDC Process
                    decryptedSdcParamsList.RemoveRange(0, 2);   // remove Infoflo account and security switch parameters, not need anymore
                    sdcReturnMsg = sdc.CallUniBasicProgram(sdcProgramName, sdcProgramParmsNum, decryptedSdcParamsList);
                }
                else
                {
                    sdcReturnMsg = WebConfigurationManager.AppSettings["INVALID_APPROVER"].ToString();
                }
            }

            // Explicitly release UniObject.Net resource before GC kicks in
            sdc.Disconnect();

            return sdcReturnMsg;
        }

        /// <summary>
        /// This function generates the SDC html response web page and return as a string.
        /// </summary>
        private string BuildSdcHtmlResponsePage(string responseText)
        {
            string htmlResponsePage = "";
            htmlResponsePage = "<!DOCTYPE html>";
            htmlResponsePage += "<head>";
            htmlResponsePage += "<title>SDC Return Message.</title>";
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
            htmlResponsePage += @"<div id=""header""><h1>SDC Internal Controls Response Message / Message de Controles Internes de SDC</h1></div>";
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
        /// This function generates the SDC html user authentication html web page and return as a string.
        /// </summary>
        private string BuildSdcHtmlLoginPage(string sdcParamsEncrypted)
        {
            string wsURI = WebConfigurationManager.AppSettings["WS_URI_SDC"].ToString();
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
            htmlResponsePage += @"<input type=""hidden"" name=""SDCParms"" value=""" + sdcParamsEncrypted + @"""/>";
            htmlResponsePage += @"<table width=""300"" border=""0"" align=""center"">";
            htmlResponsePage += @"<tr bgcolor=""#CCCCCC"">";
            htmlResponsePage += @"<td colspan=""2"">";
            htmlResponsePage += @"<div align=""center""><b>SDC User Authentication</b></div>";
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