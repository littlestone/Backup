exec pimviewapipck.setviewcontext('Context1','Approved');

select ass.name AssetID,
  pimviewapipck.getcontextname(ass.id) AssetName,
  pimviewapipck.getcontextvalue4node(ass.id,1754364) AssetLongName,
  pimviewapipck.getcontextvalue4node(ass.id,1338634) AssetFilename,
  pimviewapipck.getcontextvalue4node(ass.id,1277) AssetFileFormat,
  pimviewapipck.getcontextvalue4node(ass.id,1208380) AssetMimeType,
  pimviewapipck.getcontextvalue4node(ass.id,1208388) AssetSize,
  pimviewapipck.getcontextvalue4node(ass.id,1211558) ImageHeight,
  pimviewapipck.getcontextvalue4node(ass.id,1211604) ImageWidth
from asset_v ass
  left join pimsubtype_all st on st.id = ass.subtypeid
where st.id in (1752835,1752898,1752729,1752723,1752728,1757375,1752760,1752701,1752700,1752724,1752756,1752899,1752704,1752767,1752722,1752758,1752768,1752702,1752725,1752705,1752757,1752759,1752703)