<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">

<cfquery datasource="#request.dsn#">
	UPDATE items
	SET status = 12,<!--- NEED TO CALL --->
		dcalled = GETDATE()
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset _machine.cflocation = "index.cfm?dsp=management.reserve">
