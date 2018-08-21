<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "management">
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="subDescriptionsList">
			<cfset attributes.pageTitle = "Sub Description List">
			<cfinclude template="dsp_subDescriptionList.cfm">
		</cfcase>
		
		<cfcase value="new_subDescription">
			<cfset attributes.pageTitle = "Sub Description Detail">
			<cfinclude template="dsp_new_subDescription.cfm">
		</cfcase>
		
		<cfcase value="edit_subDescription">
			<cfset attributes.pageTitle = "Dimension Detail">
			<cfinclude template="dsp_edit_subDescription.cfm">
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
