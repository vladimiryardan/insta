<cfquery name="sqlEBAccount" datasource="#request.dsn#">
	SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
		a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
	FROM auctions u
		INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
		INNER JOIN ebitems i ON u.itemid = i.itemid
	WHERE i.ebayitem = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ebayitem#">
</cfquery>
<cfscript>
	_ebay.UserID			= sqlEBAccount.UserID;
	_ebay.UserName			= sqlEBAccount.UserName;
	_ebay.Password			= sqlEBAccount.Password;
	_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
	_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
	_ebay.CertificateName	= sqlEBAccount.CertificateName;
	_ebay.RequestToken		= sqlEBAccount.RequestToken;
</cfscript>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Second Chance</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
</cfoutput>
	<cfif isDefined("attributes.submit")>
		<cfparam name="attributes.CopyEmailToSeller" default="0">
		<cfset attributes.CopyEmailToSeller = IIF(attributes.CopyEmailToSeller EQ "1", DE("true"), DE("false"))>
		<cfset attributes.CallName = "AddSecondChanceItem">
		<cfset _ebay.CallName = attributes.CallName>
		<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
		<#attributes.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
			<RequesterCredentials>
				<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
			</RequesterCredentials>
			<RecipientBidderUserID>#attributes.RecipientBidderUserID#</RecipientBidderUserID>
			<BuyItNowPrice>#attributes.BuyItNowPrice#</BuyItNowPrice>
			<CopyEmailToSeller>#attributes.CopyEmailToSeller#</CopyEmailToSeller>
			<Duration>#attributes.Duration#</Duration>
			<ItemID>#attributes.ebayitem#</ItemID>
		</#attributes.CallName#Request>'>
		<cfset _ebay.ThrowOnError = false>
		<cfinclude template="../../api/act_call.cfm">
		<cfoutput><tr bgcolor="##FFFFFF"><td style="padding:40px 40px 40px 40px;"></cfoutput>
		<cfif _ebay.Ack EQ "failure">
			<cfoutput><h3 style="color:red;">Error while submit Second Chance. Details: #HTMLEditFormat(err_detail)#</h3></cfoutput>
		<cfelse>
			<cfinclude template="../auctions/dsp_list_item_result.cfm">
			<cfset LogAction("added Second Chance (#_ebay.xmlResponse.xmlRoot.ItemID.xmlText# for #attributes.ebayitem#, #attributes.RecipientBidderUserID#, #attributes.BuyItNowPrice#)")>
			<cfquery datasource="#request.dsn#">
				INSERT INTO ebsecondchance
				(chancenumber, ebayitem, RecipientBidderUserID, BuyItNowPrice, aid)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(attributes.RecipientBidderUserID, 100)#">,
					<cfqueryparam cfsqltype="cf_sql_money" value="#attributes.BuyItNowPrice#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.accountid#">
				)
			</cfquery>
		</cfif>
		<cfoutput></td></tr></cfoutput>
	<cfelse>
		<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td align="right" width="200"><b>eBay Number</b></td>
			<td colspan="2"><a target="_blank" href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#attributes.ebayitem#">#attributes.ebayitem#</a></td>
		</tr>
		<form action="index.cfm?dsp=admin.api.second_chance" method="post">
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Bidder User ID</b></td>
			<td colspan="2"></cfoutput><cfinclude template="inc_second_chance_bidders.cfm"><cfoutput></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Buy It Now Price</b></td>
			<td><input type="text" name="BuyItNowPrice" value="0" size="7"></td>
			<td><small>Specifies the amount the offer recipient must pay to purchase the item from the second chance offer listing. Use only when the original item was an eBay Motors (or in some categories on U.S. and international sites for high-priced items, such as items in many U.S. and Canada Business and Industrial categories) and it ended unsold because the reserve price was not met. Call fails with an error for any other item conditions.</small></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><label for="CopyEmailToSeller"><b>Copy Email To Seller</b></label></td>
			<td><input type="checkbox" name="CopyEmailToSeller" id="CopyEmailToSeller" value="1"></td>
			<td><small>Specifies whether to send a copy of the second chance offer notification email that goes to the recipient user also to the seller.</small></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Duration</b></td>
			<td><select name="Duration" size="1">#SelectOptions("Days_5", "Days_1,1 Day;Days_3,3 Days;Days_5,5 Days;Days_7,7 Days")#</select></td>
			<td><small>Specifies the length of time the second chance offer listing will be active. The recipient bidder has that much time to purchase the item or the listing expires.</small></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="3" align="center">
			<input type="hidden" name="ebayitem" value="#attributes.ebayitem#">
			<input type="submit" name="submit" value="Submit Second Chance">
		</td></tr>
		</form>
		</cfoutput>
	</cfif>
<cfoutput>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
