exec pimviewapipck.setviewcontext('Context1','Approved');

select src.name ProductSourceID, 'CertifiedStandard' CertificationLinkType,
  pimviewapipck.getcontextname(cl2.id) "Standard", pimviewapipck.getcontextname(cl1.id) Agency
from ((((product_v src 
  inner join productclassificationlink_all clnk on clnk.productid = src.id and clnk.linktypeid = 1755308)
  inner join classification_all cl1 on cl1.id = clnk.classificationid) 
  inner join classificationhierlink_all hier on hier.childid = cl1.id)
  inner join classification_all cl2 on cl2.id = hier.parentid)
where src.subtypeid in (1764537,1764538)

UNION

select src.name ProductSourceID, 'StandardMet' CertificationLinkType,
  pimviewapipck.getcontextname(cl1.id) "Standard", null Agency
from ((product_v src
  inner join productclassificationlink_all clnk on clnk.productid = src.id and clnk.linktypeid = 1755213)
  inner join classification_all cl1 on cl1.id = clnk.classificationid)
where src.subtypeid in (1764537,1764538)