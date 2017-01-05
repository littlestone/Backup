exec pimviewapipck.setviewcontext('Context1','Approved');

select pck.name PackageCodeID, 
  pimviewapipck.getcontextname(pimviewapipck.get_parent(pck.id,'p',8)) PackageType,
  pimviewapipck.getproductvalue(pck.name,'PCCode') PackageCode,
  pimviewapipck.getproductvalue(pck.name,'PkgActive') IsActive,
  pimviewapipck.getproductvalue(pck.name,'PkgDescriptionLong') LongDescription,
  pimviewapipck.getproductvalue(pck.name,'PkgDescriptionShort') ShortDescription,
  pimviewapipck.getproductvalue(pck.name,'PkgLength') "Length",
  pimviewapipck.getproductvalue(pck.name,'PkgWidth') "Width",
  pimviewapipck.getproductvalue(pck.name,'PkgHeight') "Height",
  pimviewapipck.getproductvalue(pck.name,'PkgWeight') "Weight"
from product_v pck
where pck.subtypeid in (1752837,1752836,1752909,1752905,1752838,1752840,1752832,1752839,1752910,1753142,1753014)