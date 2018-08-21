

<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "management">
	<cfswitch expression="#_machine.dsp#">

		<!--- fedex page --->
		<cfcase value="fedex">
			<cfset attributes.pageTitle = "Fedex Shipping">
			<cfinclude template="dsp_fedex.cfm">
		</cfcase>
		
		<!---fedex form --->
		<cfcase value="FedexForm">
			<cfset attributes.pageTitle = "Fedex Form">
			<cfinclude template="dsp_fedexForm.cfm">
		</cfcase>
		<!---fedex multi form --->
		<cfcase value="FedexMulti" >
			<cfset attributes.pageTitle = "Fedex Multi">
			<cfinclude template="dsp_fedexMulti.cfm" >
		</cfcase>
		
		<cfcase value="fedexPrintLabel">
			<cfset _machine.layout = "no">
			<cfset attributes.pageTitle = "Fedex Print Label">
			<cfinclude template="dsp_fedexPrintLabel.cfm">
		</cfcase>
		
		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown display (#_machine.dsp#)">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfset _machine.module = ListFirst(_machine.dsp, ".")>
	<cfset _machine.dsp = ListRest(_machine.dsp, ".")>
	<cfinclude template="#_machine.module#\dsp_index.cfm">
</cfif>
