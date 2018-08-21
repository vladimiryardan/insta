<cfif NOT isAllowed("Invoices_View")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="3">
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
	window.location.href = "#_machine.self#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Invoice List:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<strong>Store:</strong>
	<select name="store" onChange="fStore(this.value)">
		<option value="all"<cfif attributes.store EQ ""> selected</cfif>>All</option>
		<cfloop query="sqlStores">
		<option value="#sqlStores.store#"<cfif attributes.store EQ sqlStores.store> selected</cfif>>#sqlStores.store#</option>
		</cfloop>
	</select>
	<br><br>
	<br><table width=100%><tr><td width=50% align=left>
	Enter Search Name:<br>
	<form method="POST" action="#_machine.self#">
		<input type="text" size="20" maxlength="60" name="srch" value="#HTMLEditFormat(attributes.srch)#">
		<input type="submit" value="Search Invoices">
	</form></td></tr></table>
	<br><br>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<center>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Client Name</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Invoice Number</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Date</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Total</a></td>
			<td class="ColHead">Delete</td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT a.first + ' ' + a.last AS owner, i.invoicenum, i.dinvoiced,
				SUM(r.finalprice - r.ebayfees - r.ourfees - r.paypalfees) AS checkamount,
				a.store, i.aid, ISNULL(v.extra_amount, 0) AS extra_amount
			FROM items i
				INNER JOIN accounts a ON a.id = i.aid
				INNER JOIN records r ON r.itemid = i.item
				LEFT JOIN invoices v ON i.invoicenum = v.invoicenum
			WHERE i.invoicenum IS NOT NULL
			<cfif attributes.srch NEQ "">
				AND (a.first LIKE '%#attributes.srch#%'
					OR a.last LIKE '%#attributes.srch#%'
					<cfif isNumeric(attributes.srch)>
					OR a.id LIKE '%#attributes.srch#%'
					</cfif>
					OR i.invoicenum LIKE '%#attributes.srch#%')
			</cfif>

			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			GROUP BY a.first + ' ' + a.last, i.invoicenum, i.dinvoiced, a.store, i.aid, v.extra_amount
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfset prevValue = "">
		<cfset oddRow = false>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<cfif sqlTemp.owner NEQ prevValue>
			<cfset oddRow = NOT oddRow>
			<cfset prevValue = sqlTemp.owner>
		</cfif>
		<tr bgcolor="##<cfif oddRow>FFFFFF<cfelse>F0F1F3</cfif>">
			<td><a href="index.cfm?dsp=account.edit&id=#sqlTemp.aid#">#sqlTemp.owner#</a></td>
			<td><a target="_blank" href="invoices/Invoice #sqlTemp.store#.#sqlTemp.aid#.#sqlTemp.invoicenum#.htm">#sqlTemp.invoicenum#</a></td>
			<td>#DateFormat(dinvoiced)#</td>
			<td><cfif sqlTemp.extra_amount + sqlTemp.checkamount LT 0>$0<cfelse>#DollarFormat(sqlTemp.extra_amount + sqlTemp.checkamount)#</cfif></td>
			<td><a href="index.cfm?act=management.items.delinvoice&byinvoice=#sqlTemp.invoicenum#" onClick="return confirm('Are you sure you want to delete invoice for every item on this invoice?');"><img src="#request.images_path#icon16.gif" border=0></a></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="5" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
		</center>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
