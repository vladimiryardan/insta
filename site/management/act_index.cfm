<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfcase value="update_record">
			<cfinclude template="act_update_record.cfm">
		</cfcase>
		<cfcase value="ntc">
			<cfinclude template="act_ntc.cfm">
		</cfcase>
		<cfcase value="rtc">
			<cfinclude template="act_rtc.cfm">
		</cfcase>
		<cfcase value="called">
			<cfinclude template="act_called.cfm">
		</cfcase>
		<cfcase value="just_called">
			<cfinclude template="act_just_called.cfm">
		</cfcase>
		<cfcase value="just_return">
			<cfinclude template="act_just_return.cfm">
		</cfcase>
		<cfcase value="massemail">
			<cfinclude template="act_massemail.cfm">
		</cfcase>
		<cfcase value="taemail">
			<cfinclude template="act_taemail.cfm">
		</cfcase>
		<cfcase value="returnemail">
			<cfinclude template="act_returnemail.cfm">
		</cfcase>
		<cfcase value="update_printlabel">
			<cfinclude template="act_update_printlabel.cfm">
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
