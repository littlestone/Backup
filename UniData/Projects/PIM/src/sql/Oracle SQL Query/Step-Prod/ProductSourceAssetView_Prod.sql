exec pimviewapipck.setviewcontext('Context1','Approved');

select prs.name ProductSourceID, 
  ass.name AssetID, st.Name AssetType,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(lnk.id,1757379), '<multisep/>', ';') CertificationFileStandards,
  pimviewapipck.getcontextvalue4edge(lnk.id,1757383) CertificationFileAgency
from ((product_v prs
  inner join productassetreferencelink_v lnk on lnk.sourceid = prs.id and referencetypeid in (1754748,1757384,1754759,1754758))
  inner join asset_v ass on ass.id = lnk.targetid)
  inner join pimsubtype_all st on st.id = ass.subtypeid
where prs.subtypeid in (1753143,1753141)