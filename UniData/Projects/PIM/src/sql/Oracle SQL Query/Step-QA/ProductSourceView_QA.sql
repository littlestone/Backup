exec pimviewapipck.setviewcontext('Context1','Approved');

select ProductSourceID, ProductID, ProductCode, 
  substr(ProductSource,1,instr(ProductSource, ' - ')-1) SourceCode,
  substr(ProductSource,instr(ProductSource, ' - ')+3, length(ProductSource)-instr(ProductSource, ' - ')-2) SourceName,
  SourceType, NoCertification, CertificationInternalNotes, CertificationExternalNotes, LinkType
from (
select psc.name ProductSourceID, pimviewapipck.getname(prdlnk.sourceid) ProductID, 
  pimviewapipck.getproductvalue(psc.name, 'ProductCode') ProductCode, 
  pimviewapipck.getcontextname(src.classificationid) ProductSource,
  stp.name SourceType,
  pimviewapipck.getproductvalue(psc.name, 'NoCertification') NoCertification,
  pimviewapipck.getproductvalue(psc.name, 'InternalCertificationNotes') CertificationInternalNotes,
  pimviewapipck.getproductvalue(psc.name, 'ExternalCertificationNotes') CertificationExternalNotes,
  case nvl(lnk.referencetypeid,0) when 0 then '' when 1755195 then 'Primary' else 'Alternate' end LinkType
from (((((product_v psc 
  left join productreferencelink_v lnk on lnk.targetid = psc.id and lnk.referencetypeid in (1755195,1755196))
  left join productclassificationlink_v src on src.productid = psc.id and src.linktypeid in (1764547,1764548))
  left join classification_v cls on cls.id = src.classificationid) left join pimsubtype_all stp on stp.id = cls.subtypeid)
  left join productreferencelink_v prdlnk on prdlnk.targetid = psc.id)
where psc.subtypeid in (1764537,1764538))