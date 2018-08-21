<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfquery datasource="#request.dsn#">
	DELETE FROM items_ended
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
</cfquery>
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET listcount = listcount + 1
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
</cfquery>

<cfset fChangeStatus(attributes.itemid, 4)><!--- Auction Listed --->

<cfset _machine.cflocation = "index.cfm?dsp=management.items.sold">
