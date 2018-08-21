<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfif isdefined("attributes.rdio_ItemTemplate")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET itemis_template = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.rdio_ItemTemplate#">,
		itemis_template_setdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>



<cfset LogAction("edited item #attributes.item# marked as template auction")>
<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">