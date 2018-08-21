<cfif attributes.stype EQ 1>
	<cfparam name="attributes.StatusIs">
	<cfparam name="attributes.PaymentMethodUsed">
	<cfparam name="attributes.pos" default="0">
	<cfif attributes.pos NEQ 0>
		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET pos = 1
			WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
		</cfquery>
	</cfif>
	<cfquery name="sqlItems2Revise" datasource="#request.dsn#">
		SELECT i.item, i.ebayitem, MAX(t.TransactionID) AS TransactionID
		FROM items i
			LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
		WHERE i.item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
		GROUP BY i.item, i.ebayitem
	</cfquery>
	<cfloop query="sqlItems2Revise">
		<cfset attributes.itemid = sqlItems2Revise.item>
		<cfset attributes.ebayitem = sqlItems2Revise.ebayitem>
		<cfif sqlItems2Revise.TransactionID EQ "">
			<cfset attributes.TransactionID = 0>
		<cfelse>
			<cfset attributes.TransactionID = sqlItems2Revise.TransactionID>
		</cfif>
		<cfinclude template="act_revise_status.cfm">
	</cfloop>
<cfelse>
	<cfloop index="itemid" list="#attributes.items#">
		<cfset fChangeStatus (itemid, 9)><!--- RETURNED TO CLIENT --->
	</cfloop>
</cfif>

<cfif isDefined("attributes.dsp")>
	<cfset _machine.cflocation = "index.cfm?dsp=" & attributes.dsp>
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.pos.client_pickup">
</cfif>
