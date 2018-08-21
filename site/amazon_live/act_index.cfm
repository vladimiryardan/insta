<cfif ListLen(_machine.act, ".") EQ 1>
<cfswitch expression="#_machine.act#">
		<cfcase value="act_update_itemid">
			<cfinclude template="act_update_itemid.cfm">
		</cfcase>
		<cfcase value="act_update_itemidMulti">
			<cfinclude template="act_update_itemidMulti.cfm">
		</cfcase>
		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown action (#_machine.act#)">
		</cfdefaultcase>
</cfswitch>
</cfif>