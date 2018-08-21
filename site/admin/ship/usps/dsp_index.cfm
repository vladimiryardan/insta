<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="request_label">
			<cfset request.show_form = TRUE>
			<cfinclude template="get_request_label.cfm">
			<cfif request.show_form>
				<cfinclude template="dsp_request_label.cfm">
			</cfif>
		</cfcase>
		<cfcase value="request_multilabel">
			<cfset request.show_form = TRUE>
			<cfinclude template="get_request_multilabel.cfm">
			<cfif request.show_form>
				<cfinclude template="dsp_request_multilabel.cfm">
			</cfif>
		</cfcase>
		<cfcase value="print_label">
			<cfset _machine.layout = "no">
			<cfinclude template="dsp_print_label.cfm">
		</cfcase>
		<cfcase value="buy_postage">
			<cfinclude template="dsp_buy_postage.cfm">
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
