<cfif NOT isAllowed("Items_ItemLocation")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.lid, i.item, i.title, i.dlid, i.status, s.status as curstatus
	FROM items i
		LEFT JOIN status s ON i.status = s.id
	WHERE lid LIKE '%[.]%'
		AND i.multiple = ''
	ORDER BY lid, item
</cfquery>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Incorrect Locations:</strong></font>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td align="center"><strong>LID</strong></td>
			<td align="center"><strong>Item Number</strong></td>
			<td align="left"><strong>Item Title</strong></td>
			<td align="center"><strong>LID Date</strong></td>
		</tr>
		<cfloop query="sqlList">
		<tr bgcolor="##FFFFFF">
			<td align="center"><strong>#sqlList.lid#</strong></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlList.item#">#sqlList.item#</a></td>
			<td align="left"><b>#sqlList.title# (#sqlList.curstatus#)</b></td>
			<td align="center" nowrap>#DateFormat(sqlList.dlid)# #TimeFormat(sqlList.dlid)#</td>
		</tr>
		</cfloop>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
