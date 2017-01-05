select x.PackageID, x.PackageCodeID, x.I2OF5, x.IsDefaultOption, y.IsDefaultBranch, y.Quantity, 
  case x.PkgLength when '0' then x.PCLength else x.PkgLength end "Length",
  case x.PkgWidth when '0' then x.PCWidth else x.PkgWidth end "Width",
  case x.PkgHeight when '0' then x.PCHeight else x.PkgHeight end "Height",
  case x.PkgWeight when '0' then x.PCWeight else x.PkgWeight end "Weight",
  x.PerTruckLoad, x.ChildID, x.ChildType, x.PkgChild "Child"
from 
(select prd.name PackageID,
  pkgcode.PackageCodeID,
  pkgcode.PCLength, pkgcode.PCWidth, pkgcode.PCHeight, pkgcode.PCWeight,
  pimviewapipck.getcontextvalue4node(prd.id,1753766) I2OF5,
  pimviewapipck.getcontextvalue4node(prd.id,1753833) IsDefaultOption,  
  pimviewapipck.getcontextvalue4node(prd.id,1754731) PkgLength,
  pimviewapipck.getcontextvalue4node(prd.id,1754268) PkgWidth,
  pimviewapipck.getcontextvalue4node(prd.id,1754370) PkgHeight,
  pimviewapipck.getcontextvalue4node(prd.id,1753831) PkgWeight,
  pimviewapipck.getcontextvalue4node(prd.id,1754023) PerTruckLoad,
  pimviewapipck.getname(lnk.targetid) ChildID,
  case chld.subtypeid when 1752908 then 'Product' when 1753013 then 'Product' else 'SubPackage' end ChildType,
  pimviewapipck.getcontextvalue4node(chld.id, case chld.subtypeid when 1752908 then 1753688 when 1753013 then 1753688 else 1753766 end) PkgChild,
  lnk.id EdgeID
from (product_v prd
  left join productreferencelink_v lnk on lnk.sourceid = prd.id)
  left join product_v chld on chld.id = lnk.targetid
  left join (
      select pck.name PackageCodeID, 
        pimviewapipck.getproductvalue(pck.name,'PkgLength') PCLength,
        pimviewapipck.getproductvalue(pck.name,'PkgWidth') PCWidth,
        pimviewapipck.getproductvalue(pck.name,'PkgHeight') PCHeight,
        pimviewapipck.getproductvalue(pck.name,'PkgWeight') PCWeight
      from product_v pck
      where pck.subtypeid in (1752837,1752836,1752909,1752905,1752838,1752840,1752832,1752839,1752910,1753142,1753014)
  ) pkgcode on pkgcode.PackageCodeID = pimviewapipck.getname(pimviewapipck.get_parent(prd.id,'p',8))
where prd.subtypeid in (1753010,1752912,1753019,1752906,1753027,1752902,1753020,1753021,1753028,1753148,1753025)
and lnk.referencetypeid in (1754765,1754766,1754764,1754768,1754762,1754776,1754771,1754770,1754767,1754775,1754763)) x
  left join (
    select prl.id, pimviewapipck.getcontextvalue(vl1.valueid) Quantity, pimviewapipck.getcontextvalue(vl2.valueid) IsDefaultBranch
    from productreferencelink_v prl left join valuelink_v vl1 on vl1.linkid = prl.id and vl1.attributeid = 1753657
      left join valuelink_v vl2 on vl2.linkid = prl.id and vl2.attributeid = 1754007
    where referencetypeid in (1754765,1754766,1754764,1754768,1754762,1754776,1754771,1754770,1754767,1754775,1754763)
  ) y on y.id = x.EdgeID