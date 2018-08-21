<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">

<cfquery name="sqlStatusHistory" datasource="#request.dsn#">
	SELECT s1.status AS old_status, s2.status AS new_status, DATEADD(SECOND, [timestamp] + DATEDIFF(SECOND, GETUTCDATE(), GETDATE()), '01/01/1970') AS dstatus_changed
	FROM status_history h
		LEFT JOIN status s1 ON h.old_status = s1.id
		LEFT JOIN status s2 ON h.new_status = s2.id
	WHERE h.iid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	ORDER BY 3 DESC
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
		<td class="ColHead" width="150">Old Status</td>
		<td class="ColHead" width="150">New Status</td>
		<td class="ColHead" width="150">Changed At</td>
	</tr>
	<cfloop query="sqlStatusHistory">
		<tr bgcolor="##<cfif CurrentRow MOD 2 EQ 0>F0F1F3<cfelse>FFFFFF</cfif>">
			<td>#old_status#</td>
			<td>#new_status#</td>
			<td align="center">#strDate(dstatus_changed)#</td>
		</tr>
	</cfloop>
	</table>
</td></tr>
</table>
<br>
</cfoutput>
