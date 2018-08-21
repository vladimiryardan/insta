
<cfif NOT isAllowed("Items_ChangeStatus") AND NOT isAllowed("Items_NormalChangeStatus")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>






<cfloop index="i" from="1" to="#attributes.num#">
	<cfif isDefined("attributes.cs#i#")>
		<cfset attributes.item = attributes["item#i#"]>
		<cfset attributes.ebayitem = attributes["ebayitem#i#"]>
		<cfset attributes.newstatusid = attributes["newstatusid#i#"]>
		<cfif (attributes.newstatusid NEQ 4) OR (attributes.ebayitem NEQ "")>
			<cfinclude template="act_change_status.cfm">
		</cfif>

		<!--- changing lid --->
		<cfinclude template="act_mass_change_lid.cfm" >
	</cfif>
</cfloop>
<cfparam name="attributes.srch" default="" >
<cfset _machine.cflocation = "index.cfm?dsp=management.items&srch=#attributes.srch#">
