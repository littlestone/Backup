using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace K2InfofloService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IShipAndDebit" in both code and config file together.
    [ServiceContract]
    public interface IShipAndDebit
    {
        #region SD Distributor

        [OperationContract]
        List<SdUserSecurity> GetSdUserSecurityList(string userid);

        [OperationContract]
        SdConstant GetSdConstant();

        [OperationContract]
        List<Distributor> GetDistributorList(string companyCode, string sdQueryFlag);

        [OperationContract]
        List<DistributorShipTo> GetDistributorShipToList(string companyCode, string distributorNumber);

        [OperationContract]
        List<RequestSalesOffice> GetRequestSalesOfficeList(string requestID);

        [OperationContract]
        List<ProductCrossReference> GetProductCrossReferenceList();

        [OperationContract]
        DistributorHeader GetDistributorHeaderListFirstItem(string requestID);

        [OperationContract]
        DistributorBranch GetDistributorBranchListFirstItem(string requestID);

        [OperationContract]
        String DeleteDistributorHeader(string requestID);

        [OperationContract]
        String DeleteDistributorBranch(string requestID);

        [OperationContract]
        String CloneDistributorBranch(string cloneRequestID, string newRequestID);

        [OperationContract]
        string CallInfofloNewDistributorRequestProcess(string requestID, string actionCode);

        #endregion

        #region SD Contractor Agreement

        [OperationContract]
        List<AgreementDistributor> GetAgreementDistributorList(string companyCode);

        [OperationContract]
        List<AgreementSalesOffice> GetAgreementSalesOfficeList(string companyCode, string distributorNumber);

        [OperationContract]
        List<AgreementDistributorBranch> GetAgreementDistributorBranchList(string companyCode, string distributorNumber);

        [OperationContract]
        String DeleteAgreementDistributorBranch(string agreementRequestID);

        [OperationContract]
        String DeleteAgreementDetails(string agreementRequestID);

        [OperationContract]
        List<AgreementItemType> GetAgreementItemTypeList();

        [OperationContract]
        List<AgreementItemUnitOfMeasure> GetAgreementItemUnitOfMeasureList();

        [OperationContract]
        List<AgreementItem> GetAgreementItemList(string itemTypeCode, string itemNumber = "");

        [OperationContract]
        AgreementItem GetAgreementDetailListFirstItem(string agreementRequestID);

        [OperationContract]
        List<AgreementPriceType> GetAgreementPriceTypeList();

        [OperationContract]
        List<AgreementPricePer> GetAgreementPricePerList();

        [OperationContract]
        List<AgreementTradePrice> GetAgreementTradePriceList(string companyCode, string distributorNumber);

        [OperationContract]
        List<AgreementProvinceState> GetAgreementProvinceStateList();

        [OperationContract]
        List<AgreementCountry> GetAgreementCountryList();

        [OperationContract]
        List<AgreementCategory> GetAgreementCategoryList();

        [OperationContract]
        List<RequestDistributorBranch> GetRequestDistributorBranchList(string requestID);

        [OperationContract]
        string CallInfofloNewContractorAgreementRequestProcess(string requestID, string actionCode);

        #endregion
    }

    #region SD Distributor

    [DataContract]
    public class SdUserSecurity
    {
        [DataMember]
        public string Userid { get; set; }
        [DataMember]
        public string DistributorMaintenanceAccess { get; set; }
        [DataMember]
        public string ContractorMaintenanceAccess { get; set; }
        [DataMember]
        public string AgreementMaintenanceAccess { get; set; }
    }

    [DataContract]
    public class SdConstant
    {
        [DataMember]
        public string DefaultNoticeDays { get; set; }
    }

    [DataContract]
    public class Distributor
    {
        [DataMember]
        public string DistributorNumber { get; set; }
        [DataMember]
        public string DistributorName { get; set; }
    }

    [DataContract]
    public class DistributorShipTo
    {
        [DataMember]
        public string ShipToNumber { get; set; }
        [DataMember]
        public string ShipToName { get; set; }
        [DataMember]
        public string Contact { get; set; }
        [DataMember]
        public string Email { get; set; }
    }

    [DataContract]
    public class ProductCrossReference
    {
        [DataMember]
        public string ProductCrossReferenceCode { get; set; }
        [DataMember]
        public string ProductCrossReferenceName { get; set; }
    }

    [DataContract]
    public class DistributorHeader
    {
        [DataMember]
        public string RequestID { get; set; }
        [DataMember]
        public string CompanyCode { get; set; }
        [DataMember]
        public string DistributorNumber { get; set; }
        [DataMember]
        public string SalesOfficeCode { get; set; }
        [DataMember]
        public string ProductCrossReferenceCode { get; set; }
        [DataMember]
        public string AlternateProductCrossReferenceCode { get; set; }
        [DataMember]
        public string DefaultNoticeDays { get; set; }
        [DataMember]
        public string OverrideNoticeDays { get; set; }
        [DataMember]
        public string SalesPerson { get; set; }
        [DataMember]
        public string AdminContact { get; set; }
        [DataMember]
        public string AdminEmailAddress { get; set; }
        [DataMember]
        public string CreditAdminContact { get; set; }
        [DataMember]
        public string CreditAdminEmailAddress { get; set; }
        [DataMember]
        public string AllCustomerFlag { get; set; }
        [DataMember]
        public string TransferHistoryToCustomer { get; set; }
        [DataMember]
        public string SpecialTermsConditionsEnglish { get; set; }
        [DataMember]
        public string SpecialTermsConditionsFrench { get; set; }
        [DataMember]
        public string ProgramExceptionsEnglish { get; set; }
        [DataMember]
        public string ProgramExceptionsFrench { get; set; }
        [DataMember]
        public string Comment { get; set; }
        [DataMember]
        public string UserID { get; set; }
    }

    [DataContract]
    public class DistributorBranch
    {
        [DataMember]
        public string RequestID { get; set; }
        [DataMember]
        public string BranchCode { get; set; }
        [DataMember]
        public string BranchName { get; set; }
        [DataMember]
        public string ShipToNumber { get; set; }
        [DataMember]
        public string ContactName { get; set; }
        [DataMember]
        public string EmailAddress { get; set; }
        [DataMember]
        public string CreditContactName { get; set; }
        [DataMember]
        public string CreditEmailAddress { get; set; }
        [DataMember]
        public string SalesPerson { get; set; }
    }

    [DataContract]
    public class RequestSalesOffice
    {
        [DataMember]
        public string SalesOfficeCode { get; set; }
        [DataMember]
        public string SalesOfficeName { get; set; }
        [DataMember]
        public string SalesOfficeCodeChecked { get; set; } // delimited by semicolon uesed to set checked for the given sales office code
    }

    #endregion

    #region SD Contractor Agreement

    [DataContract]
    public class AgreementDistributor
    {
        [DataMember]
        public string CompanyCode { get; set; }
        [DataMember]
        public string DistributorNumber { get; set; }
        [DataMember]
        public string DistributorName { get; set; }
        [DataMember]
        public string BillToNumber { get; set; }
        [DataMember]
        public string BillToName { get; set; }
        [DataMember]
        public string SalesPersonUserid { get; set; }
        [DataMember]
        public string SalesPersonName { get; set; }
        [DataMember]
        public string DefaultTradePriceList { get; set; }
    }

    [DataContract]
    public class AgreementSalesOffice
    {
        [DataMember]
        public string SalesOfficeCode { get; set; }
        [DataMember]
        public string SalesOfficeName { get; set; }
    }

    [DataContract]
    public class AgreementDistributorBranch
    {
        [DataMember]
        public string CompanyCode { get; set; }
        [DataMember]
        public string DistributorNumber { get; set; }
        [DataMember]
        public string BranchCode { get; set; }
        [DataMember]
        public string BranchName { get; set; }
        [DataMember]
        public string ShipToNumber { get; set; }
    }

    [DataContract]
    public class AgreementItemType
    {
        [DataMember]
        public string ItemTypeCode { get; set; }
        [DataMember]
        public string ItemTypeName { get; set; }
    }

    [DataContract]
    public class AgreementItemUnitOfMeasure
    {
        [DataMember]
        public string ItemUnitOfMeasureCode { get; set; }
        [DataMember]
        public string ItemUnitOfMeasureName { get; set; }
    }

    [DataContract]
    public class AgreementItem
    {
        [DataMember]
        public string RequestID { get; set; }
        [DataMember]
        public string ItemType { get; set; }
        [DataMember]
        public string ItemNumber { get; set; }
        [DataMember]
        public string ItemDescription { get; set; }
        [DataMember]
        public string PriceType { get; set; }
        [DataMember]
        public string SpecialPrice { get; set; }
        [DataMember]
        public string TradePriceList { get; set; }
        [DataMember]
        public string PricePer { get; set; }
        [DataMember]
        public string UnitOfMeasure { get; set; }
    }

    [DataContract]
    public class AgreementPriceType
    {
        [DataMember]
        public string PriceTypeCode { get; set; }
        [DataMember]
        public string PriceTypeName { get; set; }
    }

    [DataContract]
    public class AgreementPricePer
    {
        [DataMember]
        public string PricePerCode { get; set; }
        [DataMember]
        public string PricePerName { get; set; }
    }

    [DataContract]
    public class AgreementTradePrice
    {
        [DataMember]
        public string TradePriceCode { get; set; }
    }

    [DataContract]
    public class AgreementProvinceState
    {
        [DataMember]
        public string ProvinceStateCode { get; set; }
        [DataMember]
        public string ProvinceStateName { get; set; }
    }

    [DataContract]
    public class AgreementCountry
    {
        [DataMember]
        public string CountryCode { get; set; }
        [DataMember]
        public string CountryName { get; set; }
    }

    [DataContract]
    public class AgreementCategory
    {
        [DataMember]
        public string CategoryCode { get; set; }
        [DataMember]
        public string CategoryName { get; set; }
    }

    [DataContract]
    public class RequestDistributorBranch
    {
        [DataMember]
        public string BranchCode { get; set; }
        [DataMember]
        public string BranchName { get; set; }
        [DataMember]
        public string BranchCodeChecked { get; set; } // delimited by semicolon uesed to set checked for the given branch code
    }

    #endregion
}
