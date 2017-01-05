exec pimviewapipck.setviewcontext('Context1','Approved');

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Product' AssetLevel
from ((product_v prc
  inner join productassetreferencelink_v lnk on lnk.sourceid = prc.id and referencetypeid in (1775718,1775719,1775721,1775725,4366856,4366857,1755156))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1768110

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Product Line' AssetLevel
from (((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1768878)
  inner join link_v asslnk on asslnk.childid = pline.classificationid and asslnk.reallinktypeid in (1775718,1775719,1775721,1775725,4366856,4366857,1755156,1775727))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1768110

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Application' AssetLevel
from ((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1768878)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join link_v asslnk on asslnk.childid = appli.parentid and asslnk.reallinktypeid in (1775718,1775721,1775725))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1768110

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Market Segment' AssetLevel
from (((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1768878)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join classificationhierlink_v segm on segm.childid = appli.parentid)
  inner join link_v asslnk on asslnk.childid = segm.parentid and asslnk.reallinktypeid in (1775718))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1768110

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Company' AssetLevel
from ((((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1768878)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join classificationhierlink_v segm on segm.childid = appli.parentid)
  inner join classificationhierlink_v comp on comp.childid = segm.parentid)
  inner join link_v asslnk on asslnk.childid = comp.parentid and asslnk.reallinktypeid in (1775727))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1768110