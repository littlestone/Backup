using System;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.IO;

namespace WebServiceRepository
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IInfofloService" in both code and config file together.
    [ServiceContract]
    public interface IInfofloService
    {
        /*** Purchase Order Internal Controls - PO Approval Process ***/
        [WebInvoke(Method = "GET", UriTemplate = "pic/?action={picParamsEncrypted}")]
        [OperationContract]
        Stream DeserializePicGetRequest(string picParamsEncrypted);

        /*** Purchase Order Internal Controls - User Authentication Process ***/
        [WebInvoke(Method = "POST", UriTemplate = "pic", BodyStyle = WebMessageBodyStyle.WrappedRequest)]
        [OperationContract]
        Stream DeserializePicPostRequest(Stream request);

        /*** Ship and Debit Claims Internal Controls - SDC Approval Process ***/
        [WebInvoke(Method = "GET", UriTemplate = "sdc/?action={sdcParamsEncrypted}")]
        [OperationContract]
        Stream DeserializeSdcGetRequest(string sdcParamsEncrypted);

        /*** Ship and Debit Claims Internal Controls - User Authentication Process ***/
        [WebInvoke(Method = "POST", UriTemplate = "sdc", BodyStyle = WebMessageBodyStyle.WrappedRequest)]
        [OperationContract]
        Stream DeserializeSdcPostRequest(Stream request);
    }
}
