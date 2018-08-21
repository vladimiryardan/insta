<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="dtstart">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">

<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
//-->
</script>


<style type="text/css">
	##amazonWrapper
	{
		padding: 0 5px;
	}
</style>

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
	where amazon_item_orderstatus = 'unshipped'
	and amazon_item_quantityordered != 0<!--- this is canceled order --->
</cfquery>
<cfset _paging.RecordCount = get_amazonUnshipped.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
<cfoutput>

	<div id="amazonWrapper">
	<h1>Unshipped Amazon Items</h1>
	<hr size="1" noshade="" style="color: Black;">

	<table width="100%" cellspacing="0" cellpadding="4" border="1" style="text-align:center">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Amazon<br>Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">SKU</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Price</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">Purchase<br>Date</a></td>
			<td>QTY<br>ordered</td>
			<td>Link to<br>Item</td>
		</tr>
</cfoutput>
<cfoutput query="get_amazonUnshipped" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr>
			<td><cfif #get_amazonUnshipped.items_itemid# neq ""><a href="index.cfm?dsp=management.items.edit&item=#get_amazonUnshipped.items_itemid#">#get_amazonUnshipped.items_itemid#</a><cfelse>&nbsp;</cfif></td>
			<td><a href="index.cfm?dsp=amazon_live.dsp_link_to_item&amazon_item=#get_amazonUnshipped.amazon_item_amazonorderid#">#get_amazonUnshipped.amazon_item_amazonorderid#</a></td>
			<td align="left"><div style="width:256px">#get_amazonUnshipped.amazon_item_title#</div></td>
			<td>#get_amazonUnshipped.amazon_item_sellersku#</td>
			<td>#dollarformat(get_amazonUnshipped.amazon_item_ordertotal_amount)#</td>
			<td>#get_amazonUnshipped.amazon_item_purchasedate#</td>
			<td>#get_amazonUnshipped.amazon_item_quantityordered#</td>
			<td >
				<button type="button" onclick="location.href='index.cfm?dsp=amazon_live.dsp_link_to_item&amazon_item=#get_amazonUnshipped.amazon_item_amazonorderid#'" value="Link">Link</button>
				<cfif get_amazonUnshipped.amazon_item_quantityordered gt 1>
					<button type="button" onclick="location.href='index.cfm?dsp=amazon_live.dsp_multi_linkto_item&amazon_item=#get_amazonUnshipped.amazon_item_amazonorderid#'" value="Multi Link" style="background-color:##3266CB;">Multi Link</button>
				</cfif>
			</td>
		</tr>
</cfoutput>
<cfoutput>
	<tr>
		<td colspan="76" align="right">
			<cfinclude template="../../paging.cfm">
		</td>
	</tr>
	</table>
	<br><br><br><br><br><br><br>
	</div>
</cfoutput>




