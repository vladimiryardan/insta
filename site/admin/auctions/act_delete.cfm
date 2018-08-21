<cfif NOT isAllowed("Lister_CreateAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.awaiting_listing">

<cfquery datasource="#request.dsn#" name="sqlCurrent">
	DELETE FROM auctions
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset LogAction("deleted auction for item #attributes.item#")>
