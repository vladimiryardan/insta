<cfoutput><h1>SEND ALERTS STARTED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
<!--- LISTER ALERT --->
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.item, i.lid, i.dpictured, i.title
	FROM items i
		INNER JOIN accounts a ON i.aid = a.id
	WHERE DATEDIFF(DAY, i.dpictured, GETDATE()) BETWEEN #_vars.Alert_Lister.Older_Than# AND #_vars.Alert_Lister.Newer_Than#
		AND a.business_client = 0
		AND a.invested = 0
		AND i.multiple = ''
		AND i.status = 3<!--- Item Received --->
	ORDER BY i.dpictured
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# items to be listed</h2></cfoutput>
<cfmail from="#_vars.mails.from#"
	to="#_vars.Alert_Lister.Emails#" 
	subject="Alert - #sqlList.RecordCount# items to be listed" type="html">
Pictured items that received between #_vars.Alert_Lister.Older_Than# and #_vars.Alert_Lister.Newer_Than# days ago<br>
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>ItemID</th>
	<th>Title</th>
	<th>LID</th>
	<th>Date Pictured</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#item#</td>
	<td>#title#</td>
	<td>#lid#</td>
	<td>#DateFormat(dpictured)#</td>
</tr></cfloop>
</table>
</cfmail>

<!--- PHOTOGRAPHER ALERT --->
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.item, i.lid, i.dreceived, i.title
	FROM items i
		INNER JOIN accounts a ON i.aid = a.id
	WHERE DATEDIFF(DAY, i.dreceived, GETDATE()) BETWEEN #_vars.Alert_Photographer.Older_Than# AND #_vars.Alert_Photographer.Newer_Than#
		AND a.business_client = 0
		AND a.invested = 0
		AND i.dpictured IS NULL
		AND i.multiple = ''
		AND i.status = 3<!--- Item Received --->
	ORDER BY i.dreceived
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# items to be pictured</h2></cfoutput>
<cfmail from="#_vars.mails.from#"
	to="#_vars.Alert_Photographer.Emails#" 
	subject="Alert - #sqlList.RecordCount# items to be pictured" type="html">
Items that received between #_vars.Alert_Photographer.Older_Than# and #_vars.Alert_Photographer.Newer_Than# days ago and not pictured<br>
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>ItemID</th>
	<th>Title</th>
	<th>LID</th>
	<th>Date Received</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#item#</td>
	<td>#title#</td>
	<td>#lid#</td>
	<td>#DateFormat(dreceived)#</td>
</tr></cfloop>
</table>
</cfmail>

<!--- NEW ACCOUNT ALERT --->
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT id, phone, [first], [last], dcreated
	FROM accounts
	WHERE DATEDIFF(DAY, dcreated, GETDATE()) > #_vars.Alert_Account.Older_Than#
		AND dcalled IS NULL
		AND dcreated >= '2006-01-01'
	ORDER BY dcreated
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# accounts to be called</h2></cfoutput>
<cfmail from="#_vars.mails.from#"
	to="#_vars.Alert_Account.Emails#" 
	subject="Alert - #sqlList.RecordCount# accounts to be called" type="html">
Accounts that created more than #_vars.Alert_Account.Older_Than# days ago and not called<br>
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>Account ID</th>
	<th>Name</th>
	<th>Phone</th>
	<th>Date Created</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#id#</td>
	<td>#first# #last#</td>
	<td>#phone#</td>
	<td>#DateFormat(dcreated)#</td>
</tr></cfloop>
</table>
</cfmail>

