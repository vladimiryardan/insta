<cfif NOT isGroupMemberAllowed("Listings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.dayrange" default="30">
<cfparam name="attributes.enddate" default="#now()#">
<cfparam name="attributes.startdate" default="#DateAdd( "d", -attributes.dayrange, now() )#">

<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&srch=#attributes.srch#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&srch=#attributes.srch#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Fixed Item Paid and Shipped (#attributes.dayrange# days Range):</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<!---
<cfif isAllowed("EndOfDay_Shipments")>
	<b>Print Daily Report For:</b>
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>
--->
	</td></tr>
</table>
<br><br>

	<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead">Track</td>
			<td class="ColHead">Label</td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Paid</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Shipped</a></td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item, i.ebayitem, i.title, i.PaidTime, i.ShippedTime, i.shipper, i.tracking, i.byrName
			FROM items i
			INNER JOIN auctions a ON i.item = a.itemid
			WHERE i.shipped = '1'
				AND i.paid = '1'
				and a.listingtype =  '1'
				and i.PaidTime between #createodbcdatetime(attributes.startdate)# and #createodbcdatetime(attributes.enddate)#
				<!---
				AND i.PaidTime IS NOT NULL
				AND i.ShippedTime IS NOT NULL
				--->
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srch NEQ "">
				AND (
					i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.ebayitem LIKE '%#attributes.srch#%'
					OR
					i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.byrName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.tracking LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
<!---					OR
					i.PaidTime LIKE #ParseDateTime("#attributes.srch#")#
					OR
					i.ShippedTime LIKE #ParseDateTime("#attributes.srch#")# --->
				)
			</cfif>
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title#</td>
			<td>
				<cfif (sqlTemp.shipper EQ "UPS") AND (sqlTemp.tracking NEQ "")>
					<a href="http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#sqlTemp.tracking#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12" target="_blank">#sqlTemp.tracking#</a>
				<cfelseif (sqlTemp.shipper EQ "USPS") AND (sqlTemp.tracking NEQ "")>
					<a href="http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#sqlTemp.tracking#" target="_blank">#sqlTemp.tracking#</a>
				<cfelse>
					&nbsp;
				</cfif>
			</td>
			<td align="center">
				<cfif (sqlTemp.shipper EQ "UPS") AND (sqlTemp.tracking NEQ "")>
					<a href="ups/label#sqlTemp.tracking#.html" target="_blank"><img src="#request.images_path#icon11.gif" border=0></a>
				<cfelseif (sqlTemp.shipper EQ "USPS") AND (sqlTemp.tracking NEQ "")>
					<a href="index.cfm?dsp=admin.ship.usps.print_label&itemid=#sqlTemp.item#" target="_blank"><img src="#request.images_path#icon11.gif" border=0></a>
				<cfelse>
					&nbsp;
				</cfif>
			</td>
			<td align="left">#DateFormat(sqlTemp.PaidTime)#</td>
			<td align="left">#DateFormat(sqlTemp.ShippedTime)#</td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
