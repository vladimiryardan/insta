<cfparam name="attributes.itemid">
<cfparam name="attributes.ebayitem">
<cfparam name="attributes.TransactionID">
<cfparam name="attributes.PaymentMethodUsed">
<cfparam name="attributes.StatusIs">
<cfif attributes.StatusIs EQ 2>
	<cfset CheckoutStatus = "Complete">
	<cfif isDefined("session.user.accountid")>
		<cfset aid = session.user.accountid>
	<cfelse>
		<cfset aid = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET aid_checkout_complete = <cfqueryparam cfsqltype="cf_sql_integer" value="#aid#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
<cfelse>
	<cfset CheckoutStatus = "Incomplete">
</cfif>
<cfset LogAction("revised checkout status for item #attributes.itemid#")>
<cfif attributes.PaymentMethodUsed EQ "PayPal">
	<!---
		eBayXMLAPIAllDocs\WebHelp\ReviseCheckoutStatusCall-ReviseCheckoutStatus_Concepts.html
		*** Notes for Third-Party Checkout Providers ***
		When the buyer selects PayPal as the payment method, the Third-Party Checkout Provider
		application should not call ReviseCheckoutStatus. Instead, after it finishes its own processes,
		it should provide the buyer with a link to PayPal. There, the buyer can pay and complete
		the checkout process. 
	--->
	<cfset LogAction("DEBUG: ReviseCheckoutStatus API call skipped for #attributes.itemid# because PayPal used")>
	<cfset attributes.paid = attributes.StatusIs - 1><!--- 1 = Incomplete, 2 = Complete --->
	<cfinclude template="act_complete_sale.cfm">
<cfelse>
	<cfif attributes.PaymentMethodUsed EQ "VisaMC">
		<cfset FIX_PaymentMethodUsed = "AmEx">
	<cfelse>
		<cfset FIX_PaymentMethodUsed = attributes.PaymentMethodUsed>
	</cfif>
	<cfquery name="sqlEBAccount" datasource="#request.dsn#">
		SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
			a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
		FROM auctions u
			INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
		WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
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
	<cfset _ebay.CallName ="ReviseCheckoutStatus">
	<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
	<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
		<RequesterCredentials>
			<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
		</RequesterCredentials>
		<Version>#_ebay.CompatibilityLevel#</Version>
		<ItemID>#attributes.ebayitem#</ItemID>
		<TransactionID>#attributes.TransactionID#</TransactionID>
		<CheckoutStatus>#CheckoutStatus#</CheckoutStatus>
		<PaymentMethodUsed>#FIX_PaymentMethodUsed#</PaymentMethodUsed>
		<StatusIs>#attributes.StatusIs#</StatusIs>
	</#_ebay.CallName#Request>'>
	<cfset _ebay.ThrowOnError = false>
	<cfinclude template="../../api/act_call.cfm">
	<cfif NOT isDefined("_ebay.xmlResponse")>
		<cfoutput><h1 style="color:red;">ERROR OCCURED: #_ebay.response#</h1></cfoutput>
		<cfset _machine.error_in_action = true>
	<cfelseif _ebay.Ack EQ "failure">
		<cfoutput><h1 style="color:red;">API call failed!</h1></cfoutput>
		<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.Errors)#">
			<cfoutput>
			<h2 style="color:red;">#_ebay.xmlResponse.xmlRoot.Errors[i].SeverityCode.xmlText#: #_ebay.xmlResponse.xmlRoot.Errors[i].ShortMessage.xmlText#</h2>
			#_ebay.xmlResponse.xmlRoot.Errors[i].LongMessage.xmlText#
			</cfoutput>
		</cfloop>
		<cfset _machine.error_in_action = true>
	<cfelse>
		<cfset attributes.paid = attributes.StatusIs - 1><!--- 1 = Incomplete, 2 = Complete --->
		<cfinclude template="act_complete_sale.cfm">
	</cfif>
</cfif>
<!--- UPDATE LOCAL DATABASE --->
<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.itemid#">
