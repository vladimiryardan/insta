<cfoutput><h2>GetSellerTransaction started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
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

<cfloop query="sqlEBAccount">
	<cfoutput>Process record with UserID=#UserID#, status=#trans_status#, from=#trans_from#<br></cfoutput>
	<cfset st_GetSellerTransactions_Status = trans_status>
	<cfset st_GetSellerTransactions_ModTimeFrom = trans_from>
	<cfset st_GetSellerTransactions_ModTimeTo = trans_to>
	<cfset st_GetSellerTransactions_Page = trans_page>
	<cfset bLoop = true>
<cfoutput><h3>DEBUG</h3><h4>RETRIEVED FROM DB</h4><pre>UserID=#UserID#
st_GetSellerTransactions_Status=#st_GetSellerTransactions_Status#
st_GetSellerTransactions_ModTimeFrom=#st_GetSellerTransactions_ModTimeFrom#
st_GetSellerTransactions_ModTimeTo=#st_GetSellerTransactions_ModTimeTo#
st_GetSellerTransactions_Page=#st_GetSellerTransactions_Page#
</pre></cfoutput><cfflush interval="100">
	<cfloop condition="#bLoop#">
		<cfif st_GetSellerTransactions_Status EQ "NEW">
			<cfoutput><li>Task executed first time</li></cfoutput>
			<cfset st_GetSellerTransactions_Status = "READ">
			<cfset st_GetSellerTransactions_ModTimeFrom = "#DateAdd("h", -72, Now())#"><!--- 3 days --->
			<cfset st_GetSellerTransactions_ModTimeTo = Now()>
			<cfset st_GetSellerTransactions_Page = 1>
			<cfquery datasource="#request.dsn#">
				UPDATE ebaccounts
				SET trans_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#st_GetSellerTransactions_Status#">,
					trans_from = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeFrom#">,
					trans_to = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeTo#">,
					trans_page = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#st_GetSellerTransactions_Page#">
				FROM ebaccounts
				WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
			</cfquery>
		<cfelseif st_GetSellerTransactions_Status EQ "DONE">
			<cfoutput><li>Schedule new download</li></cfoutput>
			<cfset st_GetSellerTransactions_Status = "READ">
			<cfset st_GetSellerTransactions_ModTimeFrom = DateAdd('h', -2, st_GetSellerTransactions_ModTimeTo)>
			<cfset st_GetSellerTransactions_ModTimeTo = Now()>
			<cfset st_GetSellerTransactions_Page = 1>
			<cfquery datasource="#request.dsn#">
				UPDATE ebaccounts
				SET trans_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#st_GetSellerTransactions_Status#">,
					trans_from = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeFrom#">,
					trans_to = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeTo#">,
					trans_page = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#st_GetSellerTransactions_Page#">
				FROM ebaccounts
				WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
			</cfquery>
		<cfelseif st_GetSellerTransactions_Status EQ "FAIL">
			<cfoutput><li>Previous run failed, schedule new download</li></cfoutput>
			<cfset st_GetSellerTransactions_Status = "READ">
			<cfset st_GetSellerTransactions_ModTimeFrom = st_GetSellerTransactions_ModTimeFrom>
			<cfset st_GetSellerTransactions_ModTimeTo = DateAdd('h', 8, st_GetSellerTransactions_ModTimeFrom)>
			<cfset st_GetSellerTransactions_Page = 1>
			<cfquery datasource="#request.dsn#">
				UPDATE ebaccounts
				SET trans_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#st_GetSellerTransactions_Status#">,
					trans_from = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeFrom#">,
					trans_to = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#st_GetSellerTransactions_ModTimeTo#">,
					trans_page = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#st_GetSellerTransactions_Page#">
				FROM ebaccounts
				WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
			</cfquery>
		<cfelse>
			<cfoutput><li>Load page #st_GetSellerTransactions_Page# (#st_GetSellerTransactions_ModTimeFrom# - #st_GetSellerTransactions_ModTimeTo#)</li></cfoutput>
			<cfscript>
				_ebay.UserID			= UserID;
				_ebay.UserName			= UserName;
				_ebay.Password			= Password;
				_ebay.DeveloperName		= DeveloperName;
				_ebay.ApplicationName	= ApplicationName;
				_ebay.CertificateName	= CertificateName;
				_ebay.RequestToken		= RequestToken;
			</cfscript>
			<cfset _ebay.CallName ="GetSellerTransactions">
			<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
	<GetSellerTransactionsRequest xmlns="urn:ebay:apis:eBLBaseComponents">
		<RequesterCredentials>
			<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
		</RequesterCredentials>
		<DetailLevel>ReturnAll</DetailLevel>
		<ModTimeFrom>#DateTimeToEBay(st_GetSellerTransactions_ModTimeFrom)#</ModTimeFrom>
		<ModTimeTo>#DateTimeToEBay(st_GetSellerTransactions_ModTimeTo)#</ModTimeTo>
		<Pagination>
			<EntriesPerPage>10</EntriesPerPage>
			<PageNumber>#st_GetSellerTransactions_Page#</PageNumber>
		</Pagination>
	</GetSellerTransactionsRequest>'>
