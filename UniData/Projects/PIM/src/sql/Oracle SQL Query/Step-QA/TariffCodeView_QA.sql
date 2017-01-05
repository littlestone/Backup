exec pimviewapipck.setviewcontext('Context1','Approved');

select name TariffCodeID, pimviewapipck.getcontextname(id) TariffCode, 
  pimviewapipck.getcontextvalue4node(id,1762250) TariffCodeCA,
  pimviewapipck.getcontextvalue4node(id,1762242) TariffCodeUS,
  pimviewapipck.getcontextvalue4node(id,1762028) TariffCodeCode,
  pimviewapipck.getcontextvalue4node(id,1762198) TariffCodeLongDescription,
  pimviewapipck.getcontextvalue4node(id,1762222) TariffCodeShortDescription
from entity_all where subtypeid=1754570