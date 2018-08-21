

<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "management">
	<cfswitch expression="#_machine.dsp#">

		<!--- waltermart page --->
		<cfcase value="walMart">
			<cfset attributes.pageTitle = "walmart">
			<cfinclude template="dsp_walMart.cfm">
		</cfcase>
		
			<!---fedex form --->
	
		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown display (#_machine.dsp#)">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfset _machine.module = ListFirst(_machine.dsp, ".")>
	<cfset _machine.dsp = ListRest(_machine.dsp, ".")>
	<cfinclude template="#_machine.module#\dsp_index.cfm">
</cfif>
