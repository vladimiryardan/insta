<!---
	passing in an item number we get all items with the same internal_itemSKU2
--->



<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="i.dcreated">
<cfparam name="attributes.dir" default="desc">
<cfparam name="attributes.page" default="1">

<cfparam name="attributes.days" default="90" >

<cfparam name="attributes.item" default="0">
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page+"&item="+"#attributes.item#";
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Template List:</strong></font><br>
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
		<td class="ColHead">Title</td>
		<td class="ColHead">Date Shipped</td>

		<td class="ColHead">SKU2</td>
		<td class="ColHead">Final Price</td>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">

				SELECT i.item AS itemid, i.title, i.ShippedTime,
				i.dpictured,i.internal_itemSKU2,
				i.dcreated
				FROM items i
				WHERE i.shipped = '1'								
				AND i.paid = '1' 
				and i.ShippedTime >= DATEADD(Day, -#attributes.days#, GETDATE())
				and i.internal_itemSKU2 = (
					select internal_itemSKU2 from items 
					where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
				)				
				
			  order by 3 desc	
			<!---ORDER BY #attributes.orderby# #attributes.dir#--->
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">

		<cfquery datasource="#request.dsn#" name="sqlRecord">
			SELECT finalprice, dended
			FROM records
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.itemid#">
		</cfquery>
		

		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.itemid#">#sqlTemp.itemid#</a></td>
			<td>#sqlTemp.title#</td>

			<td>#dateformat(sqlTemp.dcreated,"medium" )#</td>
			<td>#sqlTemp.internal_itemSKU2#</td>
			<td>
				<cftry>
                	#dollarFormat(sqlRecord.finalprice)#                
                <cfcatch type="Any" >
                	0
                </cfcatch>
                </cftry>

			</td>
		</tr>

		</cfoutput>
		<cfoutput>

		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
