<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfsetting requesttimeout="500">

<cfparam name="attributes.orderby" default="1">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.status" default="3">
<cfparam name="attributes.daysCreated" default="0">

<cfquery name="sqlTemp" datasource="#request.dsn#" >
	SELECT i.lid, i.item, i.title, i.dlid, i.status,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		u.ready
		,e.dtend
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
		<cfif attributes.status EQ "4">
			INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		<cfelse>
			LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem	
		</cfif>

	WHERE i.lid != ''
		AND i.lid != 'RTC'
		AND i.lid != 'DTC'
		AND i.lid != 'RELOT'
		AND i.lid != 'P&S'
		<!---AND i.multiple = '' 20160928. patrick says old code --->
		AND i.internal_itemCondition not like ('%amazon%')
		and i.lid not like ('%dummy%')

		
		<cfif attributes.status NEQ "0">
			AND i.status = #attributes.status#
		</cfif>
		
		<!---20161025. Patrick If within the last 36 hours do not include in the list --->
		<cfif attributes.status EQ "4"><!---Auction Listed (after auction ended) --->
			and e.dtend < DATEADD( DAY, -3, GETDATE() ) 
		</cfif>		
		
		<!--- Item Received --->
		<cfif attributes.status eq 3>
			and i.internal_itemCondition != 'bonanza' <!--- don't include bonanza --->
			
			and 
			<!---if Time Received within 72 hours do not include--->
			i.dreceived < GETDATE()
				<!---and i.dreceived < DATEADD( DAY, 3, GETDATE()---> 
			
		
		</cfif>

		<!--- 20161026 - FUTURE end date should not be in list --->	
		<cfif attributes.status EQ "11">
			and e.dtend < GETDATE() 
			and e.dtend < DATEADD( DAY, -3, GETDATE() ) 
		</cfif>	
					
		<cfif attributes.status EQ "4">
			AND e.dtend < GETDATE()			
		<cfelse>
			<cfif attributes.daysCreated NEQ "0">
				AND i.dcreated > DATEADD(DAY, -#attributes.daysCreated#, GETDATE())
			</cfif>
		</cfif>
		
		
		
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
		<!--- 20161025. optimize by filtering by the item match --->
		and i.item NOT IN
			(
				SELECT ii.item
				FROM accounts a
				INNER JOIN items ii ON a.id = ii.aid
				INNER JOIN auctions u ON ii.item = u.itemid
				LEFT JOIN queue q ON ii.item = q.itemid
				WHERE ii.item = i.item
				and q.itemid IS NOT NULL<!--- scheduled --->
				AND u.ready = '1'
				<cfif session.user.store EQ "202">
					AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
				</cfif>
			)
		and i.item NOT IN
			(
				SELECT ii.item
				FROM accounts a
					INNER JOIN items ii ON a.id = ii.aid
					LEFT JOIN auctions u ON ii.item = u.itemid
				WHERE ii.item = i.item
					and ii.status = '3'<!--- Item Received --->
					AND ii.lid != 'RTC'
					AND ii.lid != 'DTC'
					AND ii.lid != 'RELOT'
					AND ii.lid != 'P&S'
					
					and (u.ready = '' or u.ready is null)
					AND (ii.dpictured IS NULL or ii.dpictured = '')
					AND CASE WHEN ii.dreceived=0 THEN ii.dcreated ELSE ii.dreceived END > DATEADD(DAY, -#_vars.auctions.awaiting_auction_daysbackward_check#, GETDATE())
					<cfif session.user.store EQ "202">
						AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
					</cfif>
			)
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>


<!---	<cfquery name="sqlScheduled" datasource="#request.dsn#">
	SELECT i.item, q.listAt, u.title, a.id, u.GalleryImage, q.error,
		CASE WHEN LEN(u.use_pictures) > 0
			THEN u.use_pictures
			ELSE i.item
		END AS use_pictures
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		INNER JOIN auctions u ON i.item = u.itemid
		LEFT JOIN queue q ON i.item = q.itemid
	WHERE q.itemid IS NOT NULL<!--- scheduled --->
		AND u.ready = '1'
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
	</cfquery>--->


<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
	<cfoutput>
	<script language="javascript" type="text/javascript">
	<!--//
		function fPage(Page){
			window.location.href = "#_machine.self#&status=#attributes.status#&daysCreated=#attributes.daysCreated#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
		}
		function fSort(OrderBy){
			if (#attributes.orderby# == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&status=#attributes.status#&daysCreated=#attributes.daysCreated#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
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
		<td align="left"><font size="4"><strong>Item Recieved Errors:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#
			<cfelse>
				<a href="#_machine.self#&status=#attributes.status#&daysCreated=#attributes.daysCreated#&page=#attributes.page#&orderby=#attributes.orderby#&dir=#attributes.dir#&printable" target="_blank">Printable version</a>
			</cfif>
		</td>
	</tr>
	</table>
	<cfif NOT isDefined("attributes.printable")>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
		<table>
		<tr>
			<td>
				Enter Item Number:<br>
				<form method="POST" action="index.cfm?dsp=admin.auctions.step1">
					<input type="text" size="20" maxlength="18" name="item">
					<input type="submit" value="Create Auction">
				</form>
			</td>
			<td width="50">&nbsp;</td>
			<form method="POST" action="#_machine.self#">
			<td>
				Status:<br>
				<select name="status">
				#SelectOptions(attributes.status, "0,ALL;3,Item Received;4,Auction Listed (after auction ended);7,Check Sent;9,Returned to Client;11,Paid and Shipped;13,Donated to Charity;14,Item Relotted")#
				</select>
			</td>
			<td>
				Days Created:<br>
				<select name="daysCreated" style="width:100px; ">
				#SelectOptions(attributes.daysCreated, "0,ALL;7,7 Days;31,31 Days;45,45 Days;60,60 Days")#
				</select>
			</td>
			<td>
				<br>
				<input type="submit" value="Search">
			</td>
			</form>
		</tr>
		</table>
		<br><br>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<cfif isDefined("attributes.printable")>
			<td class="ColHead">Item ID</td>
			<td class="ColHead">Title</td>
			<td class="ColHead">Time Received</td>
			<td class="ColHead">LID</td>
			<td class="ColHead">LID Date</td>
		<cfelse>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td width="80" class="ColHead"><a href="JavaScript: void fSort(6);">Time Received</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">LID</a></td>
			<td width="80" class="ColHead"><a href="JavaScript: void fSort(4);">LID Date</a></td>
			<td class="ColHead">End</td>
			<td width="90" class="ColHead">Auction</td>
		</cfif>
		</tr>
		</cfoutput>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#</td>
			<td align="center"><cfif sqlTemp.isrec EQ "0"><font color="blue"></cfif>#DateFormat(sqlTemp.drec)#<br>#TimeFormat(sqlTemp.drec)#<cfif sqlTemp.isrec EQ "0"></font></cfif></td>
			<td align="center"><strong>#sqlTemp.lid#</strong></td>
			<td align="center">#DateFormat(sqlTemp.dlid)#<br>#TimeFormat(sqlTemp.dlid)#</td>
		<cfif NOT isDefined("attributes.printable")>
			<td>#sqlTemp.dtend#</td>
			<td align="center">
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
<cfif NOT isDefined("attributes.printable")>
<script language="javascript" type="text/javascript">
<!--
document.getElementById("item").focus();
//-->
</script>
</cfif>
</cfoutput>