<!--- URGENT SHIPMENT ALERT --->
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.item, i.lid, i.dlid, i.paidtime
	FROM items i
		LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
		LEFT JOIN (SELECT DISTINCT itmItemID, byrCountry FROM ebtransactions) t ON i.ebayitem = t.itmItemID
	WHERE
		(
			(
				e.hbuserid NOT IN
				(
					SELECT e2.hbuserid
					FROM items i2
						LEFT JOIN ebitems e2 ON i2.ebayitem = e2.ebayitem
					WHERE e2.hbuserid IS NOT NULL
						AND i2.paid = '1'
						AND i2.shipped = '0'
						AND i2.ShippedTime IS NULL
					GROUP BY e2.hbuserid
					HAVING COUNT(i2.item) > 1
				)
			)
		)
		AND
		(
			(
				i.exception = 0
				AND i.paid = '1'
				AND i.shipped = '0'
				AND i.ShippedTime IS NULL
				AND i.drefund IS NULL
				AND
				(
					(i.PaidTime <= DATEADD(DAY, -7, GETDATE()) AND t.byrCountry = 'US')
					OR
					(i.PaidTime IS NOT NULL AND t.byrCountry != 'US')
				)
			)
			OR (i.exception = 1)
		)
	ORDER BY i.paidtime
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# items to be shipped</h2></cfoutput>
<cfmail from="#_vars.mails.from#"
	to="#_vars.Alert_Shipper.Emails#" 
	subject="Alert - #sqlList.RecordCount# items to be shipped" type="html">
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>ItemID</th>
	<th>LID</th>
	<th>DLID</th>
	<th>Date Paid</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#item#</td>
	<td>#lid#</td>
	<td>#strDate(dlid)#</td>
	<td>#strDate(paidtime)#</td>
</tr></cfloop>
</table>
</cfmail>

<!--- PayPal vs Awayting Payment errors ALERT --->
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.ebayitem, i.item, i.title, i.lid, i.dlid, MAX(t.PaidTime) AS pt
	FROM items i
		INNER JOIN ebtransactions t ON i.ebayitem = t.itmItemID
	WHERE i.status = 5<!--- Awayting Payment --->
		AND t.stsPaymentMethodUsed = 'PayPal'
		AND i.ebayitem NOT IN (SELECT itmItemID FROM ebtransactions WHERE LEN(extExternalTransactionID) > 0)
	GROUP BY i.ebayitem, i.item, i.title, i.lid, i.dlid
	ORDER BY 2
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# PayPal error items</h2></cfoutput>

<cfmail from="#_vars.mails.from#"
	to="#_vars.Alert_Errors.Emails#" 
	subject="Alert - #sqlList.RecordCount# PayPal error items" type="html">
Items with PayPal method of payment and Awayting Payment status<br>
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>ItemID</th>
	<th>AuctionID</th>
	<th>LID</th>
	<th>DLID</th>
	<th>Paid</th>
	<th>Title</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#item#</td>
	<td>#ebayitem#</td>
	<td>#lid#</td>
	<td>#strDate(dlid)#</td>
	<td>#strDate(pt)#</td>
	<td>#Left(title, 30)#</td>
</tr></cfloop>
</table>
</cfmail>


<!--- Expensive items that sold and not invoiced ALERT --->
<!---<cfset _vEmails = getVar('Alert_Expensive.emails', 'pkelley@instantauctions.net', 'STRING')>--->

<cfset _vEmails = #_vars.Alert_Expensive.emails#>
<cfset _vMin_Amount = getVar('Alert_Expensive.Min_Amount', '200', 'NUMBER')>
<cfset _vMin_Days = getVar('Alert_Expensive.Min_Days', '10', 'NUMBER')>
<cfquery name="sqlList" datasource="#request.dsn#">
	SELECT i.ebayitem, i.item, i.title, i.lid, i.dlid, e.price, a.ReservePrice
	FROM items i
		INNER JOIN accounts ac ON i.aid = ac.id
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		LEFT JOIN auctions a ON i.item = a.itemid
	WHERE (i.status = 5 OR i.status = 7 OR i.status = 10 OR i.status = 11)
		AND i.invoicenum IS NULL
		AND e.price > #_vMin_Amount#
		AND DATEDIFF(DAY, e.dtend, GETDATE()) > #_vMin_Days#
		AND (e.price > a.ReservePrice OR a.ReservePrice = 0 OR a.ReservePrice IS NULL)
		AND ac.business_client = 0
	ORDER BY 2
