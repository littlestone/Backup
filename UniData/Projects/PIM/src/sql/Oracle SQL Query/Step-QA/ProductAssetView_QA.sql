exec pimviewapipck.setviewcontext('Context1','Approved');

select prd.name ProductID,
  ass.name AssetID, 
  case lnk.referencetypeid when 1755191 then 'Primary' when 1755190 then 'Alternate' else '' end || st.Name AssetType, 
  'Product' AssetLevel,
  pimviewapipck.getcontextvalue4edge(lnk.id,1777833) IsFamilyImage
from ((product_v prd
  inner join productassetreferencelink_v lnk on lnk.sourceid = prd.id and lnk.referencetypeid in (1755191,1755190,1755186,1755193))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prd.subtypeid in (1754741,1754565) 

UNION

select prd.name ProductID,
  ass.name AssetID, 
  st.Name AssetType, 
  'Material' AssetLevel,
  null IsFamilyImage
from (((product_v prd
  inner join productclassificationlink_v mat on mat.productid = prd.id and mat.linktypeid = 1803683)
  inner join link_v asslnk on asslnk.childid = mat.classificationid and asslnk.reallinktypeid in (1775720,1755193))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prd.subtypeid in (1754741,1754565)
