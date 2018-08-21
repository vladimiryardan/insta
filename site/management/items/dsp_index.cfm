<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="ir_errors">
			<cfinclude template="dsp_ir_errors.cfm">
		</cfcase>
		<cfcase value="invalid">
			<cfinclude template="dsp_invalid.cfm">
		</cfcase>
		<cfcase value="multiple">
			<cfinclude template="dsp_multiple.cfm">
		</cfcase>
		<cfcase value="active">
			<cfinclude template="dsp_active.cfm">
		</cfcase>
		<cfcase value="active_fixed">
			<cfinclude template="dsp_active_fixed.cfm">
		</cfcase>
		<cfcase value="activetry">
			<cfinclude template="dsp_activetry.cfm">
		</cfcase>
		<cfcase value="awaiting_listing">
			<cfinclude template="dsp_awaiting_listing.cfm">
		</cfcase>
		<cfcase value="awaiting_auction">
			<cfinclude template="dsp_awaiting_auction.cfm">
		</cfcase>
		<cfcase value="ready2launch">
			<cfinclude template="dsp_ready2launch.cfm">
		</cfcase>
		<cfcase value="scheduled">
			<cfinclude template="dsp_scheduled.cfm">
		</cfcase>
		<cfcase value="awaiting_items">
			<cfinclude template="dsp_awaiting_items.cfm">
		</cfcase>
		<cfcase value="sold">
			<cfinclude template="dsp_sold.cfm">
		</cfcase>
		<cfcase value="edit">
			<cfinclude template="dsp_edit.cfm">
		</cfcase>
		<cfcase value="salesedit">
			<cfinclude template="dsp_salesedit.cfm">
		</cfcase>
		<cfcase value="status_history">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_status_history.cfm">
		</cfcase>
		<cfcase value="location_history">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_location_history.cfm">
		</cfcase>
		<cfcase value="copy">
			<cfinclude template="get_copy.cfm">
			<cfinclude template="dsp_create.cfm">
		</cfcase>
		<cfcase value="create">
			<cfinclude template="dsp_create.cfm">
		</cfcase>
		<cfcase value="location">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_location.cfm">
		</cfcase>
		<cfcase value="location2">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_location2.cfm">
		</cfcase>		
		<cfcase value="locationlisterrors">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_locationlisterrors.cfm">
		</cfcase>
		<cfcase value="locationlist">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_locationlist.cfm">
		</cfcase>
		<cfcase value="list">
			<cfinclude template="dsp_list2.cfm">
		</cfcase>
		<cfcase value="packinglist">
			<cfset _machine.layout = "packing">
			<cfinclude template="dsp_packinglist.cfm">
		</cfcase>
		<cfcase value="itemslip">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_itemslip.cfm">
		</cfcase>
		<cfcase value="customerslip">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_customerslip.cfm">
		</cfcase>
		<cfcase value="detail">
			<cfset _machine.menuname = "account">
			<cfinclude template="dsp_detail.cfm">
		</cfcase>
		<cfcase value="dsp_inventoryManagement">
			<cfinclude template="dsp_inventoryManagement.cfm">
		</cfcase>
		<cfcase value="dsp_inventoryManagement2">
			<cfinclude template="dsp_inventoryManagement2.cfm">
		</cfcase>
		<cfcase value="dsp_inventorySkuCondition">
			<cfinclude template="dsp_inventorySkuCondition.cfm">
		</cfcase>
		<cfcase value="active_fixedList">
			<cfinclude template="dsp_active_fixedList.cfm">
		</cfcase>
		<cfcase value="active_fixedInventoryList">
			<cfinclude template="dsp_active_fixedInventoryList.cfm">
		</cfcase>
		<cfcase value="craiglist">
			<cfinclude template="dsp_craiglist.cfm">
		</cfcase>
		<cfcase value="templateList">
			<cfinclude template="dsp_templateList.cfm">
		</cfcase>
		<cfcase value="itemsSku2">
			<cfinclude template="dsp_itemsSku2.cfm">
		</cfcase>
		<cfcase value="Bonanza">
			<cfinclude template="dsp_Bonanza.cfm">
		</cfcase>
		<cfcase value="confirmDuplicateItems">
			<cfinclude template="dsp_confirmDuplicateItems.cfm">
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
