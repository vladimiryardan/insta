﻿<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfsetting requesttimeout="240">
<cfparam name="attributes.orderby" default="i.internal_itemSKU">
<cfparam name="attributes.dir" default="asc">
<cfparam name="attributes.page" default="1">
<cfoutput>
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

	function toggle(source) {
		  checkboxes = document.getElementsByName('chkRelist');
		  for(var i=0, n=checkboxes.length;i<n;i++) {
		    checkboxes[i].checked = source.checked;
		  }
	}
	
//-->
</script>
<style type="text/css">
	.vbmenu_popup {
		width: 900px;
	}
	.customNoShow{
		display:none;
	}
</style>



<cfif isdefined("form.submitted") and isdefined("form.chkRelist")>

	<!--- loop over the items to relist --->
	<cfloop list="#form.chkRelist#" index="itemx">
		
		<!--- check if the item is already listed and prevent double auction --->
		<cfquery datasource="#request.dsn#" name="relistCheck">
			select duration, relistDate from auctions
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
			and (
			<!---relistdate is not null or DATEADD (d, duration , relistDate ) > getdate()--->			
				relistDate is not null 
				and
				getdate() < DATEADD (d, duration , relistDate )											
			)
		</cfquery>
		
		
		
		<!--- dont relist if its still active --->
		<cfif relistCheck.RecordCount gte 1>
			<!--- item is relisted. do nothing  --->
		<cfelse>
			
					<cfset nameNumx = replace(itemx,".","","all")>
					<!--- get data --->
					<cfquery datasource="#request.dsn#" name="sqlData">
						SELECT i.ebayitem, a.StartingPrice AS StartPrice, a.BuyItNowPrice, 
						a.Duration AS ListingDuration, a.ReservePrice, a.ready, a.Title, a.WhoPaysShipping, 
						a.ShippingServiceCost, a.ShipToLocations, a.PackedWeight_oz, a.PackedWeight, 
						i.title as itemTitle, e.title AS ebtitle, i.weight
						FROM items i
							LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
							LEFT JOIN auctions a ON i.item = a.itemid
						WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
					</cfquery>
							
					<!--- proceed and relist --->
					<cfquery name="sqlEBAccount" datasource="#request.dsn#">
						SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
							a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
							, u.SiteID
						FROM auctions u
							INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
						WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
					</cfquery>
					<cfscript>
						_ebay.UserID			= sqlEBAccount.UserID;
						_ebay.UserName			= sqlEBAccount.UserName;
						_ebay.Password			= sqlEBAccount.Password;
						_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
						_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
						_ebay.CertificateName	= sqlEBAccount.CertificateName;
						_ebay.RequestToken		= sqlEBAccount.RequestToken;
						_ebay.SiteID			= sqlEBAccount.SiteID;
					</cfscript>
					<cfset attributes.CallName = "RelistItem">
					<cfset _ebay.CallName = attributes.CallName>	
					<!--- build the request string --->		
					<cfscript>
					variables.ModifiedFields = "";
					_ebay.XMLRequest		= '<?xml version="1.0" encoding="UTF-8"?>
					<#attributes.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
					<RequesterCredentials>
						<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
					</RequesterCredentials>
					<Item>
						<ItemID>#sqlData.ebayitem#</ItemID>';

					if(attributes["defStartPrice_#nameNumx#"] NEQ attributes["StartPrice_#nameNumx#"]){
						_ebay.XMLRequest = _ebay.XMLRequest & '<StartPrice>#attributes["StartPrice_#nameNumx#"]#</StartPrice>';
						variables.ModifiedFields = ListAppend(variables.ModifiedFields, "Item.StartPrice");
					}
					if(attributes["defListingDuration_#nameNumx#"] NEQ attributes["ListingDuration_#nameNumx#"]){
						_ebay.XMLRequest = _ebay.XMLRequest & '<ListingDuration>Days_#attributes["ListingDuration_#nameNumx#"]#</ListingDuration>';
						variables.ModifiedFields = ListAppend(variables.ModifiedFields, "Item.ListingDuration");
					}
					
				//check weight of the item
				if((attributes["PackedWeight_#nameNumx#"] + attributes["PackedWeight_oz_#nameNumx#"] /16) GT 3){
					vartype_ShippingService = "UPSGround";
				}else{
					vartype_ShippingService = "USPSPriority";
				}

				if (structKeyExists(attributes, "WhoPaysShipping_#nameNumx#")) {
					if(attributes['WhoPaysShipping_#nameNumx#'] EQ 1){
					_ebay.XMLRequest = _ebay.XMLRequest & '
					<ShippingDetails>
					 <ShippingServiceOptions>
				        <FreeShipping>1</FreeShipping>
				        <ShippingService>#vartype_ShippingService#</ShippingService>
				        <ShippingServiceCost currencyID="USD">0</ShippingServiceCost>
				        <ShippingServicePriority>1</ShippingServicePriority>
				      </ShippingServiceOptions>
					</ShippingDetails>';
					}
				}
								
					_ebay.XMLRequest = _ebay.XMLRequest & '
					</Item>';
		
					_ebay.XMLRequest = _ebay.XMLRequest & '</#attributes.CallName#Request>';
				</cfscript>
				<cfset _ebay.ThrowOnError = false>
				<cfinclude template="../../api/act_call.cfm">				
		
				<cfif _ebay.Ack EQ "failure">
					<cfoutput><h3 style="color:red;">Error while submit Relist Item. Details: #HTMLEditFormat(err_detail)#</h3></cfoutput>
				<cfelse>
					<cfquery datasource="#request.dsn#" >
						UPDATE auctions
						SET StartingPrice = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes['StartPrice_#nameNumx#']#">,
							<!---BuyItNowPrice = <cfqueryparam cfsqltype="cf_sql_float" value="#sqldata.BuyItNowPrice#">,--->
							Duration = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes['ListingDuration_#nameNumx#']#">,
							<!---ReservePrice = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ReservePrice#">,--->
							relistDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
							<!--- we only have seller pays shipping --->
							<cfif structKeyExists(attributes, "WhoPaysShipping_#nameNumx#")>
								,WhoPaysShipping = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes['WhoPaysShipping_#nameNumx#']#">
								,ShippingServiceCost = 0
							</cfif>
						WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
					</cfquery>
					<!--- we need to set the attributes.item here coz the next script needs it --->
					<cfset attributes.item = itemx>						
					<!--- lets hide --->
					<div class="customNoShow">
						<cfinclude template="../auctions/dsp_list_item_result.cfm">
					</div>
					
					<div>#itemx# Relisted</div>
					
					<cfset LogAction("relisted auction (#sqlData.ebayitem#, #attributes['StartPrice_#nameNumx#']#, #attributes['ListingDuration_#nameNumx#']#)")>
				</cfif>	
				
											
		</cfif><!--- relistCheck.RecordCount --->
				
		
	</cfloop>	
