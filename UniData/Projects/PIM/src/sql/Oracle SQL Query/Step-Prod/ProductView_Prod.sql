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
    pimviewapipck.getcontextvalue4node(prd.id,1754727) InfofloCPN,    
    pimviewapipck.getcontextvalue4node(prd.id,1753688) ProductCode,
    pimviewapipck.getcontextvalue4node(prd.id,1754398) AltProductCode,
    pimviewapipck.getcontextvalue4node(prd.id,1754376) UPCCode,
    pimviewapipck.getcontextvalue4node(prd.id,1754386) AlternateUPCCode,
    pimviewapipck.getcontextvalue4node(prd.id,1753847) UniPartNumber,
    pimviewapipck.getcontextvalue4node(prd.id,1754133) OEMNumber,
    pimviewapipck.getcontextname(pimviewapipck.get_parent(prd.id,'p',8)) ProductCategory,
    pimviewapipck.getcontextvalue4node(prd.id,1754569) ProductSubCategory,
    pimviewapipck.getcontextvalue4node(prd.id,1753975) AttributeBasedDescI,
    pimviewapipck.getcontextvalue4node(prd.id,1754414) AttributeBasedDescM,
	REPLACE(pimviewapipck.getcontextvalues4node_multisep(prd.id,1753861), '<multisep/>', ';') FeaturesAndBenefits,	  
    pimviewapipck.getcontextvalue4node(prd.id,1753706) InfofloItemType,
    pimviewapipck.getcontextvalue4node(prd.id,1753768) ProductIsOEM,
    pimviewapipck.getcontextvalue4node(prd.id,1754394) ProductStatus,      
    pimviewapipck.getcontextvalue4node(prd.id,1753629) CreationDate,
    pimviewapipck.getcontextvalue4node(prd.id,1753684) ObsolescenceDate,
    pimviewapipck.getcontextvalue4node(prd.id,1754372) ABCCategory,
    pimviewapipck.getcontextvalue4node(prd.id,1753762) DuplicateReasonCode,
    pimviewapipck.getcontextvalue4node(prd.id,1753839) NonRetNonCanc,
    pimviewapipck.getcontextvalue4node(prd.id,1754248) PrimarySourceType,
    pimviewapipck.getcontextvalue4node(prd.id,1754234) PurchasedFromAliaxis,
    pimviewapipck.getcontextvalue4node(prd.id,1754551) DGFlashpointC,
    pimviewapipck.getcontextvalue4node(prd.id,1754599) DGFlashpointF,
    pimviewapipck.getcontextvalue4node(prd.id,1754541) BaseUOM,
    pimviewapipck.getcontextvalue4node(prd.id,1754246) BaseQty,
    pimviewapipck.getcontextvalue4node(prd.id,1754703) ShippingWeight,
    pimviewapipck.getcontextvalue4node(prd.id,1754711) "Length",
    pimviewapipck.getcontextvalue4node(prd.id,1754715) Width,
    pimviewapipck.getcontextvalue4node(prd.id,1754735) Height,  
    pimviewapipck.getcontextvalue4node(prd.id,1754410) ProductType,
    pimviewapipck.getcontextvalue4node(prd.id,1754005) Material,
    pimviewapipck.getcontextvalue4node(prd.id,1753752) Color,
    pimviewapipck.getcontextvalue4node(prd.id,1754565) "Class",
    pimviewapipck.getcontextvalue4node(prd.id,1754113) Connection,
    pimviewapipck.getcontextvalue4node(prd.id,1754348) Certification,
    pimviewapipck.getcontextvalue4node(prd.id,1753748) Application,  
    pimviewapipck.getcontextvalue4node(prd.id,1753776) Angle,
    pimviewapipck.getcontextvalue4node(prd.id,1753696) "Component",
    pimviewapipck.getcontextvalue4node(prd.id,1753645) Diameter1I,
    pimviewapipck.getcontextvalue4node(prd.id,1753676) Diameter1M,
    pimviewapipck.getcontextvalue4node(prd.id,1754101) Diameter2I,
    pimviewapipck.getcontextvalue4node(prd.id,1753995) Diameter2M,
    pimviewapipck.getcontextvalue4node(prd.id,1754232) Diameter3I,
    pimviewapipck.getcontextvalue4node(prd.id,1753680) Diameter3M,
    pimviewapipck.getcontextvalue4node(prd.id,1754595) Diameter4I,
    pimviewapipck.getcontextvalue4node(prd.id,1753823) Diameter4M,
    pimviewapipck.getcontextvalue4node(prd.id,1754272) DimensionalStandard,
    pimviewapipck.getcontextvalue4node(prd.id,1754402) FeatureA,
    pimviewapipck.getcontextvalue4node(prd.id,1754581) FeatureB,
    pimviewapipck.getcontextvalue4node(prd.id,1754547) "Function",      
    pimviewapipck.getcontextvalue4node(prd.id,1753851) GlobeColor,
    pimviewapipck.getcontextvalue4node(prd.id,1754117) GlobeMaterial,
    pimviewapipck.getcontextvalue4node(prd.id,1754282) LampIncluded,
    pimviewapipck.getcontextvalue4node(prd.id,1754356) LampType,
    pimviewapipck.getcontextvalue4node(prd.id,1754260) LengthI,
    pimviewapipck.getcontextvalue4node(prd.id,1754224) LengthM,
    pimviewapipck.getcontextvalue4node(prd.id,1754352) MountType,      
    pimviewapipck.getcontextvalue4node(prd.id,1754719) NumberOfGangs,
    pimviewapipck.getcontextvalue4node(prd.id,1753700) NumberOfLamps,
    pimviewapipck.getcontextvalue4node(prd.id,1753704) NumberOfOutlets,
    pimviewapipck.getcontextvalue4node(prd.id,1754360) Options,
    pimviewapipck.getcontextvalue4node(prd.id,1753784) SealMaterial,
    pimviewapipck.getcontextvalue4node(prd.id,1753855) Series,
    pimviewapipck.getcontextvalue4node(prd.id,1754555) Shape,
    pimviewapipck.getcontextvalue4node(prd.id,1754406) SizeI,
    pimviewapipck.getcontextvalue4node(prd.id,1754390) SizeM,
    pimviewapipck.getcontextvalue4node(prd.id,1754125) ThicknessI,
    pimviewapipck.getcontextvalue4node(prd.id,1754573) ThicknessM,
    pimviewapipck.getcontextvalue4node(prd.id,1753772) Torque,
    pimviewapipck.getcontextvalue4node(prd.id,1753637) Voltage,
    pimviewapipck.getcontextvalue4node(prd.id,1754238) Watt,      
    pimviewapipck.getcontextvalue4node(prd.id,1754280) RadiusI,
    pimviewapipck.getcontextvalue4node(prd.id,1753985) RadiusM,
    pimviewapipck.getcontextvalue4node(prd.id,1754416) FlameSpread,
    pimviewapipck.getcontextvalue4node(prd.id,1754609) SmokeDevelopment,
    pimviewapipck.getcontextvalue4node(prd.id,1757872) CertificationExternalNotes
    from product_v prd
    where prd.subtypeid in (1752908,1753013)
  ) ProductView
    left join (
      select etim.productid, pimviewapipck.getcontextname(etim.classificationid) ETIM
      from productclassificationlink_v etim
      where etim.linktypeid = 1754875
    ) PrdRefETIMClassView
      on PrdRefETIMClassView.productid = ProductView.id
    left join (
      select iih.productid, pimviewapipck.getname(iih.classificationid) ProductLineID
      from productclassificationlink_v iih
      where iih.linktypeid = 1754880
    ) PrdRefIIHView
      on PrdRefIIHView.productid = ProductView.id
    left join (
      select unspsc.productid,
        case unspsc_parent.subtypeid when 1752904 then pimviewapipck.getcontextname(unspsc_parent.id) else pimviewapipck.getcontextname(unspsc.classificationid) end UNSPSC,
        case unspsc_parent.subtypeid when 1752904 then pimviewapipck.getcontextname(unspsc.classificationid) else null end IGCC
      from productclassificationlink_v unspsc
        left join classificationhierlink_v unspscup on unspscup.childid = unspsc.classificationid
        left join classification_v unspsc_parent on unspsc_parent.id = unspscup.parentid
      where unspsc.linktypeid = 1754877
    ) PrdRefUNSPSCView
      on PrdRefUNSPSCView.productid = ProductView.id   
    left join (
      select altupc.sourceid, pimviewapipck.getcontextvalue4node(altupc.targetid,1753688) AlternateUPCProductCode
      from productreferencelink_v altupc
      where altupc.referencetypeid = 1754761
    ) PrdRefAltUPCView
      on PrdRefAltUPCView.sourceid = ProductView.id
    left join (
      select ssb.sourceid, pimviewapipck.getcontextvalue4node(ssb.targetid,1753688) SupersededByProductCode
      from productreferencelink_v ssb
      where ssb.referencetypeid = 1754769
    ) PrdRefSSBView
      on PrdRefSSBView.sourceid = ProductView.id  
    left join (
      select coo.sourceid, pimviewapipck.getcontextvalue4node(coo.targetid,1753760) CountryOfOriginCode, pimviewapipck.getcontextname(coo.targetid) CountryOfOriginName
      from productentityreferencelink_v coo
      where coo.referencetypeid = 1754777
    ) PrdRefCOOView
      on PrdRefCOOView.sourceid = ProductView.id
    left join (
      select dg.sourceid, pimviewapipck.getname(dg.targetid) DangerousGoodCodeID
      from productentityreferencelink_v dg
      where dg.referencetypeid = 1754778
    ) PrdRefDGView
      on PrdRefDGView.sourceid = ProductView.id    
    left join (
      select tc.sourceid, pimviewapipck.getname(tc.targetid) TariffCodeID
      from productentityreferencelink_v tc
      where tc.referencetypeid = 1754779
    ) PrdRefTCView
      on PrdRefTCView.sourceid = ProductView.id