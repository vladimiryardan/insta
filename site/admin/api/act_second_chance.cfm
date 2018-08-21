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
<cfset _ebay.CallName ="GetItem">
<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<ItemID>#attributes.ebayitem#</ItemID>
	<DetailLevel>ItemReturnDescription</DetailLevel>
</#_ebay.CallName#Request>'>
<cfset _ebay.ThrowOnError = false>
<cfinclude template="../../api/act_call.cfm">
<cfif _ebay.Ack EQ "failure">
	<cfoutput><h3 style="color:red;">Error while retrieving auction #attributes.ebayitem#. Details: #err_detail#</h3></cfoutput>
	<cfset _machine.error_in_action = true>
<cfelse>
	<cfset Item = _ebay.xmlResponse.xmlRoot.Item>
	<cfif Item.SellingStatus.SecondChanceEligible.xmlText EQ "true">
		<cfset _machine.cflocation = "index.cfm?dsp=admin.api.second_chance&ebayitem=#attributes.ebayitem#">
	<cfelse>
		<cfset _machine.cflocation = "index.cfm?dsp=management.reserve&error_message=Sorry, second chance is not eligible for #attributes.ebayitem#">
	</cfif>
</cfif>
