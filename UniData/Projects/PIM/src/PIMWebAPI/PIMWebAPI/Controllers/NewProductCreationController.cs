using System;
using System.IO;
using System.Text;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PIMWebAPI.Properties;

namespace PIMWebAPI.Controllers
{
    [RoutePrefix("api/service/pim")]
    public class NewProductCreationController : ApiController
    {
        private static readonly SemaphoreSlim _syncLock = new SemaphoreSlim(1);
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(InfofloIntegrationController));

        private string httpBaseAddressUri = Settings.Default.PIM_Http_BaseAddress_Uri;
        private string httpRestApiServiceUri = Settings.Default.PIM_Http_Restapi_Service_Uri;
        private string httpMediumTypeAccept = Settings.Default.PIM_Http_MediaType_Accept;
        private string httpAuthHeaderSchema = Settings.Default.PIM_Http_AuthHeader_Schema;
        private string httpAuthHeaderParameter = Settings.Default.PIM_Http_AuthHeader_Parameter;
        private string pimProductIdPrefix = Settings.Default.PIM_ProductIdPrefix;
        private int erpProductCpnLength = Settings.Default.ERP_ProductCpnLength;
        private int erpProductUpcLength = Settings.Default.ERP_ProductUpcLength;

        // PUT api/service/pim/newproductcreation
        [Route("newproductcreation")]
        public async Task<HttpResponseMessage> Post([FromBody] string jsonBody)
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
            string jsonData = "";

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
                if (jsonBody != null)
                {
                    // Desearilize JSON data string
                    jsonData = JsonConvert.DeserializeObject<JToken>(HttpUtility.UrlDecode(jsonBody)).ToString();

                    // Queue incoming request(s)                
                    File.WriteAllText(queueFilePath, jsonData);

                    // Validate request parameters
                    string id = "", cpn = "", upc = "";
                    JArray requestParams = JArray.Parse(jsonData);
                    if (requestParams.Count != 3)
                    {
                        throw new Exception("Expecting 3 request parameters (i.e. ID, CPN and UPC), but only " + requestParams.Count + " has been received.");
                    }
                    else
                    {
                        id = requestParams[0].ToString().Trim();
                        if (!string.IsNullOrEmpty(id) && id.Substring(0, 3) != pimProductIdPrefix)
                        {
                            throw new Exception("Invalid PIM ProductId received { " + id + " }.");
                        }

                        cpn = requestParams[1].ToString().Trim();
                        if (!string.IsNullOrEmpty(cpn) && cpn.Length != erpProductCpnLength)
                        {
                            throw new Exception("Invalid Infoflo CPN received { " + cpn + " }.");
                        }

                        upc = requestParams[2].ToString().Trim();
                        if (!string.IsNullOrEmpty(upc) && upc.Length != erpProductUpcLength)
                        {
                            throw new Exception("Invalid Infoflo UPC received { " + upc + " }.");
                        }
                    }
            
                    // Call PIM REST API to Pass STEPID, CPN, UPC in CSV data format
                    using (HttpClient httpClient = new HttpClient())
                    {
                        httpClient.BaseAddress = new Uri(httpBaseAddressUri);
                        httpClient.Timeout = new TimeSpan(0, 2, 0);
                        httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue(httpMediumTypeAccept));
                        httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(httpAuthHeaderSchema, httpAuthHeaderParameter);

                        string postData = id + "," + cpn + "," + upc;
                        string requestUri = httpClient.BaseAddress + httpRestApiServiceUri;
                        HttpContent contentPost = new StringContent(postData, Encoding.UTF8, httpMediumTypeAccept);

                        response = httpClient.PostAsync(requestUri, contentPost).Result;
                        if (!response.IsSuccessStatusCode)
                        {
                            throw new Exception(response.ReasonPhrase);
                        }
                    }

                    // Archive
                    if (File.Exists(queueFilePath)) { File.Move(queueFilePath, requestFilePath); }

                    // Return status
                    response.StatusCode = HttpStatusCode.OK;

                    return response;
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
                    File.WriteAllText(errorFilePath, jsonData);
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
