<cfif NOT isDefined("session.user")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfquery datasource="#request.dsn#">
	UPDATE items
	SET title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.title#">,
		description = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.description#">
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset LogAction("edited item #attributes.item#")>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.detail&item=#attributes.item#">
