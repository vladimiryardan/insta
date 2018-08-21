<cfoutput><h2>Fix Missed Items started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
<cfquery datasource="#request.dsn#" name="sqlItems">
	SELECT e.id, i.item
	FROM ebitems e
		LEFT JOIN items i ON e.ebayitem = i.ebayitem
	WHERE e.itemid = ''
		AND i.item IS NOT NULL
</cfquery>
<cfoutput><h3>Update ebITEMS that were lookup manually (#sqlItems.RecordCount#: total)</h3></cfoutput>
<cfloop query="sqlItems">
	<cfquery datasource="#request.dsn#">
		UPDATE ebitems
		SET itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlItems.item#">
		WHERE id = <cfqueryparam cfsqltype="cf_sql_int" value="#sqlItems.id#">
	</cfquery>
</cfloop>
<cfset maxFix = 200><!--- maximum items to fix per once --->
<cfquery datasource="#request.dsn#" name="sqlMissed" maxrows="#maxFix#">
	SELECT ebayitem
	FROM ebitems
	WHERE itemid = ''
	ORDER BY dtend DESC
</cfquery>
<cfoutput>
<h3>Process rest of ebITEMS (#sqlMissed.RecordCount# record process, #maxFix# maximum processed per once). RequestToke: #_ebay.UserName# - #_ebay.Password# </h3>
<ul>
</cfoutput>
<cfloop query="sqlMissed">
	<cfset _ebay.CallName ="GetItem">
	<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
	<GetItemRequest xmlns="urn:ebay:apis:eBLBaseComponents">
		<RequesterCredentials>
			<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
		</RequesterCredentials>
		<ItemID>#sqlMissed.ebayitem#</ItemID>
		<DetailLevel>ItemReturnDescription</DetailLevel>
	</GetItemRequest>'>
	<cfset _ebay.ThrowOnError = false>
	<cfinclude template="../../api/act_call.cfm">
	<cfif _ebay.Ack EQ "failure">
		<cfoutput><li style="color:red;">Error while retrieving auction #sqlMissed.ebayitem#. Detail: #err_detail#</li></cfoutput>
		
		
			<cfset FoundWord = #FindNoCase("This item cannot be accessed because the listing has been deleted", err_detail)# >
			
			<!--- vlad added this coz there are error in the schedule call. Date: 20101122 --->		
			<cfif #FoundWord# >			
					<cfquery datasource="#request.dsn#" name="delErrorItems" maxrows="#maxFix#">
						delete from ebitems
						where ebayitem = '#sqlMissed.ebayitem#'
					</cfquery>
				<cfoutput>	<li style="color:red;">Deleting from ebitems TABLE: ebayitem = #sqlMissed.ebayitem#. Reason: "This item cannot be accessed because the listing has been deleted" (API CALL RESPONSE).</li></cfoutput>
			</cfif>
	<cfelse>
		<cfset sItem = "">
		<cfset Item = _ebay.xmlResponse.xmlRoot.Item>
		<cfif StructKeyExists (Item, "SKU") AND (ListLen(Item.SKU.xmlText, ".") EQ 3)>
			<cfset sItem = Item.SKU.xmlText>
		<cfelseif StructKeyExists (Item, "Description")>
			<cfset sDescription = Item.Description.xmlText>
			<cfset aLenPos = REFindNoCase(">[ ]*[0-9]*\.[0-9]*\.[0-9]*[ ]*<", sDescription, 1, true)>
			<cfif aLenPos.len[1] GT 0>
				<cfset sFinding = Trim(mid(sDescription, aLenPos.pos[1], aLenPos.len[1]))>
				<cfset sItem = mid(sFinding, 2, Len(sFinding)-2)>
			<cfelse>
				<!--- <font size=1>201.2405.17-AW</font> --->
				<cfset aLenPos = REFindNoCase("<font size=1>[ ]*[0-9]*\.[0-9]*\.[0-9]*[ ]*-..</font>", sDescription, 1, true)>
				<cfif aLenPos.len[1] GT 0>
					<cfset sFinding = Trim(mid(sDescription, aLenPos.pos[1], aLenPos.len[1]))>
					<cfset sItem = mid(sFinding, 14, Len(sFinding)-23)>
				</cfif>
			</cfif>
		</cfif>
		<cfquery datasource="#request.dsn#">
			UPDATE ebitems
			SET itemxml = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#ToString(Item)#">,
				dtstart = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.StartTime.xmlText)#">,
				dtend = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Item.ListingDetails.EndTime.xmlText)#">,
				
				<!--- vlad adds this to fix the problem of final price in fixedpriceitem.
				date added: 20101016
				--->				
				price = <cfqueryparam cfsqltype="cf_sql_float" value="#Item.SellingStatus.CurrentPrice.xmlText#">,
				
				
				bidcount = <cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.BidCount.xmlText#">,
				<cfif ListLen(sItem, ".") EQ 3>
					itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sItem#">,
				</cfif>
				<cfif StructKeyExists (Item.SellingStatus, "HighBidder")>
					<cfif StructKeyExists (Item.SellingStatus.HighBidder, "UserID")>
						hbuserid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.SellingStatus.HighBidder.UserID.xmlText#">,
					</cfif>
					<cfif StructKeyExists (Item.SellingStatus.HighBidder, "FeedbackScore")>
						hbfeedbackscore = <cfqueryparam cfsqltype="cf_sql_integer" value="#Item.SellingStatus.HighBidder.FeedbackScore.xmlText#">,
					</cfif>
				</cfif>
				title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Item.Title.xmlText#">,
				dtwhen = GETDATE(),
				status = 'parsed'
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
		</cfquery>
		<cfoutput><li>Auction {#Item.ItemID.xmlText#} lookup with {#sItem#} item</li></cfoutput>
	</cfif>
	

<!---<cfoutput><li>Item.ListingType = #Item.ListingType.xmlText#<br></li></cfoutput>--->
	
	
</cfloop>

<cfoutput>
</ul>
<h2>Fix Missed Items finished at #DateFormat(Now())# #TimeFormat(Now())#</h2>
</cfoutput>
