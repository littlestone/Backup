exec pimviewapipck.setviewcontext('Context1','Approved');

select line.name ProductLineID, pimviewapipck.getcontextname(line.id) ProductLine,
  pimviewapipck.getcontextname(pgrp.parentid) ProductGroup, pimviewapipck.getcontextname(sgrp.parentid) SuperGroup, 
  pimviewapipck.getcontextname(ptyp.parentid) ProductType, pimviewapipck.getcontextname(segm.parentid) MarketSegment
from ((((classification_v line left join classificationhierlink_v pgrp on pgrp.childid = line.id) 
  left join classificationhierlink_v sgrp on sgrp.childid = pgrp.parentid) 
  left join classificationhierlink_v ptyp on ptyp.childid = sgrp.parentid)
  left join classificationhierlink_v segm on segm.childid = ptyp.parentid)
where line.subtypeid=1754887;
