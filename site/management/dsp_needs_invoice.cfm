<cfif NOT isAllowed("Invoices_Awaiting")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.store" default="all">
<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts ORDER BY store
</cfquery>
<cfparam name="attributes.srchState" default="XX">
<cfset statesList = "XX,Any;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming">
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&srchState=#attributes.srchState#&srch=#URLEncodedFormat(attributes.srch)#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&srchState=#attributes.srchState#&srch=#URLEncodedFormat(attributes.srch)#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Need to be Invoiced List:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td align="left" width="35%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td>
		<td align="right" width="65%"><a href="index.cfm?dsp=admin.invoice_report" target="_blank">Accounting Report</a></td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td>
			<br><strong>Store:</strong>
			<select name="store" onChange="fStore(this.value)">
				<option value="all"<cfif attributes.store EQ ""> selected</cfif>>All</option>
				<cfloop query="sqlStores">
				<option value="#sqlStores.store#"<cfif attributes.store EQ sqlStores.store> selected</cfif>>#sqlStores.store#</option>
				</cfloop>
			</select>
		</td>
		<td>
			Enter Account Number or User Name and/or State:<br>
			<form method="POST" action="#_machine.self#&store=#attributes.store#">
				<input type="text" size="30" maxlength="50" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<select name="srchState">#SelectOptions(attributes.srchState, statesList)#</select>
				<input type="submit" value="Search">
			</form>
		</td>
	</tr>
	</table>
	<br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<center>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Invoice</td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Client Name</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Item Count</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Check Total</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Days on List</a></td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT a.first + ' ' + a.last AS owner, COUNT(i.id) AS numitems,
				SUM(r.checkamount) AS totalprice, MIN(r.dended) AS dol,
				a.id, i.status
			FROM items i
				INNER JOIN records r ON i.item = r.itemid
				INNER JOIN accounts a ON i.aid = a.id
			WHERE i.invoicenum IS NULL
				AND i.status = '11'
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srchState NEQ "XX">
				AND a.state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.srchState#">
			</cfif>
			<cfif isNumeric(attributes.srch)>
				AND a.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.srch#">
			<cfelseif attributes.srch NEQ "">
				AND a.first + ' ' + a.last LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
			</cfif>
			GROUP BY a.id, a.first + ' ' + a.last, a.id, i.status
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfset qClients = 0>
		<cfset qItems = 0>
		<cfset qPrice = 0>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
			<cfset qClients = qClients + 1>
			<cfset qItems = qItems + sqlTemp.numitems>
			<cfset qPrice = qPrice + sqlTemp.totalprice>
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.list&filter=noninvoiced30&account=#sqlTemp.id#"><img border="0" src="#request.images_path#payment.gif" alt="Invoice Items"></a></td>
			<td align="left"><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.owner#</a></td>
			<td>#sqlTemp.numitems#</td>
			<td align="right">#DollarFormat(sqlTemp.totalprice)#</td>
			<td align="right"><cftry>#DateDiff("d", ToString(sqlTemp.dol), Now())-10#<cfcatch type="any">N/A</cfcatch></cftry></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<cfif isAllowed("Full_Access")>
		<tr bgcolor="##F0F1F3">
			<td>&nbsp;</td>
			<td align="left">
				<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="left"><b>Page Total:</b></td>
					<td align="right"><b>#qClients#</b></td>
				</tr>
				</table>
			</td>
			<td><b>#qItems#</b></td>
			<td align="right"><b>#DollarFormat(qPrice)#</b></td>
			<td>&nbsp;</td>
		</tr>
		</cfif>
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
