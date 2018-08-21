<cfquery datasource="#request.dsn#" name="sqlData">
	SELECT ebayitem
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfset _ebay.CallName ="GetAllBidders">
<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<ItemID>#sqlData.ebayitem#</ItemID>
	<CallMode>ViewAll</CallMode>
</#_ebay.CallName#Request>'>
<cfset _ebay.ThrowOnError = false>
<cfinclude template="../../api/act_call.cfm">
<cfsavecontent variable="theContent">
<cfif _ebay.Ack EQ "failure">
	<cfoutput><p style="color:##FF0000; font-weight:bold;">API Call (#_ebay.CallName#) error. Details: #err_detail#</p></cfoutput>
<cfelse>
	<cfset BidArray = _ebay.xmlResponse.xmlRoot.BidArray>
	<cfif ArrayLen(_ebay.xmlResponse.xmlRoot.BidArray.xmlChildren) GT 0>
		<cfoutput>
		<ul>
			<b>List of Bidders:</b>
			<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.BidArray.xmlChildren)#">
				<cfset Offer = _ebay.xmlResponse.xmlRoot.BidArray.xmlChildren[i]>
				<li>#Offer.User.UserID.xmlText# - $#Offer.MaxBid.xmlText#</li>
			</cfloop>
		</ul>
		<p style="color:##FF0000; font-weight:bold;">
			Please make sure that you logged to eBay and cancelled existing bids (those that higher than reserve price).<br>
			Otherwise, ending auction will end up with item being sold.
		</p>
		</cfoutput>
	<cfelse>
		<cfoutput><p>No bidds on this auction at the moment</p></cfoutput>
	</cfif>
</cfif>
</cfsavecontent>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>End My Listing Early</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	#theContent#
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<form action="index.cfm?act=admin.auctions.end_item" method="post">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3">
			<td align="right"><b>ItemID:</b></td>
			<td>#attributes.item#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="EndingReason" id="NotAvailable" value="NotAvailable" checked></td>
			<td><label for="NotAvailable">The item is no longer available for sale</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="EndingReason" id="Incorrect" value="Incorrect"></td>
			<td><label for="Incorrect">The minimum bid or reserve price is incorrect</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="EndingReason" id="OtherListingError" value="OtherListingError"></td>
			<td><label for="OtherListingError">The listing contained an error (other than minimum bid or reserve price)</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="EndingReason" id="LostOrBroken" value="LostOrBroken"></td>
			<td><label for="LostOrBroken">The item was lost or broken</label></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
			<input type="hidden" name="item" value="#attributes.item#">
			<input type="submit" value="End My Listing">
		</td></tr>
		</table>
	</td></tr>
	</form>
	</table>
</td></tr>
</table>
</cfoutput>
