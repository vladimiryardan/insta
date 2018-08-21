<cfif NOT isAllowed("Items_ChangeStatus") AND NOT isAllowed("Items_NormalChangeStatus")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>



<cfif isAllowed("Items_ChangeStatus")>
	<cfif isdefined("attributes.changelid") and isdefined("attributes.item") and isdefined("attributes.newlidName")>
		<cfif attributes.newlidName neq "">
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET lid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.newlidName#">
				WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
			</cfquery>
			<cfset LogAction("lid changed to #attributes.newlidName# for item #attributes.item#")>
			<cfset x = fChangeLocation(attributes.item, attributes.newlidName) >
		</cfif>
	</cfif>
</cfif>