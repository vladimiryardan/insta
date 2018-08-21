<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="bad_location">
			<cfinclude template="dsp_bad_location.cfm">
		</cfcase>
		<cfcase value="badly_listed">
			<cfinclude template="dsp_badly_listed.cfm">
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
