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

        public Stream DeserializePicRequest(string picParamsEncrypted)
        {
            try
            {   
                // Secure the URI resource
                if (picParamsEncrypted == "" || picParamsEncrypted == null)
                {
                    throw new Exception(WebConfigurationManager.AppSettings["INVALID_ENDPOINT"].ToString());
                }

                // Display PIC Approver Authentication Page in HTML
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlLoginPage(picParamsEncrypted)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
            catch(Exception ex)
            {
                System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                MemoryStream ms = new MemoryStream(encoding.GetBytes(BuildPicHtmlResponsePage(ex.Message)));
                WebOperationContext.Current.OutgoingResponse.ContentType = "text/html";

                return ms;
            }
        }

        public Stream DeserializePostRequest(Stream request)
        {
            // Get http post stream from HTML form 
            StreamReader reader = new StreamReader(request);

            // Parse the query string variables into a NameValueCollection.
            string queryString = reader.ReadToEnd();//HttpUtility.UrlDecode(reader.ReadToEnd());
            NameValueCollection qscoll = HttpUtility.ParseQueryString(queryString);
            string domainUserName = qscoll["userid"];    // IPEX domain user credential
            string domainPassword = qscoll["password"];  // IPEX domain user credential
            string picParamsEncrypted = qscoll["picParms"];  // IPEX domain user credential
            string picReturnMsg = "";

            // Common Subroutines
            CommonServiceLibrary commonServiceLibrary = new CommonServiceLibrary();

            // Authenticate Requester's Login Crendential with Active Directory
            if (commonServiceLibrary.IsAuthenticated(domainUserName, domainPassword))
            {
                // Establish Infoflo session for PIC
                Infoflo pic = new Infoflo();

                // Decrypt the encrypted PIC parameters
                string bpEncryptName = WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[0];
                int bpEncryptParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["ENCRYPT_DECRYPT"].ToString().Split('|')[1]);
                string picParamsDecrypted = pic.CallUniBasicProgram(bpEncryptName, bpEncryptParmsNum, commonServiceLibrary.GetEncryptedParmsList(picParamsEncrypted));

                // Unable to decrypt, display detail error message returned from Infoflo PIC program.
                if (picParamsDecrypted.Split((char)254)[0] == "" || picParamsDecrypted.Split((char)254)[0].Contains("ErrorCode"))
                {
                    throw new Exception(picParamsDecrypted.Split((char)254)[1]);
                }

                // Get PIC UniBasic program name and its number of parameters
                string picProgramName = WebConfigurationManager.AppSettings["PIC_PROGRAM"].ToString().Split('|')[0];
                int picProgramParmsNum = Convert.ToInt32(WebConfigurationManager.AppSettings["PIC_PROGRAM"].ToString().Split('|')[1]);

                // Parse the decrypted PIC parameters
                string picPoNumber = picParamsDecrypted.Split('|')[0];
                string picApproverUserID = picParamsDecrypted.Split('|')[1];
                string picAction = picParamsDecrypted.Split('|')[2];
                string picLevel = picParamsDecrypted.Split('|')[3];
                string picEmailTimestamp = picParamsDecrypted.Split('|')[4];

                // Verify requester's domain identity name (AD) versus the approver's userid
                if (picApproverUserID.ToLower() == domainUserName.ToLower())
                {
                    List<string> decryptedPicParamsList = new List<string>();
                    decryptedPicParamsList = GetDecryptedParmsList(picPoNumber, picApproverUserID, picAction, picLevel, picEmailTimestamp);
                    picReturnMsg = pic.CallUniBasicProgram(picProgramName, picProgramParmsNum, decryptedPicParamsList);

                    // Explicitly release UniObject.Net resource before GC kicks in
                    pic.Disconnect();
                }
                else
                {
                    picReturnMsg = WebConfigurationManager.AppSettings["INVALID_APPROVER"].ToString();
                }
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

        private List<string> GetDecryptedParmsList(string picPoNumber, string picApproverUserID, string picAction, string picLevel, string picEmailTimestamp)
        {
            List<string> paramsList = new List<string>();
            paramsList.Add(picPoNumber);        // PIC PO number
            paramsList.Add(picApproverUserID);  // PIC approver user id
            paramsList.Add(picAction);          // PIC action
            paramsList.Add(picLevel);           // PIC control level
            paramsList.Add(picEmailTimestamp);  // PIC Approval email request issued timestamp
            paramsList.Add("");                 // PIC return message from Infoflo

            return paramsList;
        }

        public string BuildPicHtmlResponsePage(string responseText)
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

        public string BuildPicHtmlLoginPage(string picParamsEncrypted)
        {
            string wsURI = WebConfigurationManager.AppSettings["WS_URI"].ToString();
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