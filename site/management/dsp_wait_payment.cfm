<cfif NOT isGroupMemberAllowed("Listings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
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
	<font size="4"><strong>Awaiting Payment:</strong></font><br>
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
				<input type="text" size="20" maxlength="18" name="item">
				<input type="submit" value="Generate Label">
			</form>
		</td>
		<td>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="18" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<input type="submit" value="Search Items">
			</form>
		</td>
	</tr>
	</table>
	<br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Ended</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">LID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">DLID</a></td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item, i.ebayitem, i.title, e.dtend AS dended, i.lid, i.dlid
			FROM items i
				INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
			WHERE i.status = 5<!--- Awaiting Payment --->
				AND i.paid = '0'
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
				AND e.dtend >= '2005-11-01'

			<cfif attributes.srch NEQ "">
				AND (
					i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					e.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.ebayitem LIKE '%#attributes.srch#%'
					OR
					i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
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
			<td nowrap>#DateFormat(sqlTemp.dended)#</td>
			<td>#sqlTemp.lid#</td>
			<td nowrap>#DateFormat(sqlTemp.dlid)#</td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="6" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
