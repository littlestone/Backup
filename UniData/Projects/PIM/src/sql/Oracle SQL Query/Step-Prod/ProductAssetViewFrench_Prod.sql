exec pimviewapipck.setviewcontext('Context2','Approved');

select prd.name ProductID,
  ass.name AssetID, 
  case lnk.referencetypeid when 1754756 then 'Primary' when 1754757 then 'Alternate' else '' end || st.Name AssetType, 
  'Product' AssetLevel,
  pimviewapipck.getcontextvalue4edge(lnk.id,1754583) IsFamilyImage
from ((product_v prd
  inner join productassetreferencelink_v lnk on lnk.sourceid = prd.id and lnk.referencetypeid in (1754756,1754757,1754760,1754755))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prd.subtypeid in (1752908,1753013) 

UNION

select prd.name ProductID,
  ass.name AssetID, 
  st.Name AssetType, 
  'Material' AssetLevel,
  null IsFamilyImage
from (((product_v prd
  inner join productclassificationlink_v mat on mat.productid = prd.id and mat.linktypeid = 1754881)
  inner join link_v asslnk on asslnk.childid = mat.classificationid and asslnk.reallinktypeid in (1754744,1754755))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prd.subtypeid in (1752908,1753013)
