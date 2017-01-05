exec pimviewapipck.setviewcontext('Context2','Approved');

select prd.name ProductID,
  pimviewapipck.getcontextvalue4node(prd.id,1753989) AttributeBasedDescI,
  pimviewapipck.getcontextvalue4node(prd.id,1754097) AttributeBasedDescM,
  pimviewapipck.getcontextvalue4node(prd.id,1754410) ProductType,
  pimviewapipck.getcontextvalue4node(prd.id,1754005) Material,
  pimviewapipck.getcontextvalue4node(prd.id,1753752) Color,
  pimviewapipck.getcontextvalue4node(prd.id,1754565) "Class",
  pimviewapipck.getcontextvalue4node(prd.id,1754113) Connection,
  pimviewapipck.getcontextvalue4node(prd.id,1754348) Certification,
  pimviewapipck.getcontextvalue4node(prd.id,1753748) Application,  
  pimviewapipck.getcontextvalue4node(prd.id,1753696) "Component",
  pimviewapipck.getcontextvalue4node(prd.id,1754272) DimensionalStandard,
  pimviewapipck.getcontextvalue4node(prd.id,1754402) FeatureA,
  pimviewapipck.getcontextvalue4node(prd.id,1754581) FeatureB,
  pimviewapipck.getcontextvalue4node(prd.id,1754547) "Function",      
  pimviewapipck.getcontextvalue4node(prd.id,1753851) GlobeColor,
  pimviewapipck.getcontextvalue4node(prd.id,1754117) GlobeMaterial,
  pimviewapipck.getcontextvalue4node(prd.id,1754352) MountType,      
  pimviewapipck.getcontextvalue4node(prd.id,1754360) Options,
  pimviewapipck.getcontextvalue4node(prd.id,1753784) SealMaterial,
  pimviewapipck.getcontextvalue4node(prd.id,1753855) Series,
  pimviewapipck.getcontextvalue4node(prd.id,1754555) Shape,
  pimviewapipck.getcontextvalue4node(prd.id,1753772) Torque,
  pimviewapipck.getcontextvalue4node(prd.id,1753637) Voltage
from product_v prd
where prd.subtypeid in (1752908,1753013)