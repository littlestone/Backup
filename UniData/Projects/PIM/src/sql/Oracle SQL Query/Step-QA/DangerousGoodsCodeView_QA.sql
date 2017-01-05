exec pimviewapipck.setviewcontext('Context1','Approved');

select name DGCodeID, pimviewapipck.getcontextname(id) DGCode, 
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(id,1762150), '<multisep/>', ';') UNCodes,
  REPLACE(pimviewapipck.getcontextvalues4node_multisep(id,1762190), '<multisep/>', ';') UNCodeWeights,
  pimviewapipck.getcontextvalue4node(id,1762134) DGCodeCode,
  pimviewapipck.getcontextvalue4node(id,1762126) Description,
  pimviewapipck.getcontextvalue4node(id,1762164) Message,
  pimviewapipck.getcontextvalue4node(id,1762184) PrintMessageOnBOL
from entity_all where subtypeid=1754571