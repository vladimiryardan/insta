<cfif NOT isAllowed("Lister_Relotted")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="5">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.ebayitem, i.title, i.listcount, e.dtend, i.lid
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
	WHERE (i.status = 14)<!--- ITEM RELOTTED --->
		AND i.exception = 0
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>

<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
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
	</cfoutput>
</cfif>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Relotted Items:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#
			<cfelse>
				<a href="#_machine.self#&page=#attributes.page#&orderby=#attributes.orderby#&dir=#attributes.dir#&printable" target="_blank">Printable version</a>
			</cfif>
		</td>
	</tr>
	</table>
	<cfif NOT isDefined("attributes.printable")>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<cfif isDefined("attributes.printable")>
			<td class="ColHead">Item ID</td>
			<td class="ColHead">eBay Item</td>
			<td class="ColHead">Title</td>
			<td class="ColHead">Date Ended</td>
			<td class="ColHead" width="50">Times Listed</td>
		<cfelse>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Date Ended</a></td>
			<td class="ColHead" width="50"><a href="JavaScript: void fSort(4);">Times Listed</a></td>
		</cfif>
		</tr>
		</cfoutput>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title# (#sqlTemp.lid#)</td>
			<td>#DateFormat(sqlTemp.dtend, "mmm d, yyyy")#</td>
			<td align="center">#sqlTemp.listcount#</td>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput>
			<tr bgcolor="##FFFFFF"><td colspan="5" align="center">
				</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
			</td></tr>
			</cfoutput>
		</cfif>
		<cfoutput>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
