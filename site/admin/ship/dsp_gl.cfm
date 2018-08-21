<!---
PAGE NOTES:
A LOT OF CFOUTPUT IS THROWN IN THE PAGE COZ THERE PAGING USES CFOUTPUT INSTEAD OF CFLOOP

--->
<cfif ((attributes.dsp EQ "") AND NOT isGroupMemberAllowed("Listings")) OR NOT isAllowed("Lister_MarkRefundItems")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>


<cfparam name="attributes.orderby" default="13">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.local_buyers" default="0">

<cfoutput>
	<script language="javascript" type="text/javascript">
	<!--//
	function fPage(Page){
		window.location.href = "#_machine.self#&local_buyers=#attributes.local_buyers#&srch=#attributes.srch#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
	}
	function fSort(OrderBy){
		if ('#attributes.orderby#' == OrderBy){
			dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
		}else{
			dir = "ASC";
		}
		window.location.href = "#_machine.self#&local_buyers=#attributes.local_buyers#&srch=#attributes.srch#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
	}
	function fStore(store){
		window.location.href = "#_machine.self#&local_buyers=#attributes.local_buyers#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
	}
	function fShipNote(itemid){
		ShipNoteWin = window.open("index.cfm?dsp=admin.ship.note&itemid="+itemid, "ShipNoteWin", "height=300,width=600,location=no,scrollbar=yes,menubar=yes,toolbars=yes,resizable=yes");
		ShipNoteWin.opener = self;
		ShipNoteWin.focus();
	}
	//-->
	</script>
</cfoutput>




<cfparam name="attributes.ship_list" default="admin.ship.awaiting">
<cfparam name="attributes.item" default="">

<cfquery name="sqlTemp" datasource="#request.dsn#" result="rosa">
	SELECT i.item, i.title, i.PaidTime, i.weight, e.price,
				i.ebayitem, e.title AS etitle, e.hbuserid, e.galleryurl, i.shipnote,
				i.refundpr, i.drefund, i.lid, t.byrCountry, a.use_pictures
			FROM items i
				LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
				LEFT JOIN auctions a ON i.item = a.itemid<!--- for DUPLICATE AUCTIONS that doesnt carry over the image--->
				LEFT JOIN (SELECT DISTINCT itmItemID, byrCountry FROM ebtransactions) t ON i.ebayitem = t.itmItemID
			<cfif (attributes.dsp EQ "admin.ship.urgent") OR (attributes.dsp EQ "admin.ship.combined")>
				LEFT JOIN local_buyers lb ON e.hbuserid = lb.eBayUser
			WHERE lb.eBayUser IS<cfif attributes.local_buyers EQ 1> NOT</cfif> NULL
				AND
			<cfelse>
			WHERE
			</cfif>
			<cfif attributes.dsp NEQ "admin.ship.refund">
				(
					(
						e.hbuserid <cfif attributes.dsp NEQ "admin.ship.combined">NOT </cfif>IN
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
			</cfif>
			(
				(
					i.exception = 0
					AND i.paid = '1'
					AND i.shipped = '0'
					AND i.ShippedTime IS NULL
				<cfif attributes.dsp EQ "admin.ship.combined">
					AND i.drefund IS NULL
					AND i.PaidTime IS NOT NULL
<!---				AND t.byrCountry = 'US'--->
				<cfelseif attributes.dsp EQ "admin.ship.international">
					AND i.drefund IS NULL
					AND i.PaidTime IS NOT NULL
					AND t.byrCountry != 'US'
				<cfelseif attributes.dsp EQ "admin.ship.urgent">
					AND i.drefund IS NULL
					AND
					(
						(i.PaidTime <= DATEADD(DAY, -7, GETDATE()) AND t.byrCountry = 'US')
						OR
						(i.drefund IS NOT NULL AND i.PaidTime IS NOT NULL AND t.byrCountry != 'US')
					)
				<cfelseif attributes.dsp EQ "admin.ship.refund">
					AND i.drefund IS NOT NULL
					AND t.byrCountry = 'US'
				<cfelse>
					AND i.drefund IS NULL
					AND t.byrCountry = 'US'
					<cfif attributes.srch NEQ ""><!--- search on Awaiting should search also Urgent --->
						AND i.PaidTime IS NOT NULL
					<cfelse>
						AND i.PaidTime > DATEADD(DAY, -7, GETDATE())
					</cfif>
				</cfif>
				)
				<cfif (attributes.dsp EQ "admin.ship.urgent") OR ((attributes.srch NEQ "") AND (attributes.dsp EQ "admin.ship.awaiting"))><!--- search on Awaiting should search also Urgent --->
					OR (i.exception = 1)
				</cfif>
			)
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srch NEQ "">
				AND (
					i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.srch)#%">
					OR
					e.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.srch)#%">
					OR
					i.ebayitem LIKE '%#trim(attributes.srch)#%'
					OR
					i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.srch)#%">
					OR
					i.internal_itemSKU LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.srch)#%">
					OR
					i.internal_itemSKU2 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.srch)#%">

				)
			<cfelse>
				and 1=0
			</cfif>
			ORDER BY #attributes.orderby# #attributes.dir#


