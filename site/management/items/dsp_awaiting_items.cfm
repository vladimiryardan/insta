<cfif NOT isAllowed("Items_NeverReceived")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
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
	<font size="4"><strong>Never Received:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Owner</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Time Created</a></td>
			<td class="ColHead">Mark</td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT a.first + ' ' + a.last AS owner, i.item, i.title, i.dcreated, a.id
			FROM accounts a
				INNER JOIN items i ON a.id = i.aid
			WHERE i.status = '2'<!--- Item Created --->
			<cfif #session.user.store# NEQ "201">
					AND a.store = #session.user.store#
			</cfif>

			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.owner#</a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#</td>
			<td align="center">#strDate(sqlTemp.dcreated)#</td>
			<td><cfif isAllowed("Items_ChangeStatus") OR isAllowed("Items_NormalChangeStatus")><a href="index.cfm?act=management.items.change_status&item=#sqlTemp.item#&newstatusid=3&backdsp=management.items.awaiting_items">...as received</a><cfelse>N/A/</cfif></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="5" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