<cfoutput><h4>DO API CALL:</h4><pre>UserID=#UserID#
st_GetSellerTransactions_Status=#st_GetSellerTransactions_Status#
st_GetSellerTransactions_ModTimeFrom=#st_GetSellerTransactions_ModTimeFrom#
st_GetSellerTransactions_ModTimeTo=#st_GetSellerTransactions_ModTimeTo#
st_GetSellerTransactions_Page=#st_GetSellerTransactions_Page#
</pre></cfoutput><cfflush interval="100">
			<cfset _ebay.ThrowOnError = false>
			<cfinclude template="../../api/act_call.cfm">
			<cfquery datasource="#request.dsn#">
				UPDATE ebaccounts
				SET trans_response = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#_ebay.response#">
				FROM ebaccounts
				WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
			</cfquery>
			<cfif _ebay.Ack EQ "failure">
				<cfoutput><li style="color:red;">API call failed!</li></cfoutput>
				<cfset st_GetSellerTransactions_Status = "FAIL">
				<cfquery datasource="#request.dsn#">
					UPDATE ebaccounts
					SET trans_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#st_GetSellerTransactions_Status#">
					FROM ebaccounts
					WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
				</cfquery>
				<cfset bLoop = false>
				<cfif request.emails.error NEQ "">
					<cfmail from="#_vars.mails.from#"
					 to="#request.emails.error#" 
					 subject="GetSellerTransactions call failed" type="html">
						<h1>_ebay.XMLRequest</h1>
						<pre>#_ebay.XMLRequest#</pre>
						<h1>_ebay.response</h1>
						#_ebay.response#
					</cfmail>
				</cfif>
			<cfelse>

				<cfoutput><li>Parse retrieved data...</li></cfoutput>

				<cfset isError = false>
				<cftry>
					<cfinclude template="act_parse_transaction.cfm">

					<cfcatch type="any">
						<cfoutput><h1>cfcatch</h1></cfoutput>
						<cfdump var="#cfcatch#">
						<cfoutput><h1>_ebay</h1></cfoutput>
						<!---<cfdump var="#_ebay#">--->
						<cfset isError = true>
						<cfdump var="#cgi.sCRIPT_NAME#">
						<!---<cfabort>--->
					</cfcatch>
				</cftry>
				<cfif isError>
					<cfset bLoop = false>
				<cfelseif StructKeyExists (_ebay.xmlResponse.xmlRoot, "HasMoreTransactions") AND _ebay.xmlResponse.xmlRoot.HasMoreTransactions.xmlText>
					<cfoutput><li>...done, but has more transactions (#_ebay.xmlResponse.xmlRoot.PaginationResult.TotalNumberOfPages.xmlText# pages total)</li></cfoutput>
					<cfset st_GetSellerTransactions_Page = st_GetSellerTransactions_Page + 1>
					<cfquery datasource="#request.dsn#">
						UPDATE ebaccounts
						SET trans_page = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#st_GetSellerTransactions_Page#">
						FROM ebaccounts
						WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
					</cfquery>
				<cfelse>
					<cfoutput><li>...completed!</li></cfoutput>
					<cfset st_GetSellerTransactions_Status = "DONE">
					<cfquery datasource="#request.dsn#">
						UPDATE ebaccounts
						SET trans_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#st_GetSellerTransactions_Status#">
						FROM ebaccounts
						WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
					</cfquery>
					<cfset bLoop = false>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<cfoutput><h2>GetSellerTransaction finished at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
</cfloop>
