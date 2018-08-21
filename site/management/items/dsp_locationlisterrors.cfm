<cfoutput>
<table width="700" style="text-align: justify;">
<tr><td>
</cfoutput>

<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.lid, i.item, i.title, i.dlid, i.status, s.status as curstatus
	FROM items i
		LEFT JOIN status s ON i.status = s.id
	WHERE i.lid != ''
		AND i.lid != 'RTC'
		AND i.lid != 'DTC'
		AND i.lid != 'RELOT'
		AND i.lid != 'P&S'
		AND i.multiple = ''
		AND (i.status = 1 OR i.status = 2 OR (i.status = 3 AND i.dlid < DATEADD(DAY, -7, GETDATE())) OR i.status = 7 OR i.status = 9 OR i.status = 11 OR i.status = 13 OR i.status = 14)
	ORDER BY lid, item
</cfquery>

<cfoutput></table></td></tr></table><br><br>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td align="center"><strong>LID</strong></td>
			<td align="center"><strong>Item Number</strong></td>
			<td align="left"><strong>Item Title</strong></td>
			<td align="center"><strong>LID Date</strong></td>
		</td></tr>
		</cfoutput>

		<cfoutput query="sqlList">
		<tr bgcolor="##FFFFFF">
			<td align="center"><strong>#sqlList.lid#</strong></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlList.item#">#sqlList.item#</a></td>
			<td align="left"><b>#sqlList.title# (#sqlList.curstatus#)</b></td>
			<td align="center">#DateFormat(sqlList.dlid)# #TimeFormat(sqlList.dlid)#</td>
		</tr>
		</cfoutput>
<cfoutput>
	</td></tr></table>
</td></tr>
</table>
</td></tr>
</table>
</cfoutput>
