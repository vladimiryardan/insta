<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">

<cfquery datasource="#request.dsn#">
	UPDATE items
	SET status = 8<!--- DID NOT SELL --->
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">

	UPDATE ebitems
	SET hbuserid = NULL
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
	WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfif isDefined("attributes.dsp")>
	<cfset _machine.cflocation = "index.cfm?dsp=" & attributes.dsp>
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=management.reserve">
</cfif>
