<!--- cfinclude template="dsp_menu_dynamic.cfm" --->
<cfif isDefined("attributes.dsp") AND NOT isDefined("attributes.act") AND NOT isGuest()>
	<cfinclude template="dsp_menu_2008.cfm">
	<!--- TOP LEVEL MENU --->
	<cfoutput><div align="center" id="noprint">
		<table style="border:1px solid ##AAAAAA;" cellspacing="0" cellpadding="0" width="100%">
		<tr bgcolor="white"><td>
			<table cellspacing="1" cellpadding="4" border="0">
			<tr><td>
				<strong>
				<cfset delim = "">
				<cfif isGroupMemberAllowed("Overview")>
					#delim#<a href="index.cfm?dsp=management.overview">Overview</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("EndOfDay_Chart")>
					#delim#<a href="index.cfm?dsp=admin.eod">EOD</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isGroupMemberAllowed("POS")>
					#delim#<a href="index.cfm?dsp=admin.pos.client_pickup">POS</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isGroupMemberAllowed("Items")>
					#delim#<a href="index.cfm?dsp=management.items">Manage Items</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isGroupMemberAllowed("Accounts") OR  isAllowed("Overview_StoreSales")>
					#delim#<a href="index.cfm?dsp=management.accounts">Manage Accounts</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isGroupMemberAllowed("Listings")>
					#delim#<a href="index.cfm?dsp=management.items.awaiting_listing">Listings</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isGroupMemberAllowed("Invoices")>
					#delim#<a href="index.cfm?dsp=management.needs_invoice">Invoices</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("System_Synchronize")>
					#delim#<a href="index.cfm?dsp=api.errors">Synch</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Other_RMA")>
					#delim#<a href="index.cfm?dsp=rma.list" style="color:red;">RMA</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("System_Settings")>
					#delim#<a href="index.cfm?dsp=admin.settings">Settings</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Full_Access")>
					#delim#<a href="index.cfm?dsp=admin.system.undelivered_mail">Mails</a>
					<cfset delim = "| ">
				</cfif>
				</strong>
			</td></tr>
	</cfoutput>
	<!--- SECOND LEVEL MENU --->
	<cfif (ListLen(attributes.dsp, ".") EQ 4) AND (attributes.dsp NEQ "admin.ship.usps.buy_postage")>
		<cfset expression = ListDeleteAt(attributes.dsp, 4, ".")>
	<cfelse>
		<cfset expression = attributes.dsp>
	</cfif>
	<cfswitch expression="#expression#">
		<!--- Overview --->
		<cfcase value="management.overview,admin.finance.overview,admin.finance.expenses,admin.finance.monex,admin.finance.monex_new,admin.finance.monex_edit,admin.finance.monetypes,admin.finance.copy,admin.finance.monetype_edit,admin.finance.monetype_new,admin.finance.details" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfset delim = "">
				<cfif isAllowed("Full_Access")>
					#delim#<a href="index.cfm?dsp=admin.finance.overview">Finance Management</a>
					<cfset delim = "| ">
					#delim#<a href="index.cfm?dsp=admin.finance.monex">Expenses</a>
					<cfset delim = "| ">
					#delim#<a href="index.cfm?dsp=admin.finance.monetypes">Expense Types</a>
					<cfset delim = "| ">
					#delim#<a href="index.cfm?dsp=admin.finance.expenses">Client Charges</a>
					<cfset delim = "| ">
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- EOD --->
		<cfcase value="admin.eod,admin.store_daily_report,admin.listing_daily_report,admin.processing_daily_report,admin.picturing_daily_report,admin.packing_daily_report,admin.ship.daily_report" delimiters=",">
			<cfoutput>
			<tr><td>
				<table align="center" cellpadding="0" cellspacing="0">
				<tr><td align="right">
					<strong>
					<hr>
					EOD Today:
					<a target="_blank" href="index.cfm?dsp=admin.store_daily_report&repday=#DateFormat(Now())#">Store</a> |
					<a target="_blank" href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(Now())#">Processing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(Now())#">Picturing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(Now())#">Listing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(Now())#">Packing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#">Shipping</a> |
					<a target="_blank" href="index.cfm?dsp=admin.saling_daily_report&repday=#DateFormat(Now())#">Sales</a>
					<br><br>
					EOD Yesterday:
					<a target="_blank" href="index.cfm?dsp=admin.store_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Store</a> |
					<a target="_blank" href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Processing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Picturing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Listing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Packing</a> |
					<a target="_blank" href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Shipping</a> |
					<a target="_blank" href="index.cfm?dsp=admin.saling_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Sales</a>
					</strong>
				</td></tr>
				</table>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- POS --->
		<cfcase value="admin.pos.client_pickup,admin.pos.checkout,admin.pos.ship_package,admin.pos.retail,admin.pos.run_credit_card" delimiters=",">
			<cfoutput>
				<tr><td>
					<strong>
					<cfset delim = "">
					<cfif isAllowed("POS_ClientPickup")>
						<a href="index.cfm?dsp=admin.pos.client_pickup">Client Pickup</a> |
						<cfset delim = "| ">
					</cfif>
					<cfif isAllowed("POS_ShipPackage")>
						<a href="index.cfm?dsp=admin.pos.ship_package">Ship Package</a> |
						<cfset delim = "| ">
					</cfif>
					<cfif isAllowed("POS_Retail")>
						<a href="index.cfm?dsp=admin.pos.retail">Retail</a> |
						<cfset delim = "| ">
					</cfif>
					<cfif isAllowed("POS_RunCreditCard")>
						<a href="index.cfm?dsp=admin.pos.run_credit_card">Run Credit Card</a>
						<cfset delim = "| ">
					</cfif>
					</strong>
				</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Manage Items --->
		<cfcase value="management.items,management.items.create,management.items.awaiting_items,management.items.location,admin.auctions.upload_pictures,admin.auctions.manage_images,management.calc" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<a href="index.cfm?dsp=management.items">View Items</a>
				<cfif isAllowed("Items_CreateNew")>
					| <a href="index.cfm?dsp=management.items.create">Create New Item</a>
				</cfif>
				<cfif isAllowed("Items_NeverReceived")>
					| <a href="index.cfm?dsp=management.items.awaiting_items">Never Received</a>
				</cfif>
				<cfif isAllowed("Items_ItemLocation")>
					| <a href="index.cfm?dsp=management.items.location">Item Location</a>
				</cfif>
				<cfif isAllowed("Items_CheckCalculator")>
					| <a href="index.cfm?dsp=management.calc">Check Calculator</a>
				</cfif>
				<cfif isAllowed("Items_UploadPictures")>
					| <a href="index.cfm?dsp=admin.auctions.upload_pictures">Upload Pictures</a>
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Manage Accounts --->
		<cfcase value="management.accounts,account.new,account.edit,admin.overview.sales,admin.overview.accounts,management.items.list" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
					<a href="index.cfm?dsp=management.accounts">View Accounts</a>
					| <a href="index.cfm?dsp=account.new">Create New Account</a>
				<cfif isAllowed("Accounts_SalesManagement")>
					| <a href="index.cfm?dsp=admin.overview.sales">Sales Management</a>
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>

		<!--- Listings --->
		<cfcase value="account.overview,management.items.active,api.responses.list,api.mymessages.list,api.mymessages.inbox,api.mymessages.inbox4alert,api.mymessages.reply,api.mymessages.reply4alert,api.messages.list,api.messages.inbox,api.messages.reply,management.items.sold,management.apayment,management.reserve,admin.ship.gl,management.wait_payment,admin.ship.awaiting,admin.ship.ship_sold_off,admin.ship.combined,admin.ship.international,admin.ship.refund,admin.ship.urgent,management.paid_shipped,management.need_relist,management.need_return,management.items.ir_errors,management.errors.bad_location,management.errors.badly_listed,management.need_call,management.claims_list,management.need_relot,management.relotted,management.donated2charity,management.items.awaiting_listing,admin.auctions.step1,admin.auctions.item_specific,admin.auctions.step2,admin.auctions.step3,admin.auctions.list2sandbox,admin.auctions.launch,management.items.ready2launch,management.items.scheduled,admin.ship.usps.buy_postage,admin.pos.ups_list,api.mymessages.sent,api.mymessages.sent_reply,api.mymessages.sent_list,api.mymessages.send_invoice,api.disputes.list,api.disputes.inbox,api.disputes.reply,admin.ship.awaitingShipFixedItemsOnly,admin.ship.awaitingFixedPriceV2,amazon_live.amazon_unshipped" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfset delim = "">
				<cfif isAllowed("Lister_ListAuction") OR isAllowed("Lister_CreateAuction") OR isAllowed("Lister_EditAuction")>
					#delim#<a href="index.cfm?dsp=management.items.awaiting_listing" style="color:red;" title="Awaiting Listing">AL</a>
					| <a href="index.cfm?dsp=management.items.multiple">Multiple</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ListAuction")>
					#delim#<a href="index.cfm?dsp=management.items.ready2launch">Launch</a>
					| <a href="index.cfm?dsp=management.items.scheduled">Scheduled</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ActiveListings")>
					#delim#<a href="index.cfm?dsp=management.items.active">Active</a>
					<cfset delim = "| ">
				</cfif>
				<!--- 20101230 remove questions and replace with Inventory Management
				<cfif isAllowed("Other_EbayQuestions")>
					#delim#<a href="index.cfm?dsp=api.messages.list" style="color:blue;">Questions</a>
					<cfset delim = "| ">
				</cfif>
				--->
				<cfif isAllowed("Lister_ActiveListings")>
					#delim#<a href="index.cfm?dsp=management.items.dsp_inventoryManagement" style="color:blue;">Inv</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ActiveListings")>
					#delim#<a href="index.cfm?dsp=management.items.dsp_inventoryManagement2" style="color:blue;">Inv 2</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Other_MyMessages")>
					#delim#<a href="index.cfm?dsp=api.mymessages.list" style="color:green;">My Messages</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Other_Disputes")>
					#delim#<a href="index.cfm?dsp=api.disputes.list" style="color:red;">Disputes</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_SoldListings")>
					#delim#<a href="index.cfm?dsp=management.items.sold">Shipping</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_UnsoldListings")>
					#delim#<a href="index.cfm?dsp=management.need_return">Unsold</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ListAuction") OR isAllowed("Items_ItemLocation")>
					#delim#<a href="index.cfm?dsp=management.items.ir_errors">Errors</a>
					<cfset delim = "| ">
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>

		<!--- Invoices --->
		<cfcase value="management.needs_invoice,management.invoices" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfset delim = "">
				<cfif isAllowed("Invoices_Awaiting")>
					#delim#<a href="index.cfm?dsp=management.needs_invoice">Need to be Invoiced</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Invoices_View")>
					#delim#<a href="index.cfm?dsp=management.invoices">View Invoices</a>
					<cfset delim = "| ">
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>

		<!--- Synchronize --->
		<cfcase value="api.errors,api.errors1,api.errors2,api.errors3,api.errors4,api.errors5,api.downloads,api.get_changes,api.run_synch,api.call_stat" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
					<a href="index.cfm?dsp=api.errors">Synch Errors</a> |
					<a href="index.cfm?dsp=api.downloads">Get eBay Data</a> |
					<a href="index.cfm?dsp=api.get_changes">Retrieve Changes</a> |
					<a href="index.cfm?dsp=api.run_synch">Apply Changes</a> |
					<a href="index.cfm?dsp=api.call_stat">API Call Status</a>
					<li><a href="index.cfm?dsp=admin.api.st_getEbayQuantity">Run Get Qty (Warning!)</a></li>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- RMA --->
		<cfcase value="rma.list,rma.add_return,rma.add_refund,rma.saved,rma.settings.list,rma.settings.edit,rma.mails.list,rma.mails.edit" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
					<a href="index.cfm?dsp=rma.list&type=1">Return Items</a> |
					<a href="index.cfm?dsp=rma.list&type=2">Replacement Items</a> |
					<a href="index.cfm?dsp=rma.settings.list">RMA Settings</a> |
					<a href="index.cfm?dsp=rma.mails.list">RMA Mails</a>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Settings --->
		<cfcase value="admin.ebay.list,admin.settings,admin.api.schedule,admin.roles,admin.edit_role,admin.logs" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfif isAllowed("Full_Access")>
					<a href="index.cfm?dsp=admin.ebay.list" style="color:red;">eBay Accounts</a> |
				</cfif>
					<a href="index.cfm?dsp=admin.settings">Edit Settings</a> |
					<a href="index.cfm?dsp=admin.api.schedule">Schedule</a> |
				<cfif isAllowed("System_ManageRoles")>
					<a href="index.cfm?dsp=admin.roles">Roles</a> |
				</cfif>
				<cfif isAllowed("System_TroubleTickets")>
					<a href="tickets" target="_blank">Trouble Tickets</a> |
				</cfif>
				<cfif isAllowed("Items_ViewItemLogs")>
					<a href="index.cfm?dsp=admin.logs">View Logs</a> |
				</cfif>
					<a href="index.cfm?dsp=admin.settings&RefreshAppVars=true">Refresh Settings</a>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
	</cfswitch>
	<!--- THIRD LEVEL MENU --->
	<cfswitch expression="#attributes.dsp#">
		<!--- Listings => Sold --->
		<cfcase value="management.items.sold,admin.ship.gl,management.wait_payment,admin.ship.awaiting,admin.ship.ship_sold_off,admin.ship.combined,admin.ship.international,admin.ship.urgent,admin.ship.refund,management.paid_shipped,admin.ship.usps.buy_postage,admin.pos.ups_list,admin.ship.awaitingShipFixedItemsOnly,admin.ship.awaitingFixedPriceV2,amazon_live.amazon_unshipped" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
					<a href="index.cfm?dsp=management.wait_payment">AP</a> |
					<a href="index.cfm?dsp=admin.ship.gl">GL</a> |
					<a href="index.cfm?dsp=admin.ship.awaiting">Awaiting Ship</a> |
					<a href="index.cfm?dsp=admin.ship.ship_sold_off">Off eBay</a> |
					<a href="index.cfm?dsp=admin.ship.combined">Combined</a> |
					<a href="index.cfm?dsp=admin.ship.international">Inter</a> |
				<cfif isAllowed("Lister_MarkRefundItems")>
					<a href="index.cfm?dsp=admin.ship.urgent">Urgent</a> |
					<!---<a href="index.cfm?dsp=admin.ship.refund">Refund Items</a> |--->
					<a href="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">Fixed Awaiting Ship</a> |
				</cfif>
					<a href="index.cfm?dsp=management.paid_shipped">P &amp; S</a>
				<cfif isAllowed("Listings_BuyPostage")>
					| <a href="index.cfm?dsp=admin.ship.usps.buy_postage">Postage</a>
				</cfif>
				<cfif isAllowed("POS_ShipPackage")>
					| <a href="index.cfm?dsp=admin.pos.ups_list">UPS Labels</a>
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Listings => Unsold --->
		<cfcase value="management.apayment,management.need_relist,management.need_return,management.need_call,management.reserve,management.claims_list,management.need_relot,management.reloted,management.relotted,management.donated2charity" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfset delim = "">
					<a href="index.cfm?dsp=management.apayment">AP 25+</a>
					<cfset delim = "| ">
				<cfif isAllowed("Lister_ReserveNotMet")>
					#delim#<a href="index.cfm?dsp=management.reserve">Reserve Not Met</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_NeedToReturn")>
					#delim#<a href="index.cfm?dsp=management.need_return">Need to Return</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_NeedToCall")>
					#delim#<a href="index.cfm?dsp=management.need_call">Need to Call</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ClaimsList")>
					#delim#<a href="index.cfm?dsp=management.claims_list">Claims List</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_NeedToRelot")>
					#delim#<a href="index.cfm?dsp=management.need_relot">Need to Relot</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_Relotted")>
					#delim#<a href="index.cfm?dsp=management.relotted">IA Relot</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_DTC")>
					#delim#<a href="index.cfm?dsp=management.items.craiglist">Craiglist</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_DTC")>
					#delim#<a href="index.cfm?dsp=management.items.bonanza">Bonanza</a>
					<cfset delim = "| ">
				</cfif>				
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Errors --->
		<cfcase value="management.items.ir_errors,management.errors.bad_location,management.errors.badly_listed" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<cfset delim = "">
				<cfif isAllowed("Lister_ListAuction")>
					#delim#<a href="index.cfm?dsp=management.items.ir_errors">Item Recieved Errors</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Items_ItemLocation")>
					#delim#<a href="index.cfm?dsp=management.errors.bad_location">Incorrect Locations</a>
					<cfset delim = "| ">
				</cfif>
				<cfif isAllowed("Lister_ListAuction")>
					#delim#<a href="index.cfm?dsp=management.errors.badly_listed">Badly Listed</a>
					<cfset delim = "| ">
				</cfif>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- Synchronize => Synch Errors --->
		<cfcase value="api.errors,api.errors1,api.errors2,api.errors3,api.errors4,api.errors5" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
					<a href="index.cfm?dsp=api.errors1">Non-Existent</a> |
					<a href="index.cfm?dsp=api.errors2">Double-Listed</a> |
					<a href="index.cfm?dsp=api.errors3">Overwrite Conflicts</a> |
					<a href="index.cfm?dsp=api.errors4">Could Not Parse</a> |
					<a style="color:red;" href="index.cfm?dsp=api.errors5">Second Chance</a>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>

		<!--- My Messages => Sent Messages --->
		<cfcase value="api.mymessages.list,api.mymessages.inbox,api.mymessages.inbox4alert,api.mymessages.reply,api.mymessages.reply4alert,api.messages.list,api.messages.inbox,api.messages.reply,api.mymessages.sent,api.mymessages.sent_reply,api.mymessages.sent_list,api.mymessages.send_invoice" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<a href="index.cfm?dsp=api.mymessages.sent_list">Sent messages</a>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
		<!--- My Messages => Sent Messages --->
		<cfcase value="api.disputes.list,api.disputes.inbox,api.disputes.reply,api.disputes.add_step1,api.disputes.add_step2,api.disputes.add_step3" delimiters=",">
			<cfoutput>
			<tr><td>
				<strong>
				<a href="index.cfm?dsp=api.disputes.add_step1">Add Unpaid dispute</a>
				</strong>
			</td></tr>
			</cfoutput>
		</cfcase>
	</cfswitch>
	<cfoutput>
			</table>
		</td></tr>
		</table>
	</div><br></cfoutput>
	<cfif isDefined("_machine.menuTitle") AND (_machine.menuTitle NEQ "My Account")>
		<cfset bool = StructDelete(_machine, "menu")>
	</cfif>
</cfif>
