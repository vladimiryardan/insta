<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "management">
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="dimensionList">
			<cfset attributes.pageTitle = "Shipping Dimension List">
			<cfinclude template="dsp_dimensionList.cfm">
		</cfcase>
		
		<cfcase value="new_dimension">
			<cfset attributes.pageTitle = "Dimension Detail">
			<cfinclude template="dsp_new_dimension.cfm">
		</cfcase>
		
		<cfcase value="edit_dimension">
			<cfset attributes.pageTitle = "Dimension Detail">
			<cfinclude template="dsp_edit_dimension.cfm">
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
