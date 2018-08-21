<cfquery datasource="#request.dsn#">
	DELETE FROM local_buyers
	WHERE eBayUser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.buyer#">
</cfquery>
<cfset LogAction("moved #attributes.buyer# to NON-LOCAL")>
<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.urgent&local_buyers=1">
