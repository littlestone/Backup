exec pimviewapipck.setviewcontext('Context1','Approved');

select line.name ProductLineID, pimviewapipck.getcontextname(line.id) ProductLine, 
  pimviewapipck.getcontextname(appli.parentid) Application, pimviewapipck.getcontextname(segm.parentid) MarketSegment, pimviewapipck.getcontextname(comp.parentid) Company,
  pimviewapipck.getcontextvalue4node(line.id,1754617) Description,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(line.id,1754587), '<multisep/>', ';') FeaturesAndBenefits,
  pimviewapipck.getcontextvalue4node(line.id,1754242) WebsiteURL
from (((classification_v line left join classificationhierlink_v appli on appli.childid = line.id) 
  left join classificationhierlink_v segm on segm.childid = appli.parentid) 
  left join classificationhierlink_v comp on comp.childid = segm.parentid)
where line.subtypeid=1753145