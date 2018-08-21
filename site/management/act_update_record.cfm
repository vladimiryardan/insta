<cfparam name="attributes.checksent" default="0">

<cfset LogAction("edited record for item #attributes.item#")>

<cftransaction>
	<cfquery datasource="#request.dsn#">
		UPDATE records
		SET ExtraFees = <cfif isDefined("attributes.ExtraFees") AND isNumeric(attributes.ExtraFees)>'#attributes.ExtraFees#'<cfelse>NULL</cfif>
		WHERE itemid = '#attributes.item#'
	</cfquery>
</cftransaction>

<cfinclude template="items\act_recalculate_fees.cfm">

<cfset _machine.cflocation = "index.cfm?dsp=management.records&item=#attributes.item#">
