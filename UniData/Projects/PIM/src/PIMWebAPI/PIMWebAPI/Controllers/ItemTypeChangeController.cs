using System;
using System.IO;
using System.Web;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Specialized;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using U2.Data.Client;
using U2.Data.Client.UO;
using PIMWebAPI.Core.DAL;
using PIMWebAPI.Properties;

namespace PIMWebAPI.Controllers
{
    [RoutePrefix("api/service/pim")]
    public class ItemTypeChangeController : ApiController
    {
        private static readonly SemaphoreSlim _syncLock = new SemaphoreSlim(1);
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(InfofloIntegrationController));

        private StringCollection erpProductItemTypeCodeList = Settings.Default.ERP_ProductItemTypeCodeList;
        private int erpProductCpnLength = Settings.Default.ERP_ProductCpnLength;

        // PUT api/service/pim/itemtypechange
        [Route("itemtypechange")]
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
            /// Everything you ever wanted to know about ASP.NET request queueing: http://blog.leansentry.com/all-about-iis-asp-net-request-queues/
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

                    // Validate request parameters
                    string cpn = "", itemTypeCode = "";
                    JArray requestParams = JArray.Parse(jsonData);
                    if (requestParams.Count != 2)
                    {
                        throw new Exception("Expecting 2 request parameters (i.e. cpn and item type), but only " + requestParams.Count + " has been received.");
                    }
                    else
                    {
                        cpn = requestParams[0].ToString().Trim();
                        if (cpn.Length != erpProductCpnLength)
                        {
                            throw new Exception("Invalid cpn received { " + cpn + " }.");
                        }

                        itemTypeCode = requestParams[1].ToString().Trim();
                        if (!erpProductItemTypeCodeList.Contains(itemTypeCode))
                        {
                            throw new Exception("Invalid item type code received { " + itemTypeCode + " }.");
                        }
                    }

                    Infoflo infoflo = new Infoflo();
                    using (U2Connection con = infoflo.Connect())
                    {
                        // Get session object
                        UniSession uSession = con.UniSession;
                       
                        // Select UniFile ITMMST
                        UniFile uFile = uSession.CreateUniFile("ITMMST");

                        // Read the record on field 57 (Inventory Codes) for the cpn
                        UniDynArray inventoryCodes = uFile.ReadField(cpn, 57);

                        // The first digit of the inventory codes is the item type code
                        string newInventoryCodes = itemTypeCode + inventoryCodes.ToString().Substring(1);

                        // Update with the new item type code and remoev STEPID associated with the CPN & check the state of record locks during the write operation
                        int[] fieldNumbers = { 57, 185 };
                        UniDynArray uniDynArray = uFile.ReadFields(cpn, fieldNumbers);
                        uniDynArray.Replace(2, "");                        
                        uFile.WriteFields(cpn, fieldNumbers, uniDynArray);
                        if (uFile.FileStatus == -2)
                        {
                            throw new Exception("Record " + cpn + " is currently locked in ITMMST file, unable to update item type { " + itemTypeCode + " } in Infoflo!");
                        }

                        // Archive
                        File.Move(queueFilePath, requestFilePath);

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
                log.Error(errorMessage);

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
