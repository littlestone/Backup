exec pimviewapipck.setviewcontext('Context1','Approved');

select * 
from (
  select ass.name AssetID, 
    pimviewapipck.getcontextname(lnk2.parentid) AssetPushQueue, 
    pimviewapipck.getcontextname(lnk.parentid) AssetPushConfiguration, 
    pimviewapipck.getcontextvalue4edge(lnk.id,12013) AssetLibraryPath
from asset_v ass inner join link_v lnk on lnk.childid = ass.id and lnk.linktype=999
  inner join link_v lnk2 on lnk2.childid = lnk.parentid) 
where AssetLibraryPath is not null