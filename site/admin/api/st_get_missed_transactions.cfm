<cfoutput><h2>get_missed_transactions started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>

<cftry>
	<cfquery datasource="#request.dsn#" name="sqlItems">
		SELECT i.item, i.ebayitem, i.status, e.dtend, i.ShippedTime
		FROM items i
			INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
			LEFT JOIN ebtransactions t ON i.ebayitem = t.itmItemID
		WHERE t.itmItemID IS NULL
			AND i.offebay = '0'
			AND i.status IN(5,10)<!--- Awaiting Payment, Awaiting Shipment --->
			AND e.dtend BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()<!--- Auction ended within last 30 days --->
			AND e.price >= e.ReservePrice<!--- reserve met --->
			AND LEN(e.hbuserid) > 0<!--- has high bidder --->
	</cfquery>
	<cfoutput>#sqlItems.RecordCount# items has no transactions:<br></cfoutput>
	<cfloop query="sqlItems">
		<cfset attributes.ebayitem = sqlItems.ebayitem>
		<cfoutput>Get transactions for #sqlItems.ebayitem# (status #sqlItems.status#)<br></cfoutput>
		<cfinclude template="act_get_item_transaction.cfm">
		<cfquery datasource="#request.dsn#" name="sqlTransactions">
			SELECT MAX(PaidTime) AS paid, MAX(ShippedTime) AS shipped
			FROM ebtransactions
			WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
		</cfquery>
		<cfscript>
			if(isDate(sqlTransactions.shipped)){
				fChangeStatus (sqlItems.item, 11); // PAID AND SHIPPED
			}else if(isDate(sqlTransactions.paid)){
				fChangeStatus (sqlItems.item, 10); // AWAITING SHIPMENT
			}else{
				fChangeStatus (sqlItems.item, 5); // AWAITING PAYMENT
			}
		</cfscript>
	</cfloop>

	<cfcatch type="any">
		<!--- do nothing --->
	</cfcatch>
</cftry>

<cfoutput><h2>get_missed_transactions finished at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>
