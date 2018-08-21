<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">

<cfquery name="sqlHistory" datasource="#request.dsn#">
	SELECT h.lid, h.dlid,
		CASE WHEN h.aid = 0 THEN 'SYSTEM' ELSE a.first + ' ' + a.last END AS username
	FROM location_history h
		LEFT JOIN accounts a ON h.aid = a.id
	WHERE h.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	ORDER BY 2 DESC
</cfquery>

<cfoutput>
<br>
<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding="0" align="center">
<tr><td style="font-size:16px; font-weight:bold; text-align:center;">
	Status changes for item #attributes.item#
</td></tr>
<tr><td>
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr bgcolor="##F0F1F3">
		<td class="ColHead" width="150">LID</td>
		<td class="ColHead" width="150">Changed At</td>
		<td class="ColHead" width="150">Changed By</td>
	</tr>
	<cfloop query="sqlHistory">
		<tr bgcolor="##<cfif CurrentRow MOD 2 EQ 0>F0F1F3<cfelse>FFFFFF</cfif>">
			<td>#lid#</td>
			<td align="center">#strDate(dlid)#</td>
			<td>#username#</td>
		</tr>
	</cfloop>
	</table>
</td></tr>
</table>
<br>
</cfoutput>
