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
    [RoutePrefix("api/service/infoflo")]
    public class InfofloProductCodesReservationController : ApiController
    {
        private static readonly SemaphoreSlim _syncLock = new SemaphoreSlim(1);
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(InfofloIntegrationController));

        private string erpHttpUserHostName = Settings.Default.ERP_Http_UserHostName;
        private StringCollection debugHttpUserHostNameList = Settings.Default.DEBUG_HttpUserHostNameList;

        // GET api/service/infoflo/productcodesreservation/{itemnumber}
        [Route("productcodesreservation/{itemnumber}")]
        public async Task<HttpResponseMessage> Get([FromUri] string itemnumber, int? action = 0)
        {
            // Initialization
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
                // Validate Http request user agent name
                string httpUserHostName = HttpContext.Current.Request.UserHostName;
                if (httpUserHostName != erpHttpUserHostName && !debugHttpUserHostNameList.Contains(httpUserHostName))
                    throw new Exception("Unauthorized HTTP client user host name { " + httpUserHostName + " }, access denied.");

                /* Create instance of entity model */
                using (var context = new PIMEntities())
                {
                    // Call SQL Stored Procedure for Product Codes Reservation
                    List<string> productCodes = new List<string>() { };
                    switch (action)
                    {
                        case 0:
                            // peek
                            productCodes = context.spd_ReserveProductCodes(1, "F", "ALL", itemnumber, 0, "I").ToList<string>();
                            if (productCodes.Count > 0)
                            {
                                response.Content = new StringContent("0");
                            }
                            else
                            {
                                response.Content = new StringContent("1");
                            }
                            break;
                        case 1:
                            // reserve
                            productCodes = context.spd_ReserveProductCodes(1, "F", "ALL", itemnumber, 1, "I").ToList<string>();
                            if (productCodes.Count > 0)
                            {
                                response.Content = new StringContent("0");
                            }
                            else
                            {
                                response.Content = new StringContent("1");
                            }
                            break;
                        case 2:
                            // assign
                            productCodes = context.spd_AssignProductCodes(itemnumber, "I").ToList<string>();
                            if (productCodes.Count > 0)
                            {
                                response.Content = new StringContent("0");
                            }
                            else
                            {
                                response.Content = new StringContent("1");
                            }
                            break;
                        case 3:
                            // release
                            productCodes = context.spd_ReleaseProductCodes(itemnumber, "I").ToList<string>();
                            if (productCodes.Count > 0)
                            {
                                response.Content = new StringContent("0");
                            }
                            else
                            {
                                response.Content = new StringContent("1");
                            }
                            break;
                    }

                    return response;
                }
            }
            catch (Exception ex)
            {
                // get detail error message
                string errorMessage = ex.InnerException == null ? ex.Message : ex.InnerException.Message;

                // Log any exception error message for debug
                log.Error(ex.Message);

                // Return status
                response.StatusCode = HttpStatusCode.InternalServerError;
                response.Content = new StringContent(errorMessage);

                return response;
            }
            finally { _syncLock.Release(); }
        }
    }
}