</cfif>



<form method="post" action="index.cfm?dsp=admin.auctions.relistItems" id="formBulkRelist">

<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Confirm Relist:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">

	</td></tr></table>
	<br><br>

	<center>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="1">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Item ID</td>
			<td class="ColHead">Ebay Title</a></td>
			<td class="ColHead">Title</td>
			<td class="ColHead">SKU</td>
			<td class="ColHead">Ebay Number</td>
			<td class="ColHead">Duration</td>
			<td class="ColHead">Price</td>
			<td class="ColHead">LOW Price</td>
			<td class="ColHead">Retail <br> Price</td>
			<td class="ColHead">Listed<br>Count</td>
			<td class="ColHead">Who Pays<br>Shipping
			</td>
			
			<td>Check All<br>
				<input type="checkbox" onClick="toggle(this)" name="chkRelist" value=""></td>
		</tr>	
		</cfoutput>
		
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			select *, e.dtend,e.title as ebtitle, a.relistDate, a.duration AS ListingDuration, 
			a.StartingPrice AS aStartPrice, i.internal_itemSKU,
			i.age, i.startprice as itemStartPrice
			from items i 
				LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
				LEFT JOIN auctions a ON i.item = a.itemid			
			where			
			i.status = 17 <!--- Relist Confirm --->
			and 
			(
				a.relistDate is null 
				or
				DATEADD (d, duration , relistDate ) < getdate()
			 )	<!--- relist date is empty and not yet relisted --->
			
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
				
			<cfset nameNum = replace(sqlTemp.itemid,".","","all")> 	
			<tr bgcolor="##FFFFFF">
				<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
				<td>#sqlTemp.ebtitle#</td>
				<td>#sqlTemp.title#</td>
				<td>#sqlTemp.internal_itemSKU#</td>
				<td><a target="_blank" href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.item#">#sqlTemp.ebayitem#</a></td>
				<td>
					<input type="hidden" name="defListingDuration_#nameNum#" value="#sqlTemp.ListingDuration#">
					<select size="1" name="ListingDuration_#nameNum#">#SelectOptions("#sqlTemp.ListingDuration#", "1,1 Day;3,3 Days;5,5 Days;7,7 Days;10,10 Days;30,30 Days;60,60 Days;90,90 Days;120,120 Days")#</select>
									
				</td>
				<td width="250">
					<input type="hidden" name="defStartPrice_#nameNum#" value="#sqltemp.aStartPrice#">
					<input type="text" name="StartPrice_#nameNum#" id="StartPrice_#nameNum#"  value="#sqltemp.aStartPrice#">
					
					
					<select name="selStartPrice" id="selStartPrice" class="start_price" data-id="#nameNum#">
						#auctionPrices()#
					</select>
										
				</td>
				<td><cfif isnumeric(sqlTemp.itemStartPrice)>#sqlTemp.itemStartPrice#<cfelse>N/A</cfif></td>
				<td>#sqltemp.age#</td>
				
				<td>
						<cfquery name="sqlRecord" datasource="#request.dsn#">
							SELECT COUNT(DISTINCT ebayitem) AS cnt FROM ebitems WHERE 
							itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
						</cfquery>
						<br>#sqlRecord.cnt#
						
				</td>
								
				<td><input type="checkbox" name="WhoPaysShipping_#nameNum#" value="1" checked="yes"></td>
				
				<td>
					<input type="checkbox" name="chkRelist" value="#sqltemp.item#">
				<input type="hidden" name="PackedWeight_oz_#nameNum#" value="#sqltemp.PackedWeight_oz#">
				<input type="hidden" name="PackedWeight_#nameNum#" value="#sqltemp.PackedWeight#">
				
				</td>
			</tr>

	
		</cfoutput>
		<cfoutput>

		<tr bgcolor="##FFFFFF"><td colspan="8" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		
		<tr>
			<td colspan="8" align="center">
				<input type="submit" value="Relist Items" name="btnRelist">
				<input type="hidden" value="1" name="submitted">
			</td>	
		</tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</form>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script type="text/javascript">
$(function(){
	$('##btnBuyItNow').click(function(){
		$('##BuyItNowPrice').val("0.0");
	});
	
	$('.start_price').change(function(){

		 var $id = $(this).data('id');
		 var $value = $(this).val();
		 var $elem = $('##StartPrice_'+$id);
		 
		$elem.val($value);
	});

	$('##formBulkRelist').submit(function(e){
		e.preventDefault();		
		var $boxes = $('input[name=chkRelist]:checked')
		 //if there are no checked alert
		 if ($($boxes).length > 0) {
		 	this.submit();
			return true;
		  } else {
		    alert('Please check items to relist')
		    return false;
		  }
	})

			
});
</script>

</cfoutput>
