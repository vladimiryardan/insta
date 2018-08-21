<!--- 	This will be the link the amazon item to insta item. --->
<!---
notes:
- item price is starting price
- sold off to ebay
 --->

<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.amazon_item" default="0">
<!--- This will be the link the amazon item to insta item. --->
<cfquery name="get_amazonUnshipped" datasource="#request.dsn#">
	select
	   amazon_item_pkid
      ,amazon_item_amazonorderid
      ,amazon_item_asin
      ,amazon_item_sellersku
      ,amazon_item_title
      ,amazon_item_quantityordered
      ,amazon_item_quantityshipped
      ,amazon_item_giftmessagetext
      ,amazon_item_itemprice
      ,amazon_item_shippingprice
      ,amazon_item_giftwrapprice
      ,amazon_item_itemtax
      ,amazon_item_shippingtax
      ,amazon_item_giftwraptax
      ,amazon_item_shippingdiscount
      ,amazon_item_promotiondiscount
      ,amazon_account_pkid
      ,amazon_item_sellerorderid
      ,amazon_item_purchasedate
      ,amazon_item_lastupdatedate
      ,amazon_item_orderstatus
      ,amazon_item_fulfillmentchannel
      ,amazon_item_saleschannel
      ,amazon_item_orderchannel
      ,amazon_item_shipservicelevel
      ,amazon_item_shippingaddress_name
      ,amazon_item_shippingaddress_addressline1
      ,amazon_item_shippingaddress_addressline2
      ,amazon_item_shippingaddress_addressline3
      ,amazon_item_shippingaddress_city
      ,amazon_item_shippingaddress_county
      ,amazon_item_shippingaddress_district
      ,amazon_item_shippingaddress_stateorregion
      ,amazon_item_shippingaddress_postalcode
      ,amazon_item_shippingaddress_countrycode
      ,amazon_item_shippingaddress_phone
      ,amazon_item_numberofitemsshipped
      ,amazon_item_numberofitemsunshipped
      ,amazon_item_ordertotal_currencycode
      ,amazon_item_ordertotal_amount
      ,amazon_item_apiStatusFlag
      ,items_itemid
    from amazon_items
	where amazon_item_amazonorderid = '#attributes.amazon_item#'
</cfquery>

<!---
get an item from insta which has
item condition of "Amazon"
and a SKU number equal to sku of amazon
--->
<cfquery name="get_InstaItem" datasource="#request.dsn#">
SELECT item,aid,cid
      ,title
      ,description
      ,make
      ,model
      ,value
      ,age
      ,ebaytitle
      ,ebaydesc
      ,status
      ,ebayitem
      ,shipper
      ,tracking
      ,invoicenum
      ,weight
      ,commission
      ,dcreated
      ,dreceived
      ,listcount
      ,dinvoiced
      ,offebay
      ,shipped
      ,paid
      ,PaidTime
      ,ShippedTime
      ,shipnote
      ,ShipCharge
      ,byrName
      ,byrStreet1
      ,byrStreet2
      ,byrCityName
      ,byrStateOrProvince
      ,byrCountry
      ,byrPhone
      ,byrPostalCode
      ,byrCompanyName
      ,byrOrderQtyToShip
      ,startprice
      ,dcalled
      ,bold
      ,border
      ,highlight
      ,vehicle
      ,drefund
      ,refundpr
      ,lid
      ,lid2
      ,dlid
      ,startprice_real
      ,buy_it_now
      ,dpacked
      ,dpictured
      ,who_created
      ,exception
      ,purchase_price
      ,multiple
      ,pos
      ,aid_checkout_complete
      ,combined
      ,width
      ,height
      ,depth
      ,weight_oz
      ,label_printed
      ,internal_itemSKU
      ,internal_itemCondition
      ,itemManual
      ,itemComplete
      ,itemTested
      ,retailPackingIncluded
      ,specialNotes
      ,internalShipToLocations
  FROM instant_main.dbo.items
  where internal_itemSKU = '#get_amazonUnshipped.amazon_item_sellersku#'
  and internal_itemCondition = 'amazon'
  and status = '3'<!--- item received --->
  AND paid != '1'
</cfquery>

