<cfset _machine.cflocation = "index.cfm?dsp=" & attributes.dsp>

<cfquery datasource="#request.dsn#">
	DELETE FROM queue
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset LogAction("canceled schedule of #attributes.item#")>
