<cfoutput><h1>SYNC started at #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
<cfquery datasource="#request.dsn#" name="sqlEBAccount">
	SELECT eBayAccount,
		DeveloperName, ApplicationName, CertificateName,
		UserID, UserName, Password, RequestToken,
		sync_active, sync_from, sync_to, sync_status
	FROM ebaccounts
	WHERE sync_active = 1
	<cfif isDefined("attributes.justThose")>
		AND eBayAccount IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.justThose#" list="yes">)
	</cfif>
	ORDER BY sync_from
</cfquery>
<cfloop query="sqlEBAccount">
	<cfoutput>Process record with UserID=#UserID#, status=#sync_status#, from=#sync_from#<br></cfoutput>
	<cfscript>
		_ebay.UserID			= UserID;
		_ebay.UserName			= UserName;
		_ebay.Password			= Password;
		_ebay.DeveloperName		= DeveloperName;
		_ebay.ApplicationName	= ApplicationName;
		_ebay.CertificateName	= CertificateName;
		_ebay.RequestToken		= RequestToken;
	</cfscript>
	<cfswitch expression="#sync_status#">
		<cfcase value="new">
			<cfset dtFROM	= sync_from>
			<cfset dtTO		= Now()>
		</cfcase>
<!---
		<cfcase value="read">
			<cfset dtFROM	= sync_from>
			<cfset dtTO		= sync_to>
		</cfcase>
		<cfcase value="parse">
			<cfset dtFROM	= sync_from>
			<cfset dtTO		= sync_to>
		</cfcase>
--->
		<cfcase value="done">
			<cfset dtFROM	= sync_to>
			<cfset dtTO		= Now()>
		</cfcase>
		<cfdefaultcase><!--- error --->
			<cfset dtFROM	= sync_from>
			<cfset dtTO		= Min(sync_to, DateAdd('h', 8, Now()))>
		</cfdefaultcase>
	</cfswitch>
	<cfquery datasource="#request.dsn#">
		UPDATE ebaccounts
		SET sync_status	= 'read',
			sync_from	= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dtFROM#">,
			sync_to		= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dtTO#">
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
	</cfquery>
	<cfset _ebay.CallName ="GetSellerEvents">
	<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
	<GetSellerEventsRequest xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<UserID>#_ebay.UserID#</UserID>
	<DetailLevel>ReturnAll</DetailLevel>
	<EndTimeFrom>#DateTimeToEBay(dtFROM)#</EndTimeFrom>
	<EndTimeTo>#DateTimeToEBay(DateAdd('d', 29, dtFROM))#</EndTimeTo>
	</GetSellerEventsRequest>'>
	<cfset _ebay.ThrowOnError = false>
	<cfinclude template="../../api/act_call.cfm">
	<cfif _ebay.Ack EQ "failure">
		<cfquery datasource="#request.dsn#">
			UPDATE ebaccounts
			SET sync_response = '#PreserveSingleQuotes(_ebay.response)#',
				sync_status = 'error'
			WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
		</cfquery>
		<cfoutput>Failed<br></cfoutput>
		<cfdump var="#_ebay.response#">
		<cfoutput><br></cfoutput>
	<cfelse>
		<cfquery datasource="#request.dsn#">
			UPDATE ebaccounts
			SET sync_response = '#PreserveSingleQuotes(_ebay.response)#',
				sync_status = 'parse'
			WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
		</cfquery>
	</cfif>
	<cfif _ebay.Ack NEQ "failure">
		<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.ItemArray.xmlChildren)#">
			<cfset Item = _ebay.xmlResponse.xmlRoot.ItemArray.xmlChildren[i]>
			<cfquery datasource="#request.dsn#" name="sqlItem">
				SELECT * FROM ebitems
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
			</cfquery>
			<cfquery datasource="#request.dsn#">
				<cfif sqlItem.RecordCount EQ 0>
					INSERT INTO ebitems
					(
						itemxml, itemid, ebayitem, dtwhen, status, dtstart, dtend, price, bidcount,
						<cfif StructKeyExists (Item.SellingStatus, "HighBidder")>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "UserID")>hbuserid,</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "Email")>hbemail,</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "FeedbackScore")>hbfeedbackscore,</cfif>
						</cfif>
						<cfif StructKeyExists(Item, "ReservePrice")>
							ReservePrice,
						</cfif>
						title
					)
					VALUES
					(
						'', '',
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">,
						GETDATE(),
						'parsed',
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.StartTime.xmlText)#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.EndTime.xmlText)#">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#Item.SellingStatus.CurrentPrice.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.BidCount.xmlText#">,
						<cfif StructKeyExists (Item.SellingStatus, "HighBidder")>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "UserID")>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.SellingStatus.HighBidder.UserID.xmlText#">,
							</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "Email")>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.SellingStatus.HighBidder.Email.xmlText#">,
							</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "FeedbackScore")>
								<cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.HighBidder.FeedbackScore.xmlText#">,
							</cfif>
						</cfif>
						<cfif StructKeyExists(Item, "ReservePrice")>
							'#Item.ReservePrice.xmlText#',
						</cfif>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.Title.xmlText#">
					)
				<cfelse>
					UPDATE ebitems
					SET dtwhen = GETDATE(),
						status = 'parsed',
						dtstart = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.StartTime.xmlText)#">,
						dtend = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.EndTime.xmlText)#">,
						price = <cfqueryparam cfsqltype="cf_sql_float" value="#Item.SellingStatus.CurrentPrice.xmlText#">,
						bidcount = <cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.BidCount.xmlText#">,
						<cfif StructKeyExists (Item.SellingStatus, "HighBidder")>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "UserID")>
								hbuserid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.SellingStatus.HighBidder.UserID.xmlText#">,
							</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "Email")>
								hbemail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.SellingStatus.HighBidder.Email.xmlText#">,
							</cfif>
							<cfif StructKeyExists (Item.SellingStatus.HighBidder, "FeedbackScore")>
								hbfeedbackscore = <cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.HighBidder.FeedbackScore.xmlText#">,
							</cfif>
						</cfif>
						<cfif StructKeyExists(Item, "ReservePrice")>
							ReservePrice = '#Item.ReservePrice.xmlText#',
						</cfif>
						title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.Title.xmlText#">
					WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
				</cfif>
			</cfquery>
			<cfif StructKeyExists(Item, "ReservePrice")>
				<cfquery datasource="#request.dsn#">
					UPDATE items
					SET startprice = '#Item.ReservePrice.xmlText#'
					WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
				</cfquery>
			</cfif>
		</cfloop>
		<cfquery datasource="#request.dsn#">
			UPDATE ebaccounts
			SET sync_status = 'done'
			WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#eBayAccount#">
		</cfquery>
		<cfoutput>Done (#ArrayLen(_ebay.xmlResponse.xmlRoot.ItemArray.xmlChildren)# items retrieved)<br></cfoutput>
	</cfif>
</cfloop>

<cfoutput><h1>SYNC finished at #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
