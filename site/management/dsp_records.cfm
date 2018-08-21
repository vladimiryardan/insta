<cfparam name="attributes.item" default="">
<cfif NOT isAllowed("Items_AuctionFeeRecords")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfif attributes.item  EQ "">
	<cfoutput>NO ITEM ## GIVEN</cfoutput>
	<cfexit method="exittemplate">
</cfif>

<cfquery name="sqlRecord" datasource="#request.dsn#">
	SELECT r.[desc], r.dstarted, r.dended, r.finalprice, r.highbidder,
		r.shipping, r.actualshipping, r.salestax, r.ebayfees, r.ourfees,
		r.checkamount, r.paypalfees, r.checksent, r.tracking, r.netincome,
		i.item, i.commission, i.ebayitem, i.aid, i.invoicenum, r.ExtraFees,
		a.first, a.last, a.address1, a.address2, a.city, a.state, a.zip, a.store
	FROM records r
		INNER JOIN items i ON r.itemid = i.item
		INNER JOIN accounts a ON i.aid = a.id
	WHERE r.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfif sqlRecord.RecordCount EQ 0>
	<cfoutput>NO RECORD FOUND</cfoutput>
	<cfexit method="exittemplate">
</cfif>

<cfoutput query="sqlRecord">
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Records Management:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<b>Item ID: </b><a href="index.cfm?dsp=management.items.edit&item=#item#">#item#</a><br><br>
	<b>Account: </b><a href="index.cfm?dsp=account.edit&id=#aid#">#first# #last#</a>
	<a href="mailto:$email?subject=Instant Auctions: Item #item#"><img src="#request.images_path#emailblue.gif" align="middle" border=0></a><br><br>
	<cfif checksent EQ "1">
		<cfset checked = "CHECKED">
		<b>Invoice: </b> <a href="invoices/Invoice #store#.#aid#.#invoicenum#.htm" target="_blank">View Invoice</a><br><br>
	<cfelse>
		<cfset checked = "">
	</cfif>
	<center>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<form method="POST" action="index.cfm?act=management.update_record">
		<input type="hidden" name="item" value="#item#">
		<table width=100% bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
		<tr><td>
			<table width="100%" border="0" cellpadding="4" cellspacing="1">
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>eBay Item:</b></td><td width="70%" align="left"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#ebayitem#" target="_blank">#ebayitem#</a></td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>eBay Title:</b></td><td width="70%" align="left">#desc#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Account ID:</b></td><td width="70%" align="left"><a href="index.cfm?dsp=account.edit&id=#aid#">#aid#</a></td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Time Started:</b></td><td width="70%" align="left">#dstarted#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Time Ended:</b></td><td width="70%" align="left">#dended#</td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Final Price:</b></td><td width="70%" align="left">$#finalprice#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>High Bidder:</b></td><td width="70%" align="left">#URLDecode(highbidder)#</td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Shipping:</b></td><td width="70%" align="left">$#shipping#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Actual Shipping:</b></td><td width="70%" align="left">$#actualshipping#</td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Sales Tax:</b></td><td width="70%" align="left">$#salestax#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>eBay Fees:</b></td><td width="70%" align="left">$#ebayfees#</td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Our Fees:</b></td><td width="70%" align="left">$#ourfees#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>PayPal Fees:</b></td><td width="70%" align="left">$#paypalfees#</td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Check Amount:</b></td><td width="70%" align="left">$#checkamount#</td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Invoiced:</b></td><td width="70%" align="left"><input type="checkbox" name="checksent" #checked# value="1" disabled></td></tr>
			<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Net Income:</b></td><td width="70%" align="left"><b>$#netincome#</b></td></tr>
			<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Extra Fees:</b></td><td width="70%" align="left"><b>$</b><input type="textbox" name="ExtraFees" value="#ExtraFees#" size=10 style="font-size: 11px;"></td></tr>
			</table>
		</td></tr>
		</table>
	</td></tr>
	</table>
	<br>
	<input type="submit" value="Save Fees" length="30">
	</form>
	<br><br>
	<form method="POST" action="index.cfm?act=management.items.invoice">
		<input type="hidden" name="account" value="#aid#">
		<input type="hidden" name="items" value="#item#">
		<input type="hidden" name="createreceipt" value="1">
		<input type="submit" value="Create Invoice " length="30"<cfif checksent EQ "1"> disabled</cfif>>
	</form>
	<form method="POST" action="index.cfm?act=management.items.recalculate_fees">
		<input type="hidden" name="item" value="#item#">
		<input type="submit" value="   Recalculate Fees   " length="30" onClick="return confirm('Be sure to Save Changes first! Continue?');">
	</form>
	</center>
</td></tr>
</table>
</cfoutput>
