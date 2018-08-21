<cfif ((attributes.dsp EQ "") AND NOT isGroupMemberAllowed("Listings")) OR NOT isAllowed("Lister_MarkRefundItems")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="3">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>
<cfoutput>
	<style>
	tr.rowOdd {background-color: ##FFFFFF;}
	tr.rowEven {background-color: ##E7E7E7;}
	tr.rowHighlight {background-color: ##FFFF99;}
	</style>
</cfoutput>
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&srch=#attributes.srch#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&srch=#attributes.srch#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
function fShipNote(itemid){
	ShipNoteWin = window.open("index.cfm?dsp=admin.ship.note&itemid="+itemid, "ShipNoteWin", "height=300,width=600,location=no,scrollbar=yes,menubar=yes,toolbars=yes,resizable=yes");
	ShipNoteWin.opener = self;
	ShipNoteWin.focus();
}
//-->
</script>
<style type="text/css">
##comlist{background-color:##AAAAAA;}
##comlist th{background-color:##F0F1F3; font-weight:bold; text-align:center;}
##comlist td{background-color:white;}
##comlist th a, ##comlist th a:visited{color:red;}
##comlist th a:hover{color:green;}
</style>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>#attributes.pageTitle#</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td width="100">Store:</td>
		<td width="350">Enter Item Number:</td>
		<td>Enter Search Term (title, number, buyer name):</td>
	</tr>
	<tr>
		<td>
			<select name="store" onChange="fStore(this.value)">
				<option value="all"<cfif attributes.store EQ ""> selected</cfif>>All</option>
				<cfloop query="sqlStores">
				<option value="#sqlStores.store#"<cfif attributes.store EQ sqlStores.store> selected</cfif>>#sqlStores.store#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<form method="POST" action="index.cfm?act=admin.ship.generate_label">
				<input type="text" size="20" maxlength="18" name="item" id="item">
				<input type="submit" value="Generate Label">
			</form>
		</td>
		<td>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="18" name="srch" id="search" value="#HTMLEditFormat(attributes.srch)#">
				<input type="submit" value="Search Items">
			</form>
		</td>
	</tr>
	</table><br>
	<a href="index.cfm?dsp=admin.ship.shipping_list&called_from=#attributes.dsp#&orderby=#attributes.orderby#&dir=#attributes.dir#&store=#attributes.store#&srch=#attributes.srch#" target="_blank">Print Shipping List</a><br><br>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead" rowspan="2">Gallery</td>
			<td class="ColHead" rowspan="2">Note</td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID<br><a href="JavaScript: void fSort(13);">LID</a></a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Paid Time</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Weight</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Price</a></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(6);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">eBay Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(8);">High Bidder</a></td>
			<td class="ColHead">Mark Shipped</td>
			<td class="ColHead">Create Label</td>
		</tr>
		<form action="index.cfm?act=admin.exception&dsp=#attributes.dsp#&exception=1" method="post">
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#" result="rosa">
			SELECT i.item, i.title, i.PaidTime, i.weight, e.price,
				i.ebayitem, e.title AS etitle, e.hbuserid, e.galleryurl, i.shipnote,
				i.refundpr, i.drefund, i.lid, t.byrCountry, ai.amazon_item_amazonorderid,
				i.byrCompanyName, i.byrOrderQtyToShip, i.internal_itemSKU2
			FROM items i
				LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
				LEFT JOIN (SELECT DISTINCT itmItemID, byrCountry FROM ebtransactions) t ON i.ebayitem = t.itmItemID
				left join amazon_items ai ON ai.items_itemid = i.item
			WHERE i.offebay = '1'
				AND i.status = 10<!--- Awaiting Shipment --->
<!---
				(
					(i.status = 10<!--- Awaiting Shipment --->)
					OR
					(
						e.hbuserid NOT IN
						(
							SELECT e2.hbuserid
							FROM items i2
								LEFT JOIN ebitems e2 ON i2.ebayitem = e2.ebayitem
							WHERE e2.hbuserid IS NOT NULL
								AND i2.paid = '1'
								AND i2.shipped = '0'
								AND i2.ShippedTime IS NULL
							GROUP BY e2.hbuserid
							HAVING COUNT(i2.item) > 1
						)
					)
				)
				AND
			(
				(
					i.exception = 0
					AND (i.paid = '1' OR (i.offebay = '1' AND i.status = 10<!--- Awaiting Shipment --->))
					AND i.shipped = '0'
					AND i.ShippedTime IS NULL
					AND i.drefund IS NULL
					AND
					(
						(
							(t.byrCountry = 'US')
							<cfif attributes.srch NEQ ""><!--- search on Awaiting should search also Urgent --->
								AND i.PaidTime IS NOT NULL
							<cfelse>
								AND i.PaidTime > DATEADD(DAY, -7, GETDATE())
							</cfif>
						)
						OR
						(i.offebay = '1' AND i.status = 10<!--- Awaiting Shipment --->)
					)
				)
				<cfif attributes.srch NEQ ""><!--- search on Awaiting should search also Urgent --->
					OR (i.exception = 1)
				</cfif>
			)
--->
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srch NEQ "">
				AND (
					i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					e.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.ebayitem LIKE '%#attributes.srch#%'
					OR
					i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.internal_itemSKU2 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
				)
			</cfif>
			ORDER BY i.byrCompanyName,#attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
			<td rowspan="2" align=center><cfif sqlTemp.galleryurl EQ ""><img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg"><cfelse><a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" width=80 border=1></cfif></td>
			<td rowspan="2" align=center><cfif isAllowed("Listings_EditShippingNote")><a href="javascript: fShipNote('#sqlTemp.item#')"><cfif sqlTemp.shipnote EQ ""><img src="#request.images_path#icon14.gif" border=0><cfelse>Edit</cfif></a><cfelse><cfif sqlTemp.shipnote EQ "">N/A<cfelse><a href="javascript: fShipNote('#sqlTemp.item#')">View</a></cfif></cfif></td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a><br>LID: #sqlTemp.lid#</td>
			<td align=left>#sqlTemp.title#</td>
			<td nowrap align=center>#DateFormat(sqlTemp.PaidTime)#</td>
			<td align=center>#sqlTemp.weight# lbs.</td>
			<td align=center>$#sqlTemp.price#</td>
		</tr><!---bgcolor="##C96E6E"--->
		<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
			<td width="180">
				<a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">
			#sqlTemp.ebayitem#</a><br>
			Amzn: <strong>#sqlTemp.amazon_item_amazonorderid#</strong><br>
			Byr: <strong>#sqlTemp.byrCompanyName#</strong><br>
			qty: <strong>#sqlTemp.byrOrderQtyToShip#</strong><br>
			sku2: <strong>#sqlTemp.internal_itemSKU2#</strong>
			</td>
			<td >#sqlTemp.etitle#</td>
			<td align="center">#sqlTemp.hbuserid#<cfif Trim(sqlTemp.byrCountry) NEQ ""> (#sqlTemp.byrCountry#)</cfif></td>
			<td align="center"><cfif isAllowed("Listings_CreateLabel")><a href="index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#sqlTemp.item#&ebayitem=#sqlTemp.ebayitem#&TransactionID=0&nextdsp=#attributes.dsp#" onClick="return confirm('Are you sure to change item status on eBay?');"><img src="#request.images_path#icon8.gif" border=0></a><cfelse>N/A</cfif></td>
			<td align="center"><a href="index.cfm?dsp=admin.ship.fedex.FedexForm&item=#sqlTemp.item#"><img src="#request.images_path#icon13.gif" border=0></a></td>
		</tr>
		<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
			<td colspan="6" align="right"><a href="index.cfm?act=admin.exception&items=#sqlTemp.item#&dsp=#attributes.dsp#&exception=1">Move to Urgent Shipment</a></td>
			<td align="center"><input type="checkbox" name="items" value="#sqlTemp.item#"></td>
		</tr>
		<cfif sqlTemp.shipnote NEQ "">
			<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
				<td colspan="7"><b>Note: </b>#sqlTemp.shipnote#<br><br></td></tr>
		<cfelse>
			<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>><td colspan="7">&nbsp;</td></tr>
		</cfif>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF">
			<td colspan="4">&nbsp;</td>
			<td colspan="3" align="center"><input type="submit" value="Move checked to Urgent Shipment" style="width:220px;"></td>
		</tr>
		</form>
		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--
document.getElementById("search").focus();
document.getElementById("search").value = ".";
document.getElementById("search").select();
document.getElementById("search").value = "";
//-->
</script>
</cfoutput>
