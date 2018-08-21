<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown action (#_machine.act#)">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfset _machine.module = ListFirst(_machine.act, ".")>
	<cfset _machine.act = ListRest(_machine.act, ".")>
	<cfinclude template="#_machine.module#\act_index.cfm">
</cfif>
