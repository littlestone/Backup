exec pimviewapipck.setviewcontext('Context2','Approved');

select prd.name ProductID,
  pimviewapipck.getcontextvalue4node(prd.id,1761898) ProductCode,
  pimviewapipck.getcontextvalue4node(prd.id,1762342) AttributeBasedDescI,
  pimviewapipck.getcontextvalue4node(prd.id,1762358) AttributeBasedDescM,
  pimviewapipck.getcontextvalue4node(prd.id,1761920) ProductType,
  pimviewapipck.getcontextvalue4node(prd.id,1762366) Material,
  pimviewapipck.getcontextvalue4node(prd.id,1761910) Color,
  pimviewapipck.getcontextvalue4node(prd.id,1761938) "Class",
  pimviewapipck.getcontextvalue4node(prd.id,1762354) Connection,
  pimviewapipck.getcontextvalue4node(prd.id,1762298) Certification,
  pimviewapipck.getcontextvalue4node(prd.id,5746228) Application,  
  pimviewapipck.getcontextvalue4node(prd.id,1762146) "Component",
  pimviewapipck.getcontextvalue4node(prd.id,1762276) DimensionalStandard,
  pimviewapipck.getcontextvalue4node(prd.id,1762180) FeatureA,
  pimviewapipck.getcontextvalue4node(prd.id,1762218) FeatureB,
  pimviewapipck.getcontextvalue4node(prd.id,1761946) "Function",      
  pimviewapipck.getcontextvalue4node(prd.id,1762070) GlobeColor,
  pimviewapipck.getcontextvalue4node(prd.id,1762098) GlobeMaterial,
  pimviewapipck.getcontextvalue4node(prd.id,1762040) MountType,      
  pimviewapipck.getcontextvalue4node(prd.id,1762294) Options,
  pimviewapipck.getcontextvalue4node(prd.id,1762310) SealMaterial,
  pimviewapipck.getcontextvalue4node(prd.id,1762324) Series,
  pimviewapipck.getcontextvalue4node(prd.id,1761942) Shape,
  pimviewapipck.getcontextvalue4node(prd.id,1762060) Torque,
  pimviewapipck.getcontextvalue4node(prd.id,1762142) Voltage
from product_v prd
where prd.subtypeid in (1754741,1754565)