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


<cfif get_amazonUnshipped.RecordCount gte 1>
<h1>Amazon Item:</h1>
	<cfif isDefined("attributes.msg")>
		<cfswitch expression="#attributes.msg#">
			<cfcase value="1">
				<cfoutput><font color=red><b>Item updated sucessfully!</b> <a href="index.cfm?dsp=management.items.edit&item=#attributes.item#">View Item</a><br><br></font>

				</cfoutput>
			</cfcase>
			<cfcase value="2"><cfoutput><font color=red><b>Please enter the eBay Item Number first!</b></font><br><br></cfoutput></cfcase>
			<cfcase value="3"><cfoutput><font color=red><b>Error. Please enter another Item Number!</b></font><br><br></cfoutput></cfcase>
		</cfswitch>
	</cfif>

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
<!---
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"> ## of items Unshipped:</td>
			<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_numberofitemsunshipped#</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"> ## of items Shipped:</td>
			<td width="70%" align="left"> #get_amazonUnshipped.amazon_item_numberofitemsshipped#</td>
		</tr>
--->
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
		<tr >
			<td colspan="2" align="center"> <h3>Link to Item</h3></td>
		</tr>
		<tr >
			<td valign="middle" align="right"> Select an item ID:</td>
			<td width="70%" align="left">
			<select name="sel_instaItemid" id="sel_instaItemid">
			<option value="">--</option>
				<cfloop query="get_InstaItem">
					<option value="#get_InstaItem.item#">#get_InstaItem.item#</option>
				</cfloop>
			</select>

			</td>
		</tr>
		<!--- submit form --->
		<form method="POST" action="index.cfm?act=amazon_live.act_update_itemid" onsubmit="return validateForm()">
		<tr >
			<td valign="middle" align="right"> Enter Item ID:</td>
			<td width="70%" align="left"><input type="text" name="instaItemid" id="instaItemid" value="#get_amazonUnshipped.items_itemid#"></td>
		</tr>
		<tr >
			<td valign="middle" align="right"> Quantity:</td>


			<cfset theshipqty = get_amazonUnshipped.amazon_item_quantityordered >
			<td width="70%" align="left"><input type="text" name="byrOrderQtyToShip" id="byrOrderQtyToShip" value="#theshipqty#"></td>
		</tr>
			<input type="hidden" name="amazonorderid" value="#get_amazonUnshipped.amazon_item_amazonorderid#">

		<!--- submit form ENDS--->

		<tr >
			<td colspan="2" align="center">
				<input type="submit" name="btn_save" value="Save">
				<input type="button" name="btn_cancel" value="Cancel" onclick="history.go(-1)">
			</td>
		</tr>
		</form>
</table>


<cfelse>
	<h1>No record found</h1>
</cfif>




<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script type="text/javascript">
	$(function(){
	$('##sel_instaItemid').change(UpdateInstaItemid);
	function UpdateInstaItemid(){
		var $sel_val = $('##sel_instaItemid').val();
		$("##instaItemid").val($sel_val);
	}
	});

function validateForm()
{
var x=$('##instaItemid').val();
if (x==null || x=="")
  {
  alert("Item ID must not be blank");
  return false;
  }
}

</script>

</cfoutput>
