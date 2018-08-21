<cfparam name="attributes.SiteID" default="0">

<cfoutput><h3>GetStore for CategorySiteID = #attributes.SiteID#</h3></cfoutput>

<cfscript>
	_ebay.CallName = "GetStore";
	_ebay.ThrowOnError = false;
	_ebay.XMLRequest = '
<?xml version="1.0" encoding="utf-8"?>
<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<CategorySiteID>#attributes.SiteID#</CategorySiteID>
	<DetailLevel>ReturnAll</DetailLevel>
	<LevelLimit>1</LevelLimit>
</#_ebay.CallName#Request>';
</cfscript>

<cfinclude template="../../api/act_call.cfm">

<cfif _ebay.Ack EQ "failure">
	<cfoutput><li style="color:red;">Store information NOT updated due to API call failure.</li></cfoutput>
<cfelse>
	<cfoutput><li>Updating list of categories for store '#_ebay.xmlResponse.GetStoreResponse.Store.Name.xmlText#'</li></cfoutput>
	<cfquery datasource="#request.dsn#">
		DELETE FROM custom_categories
		WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.SiteID#">
	</cfquery>
	<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.GetStoreResponse.Store.CustomCategories.xmlChildren)#">
		<cfset Category = _ebay.xmlResponse.GetStoreResponse.Store.CustomCategories.xmlChildren[i]>
		<cfquery datasource="#request.dsn#">
			INSERT INTO custom_categories
			(
				CategoryID,
				Name,
				SortOrder,
				SiteID
			)
			VALUES (
				<cfqueryparam cfsqltype="cf_sql_integer" value="#Category.CategoryID.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Category.Name.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#Category.Order.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.SiteID#">
			)
		</cfquery>
	</cfloop>
	<cfoutput><li>List of categories updated. #ArrayLen(_ebay.xmlResponse.GetStoreResponse.Store.CustomCategories.xmlChildren)# categories affected</li></cfoutput>
</cfif>
