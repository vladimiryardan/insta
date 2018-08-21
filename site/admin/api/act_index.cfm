<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfcase value="complete_sale">
			<cfinclude template="act_complete_sale.cfm">
		</cfcase>
		<cfcase value="complete_sale_multilabel">
			<cfinclude template="act_complete_sale_multilabel.cfm">
		</cfcase>
		<cfcase value="revise_status">
			<cfinclude template="act_revise_status.cfm">
		</cfcase>
		<cfcase value="schedule">
			<cfinclude template="act_schedule.cfm">
		</cfcase>
		<cfcase value="checkout">
			<cfinclude template="act_checkout.cfm">
		</cfcase>
		<cfcase value="second_chance">
			<cfinclude template="act_second_chance.cfm">
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
