<!---
created: 20110805
author: vladimiryardan@gmail.com
description: this list items amazon and item received
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
			AND e.hbemail IS NOT NULL
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
	<font size="4"><strong>Amazon Item Managment:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<!---<cfif isAllowed("EndOfDay_Shipments")>
	<b>Print Daily Report For:</b>
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>--->
	</td></tr></table>

	<!--- searc form --->
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
			<td class="ColHead"><a href="JavaScript: void fSort(1);">SKU</a></td>
			<td class="ColHead"> <a href="JavaScript: void fSort(2);">Item received</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">P&S Items</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">SKU count</a></td>
			<!---<td class="ColHead"><!---<a href="JavaScript: void fSort(1);">SKU</a>---></td>--->
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.internal_itemSKU,
			(
			SELECT count(ii.item)
			FROM items ii
			WHERE ii.status = '3' and ii.internal_itemCondition = 'amazon' and ii.internal_itemSKU = i.internal_itemSKU
			) as itemreceived_count,

			(
			SELECT count(x.item)
			FROM items x
			WHERE x.shipped = '1' AND x.paid = '1' and x.internal_itemCondition = 'amazon' 
			and x.internal_itemSKU = i.internal_itemSKU
			) as paidnshipped_count,

			<!--- sku count --->
			(
				SELECT count(*)
				FROM items
				left JOIN status ON status.id = items.status
				where
				items.internal_itemSKU = i.internal_itemSKU
				<!--- 8 = did not sell, 3=Item received, 16=fixed inventory --->
				and (items.status = 8 or items.status = 3 or items.status = 16)
				and (items.internal_itemCondition != 'amazon')
				<!---and items.offebay = '1'--->
				and (items.item not like '%.11048.%' and items.item not like '%.11108.%') <!--- old account --->
			) as skuCount

			FROM items i
			WHERE (i.status = '3' or (i.shipped = '1' AND i.paid = '1'))  and i.internal_itemCondition = 'amazon'

			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srch NEQ "">
				AND (
					i.internal_itemSKU LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
				)
			</cfif>



			group by i.internal_itemSKU
			ORDER BY #ATTRIBUTES.ORDERBY# #ATTRIBUTES.DIR#

		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('efefef'))#">
			<!---<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>--->
			<!---<td>#sqlTemp.title#</td>--->
			<td>#sqlTemp.internal_itemSKU#</td>
		<!---
		<cfquery name="get_skuItems" datasource="#request.dsn#">
			SELECT item
			FROM items i
			WHERE i.status = '3' and i.internal_itemCondition = 'amazon' and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#'
		</cfquery>
		--->
		<td>
			<a href="index.cfm?dsp=amazon_live.item_received&sku=#URLEncodedFormat(sqlTemp.internal_itemSKU)#">#sqlTemp.itemreceived_count#</a>
		</td>
<!---
		<cfquery name="get_paidAndShipped" datasource="#request.dsn#">
			SELECT i.item, i.ebayitem, i.title, i.PaidTime, i.ShippedTime, i.shipper, i.tracking, i.byrName
			FROM items i
			WHERE i.shipped = '1' AND i.paid = '1'
			and i.internal_itemCondition = 'amazon' and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#'
		</cfquery>
--->
		<td>
			<a href="index.cfm?dsp=amazon_live.amazon_paidshipped&sku=#URLEncodedFormat(sqlTemp.internal_itemSKU)#">#sqlTemp.paidnshipped_count#</a>
		</td>
		<td>
			<a href="index.cfm?dsp=amazon_live.amazon_skucount&sku=#URLEncodedFormat(sqlTemp.internal_itemSKU)#">#sqlTemp.skuCount#</a>

		</td>
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
