using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace PIMWebAPI.Models
{
    #region STEPXML Schema

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute("STEP-ProductInformation", Namespace = "", IsNullable = false)]
    public partial class STEPProductInformation
    {
        private STEPProductInformationClassification[] classificationsField;

        private STEPProductInformationEntity[] entitiesField;

        private STEPProductInformationProduct[] productsField;

        private string exportTimeField;

        private string exportContextField;

        private string contextIDField;

        private string workspaceIDField;

        private bool useContextLocaleField;

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Classification", IsNullable = false)]
        public STEPProductInformationClassification[] Classifications
        {
            get
            {
                return this.classificationsField;
            }
            set
            {
                this.classificationsField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Entity", IsNullable = false)]
        public STEPProductInformationEntity[] Entities
        {
            get
            {
                return this.entitiesField;
            }
            set
            {
                this.entitiesField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Product", IsNullable = false)]
        public STEPProductInformationProduct[] Products
        {
            get
            {
                return this.productsField;
            }
            set
            {
                this.productsField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ExportTime
        {
            get
            {
                return this.exportTimeField;
            }
            set
            {
                this.exportTimeField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ExportContext
        {
            get
            {
                return this.exportContextField;
            }
            set
            {
                this.exportContextField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ContextID
        {
            get
            {
                return this.contextIDField;
            }
            set
            {
                this.contextIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string WorkspaceID
        {
            get
            {
                return this.workspaceIDField;
            }
            set
            {
                this.workspaceIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool UseContextLocale
        {
            get
            {
                return this.useContextLocaleField;
            }
            set
            {
                this.useContextLocaleField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationClassification
    {
        private string nameField;

        private STEPProductInformationClassificationAssetCrossReference[] assetCrossReferenceField;

        private STEPProductInformationClassificationValue[] metaDataField;

        private string idField;

        private string userTypeIDField;

        private string parentIDField;

        private bool selectedField;

        private bool referencedField;

        /// <remarks/>
        public string Name
        {
            get
            {
                return this.nameField;
            }
            set
            {
                this.nameField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("AssetCrossReference")]
        public STEPProductInformationClassificationAssetCrossReference[] AssetCrossReference
        {
            get
            {
                return this.assetCrossReferenceField;
            }
            set
            {
                this.assetCrossReferenceField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Value", IsNullable = false)]
        public STEPProductInformationClassificationValue[] MetaData
        {
            get
            {
                return this.metaDataField;
            }
            set
            {
                this.metaDataField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string UserTypeID
        {
            get
            {
                return this.userTypeIDField;
            }
            set
            {
                this.userTypeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ParentID
        {
            get
            {
                return this.parentIDField;
            }
            set
            {
                this.parentIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Selected
        {
            get
            {
                return this.selectedField;
            }
            set
            {
                this.selectedField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Referenced
        {
            get
            {
                return this.referencedField;
            }
            set
            {
                this.referencedField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationClassificationAssetCrossReference
    {
        private string assetIDField;

        private string typeField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string AssetID
        {
            get
            {
                return this.assetIDField;
            }
            set
            {
                this.assetIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string Type
        {
            get
            {
                return this.typeField;
            }
            set
            {
                this.typeField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationClassificationValue
    {
        private string attributeIDField;

        private string idField;

        private bool derivedField;

        private bool derivedFieldSpecified;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string AttributeID
        {
            get
            {
                return this.attributeIDField;
            }
            set
            {
                this.attributeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Derived
        {
            get
            {
                return this.derivedField;
            }
            set
            {
                this.derivedField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlIgnoreAttribute()]
        public bool DerivedSpecified
        {
            get
            {
                return this.derivedFieldSpecified;
            }
            set
            {
                this.derivedFieldSpecified = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationEntity
    {
        private string nameField;

        private STEPProductInformationEntityValue[] valuesField;

        private string idField;

        private string userTypeIDField;

        private string parentIDField;

        private bool selectedField;

        private bool selectedFieldSpecified;

        private bool referencedField;

        private bool referencedFieldSpecified;

        /// <remarks/>
        public string Name
        {
            get
            {
                return this.nameField;
            }
            set
            {
                this.nameField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Value", IsNullable = false)]
        public STEPProductInformationEntityValue[] Values
        {
            get
            {
                return this.valuesField;
            }
            set
            {
                this.valuesField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string UserTypeID
        {
            get
            {
                return this.userTypeIDField;
            }
            set
            {
                this.userTypeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ParentID
        {
            get
            {
                return this.parentIDField;
            }
            set
            {
                this.parentIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Selected
        {
            get
            {
                return this.selectedField;
            }
            set
            {
                this.selectedField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlIgnoreAttribute()]
        public bool SelectedSpecified
        {
            get
            {
                return this.selectedFieldSpecified;
            }
            set
            {
                this.selectedFieldSpecified = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Referenced
        {
            get
            {
                return this.referencedField;
            }
            set
            {
                this.referencedField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlIgnoreAttribute()]
        public bool ReferencedSpecified
        {
            get
            {
                return this.referencedFieldSpecified;
            }
            set
            {
                this.referencedFieldSpecified = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationEntityValue
    {
        private string attributeIDField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string AttributeID
        {
            get
            {
                return this.attributeIDField;
            }
            set
            {
                this.attributeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationProduct
    {
        private STEPProductInformationProductKeyValue[] keyValueField;

        private string nameField;

        private STEPProductInformationProductClassificationReference[] classificationReferenceField;

        private STEPProductInformationProductEntityCrossReference entityCrossReferenceField;

        private STEPProductInformationProductValue[] valuesField;

        private string idField;

        private string userTypeIDField;

        private string parentIDField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("KeyValue")]
        public STEPProductInformationProductKeyValue[] KeyValue
        {
            get
            {
                return this.keyValueField;
            }
            set
            {
                this.keyValueField = value;
            }
        }

        /// <remarks/>
        public string Name
        {
            get
            {
                return this.nameField;
            }
            set
            {
                this.nameField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("ClassificationReference")]
        public STEPProductInformationProductClassificationReference[] ClassificationReference
        {
            get
            {
                return this.classificationReferenceField;
            }
            set
            {
                this.classificationReferenceField = value;
            }
        }

        /// <remarks/>
        public STEPProductInformationProductEntityCrossReference EntityCrossReference
        {
            get
            {
                return this.entityCrossReferenceField;
            }
            set
            {
                this.entityCrossReferenceField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Value", IsNullable = false)]
        public STEPProductInformationProductValue[] Values
        {
            get
            {
                return this.valuesField;
            }
            set
            {
                this.valuesField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string UserTypeID
        {
            get
            {
                return this.userTypeIDField;
            }
            set
            {
                this.userTypeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ParentID
        {
            get
            {
                return this.parentIDField;
            }
            set
            {
                this.parentIDField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationProductKeyValue
    {
        private string keyIDField;

        private ulong valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string KeyID
        {
            get
            {
                return this.keyIDField;
            }
            set
            {
                this.keyIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public ulong Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationProductClassificationReference
    {
        private string classificationIDField;

        private string typeField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ClassificationID
        {
            get
            {
                return this.classificationIDField;
            }
            set
            {
                this.classificationIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string Type
        {
            get
            {
                return this.typeField;
            }
            set
            {
                this.typeField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationProductEntityCrossReference
    {
        private string entityIDField;

        private string typeField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string EntityID
        {
            get
            {
                return this.entityIDField;
            }
            set
            {
                this.entityIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string Type
        {
            get
            {
                return this.typeField;
            }
            set
            {
                this.typeField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class STEPProductInformationProductValue
    {
        private string attributeIDField;

        private string unitIDField;

        private string idField;

        private bool derivedField;

        private bool derivedFieldSpecified;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string AttributeID
        {
            get
            {
                return this.attributeIDField;
            }
            set
            {
                this.attributeIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string UnitID
        {
            get
            {
                return this.unitIDField;
            }
            set
            {
                this.unitIDField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public bool Derived
        {
            get
            {
                return this.derivedField;
            }
            set
            {
                this.derivedField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlIgnoreAttribute()]
        public bool DerivedSpecified
        {
            get
            {
                return this.derivedFieldSpecified;
            }
            set
            {
                this.derivedFieldSpecified = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    #endregion
}