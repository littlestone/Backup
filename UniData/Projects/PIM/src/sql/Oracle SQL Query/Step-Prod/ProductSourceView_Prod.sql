exec pimviewapipck.setviewcontext('Context1','Approved');

select ProductSourceID, ProductID, ProductCode, 
  substr(ProductSource,1,instr(ProductSource, ' - ')-1) SourceCode,
  substr(ProductSource,instr(ProductSource, ' - ')+3, length(ProductSource)-instr(ProductSource, ' - ')-2) SourceName,
  SourceType, NoCertification, CertificationExternalNotes, LinkType
from (
select psc.name ProductSourceID, pimviewapipck.getname(prdlnk.sourceid) ProductID, 
  pimviewapipck.getproductvalue(psc.name, 'ProductCode') ProductCode, 
  pimviewapipck.getcontextname(src.classificationid) ProductSource,
  stp.name SourceType,
  pimviewapipck.getproductvalue(psc.name, 'NoCertification') NoCertification,
  pimviewapipck.getproductvalue(psc.name, 'ExternalCertificationNotes') CertificationExternalNotes,
  case nvl(lnk.referencetypeid,0) when 0 then '' when 1754773 then 'Primary' else 'Alternate' end LinkType
from (((((product_v psc 
  left join productreferencelink_v lnk on lnk.targetid = psc.id and lnk.referencetypeid in (1754773,1754772))
  left join productclassificationlink_v src on src.productid = psc.id and src.linktypeid in (1754874,1754873))
  left join classification_v cls on cls.id = src.classificationid) left join pimsubtype_all stp on stp.id = cls.subtypeid)
  left join productreferencelink_v prdlnk on prdlnk.targetid = psc.id)
where psc.subtypeid in (1753141,1753143))