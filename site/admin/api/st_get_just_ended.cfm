<cfoutput><h2>get_just_ended started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>



<cfscript>
	bLoop		= true;
	endFrom		= _vars.system.schtask_lastrun;
	endTo		= Now();
	curpage		= 1;
</cfscript>


<cfloop condition="#bLoop#">
	<cfset _ebay.CallName ="GetSellerList">
	<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
	<GetSellerListRequest xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<UserID>#_ebay.UserID#</UserID>
	<DetailLevel>ReturnAll</DetailLevel>

<EndTimeFrom>#DateTimeToEBay(endFrom)#</EndTimeFrom>
<EndTimeTo>#DateTimeToEBay(endTo)#</EndTimeTo>

	<Pagination>
		<EntriesPerPage>10</EntriesPerPage>
		<PageNumber>#curpage#</PageNumber>
	</Pagination>
	</GetSellerListRequest>'>
	<!---<cfoutput>
		<pre>
<EndTimeFrom>#DateTimeToEBay(endFrom)#</EndTimeFrom><br>
<EndTimeTo>#DateTimeToEBay(endTo)#</EndTimeTo>


	<EndTimeFrom>2011-12-16 12:00:01</EndTimeFrom>
	<EndTimeTo>2011-12-16 23:59:59</EndTimeTo>

<EntriesPerPage>10</EntriesPerPage>
</pre>

	</cfoutput>--->
	<cfset _ebay.ThrowOnError = false>
	<cfinclude template="../../api/act_call.cfm">
	<cfif _ebay.Ack EQ "failure">
		<cfoutput>#_ebay.Ack# Call Failure</cfoutput>
		<cfdump var="#_ebay.response#">
		<cfbreak><!--- do nothing --->
	</cfif>

	<cfloop index="i" from="1" to="#_ebay.xmlResponse.xmlRoot.ReturnedItemCountActual.xmlText#">
		<cfset Item = _ebay.xmlResponse.xmlRoot.ItemArray.xmlChildren[i]>

		<cfoutput>Auction #Item.ItemID.xmlText# is ended<br></cfoutput>
		<cfquery datasource="#request.dsn#" name="sqlItem">
			SELECT * FROM ebitems
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
		</cfquery>
		<cfquery datasource="#request.dsn#">
			<cfif sqlItem.RecordCount EQ 0>
				INSERT INTO ebitems
				(ebayitem, itemxml, <cfif StructKeyExists(Item, "ReservePrice")>ReservePrice, </cfif>dtwhen, status)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#ToString(Item)#">,
					<cfif StructKeyExists(Item, "ReservePrice")>
						'#Item.ReservePrice.xmlText#',
					</cfif>
					GETDATE(),
					'new'
				)
			<cfelse>
				UPDATE ebitems
				SET itemxml = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#ToString(Item)#">,
					<cfif StructKeyExists(Item, "ReservePrice")>
						ReservePrice = '#Item.ReservePrice.xmlText#',
					</cfif>
					dtwhen = GETDATE(),
					status = 'new'
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
			</cfif>
		</cfquery>
		<cfif StructKeyExists(Item, "ReservePrice")>
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET startprice = '#Item.ReservePrice.xmlText#'
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Item.ItemID.xmlText#">
			</cfquery>
			<cfoutput>startprice = '#Item.ReservePrice.xmlText#' for #Item.ItemID.xmlText#<br></cfoutput>
		</cfif>
	</cfloop>
	<cfif StructKeyExists (_ebay.xmlResponse.xmlRoot, "HasMoreItems") AND _ebay.xmlResponse.xmlRoot.HasMoreItems.xmlText>
		<cfset curpage = curpage + 1>
	<cfelse>
		<cfset bLoop = false>
	</cfif>
</cfloop>
<cftry>
	<cfcatch type="any">
		<!--- do nothing --->
	</cfcatch>
</cftry>

<cfoutput><h2>get_just_ended finished at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
