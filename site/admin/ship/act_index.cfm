<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfcase value="updatesetting">
			<cfinclude template="act_updatesetting.cfm">
			<cfset _machine.cflocation = "index.cfm?dsp=admin.settings">
		</cfcase>
		<cfcase value="setnote">
			<cfinclude template="act_setnote.cfm">
			<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.note&close=1">
		</cfcase>
		<cfcase value="set_rpr">
			<cfinclude template="act_set_rpr.cfm">
			<cfset _machine.cflocation = "index.cfm?dsp=#attributes.dsp#">
		</cfcase>
		<cfcase value="generate_label">
			<cfinclude template="act_generate_label.cfm">
		</cfcase>
		<cfcase value="generate_multilabel">
			<cfinclude template="act_generate_multilabel.cfm">
		</cfcase>
		<cfcase value="move2local">
			<cfinclude template="act_move2local.cfm">
		</cfcase>
		<cfcase value="move2nonlocal">
			<cfinclude template="act_move2nonlocal.cfm">
		</cfcase>
		<cfcase value="update_itemid">
			<cfinclude template="act_update_itemid.cfm">
		</cfcase>
		<cfcase value="update_itemidMulti">
			<cfinclude template="act_update_itemidMulti.cfm">
		</cfcase>
		<cfcase value="update_itemidMultiV2">
			<cfinclude template="act_update_itemidMultiV2.cfm">
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
