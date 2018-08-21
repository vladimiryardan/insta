<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfif attributes.act EQ "management.items.dns2ntd">
	<cfset newStatus = 13><!--- DONATE TO CHARITY --->
<cfelse>
	<cfset newStatus = 9><!--- RETURNED TO CLIENT --->
</cfif>
<cfquery name="sqlItems" datasource="#request.dsn#">
	SELECT item
	FROM items
	WHERE aid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.account#">)
		AND status IN (8,12,16)<!--- DID NOT SELL, NEED TO CALL, NEED TO RELOT --->
</cfquery>
<cfloop query="sqlItems">
	<cfset fChangeStatus (sqlItems.item, newStatus)>
</cfloop>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.list&account=#attributes.account#">
