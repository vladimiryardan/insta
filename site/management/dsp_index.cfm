<cfset _machine.menuName = "management">
<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="overview">
			<cfinclude template="dsp_overview.cfm">
		</cfcase>
		<cfcase value="massemail">
			<cfinclude template="dsp_massemail.cfm">
		</cfcase>
		<cfcase value="taemail">
			<cfinclude template="dsp_taemail.cfm">
		</cfcase>
		<cfcase value="returnemail">
			<cfinclude template="dsp_returnemail.cfm">
		</cfcase>
		<cfcase value="items">
			<cfinclude template="dsp_items.cfm">
		</cfcase>
		<cfcase value="accounts">
			<cfinclude template="dsp_accounts.cfm">
		</cfcase>
		<cfcase value="invoices">
			<cfinclude template="dsp_invoices.cfm">
		</cfcase>
		<cfcase value="needs_invoice">
			<cfinclude template="dsp_needs_invoice.cfm">
		</cfcase>
		<cfcase value="records">
			<cfinclude template="dsp_records.cfm">
		</cfcase>
		<cfcase value="wait_payment">
			<cfinclude template="dsp_wait_payment.cfm">
		</cfcase>
		<cfcase value="paid_shipped">
			<cfinclude template="dsp_paid_shipped.cfm">
		</cfcase>
		<cfcase value="paid_shipped_fixed">
			<cfinclude template="dsp_paid_shipped_fixed.cfm">
		</cfcase>
		<cfcase value="reserve">
			<cfinclude template="dsp_need_relist.cfm">
		</cfcase>
		<cfcase value="apayment">
			<cfinclude template="dsp_need_relist.cfm">
		</cfcase>

		
		
		<cfcase value="need_return">
			<cfinclude template="dsp_need_return.cfm">
		</cfcase>
		<cfcase value="need_call">
			<cfinclude template="dsp_need_call.cfm">
		</cfcase>
		<cfcase value="claims_list">
			<cfinclude template="dsp_claims_list.cfm">
		</cfcase>
		<cfcase value="need_relot">
			<cfinclude template="dsp_need_relot.cfm">
		</cfcase>
		<cfcase value="relotted">
			<cfinclude template="dsp_relotted.cfm">
		</cfcase>
		<cfcase value="donated2charity">
			<cfinclude template="dsp_donated2charity.cfm">
		</cfcase>
	
		<cfcase value="calc">
			<cfinclude template="dsp_calc.cfm">
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
