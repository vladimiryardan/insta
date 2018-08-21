<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="i.itemis_template_setdate">
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
		<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(2);">Title</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(3);">Date</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(4);">Pictured</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(5);">SKU</a></td>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item AS itemid, i.title, i.itemis_template_setdate, i.dpictured,i.internal_itemSKU
			FROM items i
			where itemis_template = <cfqueryparam cfsqltype="cf_sql_bit" value="1">

			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">

		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.itemid#">#sqlTemp.itemid#</a></td>
			<td>#sqlTemp.title#</td>
			<td>#dateformat(sqlTemp.itemis_template_setdate,"medium" )#</td>
			<td>#dateformat(sqlTemp.dpictured,"medium" )#</td>
			<td>#sqlTemp.internal_itemSKU#</td>
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
