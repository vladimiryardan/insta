<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">

<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">

<cftransaction>
	<cfquery datasource="#request.dsn#">
		UPDATE items SET ebayitem = NULL
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfquery datasource="#request.dsn#">
		DELETE FROM items_ended
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cftransaction>

<cfset LogAction("unasigned auction from item #attributes.item#")>

<cfscript>
	fChangeStatus (attributes.item, 3); // ITEM RECEIVED
</cfscript>
