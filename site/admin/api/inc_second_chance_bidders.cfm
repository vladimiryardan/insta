<cfset _ebay.CallName ="GetAllBidders">
<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<ItemID>#attributes.ebayitem#</ItemID>
	<CallMode>SecondChanceEligibleEndedListing</CallMode>
</#_ebay.CallName#Request>'>
<cfset _ebay.ThrowOnError = false>
<cfinclude template="../../api/act_call.cfm">
<cfif _ebay.Ack EQ "failure">
	<cfoutput><input type="text" name="RecipientBidderUserID" value=""></cfoutput>
	<cfoutput><small style="color:red;">API Call (#_ebay.CallName#) error. Details: #err_detail#</small></cfoutput>
<cfelse>
	<cfset BidArray = _ebay.xmlResponse.xmlRoot.BidArray>
	<!---
		_ebay.xmlResponse.xmlRoot.HighBidder.xmlText - UserID of high bidder
		_ebay.xmlResponse.xmlRoot.HighestBid.xmlText - value of high bid
		_ebay.xmlResponse.xmlRoot.ListingStatus.xmlText - "Completed"
	--->
	<cfif ArrayLen(_ebay.xmlResponse.xmlRoot.BidArray.xmlChildren) GT 0>
		<cfoutput><select name="RecipientBidderUserID" size="1"></cfoutput>
		<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.BidArray.xmlChildren)#">
			<cfset Offer = _ebay.xmlResponse.xmlRoot.BidArray.xmlChildren[i]>
			<cfif Offer.SecondChanceEnabled.xmlText EQ "true">
				<!---
					Offer.MaxBid.xmlText
					Offer.User.UserID.xmlText
				--->
				<cfoutput><option value="#Offer.User.UserID.xmlText#">#Offer.User.UserID.xmlText# - $#Offer.MaxBid.xmlText#</option></cfoutput>
			</cfif>
		</cfloop>
		<cfoutput></select></cfoutput>
	<cfelse>
		<cfoutput><input type="text" name="RecipientBidderUserID" value=""></cfoutput>
	</cfif>
</cfif>
