exec pimviewapipck.setviewcontext('Context1','Approved');

select  prc.name ProductCompanyID,
  case nvl(prdlnk.sourceid,0) when 0 then null else pimviewapipck.getname(prdlnk.sourceid) end ProductID,
  pimviewapipck.getproductvalue(prc.name,'ProductCode') ProductCode,
  pimviewapipck.getproductvalue(prc.name,'ProductCompanyCode') CompanyCode,
  pimviewapipck.getproductvalue(prc.name,'PricePer') PricePer,
  pimviewapipck.getproductvalue(prc.name,'Currency') Currency,
  pimviewapipck.getproductvalue(prc.name,'CurrentListPrice') CurrentListPrice,
  pimviewapipck.getproductvalue(prc.name,'CurrentListPriceEffectiveDate') CurrentListPriceEffectiveDate,
  pimviewapipck.getproductvalue(prc.name,'FutureListPrice') FutureListPrice,
  pimviewapipck.getproductvalue(prc.name,'FutureListPriceEffectiveDate') FutureListPriceEffectiveDate,
  pimviewapipck.getproductvalue(prc.name,'TradeListName') TradeListName,
  pimviewapipck.getproductvalue(prc.name,'TradeListDescription') TradeListDescription,    
  pimviewapipck.getproductvalue(prc.name,'LastSoldDate') LastSoldDate,
  case brand_parent.subtypeid when 1753012 then pimviewapipck.getcontextvalue4node(brand_parent.id,3870964) else pimviewapipck.getcontextvalue4node(brandlnk.classificationid,3870964) end Brand,
  case brand_parent.subtypeid when 1753012 then pimviewapipck.getcontextvalue4node(brandlnk.classificationid,3870964) else null end SubBrand,
  pimviewapipck.getcontextvalue4node(brandlnk.classificationid,1754001) IsOEMBrand,
  pimviewapipck.getname(prdlinelnk.classificationid) ProductLineID
from (((((product_v prc 
  left join productclassificationlink_v brandlnk on brandlnk.productid = prc.id and brandlnk.linktypeid = 1754878)
  left join classificationhierlink_v brandup on brandup.childid = brandlnk.classificationid)
  left join classification_v brand_parent on brand_parent.id = brandup.parentid)
  left join productclassificationlink_v prdlinelnk on prdlinelnk.productid = prc.id and prdlinelnk.linktypeid = 1754879)
  left join productreferencelink_v prdlnk on prdlnk.targetid = prc.id)
where prc.subtypeid = 1753026