</cfquery>
<cfoutput><h2>Alert - #sqlList.RecordCount# expensive items</h2></cfoutput>

<cfmail from="#_vars.mails.from#"
	to="#_vEmails#" subject="Alert - #sqlList.RecordCount# expensive items" type="html">
Items that sold more than #DollarFormat(_vMin_Amount)# and paid than #_vMin_Days# days ago but not <br>
<table cellpadding="5" cellspacing="0" border="1">
<tr>
	<th>ItemID</th>
	<th>AuctionID</th>
	<th>LID</th>
	<th>DLID</th>
	<th>Final Price</th>
	<th>Reserve Price</th>
</tr><cfloop query="sqlList">
<tr>
	<td>#item#</td>
	<td>#ebayitem#</td>
	<td>#lid#</td>
	<td>#strDate(dlid)#</td>
	<td><cfif isNumeric(ReservePrice)>#DollarFormat(price)#<cfelse>N/A</cfif></td>
	<td><cfif isNumeric(ReservePrice)>#DollarFormat(ReservePrice)#<cfelse>N/A</cfif></td>
</tr></cfloop>
</table>
</cfmail>



<!--- alert duplicate fixed auction STARTS--->
<cfset sendDupAlert = 0>
<cfset itemids =  ArrayNew(1) >

<cfquery name="rs_dup" datasource="#request.dsn#">
	SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice,
	i.internal_itemSKU, a.listingtype
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN auctions a ON i.item = a.itemid
	WHERE i.status = 4<!--- Auction Listed --->
		  and a.listingtype =  '1' <!--- display only fixed price items --->
		  and (i.lid != 'P&S' or i.lid is null) <!--- don't display paid and shipped --->
		   and i.internal_itemSKU != '' <!---don't display paid and shipped --->
	ORDER BY i.internal_itemSKU DESC
</cfquery>


<cfoutput query="rs_dup">
		<!--- items count base on sku and item condition--->
		<cfquery name="rs_skuCondFixedPriceItem" datasource="#request.dsn#">
			SELECT     i.item AS itemid, i.ebayitem,  i.listcount,  i.internal_itemSKU, i.internal_itemCondition, i.status
			FROM         dbo.items i
			INNER JOIN auctions a ON i.item = a.itemid
			WHERE  i.status = 4 <!--- Auction Listed --->
				and (i.lid != 'P&S' or i.lid is null) <!--- don't display paid and shipped --->
				and a.listingtype =  '1' <!---only fixed price items --->
			and i.internal_itemSKU = '#rs_dup.internal_itemSKU#'
		</cfquery>

<!--- some duplicate found then append to array --->
<cfif rs_skuCondFixedPriceItem.RecordCount gt 1>
<cfset sendDupAlert = 1>
<cfloop query="rs_skuCondFixedPriceItem">
	<cfif rs_dup.itemid eq rs_skuCondFixedPriceItem.itemid>
		<!--- we don't need to show the other itemid --->
	<cfelse>
		<cfset #ArrayAppend(itemids, "#rs_skuCondFixedPriceItem.itemid#")#>
	</cfif>
</cfloop>
</cfif>
</cfoutput>

<!--- there is duplicate item then let send an alert --->
<cfif sendDupAlert>
<!--- present in comma separated --->
<cfset itemid_list = ArrayToList(itemids, ",")>

	<cfmail	
	from="#_vars.mails.from#"
	to="#_vEmails#"
	cc="vladimiryardan@gmail.com"
	subject="Alert - #arrayLen(itemids)# duplicate FIXED items" type="html">

	The duplicate items are:<br><br>
	#itemid_list#

	</cfmail>

</cfif>



<!--- QTY of "1" in the AMZ --->
<cfinclude template="st_alertAmazonQty.cfm" >


	
