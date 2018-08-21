<cfquery datasource="#request.dsn#">
	INSERT INTO local_buyers
	(eBayUser)
	VALUES
	(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.buyer#">
	)
</cfquery>
<cfset LogAction("moved #attributes.buyer# to LOCAL")>
<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.urgent&local_buyers=0">
