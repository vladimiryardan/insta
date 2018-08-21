<cfif NOT isAllowed("Items_Delete")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfquery datasource="#request.dsn#">
	DELETE FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset LogAction("deleted item #attributes.item#")>

<cfset _machine.cflocation = "index.cfm?dsp=management.items&msg=1">
