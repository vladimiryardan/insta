<cfif NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT itemid, ebayitem, dtend, itemxml
	FROM ebitems
	WHERE SUBSTRING(itemxml, 1, 5) = <cfqueryparam cfsqltype="cf_sql_varchar" value="<?xml">
		AND itemxml NOT LIKE '%&gt;' + itemid + '-%'
	ORDER BY dtend
</cfquery>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Badly Listed:</strong></font>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td align="center"><strong>Item Number</strong></td>
			<td align="center"><strong>Auction Number</strong></td>
			<td align="center"><strong>Auction End</strong></td>
			<td align="center"><strong>Item Number<br>(suggested)</strong></td>
		</tr>
		<cfloop query="sqlList">
			<cfset sItem = "N/A">
			<cfset aLenPos = REFindNoCase("&gt;[0-9]{3}\.[0-9]+\.[0-9]+\-", sqlList.itemxml, 1, true)>
			<cfif aLenPos.len[1] GT 0>
				<cfset sItem = mid(sqlList.itemxml, aLenPos.pos[1] + 4, aLenPos.len[1] - 5)>
			<cfelse>
				<cfset aLenPos = REFindNoCase("&gt;[0-9,'""\-\.]+&lt;", sqlList.itemxml, 1, true)>
				<cfif aLenPos.len[1] GT 0>
					<cfset sItem = mid(sqlList.itemxml, aLenPos.pos[1]+4, aLenPos.len[1]-8)>
				</cfif>
				<cfif Len(sItem) GT 20>
					<cfset sItem = Left(sItem, 20)>
				</cfif> 
			</cfif>
			<cfif sqlList.itemid NEQ sItem>
				<tr bgcolor="##FFFFFF">
					<td><a href="index.cfm?dsp=management.items.edit&item=#sqlList.itemid#">#sqlList.itemid#</a></td>
					<td align="center"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlList.ebayitem#" target="_new">#sqlList.ebayitem#</a></td>
					<td align="center" nowrap>#DateFormat(sqlList.dtend)# #TimeFormat(sqlList.dtend)#</td>
					<td align="center">
					<cfif ListLen(sItem, ".") EQ 3><a href="index.cfm?dsp=management.items.edit&item=#sItem#">#sItem#</a><cfelse>#sItem#</cfif> 
					</td>
				</tr>
			</cfif>
		</cfloop>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
