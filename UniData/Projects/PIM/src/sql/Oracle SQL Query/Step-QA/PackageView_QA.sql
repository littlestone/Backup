exec pimviewapipck.setviewcontext('Context1','Approved');

select x.PackageID, x.PackageCodeID, x.I2OF5, x.IsDefaultOption, y.IsDefaultBranch,
  y.Quantity, x.PkgLength "Length", x.PkgWidth "Width", x.PkgHeight "Height", x.PkgWeight "Weight", x.PerTruckLoad,
  x.ChildID, x.ChildType, x.PkgChild "Child"
from 
(select prd.name PackageID,
  pimviewapipck.getname(pimviewapipck.get_parent(prd.id,'p',8)) PackageCodeID,
  pimviewapipck.getcontextvalue4node(prd.id,1762318) I2OF5,
  pimviewapipck.getcontextvalue4node(prd.id,1762334) IsDefaultOption,  
  pimviewapipck.getcontextvalue4node(prd.id,1761970) PkgLength,
  pimviewapipck.getcontextvalue4node(prd.id,1762020) PkgWidth,
  pimviewapipck.getcontextvalue4node(prd.id,1762032) PkgHeight,
  pimviewapipck.getcontextvalue4node(prd.id,1762048) PkgWeight,
  pimviewapipck.getcontextvalue4node(prd.id,1767993) PerTruckLoad,
  pimviewapipck.getname(lnk.targetid) ChildID,
  case chld.subtypeid when 1754741 then 'Product' when 1754565 then 'Product' else 'SubPackage' end ChildType,
  pimviewapipck.getcontextvalue4node(chld.id, case chld.subtypeid when 1754741 then 1761898 when 1754565 then 1761898 else 1762318 end) PkgChild,
  lnk.id EdgeID
from (product_v prd
  left join productreferencelink_v lnk on lnk.sourceid = prd.id)
  left join product_v chld on chld.id = lnk.targetid
where prd.subtypeid in (1793211,1778043,1768286,1754882,1754881,1754874,1754872,1754871,1754791,1754786,1754780)
and lnk.referencetypeid in (1755202,1755200,1755203,1778047,1768016,1755206,1755198,1755199,1768017,1793212,1755205)) x
  left join (
    select prl.id, pimviewapipck.getcontextvalue(vl1.valueid) Quantity, pimviewapipck.getcontextvalue(vl2.valueid) IsDefaultBranch
    from productreferencelink_v prl left join valuelink_v vl1 on vl1.linkid = prl.id and vl1.attributeid = 1762130
      left join valuelink_v vl2 on vl2.linkid = prl.id and vl2.attributeid = 1767741
    where referencetypeid in (1755202,1755200,1755203,1778047,1768016,1755206,1755198,1755199,1768017,1793212,1755205)
  ) y on y.id = x.EdgeID