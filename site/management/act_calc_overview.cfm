<cfscript>
yesterday = DateAdd("d", -1, Now());
yesterday = CreateDate(Year(yesterday), Month(yesterday), Day(yesterday));
byStore = StructNew();
for(i=1;i LTE 3; i=i+1){
	byStore["_#i#01"] = StructNew();
	byStore["_#i#01"].salesYesterday = 0;
	byStore["_#i#01"].salesLastWeek = 0;
	byStore["_#i#01"].salesThisMonth = 0;
	byStore["_#i#01"].paidThisMonth = 0;
}
</cfscript>

<cfquery name="sqlRecords" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, dended, 101) AS dt, LEFT(itemid,3) AS store, SUM(checkamount) AS amountpaid, SUM(finalprice) AS sales
	FROM records
	WHERE DATEADD(MONTH, -1, GETDATE()) <= dended
<!---
		AND highbidder != ''
		AND highbidder != 'No%20Bids%20Yet'
		AND highbidder != 'Did%20Not%20Sell'
		AND highbidder IS NOT NULL
--->
		AND highbidder LIKE '%href%'
	GROUP BY CONVERT(VARCHAR, dended, 101), LEFT(itemid,3)
	ORDER BY CONVERT(VARCHAR, dended, 101), LEFT(itemid,3)
</cfquery>
<cfset paidYesterday = 0>
<cfset paidLastWeek = 0>
<cfset paidThisMonth = 0>
<cfset salesYesterday = 0>
<cfset salesLastWeek = 0>
<cfset salesThisMonth = 0>
<cfloop query="sqlRecords">
	<cfif NOT StructKeyExists(byStore, "_#store#")>
		<cfset byStore["_#store#"] = StructNew()>
		<cfset byStore["_#store#"].salesYesterday = 0>
		<cfset byStore["_#store#"].salesLastWeek = 0>
		<cfset byStore["_#store#"].salesThisMonth = 0>
		<cfset byStore["_#store#"].paidThisMonth = 0>
	</cfif>
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset paidYesterday = paidYesterday + amountpaid>
		<cfset salesYesterday = salesYesterday + sales>
		<cfset byStore["_#store#"].salesYesterday = byStore["_#store#"].salesYesterday + sales>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset paidLastWeek = paidLastWeek + amountpaid>
		<cfset salesLastWeek = salesLastWeek + sales>
		<cfset byStore["_#store#"].salesLastWeek = byStore["_#store#"].salesLastWeek + sales>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset paidThisMonth = paidThisMonth + amountpaid>
		<cfset salesThisMonth = salesThisMonth + sales>
		<cfset byStore["_#store#"].paidThisMonth = byStore["_#store#"].paidThisMonth + sales>
		<cfset byStore["_#store#"].salesThisMonth = byStore["_#store#"].salesThisMonth + sales>
	</cfif>
</cfloop>

<cfquery name="sqlCurrentListings" datasource="#request.dsn#">
	SELECT COUNT(*) AS cnt
	FROM items
	WHERE status = 4<!--- Auction Listed --->
</cfquery>

<cfquery name="sqlAcitve" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, e.dtstart, 101) AS dt, COUNT(i.item) AS cnt
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
	WHERE i.status = 4<!--- Auction Listed --->
		AND DATEADD(MONTH, -1, GETDATE()) <= e.dtstart
	GROUP BY CONVERT(VARCHAR, e.dtstart, 101)
	ORDER BY CONVERT(VARCHAR, e.dtstart, 101)
</cfquery>

<cfset cntYesterday = 0>
<cfset cntLastWeek = 0>
<cfset cntThisMonth = 0>
<cfloop query="sqlAcitve">
	<cfif dt EQ yesterday>
		<cfset cntYesterday = cntYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dt, Now()) LTE 7>
		<cfset cntLastWeek = cntLastWeek + cnt>
	</cfif>
	<cfif (Month(dt) EQ Month(Now())) AND (Year(dt) EQ Year(Now()))>
		<cfset cntThisMonth = cntThisMonth + cnt>
	</cfif>
</cfloop>

<!--- ITEMS CREATED --->
<cfquery name="sqlCreated" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, dcreated, 101) AS dt, COUNT(*) AS cnt
	FROM items
	WHERE DATEADD(MONTH, -1, GETDATE()) <= dcreated
		AND status = 2<!--- ITEMS CREATED --->
	GROUP BY CONVERT(VARCHAR, dcreated, 101)
	ORDER BY CONVERT(VARCHAR, dcreated, 101)
</cfquery>

<cfset createdYesterday = 0>
<cfset createdLastWeek = 0>
<cfset createdThisMonth = 0>
<cfloop query="sqlCreated">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset createdYesterday = createdYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset createdLastWeek = createdLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset createdThisMonth = createdThisMonth + cnt>
	</cfif>
</cfloop>

<!--- ITEMS RECEIVED --->
<cfquery name="sqlReceived" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, dcreated, 101) AS dt, COUNT(*) AS cnt
	FROM items
	WHERE DATEADD(MONTH, -1, GETDATE()) <= dcreated
		AND status = 3<!--- ITEMS RECEIVED --->
	GROUP BY CONVERT(VARCHAR, dcreated, 101)
	ORDER BY CONVERT(VARCHAR, dcreated, 101)
</cfquery>