<cfoutput>
<style>
tr.rowOdd {background-color: ##FFFFFF;}
tr.rowEven {background-color: ##E7E7E7;}
tr.rowHighlight {background-color: ##FFFF99;}
</style>
	<cfif get_amazonUnshipped.RecordCount gte 1>
	<h1>Amazon Item:</h1>
	<table width="100%" border="1" cellspacing="0" cellpadding="4">
			<tr >
				<td valign="middle" align="right"> Amazon OrderID:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_amazonorderid#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Amazon Seller SKU:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_sellersku#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> ASIN:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_asin#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Amazon Title:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_title#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Purchase Price:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_ordertotal_amount#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Item Price:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_itemprice#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Shipping Price:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingprice#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> QTY ordered:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_quantityordered#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> QTY shipped:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_quantityshipped#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Order Status:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_orderstatus#</td>
			</tr>

			<tr >
				<td valign="middle" align="right"> Purchase Date:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_purchasedate#</td>
			</tr>
			<tr >
				<td colspan="2" align="center"> <h3>Shipping</h3></td>
			</tr>

			<tr >
				<td valign="middle" align="right"> Name:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_name#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> Address:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_addressline1#</td>
			</tr>
			<cfif get_amazonUnshipped.amazon_item_shippingaddress_addressline2 neq "">
			<tr >
				<td valign="middle" align="right"> Address2:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_addressline2#</td>
			</tr>
			</cfif>
			<cfif get_amazonUnshipped.amazon_item_shippingaddress_addressline3 neq "">
			<tr >
				<td valign="middle" align="right"> Address3:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_addressline3#</td>
			</tr>
			</cfif>
			<tr >
				<td valign="middle" align="right"> City:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_city#</td>
			</tr>
			<cfif get_amazonUnshipped.amazon_item_shippingaddress_county neq "">
			<tr >
				<td valign="middle" align="right"> County:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_county#</td>
			</tr>
			</cfif>
			<tr >
				<td valign="middle" align="right"> State:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_stateorregion#</td>
			</tr>
			<tr >
				<td valign="middle" align="right"> phone:</td>
				<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_shippingaddress_phone#</td>
			</tr>
</table>

<cfif get_InstaItem.recordcount gte 1>
<form method="POST" action="index.cfm?act=amazon_live.act_update_itemidMulti" onsubmit="return validateForm()">
<table border="1" cellspacing="0" cellpadding="4" align="center" width="100%">
			 <tr >
				<td colspan="4" align="center"> <h3>Select items to Link</h3></td>
			</tr>

<tr>
	<td></td>
	<td align="center"><strong>Item ##</strong></td>
	<td align="center"><strong>Item Title</strong></td>
	<td align="center"><strong>Internal Sku</strong></td>
</tr>
<cfloop query="get_InstaItem">
<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
	<td align="center"><input class="d_items" type="checkbox" name="instaitems" value="#get_InstaItem.item#"></td>
	<td>#get_InstaItem.item#</td>
	<td>#get_InstaItem.title#</td>
	<td>#get_InstaItem.internal_itemSKU#</td>
</tr>
</cfloop>
<tr>
	<td colspan="4" align="center">
		<div id="displayChecked" style="float:left;"></div>
		<input type="submit" value="Confirm" name="frm_submit" id="frm_submit">
		<input type="button" name="btn_cancel" value="Cancel" onclick="history.go(-1)">
		<input type="hidden" name="amazonorderid" value="#get_amazonUnshipped.amazon_item_amazonorderid#">

	</td>
</tr>
</table>
</form>
</cfif>

	<cfelse>
		<h1>No record found</h1>
	</cfif>

<!--- spacer --->
<p>&nbsp;</p>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script type="text/javascript">

 $('.d_items').click(function(){
	var checked = $("input[type=checkbox]:checked").length;
	if (checked >= 1) {
		$('##displayChecked').html(checked+" items selected")
	// do something
	}else{
		$('##displayChecked').html(checked+" items selected")
	}
 });


function validateForm(){
	var $items_checked = $(".d_items:checked").length;
	if ($items_checked == 0)
	{
		alert('Please select atleast 1 item to link!')
	    return false;
	}
	else
	{
	    return true;
	}
}

</script>

</cfoutput>