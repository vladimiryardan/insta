<cfif NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">

<cfset attributes.CallName = "EndItem">
<cfset _ebay.CallName = attributes.CallName>
<cfquery datasource="#request.dsn#" name="sqlData">
	SELECT ebayitem
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfquery name="sqlEBAccount" datasource="#request.dsn#">
	SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
		a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
	FROM auctions u
		INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
	WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
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
<cfscript>
	variables.ModifiedFields = "";
	_ebay.XMLRequest		= '<?xml version="1.0" encoding="UTF-8"?>
<#attributes.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<ItemID>#sqlData.ebayitem#</ItemID>
	<EndingReason>#attributes.EndingReason#</EndingReason>
</#attributes.CallName#Request>';
</cfscript>
<cfset _ebay.ThrowOnError = false>
<cfinclude template="../../api/act_call.cfm">

<cfif _ebay.Ack EQ "failure">
	<cfoutput><h3 style="color:red;">Error while submit EndItem. Details: #HTMLEditFormat(err_detail)#</h3></cfoutput>
	<cfset _machine.error_in_action = TRUE>
<cfelse>
	<cfscript>
		LogAction("ended auction #sqlData.ebayitem# (itemid: #attributes.item#, reason: #attributes.EndingReason#)");
		fChangeStatus(attributes.item, 8); // Did Not Sell
	</cfscript>
</cfif>
