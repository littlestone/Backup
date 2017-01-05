exec pimviewapipck.setviewcontext('Context1','Approved');

select ProductView.*,
  PrdRefIIHView.ProductLineID,
  PrdRefETIMClassView.ETIM,
  PrdRefUNSPSCView.UNSPSC, PrdRefUNSPSCView.IGCC,
  PrdRefAltUPCView.AlternateUPCProductCode,
  PrdRefSSBView.SupersededByProductCode,
  PrdRefCOOView.CountryOfOriginCode, PrdRefCOOView.CountryOfOriginName,
  PrdRefDGView.DangerousGoodCodeID,
  PrdRefTCView.TariffCodeID
from 
(
    select prd.id, prd.name ProductID,
      pimviewapipck.getcontextvalue4node(prd.id,1768883) InfofloCPN,    
      pimviewapipck.getcontextvalue4node(prd.id,1761898) ProductCode,
      pimviewapipck.getcontextvalue4node(prd.id,1761924) AltProductCode,
      pimviewapipck.getcontextvalue4node(prd.id,1761934) UPCCode,
      pimviewapipck.getcontextvalue4node(prd.id,1761930) AlternateUPCCode,
      pimviewapipck.getcontextvalue4node(prd.id,1762328) UniPartNumber,
      pimviewapipck.getcontextvalue4node(prd.id,1761994) OEMNumber,
      pimviewapipck.getcontextname(pimviewapipck.get_parent(prd.id,'p',8)) ProductCategory,
      pimviewapipck.getcontextvalue4node(prd.id,1762194) ProductSubCategory,
      pimviewapipck.getcontextvalue4node(prd.id,1762342) AttributeBasedDescI,
      pimviewapipck.getcontextvalue4node(prd.id,1762358) AttributeBasedDescM,
	  REPLACE(pimviewapipck.getcontextvalues4node_multisep(prd.id,1768465), '<multisep/>', ';') FeaturesAndBenefits,
      pimviewapipck.getcontextvalue4node(prd.id,1761916) InfofloItemType,
      pimviewapipck.getcontextvalue4node(prd.id,1768460) ProductIsOEM,
      pimviewapipck.getcontextvalue4node(prd.id,1761926) ProductStatus,      
      pimviewapipck.getcontextvalue4node(prd.id,1762122) CreationDate,
      pimviewapipck.getcontextvalue4node(prd.id,5823016) ObsolescenceDate,
      pimviewapipck.getcontextvalue4node(prd.id,1762288) ABCCategory,
      pimviewapipck.getcontextvalue4node(prd.id,1762160) DuplicateReasonCode,
      pimviewapipck.getcontextvalue4node(prd.id,1762330) NonRetNonCanc,
      pimviewapipck.getcontextvalue4node(prd.id,1762286) PrimarySourceType,
      pimviewapipck.getcontextvalue4node(prd.id,1762260) PurchasedFromAliaxis,
      pimviewapipck.getcontextvalue4node(prd.id,1762202) DGFlashpointC,
      pimviewapipck.getcontextvalue4node(prd.id,1762214) DGFlashpointF,
      pimviewapipck.getcontextvalue4node(prd.id,1762206) BaseUOM,
      pimviewapipck.getcontextvalue4node(prd.id,5953936) BaseQty,
      pimviewapipck.getcontextvalue4node(prd.id,1762238) ShippingWeight,
      pimviewapipck.getcontextvalue4node(prd.id,1762234) "Length",
      pimviewapipck.getcontextvalue4node(prd.id,1762230) Width,
      pimviewapipck.getcontextvalue4node(prd.id,1762226) Height,  
      pimviewapipck.getcontextvalue4node(prd.id,1761920) ProductType,
      pimviewapipck.getcontextvalue4node(prd.id,1762366) Material,
      pimviewapipck.getcontextvalue4node(prd.id,1761910) Color,
      pimviewapipck.getcontextvalue4node(prd.id,1761938) "Class",
      pimviewapipck.getcontextvalue4node(prd.id,1762354) Connection,
      pimviewapipck.getcontextvalue4node(prd.id,1762298) Certification,
      pimviewapipck.getcontextvalue4node(prd.id,5746228) Application,  
      pimviewapipck.getcontextvalue4node(prd.id,1762314) Angle,
      pimviewapipck.getcontextvalue4node(prd.id,1762146) "Component",
      pimviewapipck.getcontextvalue4node(prd.id,1762138) Diameter1I,
      pimviewapipck.getcontextvalue4node(prd.id,1761902) Diameter1M,
      pimviewapipck.getcontextvalue4node(prd.id,1762102) Diameter2I,
      pimviewapipck.getcontextvalue4node(prd.id,1762084) Diameter2M,
      pimviewapipck.getcontextvalue4node(prd.id,1762006) Diameter3I,
      pimviewapipck.getcontextvalue4node(prd.id,1762158) Diameter3M,
      pimviewapipck.getcontextvalue4node(prd.id,1761958) Diameter4I,
      pimviewapipck.getcontextvalue4node(prd.id,1762052) Diameter4M,
      pimviewapipck.getcontextvalue4node(prd.id,1762276) DimensionalStandard,
      pimviewapipck.getcontextvalue4node(prd.id,1762180) FeatureA,
      pimviewapipck.getcontextvalue4node(prd.id,1762218) FeatureB,
      pimviewapipck.getcontextvalue4node(prd.id,1761946) "Function",      
      pimviewapipck.getcontextvalue4node(prd.id,1762070) GlobeColor,
      pimviewapipck.getcontextvalue4node(prd.id,1762098) GlobeMaterial,
      pimviewapipck.getcontextvalue4node(prd.id,5746102) LampIncluded,
      pimviewapipck.getcontextvalue4node(prd.id,5746107) LampType,
      pimviewapipck.getcontextvalue4node(prd.id,1762024) LengthI,
      pimviewapipck.getcontextvalue4node(prd.id,1762010) LengthM,
      pimviewapipck.getcontextvalue4node(prd.id,1762040) MountType,      
      pimviewapipck.getcontextvalue4node(prd.id,5745656) NumberOfGangs,
      pimviewapipck.getcontextvalue4node(prd.id,5745708) NumberOfLamps,
      pimviewapipck.getcontextvalue4node(prd.id,5745713) NumberOfOutlets,
      pimviewapipck.getcontextvalue4node(prd.id,1762294) Options,
      pimviewapipck.getcontextvalue4node(prd.id,1762310) SealMaterial,
      pimviewapipck.getcontextvalue4node(prd.id,1762324) Series,
      pimviewapipck.getcontextvalue4node(prd.id,1761942) Shape,
      pimviewapipck.getcontextvalue4node(prd.id,1803906) SizeI,
      pimviewapipck.getcontextvalue4node(prd.id,1803912) SizeM,
      pimviewapipck.getcontextvalue4node(prd.id,1761998) ThicknessI,
      pimviewapipck.getcontextvalue4node(prd.id,1761966) ThicknessM,
      pimviewapipck.getcontextvalue4node(prd.id,1762060) Torque,
      pimviewapipck.getcontextvalue4node(prd.id,1762142) Voltage,
      pimviewapipck.getcontextvalue4node(prd.id,1762002) Watt,      
      pimviewapipck.getcontextvalue4node(prd.id,1762044) RadiusI,
      pimviewapipck.getcontextvalue4node(prd.id,1762088) RadiusM,
      pimviewapipck.getcontextvalue4node(prd.id,1761950) FlameSpread,
      pimviewapipck.getcontextvalue4node(prd.id,1761954) SmokeDevelopment,
      pimviewapipck.getcontextvalue4node(prd.id,6315597) NoCertification,
      pimviewapipck.getcontextvalue4node(prd.id,6315583) CertificationInternalNotes,
      pimviewapipck.getcontextvalue4node(prd.id,6315588) CertificationExternalNotes
    from product_v prd
    where prd.subtypeid in (1754741,1754565)
  ) ProductView
    left join (
      select etim.productid, pimviewapipck.getcontextname(etim.classificationid) ETIM
      from productclassificationlink_v etim
      where etim.linktypeid = 1777819
    ) PrdRefETIMClassView
      on PrdRefETIMClassView.productid = ProductView.id
    left join (
      select iih.productid, pimviewapipck.getname(iih.classificationid) ProductLineID
      from productclassificationlink_v iih
      where iih.linktypeid = 1768877
    ) PrdRefIIHView
      on PrdRefIIHView.productid = ProductView.id
    left join (
      select unspsc.productid,
        case unspsc_parent.subtypeid when 1777505 then pimviewapipck.getcontextname(unspsc_parent.id) else pimviewapipck.getcontextname(unspsc.classificationid) end UNSPSC,
        case unspsc_parent.subtypeid when 1777505 then pimviewapipck.getcontextname(unspsc.classificationid) else null end IGCC
      from productclassificationlink_v unspsc
        left join classificationhierlink_v unspscup on unspscup.childid = unspsc.classificationid
        left join classification_v unspsc_parent on unspsc_parent.id = unspscup.parentid
      where unspsc.linktypeid = 1777826
    ) PrdRefUNSPSCView
      on PrdRefUNSPSCView.productid = ProductView.id   
    left join (
      select altupc.sourceid, pimviewapipck.getcontextvalue4node(altupc.targetid,1761898) AlternateUPCProductCode
      from productreferencelink_v altupc
      where altupc.referencetypeid = 1755208
    ) PrdRefAltUPCView
      on PrdRefAltUPCView.sourceid = ProductView.id
    left join (
      select ssb.sourceid, pimviewapipck.getcontextvalue4node(ssb.targetid,1761898) SupersededByProductCode
      from productreferencelink_v ssb
      where ssb.referencetypeid = 1803798
    ) PrdRefSSBView
      on PrdRefSSBView.sourceid = ProductView.id  
    left join (
      select coo.sourceid, pimviewapipck.getcontextvalue4node(coo.targetid,1761906) CountryOfOriginCode, pimviewapipck.getcontextname(coo.targetid) CountryOfOriginName
      from productentityreferencelink_v coo
      where coo.referencetypeid = 1755212
    ) PrdRefCOOView
      on PrdRefCOOView.sourceid = ProductView.id
    left join (
      select dg.sourceid, pimviewapipck.getname(dg.targetid) DangerousGoodCodeID
      from productentityreferencelink_v dg
      where dg.referencetypeid = 1755211
    ) PrdRefDGView
      on PrdRefDGView.sourceid = ProductView.id    
    left join (
      select tc.sourceid, pimviewapipck.getname(tc.targetid) TariffCodeID
      from productentityreferencelink_v tc
      where tc.referencetypeid = 1755210
    ) PrdRefTCView
      on PrdRefTCView.sourceid = ProductView.id