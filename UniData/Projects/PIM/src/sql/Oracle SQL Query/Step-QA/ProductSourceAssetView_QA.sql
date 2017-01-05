exec pimviewapipck.setviewcontext('Context1','Approved');

select prs.name ProductSourceID, 
  ass.name AssetID, st.Name AssetType,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(lnk.id,6302614), '<multisep/>', ';') CertificationFileStandards,
  pimviewapipck.getcontextvalue4edge(lnk.id,6302392) CertificationFileAgency
from ((product_v prs
  inner join productassetreferencelink_v lnk on lnk.sourceid = prs.id and referencetypeid in (1775716,6302281,1755187,1755188))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prs.subtypeid in (1764538,1764537)