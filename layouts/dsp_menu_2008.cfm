<cfoutput>
<ul id="navmenu">
	<cfif isGroupMemberAllowed("Overview")>
		<li><a href="index.cfm?dsp=management.overview">Overview</a>
			<cfif isAllowed("Full_Access")>
				<ul>
					<li><a href="index.cfm?dsp=admin.finance.overview">Finance Management</a></li>
					<li><a href="index.cfm?dsp=admin.finance.monex">Expenses</a></li>
					<li><a href="index.cfm?dsp=admin.finance.monetypes">Expense Types</a></li>
					<li><a href="index.cfm?dsp=admin.finance.expenses">Client Charges</a></li>
				</ul>
			</cfif>
		</li>
	</cfif>
	<cfif isAllowed("EndOfDay_Chart")>
		<li><a href="index.cfm?dsp=admin.eod">EOD</a>
			<ul>
				<li><a href="JavaScript:void(0);">EOD Today #RepeatString("&nbsp;", 16)#&raquo;</a>
					<ul>
						<li><a target="_blank" href="index.cfm?dsp=admin.store_daily_report&repday=#DateFormat(Now())#">Store</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(Now())#">Processing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(Now())#">Picturing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(Now())#">Listing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(Now())#">Packing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#">Shipping</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.saling_daily_report&repday=#DateFormat(Now())#">Sales</a></li>
					</ul>
				</li>
				<li><a href="JavaScript:void(0);">EOD Yesterday #RepeatString("&nbsp;", 8)#&raquo;</a>
					<ul>
						<li><a target="_blank" href="index.cfm?dsp=admin.store_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Store</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Processing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Picturing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Listing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Packing</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Shipping</a></li>
						<li><a target="_blank" href="index.cfm?dsp=admin.saling_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#">Sales</a></li>
					</ul>
				</li>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("POS")>
		<li><a href="JavaScript:void(0);">POS</a>
			<ul>
				<cfif isAllowed("POS_ClientPickup")>
					<li><a href="index.cfm?dsp=admin.pos.client_pickup">Client Pickup</a></li>
				</cfif>
				<cfif isAllowed("POS_ShipPackage")>
					<li><a href="index.cfm?dsp=admin.pos.ship_package">Ship Package</a></li>
				</cfif>
				<cfif isAllowed("POS_Retail")>
					<li><a href="index.cfm?dsp=admin.pos.retail">Retail</a></li>
				</cfif>
				<cfif isAllowed("POS_RunCreditCard")>
					<li><a href="index.cfm?dsp=admin.pos.run_credit_card">Run Credit Card</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Items")>
		<li><a href="index.cfm?dsp=management.items">Manage Items</a>
			<ul>
				<cfif isAllowed("Items_CreateNew")>
					<li><a href="index.cfm?dsp=management.items.create">Create New Item</a></li>
				</cfif>
				<cfif isAllowed("Items_NeverReceived")>
					<li><a href="index.cfm?dsp=management.items.awaiting_items">Never Received</a></li>
				</cfif>
				<cfif isAllowed("Items_ItemLocation")>
					<li><a href="index.cfm?dsp=management.items.location">Item Location</a></li>
				</cfif>
				<cfif isAllowed("Items_CheckCalculator")>
					<li><a href="index.cfm?dsp=management.calc">Check Calculator</a></li>
				</cfif>
				<cfif isAllowed("Items_UploadPictures")>
					<li><a href="index.cfm?dsp=admin.auctions.upload_pictures">Upload Pictures</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Accounts") OR  isAllowed("Overview_StoreSales")>
		<li><a href="index.cfm?dsp=management.accounts">Accounts</a>
			<ul>
				<li><a href="index.cfm?dsp=account.new">Create New Account</a></li>
				<cfif isAllowed("Accounts_SalesManagement")>
					<li><a href="index.cfm?dsp=admin.overview.sales">Sales Management</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Listings")>
		<li><a href="JavaScript:void(0);">Listings</a>
			<ul>
				<cfif isAllowed("Lister_ListAuction") OR isAllowed("Lister_CreateAuction") OR isAllowed("Lister_EditAuction")>
					<li><a href="index.cfm?dsp=management.items.awaiting_listing">Awaiting Listing</a></li>
					<li><a href="index.cfm?dsp=management.items.awaiting_auction">Awaiting Auction</a></li>
					<!---<li><a href="index.cfm?dsp=management.items.multiple">Multiple</a></li>--->
				</cfif>
				<cfif isAllowed("Lister_ListAuction")>
					<li><a href="index.cfm?dsp=management.items.ready2launch">Awaiting Launch</a></li>
					<li><a href="index.cfm?dsp=management.items.scheduled">Scheduled</a></li>
					<!---<li><a href="index.cfm?dsp=management.items.dsp_inventoryManagement">Inventory Management</a></li>--->
					<!---<li><a href="index.cfm?dsp=management.items.dsp_inventoryManagement2">Inventory Management 2</a></li>--->
				</cfif>
				<cfif isAllowed("Lister_ActiveListings")>
					<li><a href="index.cfm?dsp=management.items.active">Active</a></li>
				</cfif>
				<cfif isAllowed("Lister_ActiveListings")>
					<li><a href="index.cfm?dsp=management.items.active_fixed">Active Fixed</a></li>
				</cfif>
				<cfif isAllowed("Lister_SoldListings")>
					<li><a href="index.cfm?dsp=management.items.sold" style="color:blue;">Shipping #RepeatString("&nbsp;", 25)#&raquo;</a>
						<ul>
							<li><a href="index.cfm?dsp=management.wait_payment">Awaiting Payment</a></li>
							<li><a href="index.cfm?dsp=admin.ship.gl">Generate Label</a></li>
							<li><a href="index.cfm?dsp=admin.ship.awaiting">Awaiting Ship</a></li>
							<li><a href="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">Awaiting Ship Fixed Price</a></li>
							<li><a href="index.cfm?dsp=admin.ship.ship_sold_off">Off eBay</a></li>
							<li><a href="index.cfm?dsp=admin.ship.combined">Combined</a></li>
							<li><a href="index.cfm?dsp=admin.ship.international">Inter</a></li>
							<cfif isAllowed("Lister_MarkRefundItems")>
								<li><a href="index.cfm?dsp=admin.ship.urgent">Urgent</a></li>
								<li><a href="index.cfm?dsp=admin.ship.refund">Refund Items</a></li>
							</cfif>
							<li><a href="index.cfm?dsp=management.paid_shipped">Paid and Shipped</a></li>
							<li><a href="index.cfm?dsp=management.paid_shipped_fixed">Paid and Shipped FIXED</a></li>
							<cfif isAllowed("Listings_BuyPostage")>
								<li><a href="index.cfm?dsp=admin.ship.usps.buy_postage">Postage</a></li>
							</cfif>
							<cfif isAllowed("POS_ShipPackage")>
								<li><a href="index.cfm?dsp=admin.pos.ups_list">UPS Labels</a></li>
							</cfif>
						</ul>
					</li>
				</cfif>
				<cfif isAllowed("Lister_UnsoldListings")>
					<li><a href="index.cfm?dsp=management.need_return" style="color:blue;">Unsold #RepeatString("&nbsp;", 28)#&raquo;</a>
						<ul>
							<li><a href="index.cfm?dsp=management.apayment">Awaiting Payment 25+</a></li>
							<cfif isAllowed("Lister_ReserveNotMet")>
								<li><a href="index.cfm?dsp=management.reserve">Reserve Not Met</a></li>
							</cfif>
							<cfif isAllowed("Lister_NeedToReturn")>
								<li><a href="index.cfm?dsp=management.need_return">Need to Return</a></li>
							</cfif>
							<cfif isAllowed("Lister_NeedToCall")>
								<li><a href="index.cfm?dsp=management.need_call">Need to Call</a></li>
							</cfif>
							<cfif isAllowed("Lister_ClaimsList")>
								<li><a href="index.cfm?dsp=management.claims_list">Claims List</a></li>
							</cfif>
							<cfif isAllowed("Lister_NeedToRelot")>
								<li><a href="index.cfm?dsp=management.need_relot">Need to Relot</a></li>
							</cfif>
							<cfif isAllowed("Lister_Relotted")>
								<li><a href="index.cfm?dsp=management.relotted">IA Relot</a></li>
							</cfif>
							<cfif isAllowed("Lister_DTC")>
								<li><a href="index.cfm?dsp=management.items.craiglist">Craiglist</a></li>
							</cfif>
							<cfif isAllowed("Lister_DTC")>
								<li><a href="index.cfm?dsp=management.items.Bonanza">Bonanza</a></li>
							</cfif>							
						</ul>
					</li>
				</cfif>
				<cfif isAllowed("Lister_ListAuction") OR isAllowed("Items_ItemLocation")>
					<li><a href="index.cfm?dsp=management.items.ir_errors">Errors</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Invoices")>
		<li><a href="JavaScript:void(0);">Invoices</a>
			<ul>
				<cfif isAllowed("Invoices_Awaiting")>
					<li><a href="index.cfm?dsp=management.needs_invoice">Need to be Invoiced</a></li>
				</cfif>
				<cfif isAllowed("Invoices_View")>
					<li><a href="index.cfm?dsp=management.invoices">View Invoices</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isAllowed("Other_RMA") OR isAllowed("Ship_Claims")>
		<li><a href="JavaScript:void(0);">RMA</a>
			<ul>
				<li><a href="index.cfm?dsp=rma.list&type=1">Return Items</a></li>
				<li><a href="index.cfm?dsp=rma.list&type=2">Replacement Items</a></li>
				<li><a href="index.cfm?dsp=rma.settings.list">RMA Settings</a></li>
				<li><a href="index.cfm?dsp=rma.mails.list">RMA Mails</a></li>
				<cfif isAllowed("Ship_Claims")>
					<li class="begingroup"><a href="index.cfm?dsp=claims.list">Ship Claims</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>

