using System;
using System.IO;
using System.Xml;
using System.Net;
using System.Web;
using System.Text;
using System.Net.Http;
using System.Web.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Xml.Serialization;
using U2.Data.Client;
using HttpMultipartParser;
using PIMWebAPI.Properties;
using PIMWebAPI.Core.DAL;
using PIMWebAPI.Models;

namespace PIMWebAPI.Controllers
{
    [RoutePrefix("api/data")]
    public class InfofloIntegrationController : ApiController
    {
        private static readonly SemaphoreSlim _syncLock = new SemaphoreSlim(1);
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(InfofloIntegrationController));
        private string stepXmlRootElementName = Settings.Default.PIM_StepXml_RootElementName;
        private string @AM = Char.ConvertFromUtf32(254);  // UniData Data Delimiter - Attribute Mark @AM
        private string @VM = Char.ConvertFromUtf32(253);  // UniData Data Delimiter - Value Mark @VM
        private string @SM = Char.ConvertFromUtf32(252);  // UniData Data Delimiter - Sub-Value Mark @SM

        // POST api/data/infoflo/integration
        [Route("infoflo/integration")]
        public async Task<HttpResponseMessage> Post(HttpRequestMessage request)
        {
            // Initialization
            string queueFolderPath = Settings.Default.PIM_Outbound_QueueFolderPath;
            string queueFileName = DateTime.Now.ToString(Settings.Default.PIM_FileTimestampFormat);
            string queueFilePath = Path.Combine(queueFolderPath, queueFileName);
            string requestFolderPath = Settings.Default.PIM_Outbound_SaveFolderPath;
            string requestFileName = Settings.Default.PIM_SaveFilePrefixName + queueFileName + Settings.Default.PIM_SaveFileExtensionNameXml;
            string requestFilePath = Path.Combine(requestFolderPath, requestFileName);
            string errorFolderPath = Settings.Default.PIM_Outbound_ErrorFolderPath;
            string errorFileName = Settings.Default.PIM_ErrorFilePrefixName + queueFileName + Settings.Default.PIM_ErrorFileExtensionName;
            string errorFilePath = Path.Combine(errorFolderPath, errorFileName);
            string bpName = Settings.Default.UD_BASIC_PROGRAM.Split('|')[0];
            int parmCount = Convert.ToInt32(Settings.Default.UD_BASIC_PROGRAM.Split('|')[1]);

            string stepXML = "",  stepXMLFileName = "", result = "";
            Infoflo infoflo = new Infoflo();

            HttpResponseMessage response = new HttpResponseMessage();

            /// <summary>
            /// Threading in C# reference: http://www.albahari.com/threading/part2.aspx
            /// Parallel Programming with .NET: http://blogs.msdn.com/b/pfxteam/archive/2012/02/12/10266988.aspx
            /// C# async/await: http://stackoverflow.com/questions/17801995/c-sharp-async-await-limit-of-calls-to-async-methods-locking
            /// Everything you ever wanted to know about ASP.NET request queueing: http://blog.leansentry.com/all-about-iis-asp-net-request-queues/
            /// Only 1 thread can access the function or functions that use this lock, others trying to access - will wait until the first one released.
            /// </summary>
            await _syncLock.WaitAsync(); 
            try
            {
                if (request != null)
                {
                    // Fiddler Debug
                    if (HttpContext.Current.Request.UserAgent == "Fiddler")
                    {
                        // Convert stream to string
                        using (StreamReader reader = new StreamReader(request.Content.ReadAsStreamAsync().Result, Encoding.Default, true))
                        {
                            // read per STEPXML file and save in requests list
                            stepXML = HttpUtility.UrlDecode(reader.ReadToEnd());                            
                        }

                        if (!string.IsNullOrEmpty(stepXML))
                        {
                            // Queue incoming request(s)
                            File.WriteAllText(queueFilePath, stepXML);

                            // Push STEPXML to Infoflo
                            using (U2Connection con = infoflo.Connect())
                            {
                                List<string> parmList = new List<string>() { stepXML, queueFilePath };
                                result = infoflo.CallUniBasicProgram(bpName, parmCount, parmList).Trim();
                                if (result != "")
                                {
                                    throw new Exception(result);
                                }
                                if (infoflo != null) infoflo.Disconnect();
                            }

                            // Archive
                            if (File.Exists(queueFilePath)) { File.Move(queueFilePath, requestFilePath); }

                            // Return status
                            response.StatusCode = HttpStatusCode.OK;
                        }
                    }
                    else
                    {
                        // ===== multipart/form-data: Simple Parsing ====
                        // parse:
                        var parser = new MultipartFormDataParser(request.Content.ReadAsStreamAsync().Result);

                        // From this point the data is parsed, we can retrieve the
                        // form data using the GetParameterValue method.
                        //var name = parser.GetParameterValue("name");

                        // Files are stored in a list:
                        foreach (var file in parser.Files)
                        {
                            // per STEPXML filename
                            stepXMLFileName = file.FileName;

                            // update file path
                            queueFileName = DateTime.Now.ToString(Settings.Default.PIM_FileTimestampFormat) + "_" + stepXMLFileName;
                            queueFilePath = Path.Combine(queueFolderPath, queueFileName);
                            requestFileName = Settings.Default.PIM_SaveFilePrefixName + queueFileName;
                            requestFilePath = Path.Combine(requestFolderPath, requestFileName);

                            // convert stream to string
                            Stream data = file.Data;
                            using (StreamReader reader = new StreamReader(data, Encoding.Default, true))
                            {
                                // read per STEPXML file and save in requests list
                                stepXML = HttpUtility.UrlDecode(reader.ReadToEnd());                                
                            }

                            if (!string.IsNullOrEmpty(stepXML))
                            {
                                // Queue incoming request(s), need to convert from UTF-8 to ISO-8859-1                                 
                                File.WriteAllText(queueFilePath, Encoding.UTF8.GetString(Encoding.GetEncoding("iso-8859-1").GetBytes(stepXML)));

                                // extract product data from xml and build input data parameter for Infoflo (reserved for future use...)
                                //string productData = GetInfofloProductData(GetPimProductData(stepXML));

                                // Push STEPXML to Infoflo
                                using (U2Connection con = infoflo.Connect())
                                {
                                    List<string> parmList = new List<string>() { stepXML, requestFilePath };
                                    result = infoflo.CallUniBasicProgram(bpName, parmCount, parmList).Trim();
                                    if (result != "")
                                    {
                                        throw new Exception(result);
                                    }
                                    if (infoflo != null) infoflo.Disconnect();
                                }

                                // Archive                                
                                if (File.Exists(queueFilePath)) { File.Move(queueFilePath, requestFilePath); }

                                // Return status
                                response.StatusCode = HttpStatusCode.OK;
                            }
                        }
                    }                                        

                    return response;
                }
                else
                {
                    throw new Exception("Null request content is not allowed.");
                }
            }
            catch (Exception ex)
            {
                // get detail error message
                string errorMessage = ex.InnerException == null ? ex.Message : ex.InnerException.Message;

                // Log any exception error message for debug
                log.Error(errorMessage);

                // Archive
                errorFileName = Settings.Default.PIM_ErrorFilePrefixName + queueFileName;
                errorFilePath = Path.Combine(errorFolderPath, errorFileName);
                if (File.Exists(queueFilePath))
                {
                    File.Move(queueFilePath, errorFilePath);
                }
                else
                {
                    // need to convert from UTF-8 to ISO-8859-1
                    File.WriteAllText(errorFilePath, Encoding.UTF8.GetString(Encoding.GetEncoding("iso-8859-1").GetBytes(stepXML)));  
                }

                // GC
                if (infoflo != null) infoflo.Disconnect();

                // Return status
                response.StatusCode = HttpStatusCode.InternalServerError;
                response.Content = new StringContent(errorMessage);

                return response;
            }
            finally { _syncLock.Release(); }
        }

        private STEPProductInformation GetPimProductData(string stepXML)
        {
            // Desearilize STEPXML to PIM Data Model (STEPProductInformation)
            object pimObj;
            using (XmlReader xmlReader = XmlReader.Create(new StringReader(stepXML)))
            {
                xmlReader.MoveToContent();
                if (xmlReader.Name == stepXmlRootElementName)
                {
                    pimObj = new XmlSerializer(typeof(STEPProductInformation)).Deserialize(xmlReader);
                    return (STEPProductInformation)pimObj;
                }
                else
                {
                    throw new NotSupportedException("Unexpected STEPXML document root element name: " + xmlReader.Name);
                }
            }
        }

        /*
        private string GetInfofloProductData(STEPProductInformation pimProductData)
        {
            return "reserved for furture use...";
        }
        */
    }
}
