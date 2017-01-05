exec pimviewapipck.setviewcontext('Context1','Approved');

select ass.name AssetID,
  pimviewapipck.getcontextname(ass.id) AssetName,
  pimviewapipck.getcontextvalue4node(ass.id,5755832) AssetLongName,
  pimviewapipck.getcontextvalue4node(ass.id,1338634) AssetFilename,
  pimviewapipck.getcontextvalue4node(ass.id,1277) AssetFileFormat,
  pimviewapipck.getcontextvalue4node(ass.id,1208380) AssetMimeType,
  pimviewapipck.getcontextvalue4node(ass.id,1208388) AssetSize,
  pimviewapipck.getcontextvalue4node(ass.id,1211558) ImageHeight,
  pimviewapipck.getcontextvalue4node(ass.id,1211604) ImageWidth
from asset_v ass
  left join pimsubtype_all st on st.id = ass.subtypeid
where st.id in (1754543,1754545,1754736,1754731,1754737,6302025,1754640,4366850,4366851,1754730,1754645,1754544,1628012,1627879,1754732,1754642,1627878,1754735,1775715,1754733,1754644,1754734,1754641)