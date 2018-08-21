<cfloop index="i" list="#attributes.items#">




	<cfset attributes.itemid = i>
	<cfquery name="sqlGetItem" datasource="#request.dsn#" maxrows="1">
		SELECT i.ebayitem, t.TransactionID, i.parentEbayItemFixed, i.ebayTxnid,i.offebay
		FROM items i
			INNER JOIN accounts a ON a.id = i.aid
			INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
			LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
		WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
			AND (
				( t.stsCompleteStatus = 'Complete'
				AND t.stsCheckoutStatus = 'CheckoutComplete'
				AND t.stseBayPaymentStatus = 'NoPaymentFailure'
				)
				OR t.stsPaymentMethodUsed != 'PayPal'
			)
		ORDER BY t.tid DESC
	</cfquery>





<!--- 20120613
	lets get the combined transactionid and ebayitem for fixed price
	sqlGetItem.ebayitem = items.parentEbayItemFixed
	sqlGetItem.TransactionID = items.ebayTxnid
--->

<!--- 20120613 changes by vlad to fix sending tracking in combined --->
<!--- if its combined use this info --->
	<cfset attributes.ebayitem = sqlGetItem.ebayitem>
	<cfset attributes.TransactionID = sqlGetItem.TransactionID>
	<!--- if its fix price and combined "OVERRIDE"  --->
	<cfquery name="chkTheListingType1" datasource="#request.dsn#">
		select offebay, parentEbayItemFixed, ebayTxnid from items
		where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfif chkTheListingType1.offebay is "2">
		<cfset attributes.ebayitem = chkTheListingType1.parentEbayItemFixed>
		<cfset attributes.TransactionID = chkTheListingType1.ebayTxnid>
	</cfif>

<!---debugging code
[chkTheListingType1.offebay: [#chkTheListingType1.offebay#]]<br>
[sqlGetItem.offebay: #sqlGetItem.offebay#]<br>
[attributes.itemid: #attributes.itemid#]<br>
[attributes.ebayitem: #attributes.ebayitem#]<br>
[attributes.TransactionID: #attributes.TransactionID#]<br>
--->









	<cfinclude template="act_complete_sale.cfm">
</cfloop>
