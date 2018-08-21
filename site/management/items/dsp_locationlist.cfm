<cfquery name="sqlStatus" datasource="#request.dsn#">
	SELECT id, status
	FROM status
</cfquery>
<cfset aStatus = ArrayNew(1)>
<cfloop query="sqlStatus">
	<cfset aStatus[id] = status>
</cfloop>
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT lid, item, title, dlid, status
	FROM items 
	WHERE lid != ''
		AND lid != 'RTC'
		AND lid != 'DTC'
		AND lid != 'RELOT'
		AND lid != 'P&S'
	ORDER BY dlid, lid, item
</cfquery>

<cfquery name="sqlListcnt" datasource="#request.dsn#">
	SELECT lid, COUNT(lid) as cnt
	FROM items 
	WHERE lid != ''
		AND lid != 'RTC'
		AND lid != 'DTC'
		AND lid != 'RELOT'
		AND lid != 'P&S'
	GROUP BY lid
</cfquery>

<cfoutput>
<table width="700" style="text-align: justify;">
<tr><td>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td align="center"><strong>LID</strong></td>
			<td align="center"><strong>## of Items</strong></td>
		</tr><cfloop query="sqlListcnt">
		<tr bgcolor="##FFFFFF">
			<td align="center">#sqlListcnt.lid#</td>
			<td align="center">#sqlListcnt.cnt#</td>
		</tr></cfloop>
		</table>
	</td></tr>
	</table>
	<br><br>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td align="center"><strong>LID</strong></td>
			<td align="center"><strong>Item Number</strong></td>
			<td align="left"><strong>Item Title</strong></td>
			<td align="center"><strong>LID Date</strong></td>
		</tr><cfloop query="sqlList">
		<tr bgcolor="##FFFFFF">
			<td align="center"><strong>#sqlList.lid#</strong></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlList.item#">#sqlList.item#</a></td>
			<td align="left"><cfif ListFind("1,2,3,7,9,11,13,14", sqlList.status)><b></cfif>#sqlList.title# (#aStatus[sqlList.status]#)<cfif ListFind("1,2,3,7,9,11,13,14", sqlList.status)></b></cfif></td>
			<td align="center">#DateFormat(sqlList.dlid)# #TimeFormat(sqlList.dlid)#</td>
		</tr></cfloop>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
