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
where pck.subtypeid in (1793208,1778042,1754789,1754788,1754787,1754785,1754784,1754783,1754739,1754634,1754564)