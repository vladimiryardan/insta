<cfquery name="get_InstaItem" datasource="#request.dsn#">
SELECT items.item
		,items.aid
		,items.cid
      ,items.title
      ,items.description
      ,items.make
      ,items.model
      ,items.value
      ,items.age
      ,items.ebaytitle
      ,items.ebaydesc
      ,items.status
      ,items.ebayitem
      ,items.shipper
      ,items.tracking
      ,items.invoicenum
      ,items.weight
      ,items.commission
      ,items.dcreated
      ,items.dreceived
      ,items.listcount
      ,items.dinvoiced
      ,items.offebay
      ,items.shipped
      ,items.paid
      ,items.PaidTime
      ,items.ShippedTime
      ,items.shipnote
      ,items.ShipCharge
      ,items.byrName
      ,items.byrStreet1
      ,items.byrStreet2
      ,items.byrCityName
      ,items.byrStateOrProvince
      ,items.byrCountry
      ,items.byrPhone
      ,items.byrPostalCode
      ,items.byrCompanyName
      ,items.byrOrderQtyToShip
      ,items.startprice
      ,items.dcalled
      ,items.bold
      ,items.border
      ,items.highlight
      ,items.vehicle
      ,items.drefund
      ,items.refundpr
      ,items.lid
      ,items.lid2
      ,items.dlid
      ,items.startprice_real
      ,items.buy_it_now
      ,items.dpacked
      ,items.dpictured
      ,items.who_created
      ,items.exception
      ,items.purchase_price
      ,items.multiple
      ,items.pos
      ,items.aid_checkout_complete
      ,items.combined
      ,items.width
      ,items.height
      ,items.depth
      ,items.weight_oz
      ,items.label_printed
      ,items.internal_itemSKU
      ,items.internal_itemCondition
      ,items.itemManual
      ,items.itemComplete
      ,items.itemTested
      ,items.retailPackingIncluded
      ,items.specialNotes
      ,items.internalShipToLocations
      ,status.status as istatus
  FROM items
  left JOIN status ON status.id = items.status
  where
  (
  	items.internal_itemSKU = '#get_tid.internal_itemSKU#'
  or
  	items.internal_itemCondition = '#trim(get_tid.internal_itemSKU)#'
  or
 	items.internal_itemSKU = '#get_tid.itmSKU#'
  )
  and (items.status = '3' or items.status='8' or items.status='16')<!--- 3 = item received --->
  AND items.paid != '1'
order by items.status desc, items.dcreated asc
</cfquery>
<!---<cfdump var="#get_InstaItem#" >--->

<cfquery name="get_InstaItem2" datasource="#request.dsn#">
SELECT items.item
		,items.aid
		,items.cid
      ,items.title
      ,items.description
      ,items.make
      ,items.model
      ,items.value
      ,items.age
      ,items.ebaytitle
      ,items.ebaydesc
      ,items.status
      ,items.ebayitem
      ,items.shipper
      ,items.tracking
      ,items.invoicenum
      ,items.weight
      ,items.commission
      ,items.dcreated
      ,items.dreceived
      ,items.listcount
      ,items.dinvoiced
      ,items.offebay
      ,items.shipped
      ,items.paid
      ,items.PaidTime
      ,items.ShippedTime
      ,items.shipnote
      ,items.ShipCharge
      ,items.byrName
      ,items.byrStreet1
      ,items.byrStreet2
      ,items.byrCityName
      ,items.byrStateOrProvince
      ,items.byrCountry
      ,items.byrPhone
      ,items.byrPostalCode
      ,items.byrCompanyName
      ,items.byrOrderQtyToShip
      ,items.startprice
      ,items.dcalled
      ,items.bold
      ,items.border
      ,items.highlight
      ,items.vehicle
      ,items.drefund
      ,items.refundpr
      ,items.lid
      ,items.lid2
      ,items.dlid
      ,items.startprice_real
      ,items.buy_it_now
      ,items.dpacked
      ,items.dpictured
      ,items.who_created
      ,items.exception
      ,items.purchase_price
      ,items.multiple
      ,items.pos
      ,items.aid_checkout_complete
      ,items.combined
      ,items.width
      ,items.height
      ,items.depth
      ,items.weight_oz
      ,items.label_printed
      ,items.internal_itemSKU
      ,items.internal_itemCondition
      ,items.itemManual
      ,items.itemComplete
      ,items.itemTested
      ,items.retailPackingIncluded
      ,items.specialNotes
      ,items.internalShipToLocations
      ,status.status as istatus
  FROM items
  left JOIN status ON status.id = items.status

  where  items.internal_itemSKU = '#get_tid.itmSKU#' and items.aid = '11095'
  and (items.status = '3' or items.status='8'  or items.status='16')<!--- 3 = item received --->
  AND items.paid != '1'
	order by items.status desc, items.dcreated asc
</cfquery>

<cfquery name="get_InstaItem3" datasource="#request.dsn#">
SELECT items.item
		,items.aid
		,items.cid
      ,items.title
      ,items.description
      ,items.make
      ,items.model
      ,items.value
      ,items.age
      ,items.ebaytitle
      ,items.ebaydesc
      ,items.status
      ,items.ebayitem
      ,items.shipper
      ,items.tracking
      ,items.invoicenum
      ,items.weight
      ,items.commission
      ,items.dcreated
      ,items.dreceived
      ,items.listcount
      ,items.dinvoiced
      ,items.offebay
      ,items.shipped
      ,items.paid
      ,items.PaidTime
      ,items.ShippedTime
      ,items.shipnote
      ,items.ShipCharge
      ,items.byrName
      ,items.byrStreet1
      ,items.byrStreet2
      ,items.byrCityName
      ,items.byrStateOrProvince
      ,items.byrCountry
      ,items.byrPhone
      ,items.byrPostalCode
      ,items.byrCompanyName
      ,items.byrOrderQtyToShip
      ,items.startprice
      ,items.dcalled
      ,items.bold
      ,items.border
      ,items.highlight
      ,items.vehicle
      ,items.drefund
      ,items.refundpr
      ,items.lid
      ,items.lid2
      ,items.dlid
      ,items.startprice_real
      ,items.buy_it_now
      ,items.dpacked
      ,items.dpictured
      ,items.who_created
      ,items.exception
      ,items.purchase_price
      ,items.multiple
      ,items.pos
      ,items.aid_checkout_complete
      ,items.combined
      ,items.width
      ,items.height
      ,items.depth
      ,items.weight_oz
      ,items.label_printed
      ,items.internal_itemSKU
      ,items.internal_itemCondition
      ,items.itemManual
      ,items.itemComplete
      ,items.itemTested
      ,items.retailPackingIncluded
      ,items.specialNotes
      ,items.internalShipToLocations
      ,status.status as istatus
  FROM items
  left JOIN status ON status.id = items.status

  where items.aid = '11095'
  and (items.status = '3' or items.status='8'  or items.status='16')<!--- 3 = item received --->
  AND items.paid != '1'
  order by items.status desc, items.dcreated asc
</cfquery>