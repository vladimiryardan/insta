<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfset _paging.RowsOnPage = getVar('Paging.RowsOnPage4Multiple', 200, "NUMBER")>
<cfparam name="attributes.orderby" default="6 DESC, 3">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.title,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		a.id, u.ready, i.lid,
		i.dpictured, i.status
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE i.multiple = 'MULTIPLE'
		AND i.item IN
		(
			SELECT DISTINCT a.multiple
			FROM items a
				LEFT JOIN auctions b ON a.item = b.itemid
			WHERE b.itemid IS NULL
		)
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
		AND a.id NOT IN (8480,8099)
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
		function fCheckAll(){
			obj = document.getElementById("theForm").multidup;
			if(isNaN(obj.length)){
				obj.checked = true;
			}else{
				for(i=0; i<obj.length; i++){
					obj[i].checked = true;
				}
			}
		}
	//-->
	</script>
	</cfoutput>
</cfif>
<cfset attributes.show_check_all = FALSE>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Multiple:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				#_paging.RecordCount# records<!--- Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#--->
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
		<cfif isDefined("attributes.printable")>
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Item ID</td>
			<td class="ColHead">Title (LID)</td>
			<td class="ColHead">Time Received</td>
			<td class="ColHead">Time Pictured</td>
			<td class="ColHead">##</td>
		</tr>
		<cfelse>
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Title</a> (<a href="JavaScript: void fSort(8);">LID</a>)</td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Time Received</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(9);">Time Pictured</a></td>
			<td class="ColHead">Last Listed</td>
			<td class="ColHead">##</td>
			<td class="ColHead" colspan="2">Duplcate Auction To</td>
		</tr>
		<form action="index.cfm?dsp=#attributes.dsp#&act=admin.auctions.duplicate" method="post" id="theForm" name="theForm">
		</cfif>
		</cfoutput>
		<cfif isDefined("attributes.printable")>
			<cfset _paging.RowsOnPage = _paging.RecordCount>
			<cfset _paging.StartRow = 1>
		</cfif>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#<cfif sqlTemp.lid NEQ ""> (#sqlTemp.lid#)</cfif></td>
			<td align="center"><cfif sqlTemp.isrec EQ "0"><font color="blue"></cfif>#strDate(sqlTemp.drec)#<cfif sqlTemp.isrec EQ "0"></font></cfif></td>
			<td align="center"><cfif isDate(sqlTemp.dpictured)>#strDate(sqlTemp.dpictured)#<cfelse>N/A</cfif></td>
		<cfif isDefined("attributes.printable")>
			<cfquery name="sqlChilds" datasource="#request.dsn#">
				SELECT COUNT(i.item) AS cnt
				FROM items i
					LEFT JOIN auctions u ON i.item = u.itemid
				WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
					AND u.itemid IS NULL
			</cfquery>
			<td align="right">#sqlChilds.cnt#&nbsp;</td>
		<cfelse>
			<cfquery name="sqlStatusHistory" datasource="#request.dsn#">
				SELECT MAX(DATEADD(SECOND, h.[timestamp] + DATEDIFF(SECOND, GETUTCDATE(), GETDATE()), '01/01/1970')) AS max_listed
				FROM items i
					INNER JOIN status_history h ON i.item = h.iid
				WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
					AND h.new_status = 4
			</cfquery>
				<td nowrap align="center"><cfif isDate(sqlStatusHistory.max_listed)>#DateFormat(sqlStatusHistory.max_listed)#<cfelse>Never</cfif></td>
			<cfif sqlTemp.ready EQ "">
				<td colspan="3" align="center"><a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#">Create Auction</a></td>
			<cfelse>
				<cfquery name="sqlChilds" datasource="#request.dsn#">
					SELECT i.item AS child_itemid
					FROM items i
						LEFT JOIN auctions u ON i.item = u.itemid
					WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
						AND u.itemid IS NULL
				</cfquery>
				<cfif sqlChilds.RecordCount GT 0>
					<cfset attributes.show_check_all = TRUE>
					<td align="right">#sqlChilds.RecordCount#&nbsp;</td>
					<td align="center" width="30"><input type="checkbox" name="multidup" value="#CurrentRow#"></td>
					<td align="left" width="100">
						<input type="hidden" name="item_#CurrentRow#" value="#sqlTemp.item#">
						<select name="newitem_#CurrentRow#"><cfloop query="sqlChilds" endrow="1">
							<option value="#child_itemid#">#child_itemid#</option></cfloop>
						</select>
					</td>
				<cfelse>
					<td colspan="3" align="center">N/A</td>
				</cfif>
			</cfif>
		</cfif>
		</tr>
		<cfif ListFindNoCase("2,3", status) AND (sqlTemp.ready NEQ "1")><!--- Item Created, Item Received --->
			<cfquery name="sqlListedChilds" datasource="#request.dsn#">
				SELECT '<a href="index.cfm?dsp=#attributes.dsp#&act=admin.auctions.duplicate&newitem=#sqlTemp.item#&item=' + i.item + '">' + i.item + '</a>' AS child_itemid
				FROM items i
					INNER JOIN auctions u ON i.item = u.itemid
				WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
					AND u.ready = 1
					AND i.status IN (4,5,10,11)<!--- Auction Listed, Awaiting Payment, Awaiting Shipment, Paid and Shipped --->
			</cfquery>
			<cfif sqlListedChilds.RecordCount GT 0>
				<tr bgcolor="##FFFFFF"><td colspan="8" align="center" style="color:red;">
					LISTED AUCTION(S): #ValueList(sqlListedChilds.child_itemid)#.<br>
					Click at item to duplicate its auction to #sqlTemp.item#
				</td></tr>
			</cfif>
		</cfif>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput>
			<tr bgcolor="##F0F1F3">
				<td colspan="5" align="right">
					<cfif attributes.show_check_all>
						<input type="button" onClick="fCheckAll()" value="Check All">
					<cfelse>
						#sqlTemp.RecordCount#
					</cfif>
				</td>
				<td colspan="3" align="center">
					<input type="submit" value="Duplicate Selected" style="font-size:10px;">
				</td>
			</tr>
			</form>
			<tr bgcolor="##FFFFFF"><td colspan="8" align="center">
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
</cfoutput>
