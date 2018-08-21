<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfcase value="set_rpr">
			<cfinclude template="act_set_rpr.cfm">
		</cfcase>
		<cfcase value="buy_postage">
			<cfinclude template="act_buy_postage.cfm">
		</cfcase>
		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown action (#_machine.act#)">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfset _machine.module = ListFirst(_machine.act, ".")>
	<cfset _machine.act = ListRest(_machine.act, ".")>
	<cfinclude template="#_machine.module#\act_index.cfm">
</cfif>
