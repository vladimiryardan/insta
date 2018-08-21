<!---
Description: This script intends to get Sales record of Fixed price items
Date: 20111206
--->

<cfoutput><h2>Get Sales Record (Fixed Price Item) started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
<cfquery datasource="#request.dsn#" name="sqlEBAccount">
	SELECT eBayAccount, UserID, UserName, Password,
		DeveloperName, ApplicationName, CertificateName, RequestToken,
		trans_from, trans_to, trans_page, trans_status
	FROM ebaccounts
	WHERE trans_active = 1
	<cfif isDefined("attributes.justThose")>
		AND eBayAccount IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.justThose#" list="yes">)
	</cfif>
	ORDER BY trans_from
</cfquery>

<cfoutput>

	<cfloop query="sqlEBAccount">

		<cfset st_GetSellerTransactions_Status = trans_status>
		<cfset st_GetSellerTransactions_ModTimeFrom = trans_from>
		<cfset st_GetSellerTransactions_ModTimeTo = trans_to>
		<cfset st_GetSellerTransactions_Page = trans_page>

		<h3>DEBUG</h3>
		<h4>RETRIEVED FROM DB</h4>
		<pre>UserID=#UserID#
		st_GetSellerTransactions_Status=#st_GetSellerTransactions_Status#
		st_GetSellerTransactions_ModTimeFrom=#st_GetSellerTransactions_ModTimeFrom#
		st_GetSellerTransactions_ModTimeTo=#st_GetSellerTransactions_ModTimeTo#
		st_GetSellerTransactions_Page=#st_GetSellerTransactions_Page#
		</pre>
		<cfflush interval="100">

	</cfloop>
</cfoutput>