<cfset receivedYesterday = 0>
<cfset receivedLastWeek = 0>
<cfset receivedThisMonth = 0>
<cfloop query="sqlReceived">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset receivedYesterday = receivedYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset receivedLastWeek = receivedLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset receivedThisMonth = receivedThisMonth + cnt>
	</cfif>
</cfloop>

<!--- AWAITING SHIPMENT --->
<cfquery name="sqlAwaitShip" datasource="#request.dsn#">
	SELECT COUNT(*) AS cnt
	FROM items
	WHERE paid = '1'
		AND shipped = '0'
		AND ShippedTime IS NULL
		AND PaidTime IS NOT NULL
</cfquery>

<!--- AWAITING PAYMENT --->
<cfquery name="sqlAwaitPay" datasource="#request.dsn#">
	SELECT COUNT(*) AS cnt
	FROM items
	WHERE status = '5'
		AND paid = '0'
		AND shipped = '0'
</cfquery>

<!--- SHIPPED --->
<cfquery name="sqlShipped" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, ShippedTime, 101) AS dt, COUNT(*) AS cnt
	FROM items
	WHERE DATEADD(MONTH, -1, GETDATE()) <= ShippedTime
	GROUP BY CONVERT(VARCHAR, ShippedTime, 101)
	ORDER BY CONVERT(VARCHAR, ShippedTime, 101)
</cfquery>

<cfset shipYesterday = 0>
<cfset shipLastWeek = 0>
<cfset shipThisMonth = 0>
<cfloop query="sqlShipped">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset shipYesterday = shipYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset shipLastWeek = shipLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset shipThisMonth = shipThisMonth + cnt>
	</cfif>
</cfloop>

<!--- CHECKS TO BE WRITTEN --->
<cfquery name="sqlChecksToBeWritten" datasource="#request.dsn#">
	SELECT a.id, COUNT(*) AS cnt
	FROM items i
		INNER JOIN records r ON i.item = r.itemid
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.invoicenum IS NULL
		AND
		(
			i.offebay = '1'
			OR (
<!---
			r.highbidder !=''
			AND r.highbidder !='No%20Bids%20Yet'
			AND r.highbidder !='Did%20Not%20Sell'
			AND r.highbidder IS NOT NULL
--->
			r.highbidder LIKE '%href%'
			AND r.dended < DATEADD(DAY, -10, GETDATE())
			AND r.finalprice > 0
			AND r.finalprice >= i.startprice
			)
		)
	GROUP BY a.id
</cfquery>

<!--- ERRORS --->
<cfquery name="sqlErrors1" datasource="#request.dsn#">
	SELECT DISTINCT e.ebayitem, e.itemid, i.ebayitem AS curenum
	FROM ebitems e
		INNER JOIN items i ON e.itemid = i.item
		LEFT JOIN ebitems o ON i.ebayitem = o.ebayitem
	WHERE i.ebayitem IS NOT NULL
		AND ((e.dtend > o.dtend) OR ((o.dtend IS NULL) AND (e.dtend IS NOT NULL)))
		AND i.status != '9'<!--- RETURNED TO CLIENT --->
		AND e.itemid != ''
		AND e.ebayitem != o.ebayitem
</cfquery>
<cfquery name="sqlErrors2" datasource="#request.dsn#">
	SELECT COUNT(*) AS cnt
	FROM ebitems
	WHERE itemid = ''
		AND itemxml NOT LIKE ''
</cfquery>
<cfset cntSynchErrors = sqlErrors1.RecordCount + sqlErrors2.cnt>

<!--- TROUBLE TICKETS --->
<cfquery name="sqlTroubleTickets" datasource="#request.dsn#">
	SELECT COUNT(*) AS cnt
	FROM ts_ticket
	WHERE status < 3
		AND uid_assigned = 2<!--- only assigned to "ia" --->
</cfquery>

<cfscript>
	overview = StructNew();
	overview.calculatedOn			= Now();
	overview.salesYesterday 		= salesYesterday;
	overview.salesLastWeek			= salesLastWeek;
	overview.salesThisMonth			= salesThisMonth;
	overview.paidThisMonth			= paidThisMonth;
	overview.cntCurrentListings		= sqlCurrentListings.cnt;
	overview.cntYesterday			= cntYesterday;
	overview.cntLastWeek			= cntLastWeek;
	overview.cntThisMonth			= cntThisMonth;
	overview.cntAwaitShip			= sqlAwaitShip.cnt;
	overview.cntAwaitPay			= sqlAwaitPay.cnt;
	overview.shipYesterday			= shipYesterday;
	overview.shipLastWeek			= shipLastWeek;
	overview.shipThisMonth			= shipThisMonth;
	overview.cntChecksToBeWritten	= sqlChecksToBeWritten.RecordCount;
	overview.cntSynchErrors			= cntSynchErrors;
	overview.cntTroubleTickets		= sqlTroubleTickets.cnt;
	overview.createdYesterday		= createdYesterday;
	overview.createdLastWeek		= createdLastWeek;
	overview.createdThisMonth		= createdThisMonth;
	overview.receivedYesterday		= receivedYesterday;
	overview.receivedLastWeek		= receivedLastWeek;
	overview.receivedThisMonth		= receivedThisMonth;
	overview.byStore				= byStore;
</cfscript>

<cflock scope="application" timeout="10" type="exclusive">
	<cfset application.overview = Duplicate(overview)>
</cflock>