<!---	<cfif isGroupMemberAllowed("Other")>
		<li><a href="JavaScript:void(0);">Communications</a>
			<ul>
				<cfif isAllowed("Other_EbayQuestions")>
					<li><a href="index.cfm?dsp=api.messages.list">Questions</a></li>
				</cfif>
				<cfif isAllowed("Other_MyMessages")>
					<li class="begingroup"><a href="index.cfm?dsp=api.mymessages.list" style="color:green;">My Messages</a></li>
					<li><a href="index.cfm?dsp=api.mymessages.sent_list" style="color:green;">Sent Messages</a></li>
				</cfif>
				<cfif isAllowed("Other_Disputes")>
					<li class="begingroup"><a href="index.cfm?dsp=api.disputes.list" style="color:red;">Disputes</a></li>
					<li><a href="index.cfm?dsp=api.disputes.add_step1">Add Unpaid Dispute</a></li>
					<li><a href="index.cfm?dsp=api.disputes.unpaid_elegible">Eligible 4 Unpaid Dispute</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>--->
	<cfif isAllowed("Full_Access")>
		<li><a href="index.cfm?dsp=api.errors">Synch</a>
			<ul>
				<li><a href="index.cfm?dsp=api.errors">Synch Errors #RepeatString("&nbsp;", 12)#&raquo;</a>
					<ul>
						<li><a href="index.cfm?dsp=api.errors1">Non-Existent</a></li>
						<li><a href="index.cfm?dsp=api.errors2">Double-Listed</a></li>
						<li><a href="index.cfm?dsp=api.errors3">Overwrite Conflicts</a></li>
						<li><a href="index.cfm?dsp=api.errors4">Could Not Parse</a></li>
						<li><a style="color:red;" href="index.cfm?dsp=api.errors5">Second Chance</a></li>
					</ul>
				</li>
				<li><a href="index.cfm?dsp=api.downloads">Get eBay Data</a></li>
				<li><a href="index.cfm?dsp=api.get_changes">Retrieve Changes</a></li>
				<li><a href="index.cfm?dsp=api.run_synch">Apply Changes</a></li>
				<li><a href="index.cfm?dsp=api.call_stat">API Call Status</a></li>
				<li><a href="index.cfm?dsp=admin.api.scheduled_task_061006" target="_blank">Sync Ebay and Insta DB</a></li>
				<li><a href="index.cfm?dsp=admin.api.st_getEbayQuantity">Run Get Qty (Warning!)</a></li>
			</ul>
		</li>
	</cfif>
	<cfif isAllowed("System_Settings")>
		<li><a href="JavaScript:void(0);">System</a>
			<ul>
				<li><a href="index.cfm?dsp=admin.settings">Settings</a></li>
				<cfif isAllowed("Full_Access")>
					<li><a href="index.cfm?dsp=admin.system.undelivered_mail">Mails</a></li>
					<li><a href="index.cfm?dsp=admin.ebay.list" style="color:red;">eBay Accounts</a></li>
				</cfif>
				<cfif isAllowed("System_ManageRoles")>
					<li><a href="index.cfm?dsp=admin.roles">Roles</a></li>
				</cfif>
				<cfif isAllowed("Items_ViewItemLogs")>
					<li><a href="index.cfm?dsp=admin.logs">View Logs</a></li>
				</cfif>
				<li><a href="index.cfm?dsp=admin.api.schedule">Schedule</a></li>
				<cfif isAllowed("System_TroubleTickets")>
					<li><a href="tickets" style="color:red;" target="_blank">Trouble Tickets</a></li>
				</cfif>
			</ul>
		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Overview")>
		<li><a href="JavaScript:void(0);">Ebay Fixed Price</a>
			<ul>
				<li><a href="index.cfm?dsp=admin.ship.awaitingFixedPriceV2">Link Ebay Fixed Items</a></li>
				<li><a href="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">Awaiting Ship Fixed Items</a></li>
				<li><a href="index.cfm?dsp=admin.ship.awaitingFixedPriceV2&filter_date=7&filter_lid=paidshipped">Fixed Items P&S</a></li>
			</ul>

		</li>
	</cfif>
	<cfif isGroupMemberAllowed("Overview")>
		<li><a href="index.cfm?dsp=amazon_live.amazon_unshipped">Amazon</a>
			<cfif isAllowed("Full_Access")>
				<ul>
					<li><a href="index.cfm?dsp=amazon_live.amazon_unshipped">Unshipped Items</a></li>

					<li><a href="index.cfm?dsp=amazon_live.amazon_itemMgmt">Item Management</a></li>
					<li><a href="index.cfm?dsp=amazon_live.amazon_paidshipped">Paid and Shipped</a></li>
					<li><a href="index.cfm?dsp=amazon_live.item_received">Item Received</a></li>
					<li><a href="##">Amazon Api Calls</a>
						<ul>
							<li><a href="index.cfm?dsp=amazon_live.st_amazonItems" target="_blank">Get Unshipped Amazon Items</a></li>
							<li><a href="index.cfm?dsp=amazon_live.st_SubmitFeed" target="_blank">Push Tracking To Amazon</a></li>
							<li><a href="index.cfm?dsp=amazon_live.st_CheckSubmissionIDS" target="_blank">Check Progress</a></li>
							<li><a href="index.cfm?dsp=amazon_live.st_CheckSubmission_result" target="_blank">Check Completed</a></li>
						</ul>
					</li>


				</ul>
			</cfif>
		</li>
	</cfif>
</ul>
</cfoutput>
