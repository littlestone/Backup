using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Collections.Specialized;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PIMWebAPI.Models;
using PIMWebAPI.Properties;

namespace PIMWebAPI.Controllers
{
    [RoutePrefix("api/service/pim")]
    public class PIMProductCodesReservationController : ApiController
    {
        private static readonly SemaphoreSlim _syncLock = new SemaphoreSlim(1);
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(InfofloIntegrationController));

        private string pimHttpUserHostName = Settings.Default.PIM_Http_UserHostName;
        private string erpHttpUserHostName = Settings.Default.ERP_Http_UserHostName;
        private StringCollection debugHttpUserHostNameList = Settings.Default.DEBUG_HttpUserHostNameList;

        // GET api/service/pim/productcodesreservation/{number}/{option}/{companygroup}/{filter?}
        [Route("productcodesreservation/{number}/{option}/{companygroup}/{filter?}")]
        public async Task<HttpResponseMessage> Get([FromUri] int number, string option, string companygroup, string filter = "", int? action = 0)
        {
            // Initialization
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
                // Validate Http request user agent name
                string sourceCode = "";
                string httpUserHostName = HttpContext.Current.Request.UserHostName;
                if (httpUserHostName == pimHttpUserHostName)
                    sourceCode = "P";
                else if (httpUserHostName == erpHttpUserHostName)
                    sourceCode = "I";
                else if (debugHttpUserHostNameList.Contains(httpUserHostName))
                    sourceCode = "D";
                else
                    throw new Exception("Unauthorized HTTP client user host name { " + httpUserHostName + " }, access denied.");

                /* Create instance of entity model */
                using (var context = new PIMEntities())
                {
                    // Call SQL Stored Procedure for Product Codes Reservation
                    try
                    {
                        List<string> productCodes = context.spd_ReserveProductCodes(number, option, companygroup, filter, action, sourceCode).ToList<string>();
                        if (productCodes.Count() > 0)
                        {
                            if (sourceCode == "I")
                                response.Content = new StringContent("0");
                            else if (sourceCode == "P")
                                response.Content = new StringContent("[" + string.Join(",", productCodes) + "]");
                            else
                                response.Content = new StringContent(@"[""" + string.Join(",", productCodes) + @"""]");
                        }
                        else
                        {
                            throw new Exception("No product code(s) is available to be reserved according to your selection criteria.");
                        }
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(ex.InnerException == null ? ex.Message : ex.InnerException.Message);
                    }

                    return response;
                }
            }
            catch (Exception ex)
            {
                // Log any exception error message for debug
                log.Error(ex.Message);

                // Return status
                response.StatusCode = HttpStatusCode.InternalServerError;
                response.Content = new StringContent(ex.Message);

                return response;
            }
            finally { _syncLock.Release(); }
        }

        // PUT api/service/pim/productcodesreservation
        [Route("productcodesreservation")]
        public async Task<HttpResponseMessage> Put(HttpRequestMessage request)
        {
            // Initialization
            string queueFolderPath = Settings.Default.PIM_Outbound_QueueFolderPath;
            string queueFileName = DateTime.Now.ToString(Settings.Default.PIM_FileTimestampFormat);
            string queueFilePath = Path.Combine(queueFolderPath, queueFileName);
            string requestFolderPath = Settings.Default.PIM_Outbound_SaveFolderPath;
            string requestFileName = Settings.Default.PIM_SaveFilePrefixName + queueFileName + Settings.Default.PIM_SaveFileExtensionName_Json;
            string requestFilePath = Path.Combine(requestFolderPath, requestFileName);
            string errorFolderPath = Settings.Default.PIM_Outbound_ErrorFolderPath;
            string errorFileName = Settings.Default.PIM_ErrorFilePrefixName + queueFileName + Settings.Default.PIM_ErrorFileExtensionName;
            string errorFilePath = Path.Combine(errorFolderPath, errorFileName);
            string jsonBody = "";

            HttpResponseMessage response = new HttpResponseMessage();

            /// <summary>
            /// Threading in C# reference: http://www.albahari.com/threading/part2.aspx
            /// Parallel Programming with .NET: http://blogs.msdn.com/b/pfxteam/archive/2012/02/12/10266988.aspx
            /// C# async/await: http://stackoverflow.com/questions/17801995/c-sharp-async-await-limit-of-calls-to-async-methods-locking
            /// Only 1 thread can access the function or functions that use this lock, others trying to access - will wait until the first one released.
            /// </summary>
            await _syncLock.WaitAsync(); 
            try
            {
                if (request != null)
                {
                    // Retrieve json string from the request stream
                    StreamReader reader = new StreamReader(request.Content.ReadAsStreamAsync().Result);
                    jsonBody = HttpUtility.UrlDecode(reader.ReadToEnd());

                    // Desearilize JSON data string
                    string jsonData = JsonConvert.DeserializeObject<JToken>(jsonBody).ToString();

                    // Queue incoming request(s)                
                    File.WriteAllText(queueFilePath, jsonData);

                    // Parse request json string
                    JObject requestData = JObject.Parse(jsonData);
                    string action = requestData.Properties().FirstOrDefault().Name;
                    string productCodes = requestData.Properties().FirstOrDefault().Value.ToString();

                    // Validate request action
                    if (action.ToUpper() != "RELEASE" && action.ToUpper() != "ASSIGN")
                        throw new Exception("Invalid reuqest action detected { " + action + " }, expected release or assign.");
                    
                    // Validate Http client user agent name & host address
                    string sourceCode = "";
                    string httpUserHostName = HttpContext.Current.Request.UserHostName;
                    if (httpUserHostName == pimHttpUserHostName)
                        sourceCode = "P";
                    else if (httpUserHostName == erpHttpUserHostName)
                        sourceCode = "I";
                    else if (debugHttpUserHostNameList.Contains(httpUserHostName))
                        sourceCode = "D";
                    else
                        throw new Exception("Unauthorized HTTP client user host name { " + httpUserHostName + " }, access denied.");

                    /* Create instance of entity model */
                    using (var context = new PIMEntities())
                    {
                        // Call SQL Stored Procedure for Releasing Product Code(s)
                        try
                        {
                            if (action.ToUpper() == "ASSIGN") 
                                response.Content = new StringContent(context.spd_AssignProductCodes(productCodes, sourceCode).ToString());
                            else
                                response.Content = new StringContent(context.spd_ReleaseProductCodes(productCodes, sourceCode).ToString());
                        }
                        catch (Exception ex)
                        {
                            throw new Exception(ex.InnerException.Message);
                        }

                        // Archive
                        if (File.Exists(queueFilePath)) { File.Move(queueFilePath, requestFilePath); }

                        // Return status
                        response.StatusCode = HttpStatusCode.OK;

                        return response;
                    }
                }
                else
                {
                    throw new Exception("Null request data is not allowed.");
                }
            }
            catch (Exception ex)
            {
                // get detail error message
                string errorMessage = ex.InnerException == null ? ex.Message : ex.InnerException.Message;

                // Log any exception error message for debug
                log.Error(ex.Message);

                // Archive
                if (File.Exists(queueFilePath))
                {
                    File.Move(queueFilePath, errorFilePath);
                }
                else
                {
                    File.WriteAllText(errorFilePath, jsonBody);
                }

                // Return status
                response.StatusCode = HttpStatusCode.InternalServerError;
                response.Content = new StringContent(errorMessage);

                return response;
            }
            finally { _syncLock.Release(); }
        }
    }
}
