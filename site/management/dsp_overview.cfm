<cfif NOT isGroupMemberAllowed("Overview")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfif NOT isDefined("application.overview") OR isDefined("attributes.recalculate")>
	<cfinclude template="act_calc_overview.cfm">
<cfelse>
	<cflock scope="application" timeout="5" type="readonly">
		<cfset overview = Duplicate(application.overview)>
	</cflock>
</cfif>
<cfif DateDiff("n", overview.calculatedOn, Now()) GT 90><!--- recalculate every 1.5 hours --->
	<cfinclude template="act_calc_overview.cfm">
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Management Overview:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br>
	<br>
	<strong>Mass Email to all Users:</strong> <a href="index.cfm?dsp=management.massemail"><img src="<cfoutput>#request.images_path#</cfoutput>emailblue.gif" align=middle border=0></a>
	#RepeatString("&nbsp;", 65)#
	<a href="index.cfm?dsp=management.overview&recalculate=1">Recalculate all</a> <small>(last calculated #DateDiff("n", overview.calculatedOn, Now())# minutes ago)</small>
	<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
	<cfif isAllowed("Overview_AllSales")>
		<tr bgcolor="##F0F1F3"><td colspan="2"><a href="index.cfm?dsp=admin.overview.business">Business Overview</a>:</td></tr>
		<tr bgcolor="white">
			<td width="30%">Sales Yesterday</td>
			<td>#DollarFormat(overview.salesYesterday)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Sales This Week</td>
			<td>#DollarFormat(overview.salesLastWeek)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Sales This Month</td>
			<td>#DollarFormat(overview.salesThisMonth)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Amount Paid Out This Month</td>
			<td>#DollarFormat(overview.paidThisMonth)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Commissions This Month</td>
			<td>#DollarFormat(overview.salesThisMonth-overview.paidThisMonth)#</td>
		</tr>
	</cfif>
	<cfif isAllowed("Overview_StoreSales")>
		<tr bgcolor="##F0F1F3"><td colspan="2">Store #session.user.store# Business Overview:</td></tr>
		<tr bgcolor="white">
			<td width="30%">Sales Yesterday</td>
			<td>#DollarFormat(overview.byStore["_#session.user.store#"].salesYesterday)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Sales This Week</td>
			<td>#DollarFormat(overview.byStore["_#session.user.store#"].salesLastWeek)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Sales This Month</td>
			<td>#DollarFormat(overview.byStore["_#session.user.store#"].salesThisMonth)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Amount Paid Out This Month</td>
			<td>#DollarFormat(overview.byStore["_#session.user.store#"].paidThisMonth)#</td>
		</tr>
		<tr bgcolor="white">
			<td>Commissions This Month</td>
			<td>#DollarFormat(overview.byStore["_#session.user.store#"].salesThisMonth - overview.byStore["_#session.user.store#"].paidThisMonth)#</td>
		</tr>
	</cfif>
	<cfif isAllowed("Overview_Listings")>
		<tr bgcolor="##F0F1F3"><td colspan="2"><a href="index.cfm?dsp=admin.overview.active">Active Listings</a>:</td></tr>
		<tr bgcolor="white">
			<td>Current Listings</td>
			<td>#overview.cntCurrentListings#</td>
		</tr>
		<tr bgcolor="white">
			<td>Listed Yesterday</td>
			<td>#overview.cntYesterday#</td>
		</tr>
		<tr bgcolor="white">
			<td>Listed This Week</td>
			<td>#overview.cntLastWeek#</td>
		</tr>
		<tr bgcolor="white">
			<td>Listed This Month</td>
			<td>#overview.cntThisMonth#</td>
		</tr>
		<tr bgcolor="white">
			<td>Starting Today</td>
			<td><div style="color:red;">TODO</div></td>
		</tr>
		<tr bgcolor="white">
			<td>Ending Today</td>
			<td><div style="color:red;">TODO</div></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">Created Items:</td></tr>
		<tr bgcolor="white">
			<td>Items Created Yesterday</td>
			<td>#overview.createdYesterday#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Created This Week</td>
			<td>#overview.createdLastWeek#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Created This Month</td>
			<td>#overview.createdThisMonth#</td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">Received Items:</td></tr>
		<tr bgcolor="white">
			<td>Items Received Yesterday</td>
			<td>#overview.receivedYesterday#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Received This Week</td>
			<td>#overview.receivedLastWeek#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Received This Month</td>
			<td>#overview.receivedThisMonth#</td>
		</tr>
	</cfif>
	<cfif isAllowed("Overview_Shipments")>
		<tr bgcolor="##F0F1F3"><td colspan="2">Sold Listings:</td></tr>
		<tr bgcolor="white">
			<td>Awaiting Payment</td>
			<td>#overview.cntAwaitPay#</td>
		</tr>
		<tr bgcolor="white">
			<td><a href="index.cfm?dsp=admin.ship.awaiting">Awaiting Shipment</a></td>
			<td>#overview.cntAwaitShip#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Shipped Yesterday</td>
			<td>#overview.shipYesterday#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Shipped This Week</td>
			<td>#overview.shipLastWeek#</td>
		</tr>
		<tr bgcolor="white">
			<td>Items Shipped This Month</td>
			<td>#overview.shipThisMonth#</td>
		</tr>
	</cfif>
		<tr bgcolor="##F0F1F3"><td colspan="2">System:</td></tr>
		<tr bgcolor="white">
			<td>Checks to be Written</td>
			<td>#overview.cntChecksToBeWritten#</td>
		</tr>
		<tr bgcolor="white">
			<td>Synch Errors</td>
			<td>#overview.cntSynchErrors#</td>
		</tr>
		<tr bgcolor="white">
			<td>Trouble Tickets</td>
			<td>#overview.cntTroubleTickets#</td>
		</tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
