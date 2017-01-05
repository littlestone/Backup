exec pimviewapipck.setviewcontext('Context1','Approved');

select name TariffCodeID, pimviewapipck.getcontextname(id) TariffCode, 
  pimviewapipck.getcontextvalue4node(id,1754137) TariffCodeCA,
  pimviewapipck.getcontextvalue4node(id,1754149) TariffCodeUS,
  pimviewapipck.getcontextvalue4node(id,1754252) TariffCodeCode,
  pimviewapipck.getcontextvalue4node(id,1754559) TariffCodeLongDescription,
  pimviewapipck.getcontextvalue4node(id,1754577) TariffCodeShortDescription
from entity_all where subtypeid = 1753474