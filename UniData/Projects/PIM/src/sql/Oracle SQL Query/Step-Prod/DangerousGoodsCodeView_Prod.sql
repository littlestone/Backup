exec pimviewapipck.setviewcontext('Context1','Approved');

select name DGCodeID, pimviewapipck.getcontextname(id) DGCode, 
  pimviewapipck.getcontextvalue4node(id,1753649) DGCodeCode,
  pimviewapipck.getcontextvalue4node(id,1753625) Description,
  pimviewapipck.getcontextvalue4node(id,1753756) Message,
  pimviewapipck.getcontextvalue4node(id,1754392) PrintMessageOnBOL,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(id,1753692), '<multisep/>', ';') UNCodes,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(id,1754380), '<multisep/>', ';') UNCodeWeights
from entity_all where subtypeid=1753473