<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="6 DESC, 3">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.title,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		a.id, u.ready, u.sandbox, i.lid,
		i.dpictured
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE i.status = '3'<!--- Item Received --->
		AND i.dpictured IS NOT NULL
		AND CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END > DATEADD(DAY, -30, GETDATE())
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
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
			if ('#attributes.orderby#' == OrderBy){
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
		<td align="left"><font size="4"><strong>Awaiting Listing:</strong></font><br></td>
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

		Enter Item Number:<br>
		<form method="POST" action="index.cfm?dsp=admin.auctions.step1">
			<input type="text" size="20" maxlength="18" name="item">
			<input type="submit" value="Create Auction">
		</form>
		<br><br>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<cfif isDefined("attributes.printable")>
			<td class="ColHead">Item ID</td>
			<td class="ColHead">Title (LID)</td>
			<td class="ColHead">Time Received</td>
			<td class="ColHead">Time Pictured</td>
		<cfelse>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Title</a> (<a href="JavaScript: void fSort(8);">LID</a>)</td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Time Received</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(9);">Time Pictured</a></td>
			<td class="ColHead">Auction</td>
			<td class="ColHead">Sandbox</td>
		</cfif>
		</tr>
		</cfoutput>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#<cfif sqlTemp.lid NEQ ""> (#sqlTemp.lid#)</cfif></td>
			<td align="center"><cfif sqlTemp.isrec EQ "0"><font color="blue"></cfif>#strDate(sqlTemp.drec)#<cfif sqlTemp.isrec EQ "0"></font></cfif></td>
			<td align="center"><cfif isDate(sqlTemp.dpictured)>#strDate(sqlTemp.dpictured)#<cfelse>N/A</cfif></td>
		<cfif NOT isDefined("attributes.printable")>
			<td align="center" width="90">
			<cfif sqlTemp.ready NEQ "">
				<cfif isAllowed("Lister_CreateAuction") OR isAllowed("Lister_EditAuction")>
					<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border="0" alt="Edit Auction"></a>
				</cfif>
				<a href="index.cfm?dsp=admin.auctions.preview&item=#sqlTemp.item#" target="_blank"><img src="#request.images_path#icon12.gif" border="0" alt="Preview Auction"></a>
			<cfelse>
				<cfif isAllowed("Lister_CreateAuction")>
					<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border="0" alt="Create Auction"></a>
				</cfif>
			</cfif>
			<cfif isAllowed("Lister_CreateAuction")>
				<a href="index.cfm?act=admin.auctions.delete&item=#sqlTemp.item#" onClick="return confirm('Deleted auction can never be restored. Are you sure you want to delete this auction?')"><img src="#request.images_path#icon16.gif" border="0" alt="Delete Auction"></a>
			</cfif>
			</td>
			<td align="center" width="110">
			<cfif (sqlTemp.ready EQ "1") AND isAllowed("Lister_ListAuction")>
				<a href="index.cfm?dsp=admin.auctions.list2sandbox&item=#sqlTemp.item#">List</a>
				<cfif sqlTemp.sandbox NEQ "">
					| <a href="http://cgi.sandbox.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.sandbox#" target="_blank">#sqlTemp.sandbox#</a>
				</cfif>
			<cfelse>
				N/A
			</cfif>
			</td>
		</cfif>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput>
			<tr bgcolor="##FFFFFF"><td colspan="6" align="center">
				</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
			</td></tr>
			</cfoutput>
		</cfif>
		<cfoutput>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--
document.getElementById("item").focus();
//-->
</script>

</cfoutput>