</cfquery>


<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>#attributes.pageTitle#</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
			<div style="float:right">
				<form method="POST" action="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">
					<input type="text" name="searchTerm" id="searchTerm" value="">
					<input type="submit" value="Fix Item Search">
				</form>
			</div>

	<br><br>

<cfif isDefined("attributes.nil_error")>


			<h3 style="color:red;">Item [#attributes.item#] does not belong to selected Ship List!</h3>
			<div style="float:right">
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="18" name="srch" id="search" value="#HTMLEditFormat(attributes.srch)#">
				<input type="submit" value="Search Items">
			</form>
			</div>
<cfelse>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>Ship List:</td>
		<td>Enter Item Number:</td>
	</tr>
	<form method="POST" action="index.cfm?act=admin.ship.generate_label&maximize=true"><!--- target="_blank" onSubmit="postSubmit()"--->
	<tr>
		<td>
			<select name="ship_list">
				<option value="all"<cfif attributes.ship_list EQ "all"> selected</cfif>>All</option>
				<option value="admin.ship.awaiting"<cfif attributes.ship_list EQ "admin.ship.awaiting"> selected</cfif>>Awaiting Ship</option>
				<option value="admin.ship.ship_sold_off"<cfif attributes.ship_list EQ "admin.ship.ship_sold_off"> selected</cfif>>Off eBay</option>
				<option value="admin.ship.combined"<cfif attributes.ship_list EQ "admin.ship.combined"> selected</cfif>>Combined</option>
				<option value="admin.ship.international"<cfif attributes.ship_list EQ "admin.ship.international"> selected</cfif>>Inter</option>
				<option value="admin.ship.urgent"<cfif attributes.ship_list EQ "admin.ship.urgent"> selected</cfif>>Urgent</option>
			</select>
		</td>
		<td>
			<input type="text" size="20" maxlength="18" name="item" id="item">
			<input type="submit" value="Generate Label">
		</td>




	</tr>
	</form>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>
			<div style="float:right">
				<form method="POST" action="#_machine.self#">
					<input type="text" size="20" maxlength="18" name="srch" id="search" value="#HTMLEditFormat(attributes.srch)#">
					<input type="submit" value="Search Items">
				</form>
			</div>
		</td>
	</tr>
	</table>
</cfif>
</td></tr>
</table>
</cfoutput>

<!---
#########################
## 20120718 patrick wanted a search like in the awaiting http://www.instantonlineconsignment.com/index.cfm?dsp=admin.ship.awaiting
## starts
#########################
--->

<!--- output the search if they have search --->
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfoutput>
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
</cfoutput>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td rowspan="2" align=center>
				<!--- 20120216 fix thumb display --->
<!---				<cfif sqlTemp.galleryurl EQ "">
				<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse><a href="#sqlTemp.galleryurl#" target="_blank">
				<img src="#sqlTemp.galleryurl#" width=80 border=1>
				</cfif>--->
				<cfif sqlTemp.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
				<cftry>
						<cfhttp method="head" url="#sqlTemp.galleryurl#" result="sc">
						<cfif sc.statuscode is "200 OK">
							<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" border="1" width="80"></a>
						<cfelse>
							<!--- use_pictures --->
							<cfset sqlTemp.galleryurl = replace(sqlTemp.galleryurl,sqlTemp.item,sqlTemp.use_pictures)>
							<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" border="1" width="80"></a>
						</cfif>
				<cfcatch>
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				</cfcatch>
				</cftry>
				</cfif>
			</td>
			<td rowspan="2" align=center><cfif isAllowed("Listings_EditShippingNote")><a href="javascript: fShipNote('#sqlTemp.item#')"><cfif sqlTemp.shipnote EQ ""><img src="#request.images_path#icon14.gif" border=0><cfelse>Edit</cfif></a><cfelse><cfif sqlTemp.shipnote EQ "">N/A<cfelse><a href="javascript: fShipNote('#sqlTemp.item#')">View</a></cfif></cfif></td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a><br>LID: #sqlTemp.lid#</td>
			<td align=left>#sqlTemp.title#</td>
			<td nowrap align=center>#DateFormat(sqlTemp.PaidTime)#</td>
			<td align=center>#sqlTemp.weight# lbs.</td>
			<td align=center>$#sqlTemp.price#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.etitle#</td>
			<td align="center">#sqlTemp.hbuserid#<cfif Trim(sqlTemp.byrCountry) NEQ ""> (#sqlTemp.byrCountry#)</cfif></td>
			<td align="center"><cfif isAllowed("Listings_CreateLabel")><a href="index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#sqlTemp.item#&ebayitem=#sqlTemp.ebayitem#&TransactionID=0&nextdsp=#attributes.dsp#" onClick="return confirm('Are you sure to change item status on eBay?');"><img src="#request.images_path#icon8.gif" border=0></a><cfelse>N/A</cfif></td>
			<td align="center"><a href="index.cfm?dsp=admin.ship.fedex.FedexForm&item=#sqlTemp.item#"><img src="#request.images_path#icon13.gif" border=0></a></td>
		</tr>
		<cfif attributes.dsp EQ "admin.ship.combined">
			<tr bgcolor="##FFFFFF">
				<td colspan="3" align="center">
					<cfif attributes.local_buyers EQ 0>
						<a href="index.cfm?act=admin.ship.move2local&buyer=#URLEncodedFormat(hbuserid)#">Move <b>#sqlTemp.hbuserid#</b> to LOCAL</a>
					<cfelse>
						<a href="index.cfm?act=admin.ship.move2nonlocal&buyer=#URLEncodedFormat(hbuserid)#">Move <b>#sqlTemp.hbuserid#</b> to NON-LOCAL</a>
					</cfif>
				</td>
				<td colspan="3" align="center"><a href="#_machine.self#&srch=#attributes.srch#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=#attributes.page#&combined_add=#sqlTemp.item#">Add #sqlTemp.item# to combined shipment list</a></td>
				<td align="center"><input type="checkbox" name="combined_add" value="#sqlTemp.item#"></td>
			</tr>
		<cfelseif ListFindNoCase("admin.ship.urgent,admin.ship.refund,admin.ship.international", attributes.dsp)>
			<form action="index.cfm?dsp=#attributes.dsp#&item=#sqlTemp.item#&act=admin.ship.set_rpr" method="post">
			<tr bgcolor="##FFFFFF">
			<cfif attributes.dsp EQ "admin.ship.urgent">
				<td colspan="3" align="center">
					<a href="index.cfm?act=admin.exception&items=#sqlTemp.item#&dsp=#attributes.dsp#&exception=2">Move #sqlTemp.item# to AP 30+ Days</a>
				</td>
				<td align="center">
					<cfif attributes.local_buyers EQ 0>
						<a href="index.cfm?act=admin.ship.move2local&buyer=#URLEncodedFormat(hbuserid)#">Move <b>#sqlTemp.hbuserid#</b> to LOCAL</a>
					<cfelse>
						<a href="index.cfm?act=admin.ship.move2nonlocal&buyer=#URLEncodedFormat(hbuserid)#">Move <b>#sqlTemp.hbuserid#</b> to NON-LOCAL</a>
					</cfif>
				</td>
				<td colspan="2" align="right">
			<cfelse>
				<td colspan="6" align="right">
			</cfif>
					<b>Refund: </b><cfif isDate(sqlTemp.drefund)>#ListGetAt("N/A,Cannot Find,Double-Sold,Broken", sqlTemp.refundpr+1)#: #DateFormat(sqlTemp.drefund, "mm/dd/yyyy")#<cfelse><select name="refundpr">#SelectOptions(sqlTemp.refundpr, "1,Cannot Find;2,Double-Sold;3,Broken")#</select></cfif>
				</td>
				<td align="center"><input type="submit" value="<cfif isDate(sqlTemp.drefund)>Delete<cfelse>Save</cfif>" style="font-size: 10px;"></td>
			</tr>
			</form>
		<cfelseif attributes.dsp EQ "admin.ship.awaiting">
		<tr bgcolor="##FFFFFF">
			<td colspan="6" align="right"><a href="index.cfm?act=admin.exception&items=#sqlTemp.item#&dsp=#attributes.dsp#&exception=1">Move to Urgent Shipment</a></td>
			<td align="center"><input type="checkbox" name="items" value="#sqlTemp.item#"></td>
		</tr>
		</cfif>
		<cfif sqlTemp.shipnote NEQ "">
			<tr bgcolor="##F0F1F3"><td colspan="7"><b>Note: </b>#sqlTemp.shipnote#<br><br></td></tr>
		<cfelse>
			<tr bgcolor="##F0F1F3"><td colspan="7">&nbsp;</td></tr>
		</cfif>
		</cfoutput>
		<cfoutput>
		<cfif attributes.dsp EQ "admin.ship.awaiting">
		<tr bgcolor="##FFFFFF">
			<td colspan="4">&nbsp;</td>
			<td colspan="3" align="center"><input type="submit" value="Move checked to Urgent Shipment" style="width:220px;"></td>
		</tr>
		<cfelseif attributes.dsp EQ "admin.ship.combined">
		<tr bgcolor="##FFFFFF">
			<td colspan="7" align="center"><input type="submit" value="Move checked to Combined Shipment List" style="width:220px;"></td>
		</tr>
		</form>
		</cfif>
		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>

<cfif attributes.dsp NEQ "admin.ship.refund">
<script language="javascript" type="text/javascript">
<!--
document.getElementById("search").focus();
document.getElementById("search").value = ".";
document.getElementById("search").select();
document.getElementById("search").value = "";
//-->
</script>
</cfif>
</cfoutput>
</table>

<!---
#########################
## 20120718 patrick wanted a search like in the awaiting http://www.instantonlineconsignment.com/index.cfm?dsp=admin.ship.awaiting
## ENDS
#########################
--->

<cfoutput>
<br>
<cfif NOT isDefined("attributes.nil_error")>
<!---
	function postSubmit(){
		document.getElementById("item").focus();
		document.getElementById("item").select();
	}
--->
	<script language="javascript" type="text/javascript">
	<!--
	document.getElementById("item").focus();
	document.getElementById("item").value = ".";
	document.getElementById("item").select();
	document.getElementById("item").value = "";
	//-->
	</script>
</cfif>

<script type="text/javascript">
	var mytext = document.getElementById("search");
	mytext.focus();
</script>
</cfoutput>


