exec pimviewapipck.setviewcontext('Context2','Approved');

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Product' AssetLevel
from ((product_v prc
  inner join productassetreferencelink_v lnk on lnk.sourceid = prc.id and referencetypeid in (1754746,1754745,1754741,1754747,1754737,1754736,1754754))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1753026

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Product Line' AssetLevel
from (((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1754879)
  inner join link_v asslnk on asslnk.childid = pline.classificationid and asslnk.reallinktypeid in (1754746,1754745,1754741,1754747,1754737,1754736,1754754,1754739))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1753026

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Application' AssetLevel
from ((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1754879)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join link_v asslnk on asslnk.childid = appli.parentid and asslnk.reallinktypeid in (1754746,1754745,1754741))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1753026

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Market Segment' AssetLevel
from (((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1754879)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join classificationhierlink_v segm on segm.childid = appli.parentid)
  inner join link_v asslnk on asslnk.childid = segm.parentid and asslnk.reallinktypeid in (1754746))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1753026

UNION

select prc.name ProductCompanyID,
  ass.name AssetID, st.Name AssetType, 'Company' AssetLevel
from ((((((product_v prc
  inner join productclassificationlink_v pline on pline.productid = prc.id and pline.linktypeid = 1754879)
  inner join classificationhierlink_v appli on appli.childid = pline.classificationid)
  inner join classificationhierlink_v segm on segm.childid = appli.parentid)
  inner join classificationhierlink_v comp on comp.childid = segm.parentid)
  inner join link_v asslnk on asslnk.childid = comp.parentid and asslnk.reallinktypeid in (1754739))
  inner join asset_v ass on ass.id = asslnk.parentid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prc.subtypeid = 1753026