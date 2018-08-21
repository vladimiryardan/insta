<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfquery datasource="#request.dsn#">
	UPDATE items
	SET tracking = NULL
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">
