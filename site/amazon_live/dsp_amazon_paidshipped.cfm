<!---
created: 20110805
author: vladimiryardan@gmail.com
description: this list items paid and shipped and item condition = amazon

--->
 <cfif NOT isGroupMemberAllowed("Listings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.xls" default="">
<cfif attributes.xls EQ "emails">
	<cfcontent reset="yes" type="application/msexcel">
	<cfheader name="Content-Disposition" value="attachment; filename=paid_shipped_emails.xls">
	<cfquery name="sqlList" datasource="#request.dsn#">
		SELECT DISTINCT e.hbemail
		FROM items i
			INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		WHERE i.shipped = '1'
			AND i.paid = '1'
			<!---AND e.hbemail IS NOT NULL--->
		ORDER BY e.hbemail
	</cfquery>
	<cfset _machine.layout = "no">
	<cfoutput>
	<table cellpadding="0" cellspacing="0" border="0">
	<tr><th>Email</th></tr><cfloop query="sqlList">
	<tr><td>#hbemail#</td></tr></cfloop>
	</table>
	</cfoutput>
	<cfexit method="exittemplate">
</cfif>
<cfparam name="attributes.orderby" default="5">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.sku" default="">
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
	<font size="4"><strong>Amazon Paid and Shipped:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<!---<cfif isAllowed("EndOfDay_Shipments")>
	<b>Print Daily Report For:</b>
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>--->
	</td></tr></table>
<br><br>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>Enter Search Term (title, number, buyer name):</td>
		<td width="300" rowspan="2"><!---<a href="index.cfm?dsp=management.paid_shipped&xls=emails">GATHER EMAILS</a>---></td>
		<td width="100">Store:</td>
	</tr>
	<tr>
		<td>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="18" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<input type="submit" value="Search Items">
			</form>
		</td>
		<td>
			<select name="store" onChange="fStore(this.value)">
				<option value="all"<cfif attributes.store EQ ""> selected</cfif>>All</option>
				<cfloop query="sqlStores">
				<option value="#sqlStores.store#"<cfif attributes.store EQ sqlStores.store> selected</cfif>>#sqlStores.store#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	</table>
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
			WHERE i.shipped = '1' AND i.paid = '1'
			and i.internal_itemCondition = 'amazon'
			<cfif attributes.sku neq "">
				and i.internal_itemSKU = '#attributes.sku#'
			</cfif>
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
