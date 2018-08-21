
<cfif ListLen(_machine.act, ".") EQ 1>
	<cfswitch expression="#_machine.act#">
		<cfcase value="set_locations">
			<cfinclude template="act_set_locations.cfm">
		</cfcase>
		<cfcase value="set_locations2">
			<cfinclude template="act_set_locations2.cfm">
		</cfcase>		
		<cfcase value="create">
			<cfinclude template="act_create.cfm">
		</cfcase>
		<cfcase value="change_status">
			<cfif (attributes.newstatusid EQ 4) AND (attributes.ebayitem EQ "")>
				<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#&msg=2">
			<cfelse>
				<cfinclude template="act_change_status.cfm">
				<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">
			</cfif>
			<cfif isDefined("attributes.backdsp")>
				<cfset _machine.cflocation = "index.cfm?dsp=#attributes.backdsp#">
			</cfif>
		</cfcase>
		<cfcase value="mass_change_status">
			<cfinclude template="act_mass_change_status.cfm">
		</cfcase>
		<cfcase value="delete">
			<cfinclude template="act_delete.cfm">
		</cfcase>
		<cfcase value="relist_sold">
			<cfinclude template="act_relist_sold.cfm">
		</cfcase>
		<cfcase value="update">
			<cfinclude template="act_update.cfm">
		</cfcase>
		<cfcase value="edit">
			<cfinclude template="act_edit.cfm">
		</cfcase>
		<cfcase value="add_ebay">
			<cfinclude template="act_add_ebay.cfm">
		</cfcase>
		<cfcase value="delete_ebay">
			<cfinclude template="act_delete_ebay.cfm">
		</cfcase>
		<cfcase value="add_carrier">
			<cfinclude template="act_add_carrier.cfm">
		</cfcase>
		<cfcase value="delete_carrier">
			<cfinclude template="act_delete_carrier.cfm">
		</cfcase>
		<cfcase value="add_track">
			<cfinclude template="act_add_track.cfm">
		</cfcase>
		<cfcase value="delete_track">
			<cfinclude template="act_delete_track.cfm">
		</cfcase>
		<cfcase value="save_commission">
			<cfinclude template="act_save_commission.cfm">
		</cfcase>
		<cfcase value="delinvoice">
			<cfinclude template="act_delinvoice.cfm">
		</cfcase>
		<cfcase value="invoice">
			<cfinclude template="act_invoice.cfm">
		</cfcase>
		<cfcase value="recalculate_fees">
			<cfinclude template="act_recalculate_fees.cfm">
		</cfcase>
		<cfcase value="dns2rtc,dns2ntd" delimiters=",">
			<cfinclude template="act_dns2rtc.cfm">
		</cfcase>
		<cfcase value="itemis_template">
			<cfinclude template="act_itemis_template.cfm">
		</cfcase>
		<cfcase value="add_bonanzaBidder">
			<cfinclude template="act_add_bonanzaBidder.cfm">
		</cfcase>		
		<cfcase value="delete_bonanzaBidder">
			<cfinclude template="act_delete_bonanzaBidder.cfm">
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
