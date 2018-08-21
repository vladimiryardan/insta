<cfparam name="attributes.item" default="0">

<cfset LogAction("edited record for item #attributes.item#")>

<cftransaction>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET label_printed = 1
		WHERE item = '#attributes.item#'
	</cfquery>
</cftransaction>


<!---<cfset _machine.cflocation = "index.cfm?dsp=management.records&item=#attributes.item#">--->
<cfset _machine.cflocation = "index.cfm?dsp=management.items">

