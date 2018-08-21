<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="client_pickup">
			<cfinclude template="dsp_client_pickup.cfm">
		</cfcase>
		<cfcase value="ship_package">
			<cfinclude template="dsp_ship_package.cfm">
		</cfcase>
		<cfcase value="ups_print">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_ups_print.cfm">
		</cfcase>
		<cfcase value="ups_list">
			<cfinclude template="dsp_ups_list.cfm">
		</cfcase>
		<cfcase value="ups_invoice">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_ups_invoice.cfm">
		</cfcase>
		<cfcase value="retail">
			<cfinclude template="dsp_retail.cfm">
		</cfcase>
		<cfcase value="run_credit_card">
			<cfinclude template="dsp_run_credit_card.cfm">
		</cfcase>
		<cfcase value="checkout">
			<cfinclude template="dsp_checkout.cfm">
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
