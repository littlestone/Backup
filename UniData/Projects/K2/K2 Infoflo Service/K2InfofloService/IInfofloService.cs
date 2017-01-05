using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Collections;

namespace K2InfofloService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface IInfofloService
    {
        #region Infoflo Common ServiceContract Interfaces

        [OperationContract]
        List<Addressbook> GetAddressbookList();

        [OperationContract]
        List<Company> GetCompanyList();

        [OperationContract]
        List<SalesOffice> GetSalesOfficeList();

        [OperationContract]
        List<Warehouse> GetWarehouseList();

        #endregion
    }

    #region Infoflo Common DataContract definitions

    [DataContract]
    public class Addressbook
    {
        [DataMember]
        public string Userid { get; set; }
        [DataMember]
        public string Name { get; set; }
        [DataMember]
        public string Email { get; set; }
    }

    [DataContract]
    public class Company
    {
        [DataMember]
        public string CompanyCode { get; set; }
        [DataMember]
        public string CompanyName { get; set; }
    }

    [DataContract]
    public class SalesOffice
    {
        [DataMember]
        public string SalesOfficeCode { get; set; }
        [DataMember]
        public string SalesOfficeName { get; set; }
    }

    [DataContract]
    public class Warehouse
    {
        [DataMember]
        public string WarehouseCode { get; set; }
        [DataMember]
        public string WarehouseName { get; set; }
    }

    #endregion
}
