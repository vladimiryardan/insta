<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="e.dtend">
<cfparam name="attributes.dir" default="desc">
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
</style>



<cfif isdefined("form.submitted")>

	<!--- loop over the items to relist --->
	<cfloop list="#form.chkRelist#" index="itemx">
		
		<!--- check if the item is already listed and prevent double auction --->
		<cfquery datasource="#request.dsn#" name="relistCheck">
			select duration, relistDate from auctions
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
			and (relistdate is not null or DATEADD (d, duration , relistDate ) > getdate())
		</cfquery>
		
		
		
		<!--- check if duation is ok --->
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
					_ebay.XMLRequest = _ebay.XMLRequest & '
					</Item>';
		
					_ebay.XMLRequest = _ebay.XMLRequest & '</#attributes.CallName#Request>';
				</cfscript>
				<cfset _ebay.ThrowOnError = false>
				<cfinclude template="../api/act_call.cfm">					
		
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
							<!---<cfif isdefined("attributes.WhoPaysShipping")>
								,WhoPaysShipping = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.WhoPaysShipping#">
								,ShippingServiceCost = 0
							</cfif>--->
						WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemx#">
					</cfquery>
					<!--- we need to set the attributes.item here coz the next script needs it --->
					<cfset attributes.item = itemx>	
					<cfinclude template="../admin/auctions/dsp_list_item_result.cfm">
					<cfset LogAction("relisted auction (#sqlData.ebayitem#, #attributes.StartPrice_#nameNumx##, #attributes.ListingDuration_#nameNumx##)")>
				</cfif>	
				
											
		</cfif><!--- relistCheck.RecordCount --->
				
		
	</cfloop>	
</cfif>



<form method="post" action="index.cfm?dsp=management.relistItems">

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
			<td class="ColHead">Ebay Number</td>
			<td>Duration</td>
			<td>Price</td>
			<td>Check All<br>
				<input type="checkbox" onClick="toggle(this)" name="chkRelist" value=""></td>
		</tr>	
		</cfoutput>
		
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			select *, e.dtend,e.title as ebtitle, a.relistDate, a.duration AS ListingDuration, a.StartingPrice AS aStartPrice
			from items i 
				LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
				LEFT JOIN auctions a ON i.item = a.itemid			
			where			
			i.status = 17 <!--- Relist Confirm --->
			and 
			(
				a.relistDate is null 
				or
				DATEADD (d, duration , relistDate ) > getdate()
			 )	<!--- relist date is empty and not yet relisted --->
			
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
				
			<cfset nameNum = replace(sqlTemp.itemid,".","","all")> 	
			<tr bgcolor="##FFFFFF">
				<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.itemid#">#sqlTemp.itemid#</a></td>
				<td>#sqlTemp.ebtitle#</td>
				<td>#sqlTemp.title#</td>
				<td><a target="_blank" href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#">#sqlTemp.ebayitem#</a></td>
				<td>
					<input type="hidden" name="defListingDuration_#nameNum#" value="#sqlTemp.ListingDuration#">
					<select size="1" name="ListingDuration_#nameNum#">#SelectOptions("#sqlTemp.ListingDuration#", "1,1 Day;3,3 Days;5,5 Days;7,7 Days;10,10 Days;30,30 Days;60,60 Days;90,90 Days;120,120 Days")#</select>
									
				</td>
				<td width="250">
					<input type="hidden" name="defStartPrice_#nameNum#" value="#sqltemp.aStartPrice#">
					<input type="text" name="StartPrice_#nameNum#" id="StartPrice"  value="#sqltemp.aStartPrice#">
					
					
					<select name="selStartPrice" id="selStartPrice">
						<option value="0.0">-- Select --</option>
						<option value=".01">.01</option>
						<option value="0.99">0.99</option>
						<option value="6.99">6.99</option>
						<option value="9.99">9.99</option>
						<option value="14.99">14.99</option>
						<option value="19.99">19.99</option>
						<option value="24.99">24.99</option>
						<option value="29.98">29.98</option>
						<option value="34.99">34.99</option>
						<option value="39.99">39.99</option>
						<option value="44.98">44.98</option>
						<option value="49.99">49.99</option>
						<option value="59.98">59.98</option>
						<option value="64.97">64.97</option>
						<option value="69.99">69.99</option>
						<option value="74.97">74.97</option>
						<option value="79.97">79.97</option>
						<option value="84.99">84.99</option>
						<option value="89.97">89.97</option>
						<option value="94.97">94.97</option>
						<option value="99.99">99.99</option>
						<option value="109.97">109.97</option>
						<option value="119.95">119.95</option>
						<option value="129.97">129.97</option>
						<option value="149.95">149.95</option>
						<option value="199.97">199.97</option>
						<option value="299.97">299.97</option>
					</select>
										
				</td>
				<td><input type="checkbox" name="chkRelist" value="#sqltemp.item#"></td>
			</tr>

	
		</cfoutput>
		<cfoutput>

		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		
		<tr>
			<td colspan="7" align="center">
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
	$('##selStartPrice').change(function(){
		 var dval = $(this).val();
		$('##StartPrice').val(dval);
	});


			
});
</script>

</cfoutput>
