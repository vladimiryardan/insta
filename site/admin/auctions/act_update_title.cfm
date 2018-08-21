<cfif isDefined("attributes.dsp")>
	<cfset _machine.cflocation = "index.cfm?dsp=#attributes.dsp#">
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=management.items.ready2launch">
</cfif>

<cfquery datasource="#request.dsn#">
	UPDATE auctions
	SET
	<cfif isDefined("attributes.title")>
		Title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.title#">,
	</cfif>
	<cfif isDefined("attributes.subtitle")>
		SubTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subtitle#" maxlength="55">,
	</cfif>
	<cfif isDefined("attributes.startingprice")>
		StartingPrice = <cfqueryparam cfsqltype="cf_sql_real" value="#attributes.startingprice#">,
	</cfif>
		scheduledBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(session.user.first, 1)##Left(session.user.last, 1)#">
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
