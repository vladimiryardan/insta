<cfset yesterday = DateAdd("d", -1, Now())>
<cfset yesterday = CreateDate(Year(yesterday), Month(yesterday), Day(yesterday))>
<cfset byStore = StructNew()>
<cfloop query="store_list">
	<cfset byStore["_#store_list.store#"] = StructNew()>
	<cfset byStore["_#store_list.store#"].calculatedOn = Now()>
	<cfset byStore["_#store_list.store#"].salesYesterday = 0>
	<cfset byStore["_#store_list.store#"].salesLastWeek = 0>
	<cfset byStore["_#store_list.store#"].salesThisMonth = 0>
	<cfset byStore["_#store_list.store#"].createdYesterday = 0>
	<cfset byStore["_#store_list.store#"].createdLastWeek = 0>
	<cfset byStore["_#store_list.store#"].createdThisMonth = 0>
	<cfset byStore["_#store_list.store#"].receivedYesterday = 0>
	<cfset byStore["_#store_list.store#"].receivedLastWeek = 0>
	<cfset byStore["_#store_list.store#"].receivedThisMonth = 0>
	<cfset byStore["_#store_list.store#"].soldYesterday = 0>
	<cfset byStore["_#store_list.store#"].soldLastWeek = 0>
	<cfset byStore["_#store_list.store#"].soldThisMonth = 0>
	<cfset byStore["_#store_list.store#"].soldSumYesterday = 0>
	<cfset byStore["_#store_list.store#"].soldSumLastWeek = 0>
	<cfset byStore["_#store_list.store#"].soldSumThisMonth = 0>
	<cfset byStore["_#store_list.store#"].awaitingPayment = 0>
	<cfset byStore["_#store_list.store#"].awaitingShipment = 0>
	<cfset byStore["_#store_list.store#"].UrgentShipment = 0>
	<cfset byStore["_#store_list.store#"].NeedToReFund = 0>
	<cfset byStore["_#store_list.store#"].pain_and_shippedYesterday= 0>
	<cfset byStore["_#store_list.store#"].pain_and_shippedLastWeek = 0>
	<cfset byStore["_#store_list.store#"].pain_and_shippedThisMonth = 0>
	<cfset byStore["_#store_list.store#"].unsoldYesterday = 0>
	<cfset byStore["_#store_list.store#"].unsoldLastWeek = 0>
	<cfset byStore["_#store_list.store#"].unsoldThisMonth = 0>
	<cfset byStore["_#store_list.store#"].needReturn = 0>
</cfloop>

<!-- SALES -->
<cfquery name="sqlRecords" datasource="#request.dsn#">
	SELECT CONVERT(VARCHAR, dended, 101) AS dt, LEFT(itemid,3) AS store, SUM(finalprice) AS sales
	FROM records
	WHERE DATEADD(MONTH, -1, GETDATE()) <= dended
		AND highbidder != ''
		AND highbidder != 'No%20Bids%20Yet'
		AND highbidder != 'Did%20Not%20Sell'
		AND highbidder IS NOT NULL
	GROUP BY CONVERT(VARCHAR, dended, 101), store
	ORDER BY CONVERT(VARCHAR, dended, 101), store
</cfquery>

<cfset salesYesterday = 0>
<cfset salesLastWeek = 0>
<cfset salesThisMonth = 0>
<cfloop query="sqlRecords">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset salesYesterday = salesYesterday + sales>
		<cfset byStore["_#store#"].salesYesterday = byStore["_#store#"].salesYesterday + sales>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset salesLastWeek = salesLastWeek + sales>
		<cfset byStore["_#store#"].salesLastWeek = byStore["_#store#"].salesLastWeek + sales>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset salesThisMonth = salesThisMonth + sales>
		<cfset byStore["_#store#"].salesThisMonth = byStore["_#store#"].salesThisMonth + sales>
	</cfif>
</cfloop>

<!--- ITEMS CREATED --->
<cfquery name="sqlCreated" datasource="#request.dsn#">
	SELECT a.store, CONVERT(VARCHAR, i.dcreated, 101) AS dt, COUNT(*) AS cnt
	FROM items i 
	INNER JOIN accounts a ON i.aid = a.id
	WHERE DATEADD(MONTH, -1, GETDATE()) <= i.dcreated
		AND status = 2
	GROUP BY CONVERT(VARCHAR, i.dcreated, 101)
	ORDER BY CONVERT(VARCHAR, i.dcreated, 101)
</cfquery>

<cfset createdYesterday = 0>
<cfset createdLastWeek = 0>
<cfset createdThisMonth = 0>
<cfloop query="sqlCreated">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset createdYesterday = createdYesterday + cnt>
		<cfset byStore["_#store#"].createdYesterday = byStore["_#store#"].createdYesterday + cnt>		
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset createdLastWeek = createdLastWeek + cnt>
		<cfset byStore["_#store#"].createdLastWeek = byStore["_#store#"].createdLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset createdThisMonth = createdThisMonth + cnt>
		<cfset byStore["_#store#"].createdThisMonth = byStore["_#store#"].createdThisMonth + cnt>
	</cfif>
</cfloop>

<!--- ITEMS RECEIVED --->
<cfquery name="sqlReceived" datasource="#request.dsn#">
	SELECT a.store, CONVERT(VARCHAR, i.dcreated, 101) AS dt, COUNT(*) AS cnt
	FROM items i
	INNER JOIN accounts a ON i.aid = a.id	
	WHERE DATEADD(MONTH, -1, GETDATE()) <= i.dcreated
		AND status = 3
	GROUP BY CONVERT(VARCHAR, i.dcreated, 101)
	ORDER BY CONVERT(VARCHAR, i.dcreated, 101)
</cfquery>

<cfset receivedYesterday = 0>
<cfset receivedLastWeek = 0>
<cfset receivedThisMonth = 0>
<cfloop query="sqlReceived">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset receivedYesterday = receivedYesterday + cnt>
		<cfset byStore["_#store#"].receivedYesterday = byStore["_#store#"].receivedYesterday + cnt>		
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset receivedLastWeek = receivedLastWeek + cnt>
		<cfset byStore["_#store#"].receivedLastWeek = byStore["_#store#"].receivedLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset receivedThisMonth = receivedThisMonth + cnt>
		<cfset byStore["_#store#"].receivedThisMonth = byStore["_#store#"].receivedThisMonth + cnt>		
	</cfif>
</cfloop>


<!--- ITEMS Sold --->
<cfset soldYesterday = 0>
<cfset soldLastWeek = 0>
<cfset soldThisMonth = 0>
<cfset soldSumYesterday = 0>
<cfset soldSumLastWeek = 0>
<cfset soldSumThisMonth = 0>

<cfquery name="sqlSold" datasource="#request.dsn#">
	SELECT eb.price, a.store, e.dended AS dt,  COUNT(*) AS cnt
	FROM items_ended e
		INNER JOIN items i ON e.itemid = i.item
		INNER JOIN accounts a ON i.aid = a.id
		INNER JOIN ebitems eb ON eb.ebayitem = i.ebayitem
	WHERE e.dended IS NOT NULL
	GROUP BY eb.price, a.store, e.dended
</cfquery>
<cfloop query="sqlSold">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset soldYesterday = soldYesterday + cnt>
		<cfset byStore["_#store#"].soldYesterday = byStore["_#store#"].soldYesterday + cnt>
		<cfset soldSumYesterday = soldSumYesterday + price>
		<cfset byStore["_#store#"].soldSumYesterday = byStore["_#store#"].soldSumYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset soldLastWeek = soldLastWeek + cnt>
		<cfset byStore["_#store#"].soldLastWeek = byStore["_#store#"].soldLastWeek + cnt>
		<cfset soldSumLastWeek = soldSumLastWeek + price>
		<cfset byStore["_#store#"].soldSumYesterday = byStore["_#store#"].soldSumYesterday + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset soldSumThisMonth = soldSumThisMonth + cnt>
		<cfset byStore["_#store#"].soldSumThisMonth = byStore["_#store#"].soldSumThisMonth + cnt>		
		<cfset soldSumYesterday = soldSumYesterday + price>
		<cfset byStore["_#store#"].soldSumYesterday = byStore["_#store#"].soldSumYesterday + cnt>
	</cfif>
</cfloop>


<!-- Awaiting Payment -->
<cfset awaitingPayment = 0>
<cfquery name="sqlAwaitPay" datasource="#request.dsn#">
	SELECT a.store, COUNT(*) AS cnt
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.status = 5
		AND i.paid = '0'
		AND e.dtend >= '2005-11-01'
	GROUP BY a.store
	ORDER BY a.store
</cfquery>
<cfloop query="sqlAwaitPay">
	<cfset awaitingPayment = awaitingPayment + cnt>
	<cfset byStore["_#store#"].awaitingPayment = byStore["_#store#"].awaitingPayment + cnt>		
</cfloop>

<!-- Awaiting Shipment -->
<cfset awaitingShipment = 0>
<cfquery name="sqlAwaitShip" datasource="#request.dsn#">
	SELECT a.store, COUNT(*) AS cnt
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.paid = '1'
		AND i.shipped = '0'
		AND i.ShippedTime IS NULL
		AND i.drefund IS NULL
		AND i.PaidTime IS NOT NULL
	GROUP BY a.store
	ORDER BY a.store
</cfquery>
<cfloop query="sqlAwaitShip">
	<cfset awaitingShipment = awaitingShipment + cnt>
	<cfset byStore["_#store#"].awaitingShipment = byStore["_#store#"].awaitingShipment + cnt>		
</cfloop>


<!-- UrgentShipment -->
<cfset UrgentShipment = 0>
<cfquery name="sqlUrgentShipment" datasource="#request.dsn#">
	SELECT a.store, COUNT(*) AS cnt
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.paid = '1'
		AND i.shipped = '0'
		AND i.ShippedTime IS NULL
		AND i.PaidTime <= DATEADD(DAY, -10, GETDATE())
		AND i.drefund IS NULL
	GROUP BY a.store
	ORDER BY a.store
</cfquery>
<cfloop query="sqlUrgentShipment">
	<cfset UrgentShipment = UrgentShipment + cnt>
	<cfset byStore["_#store#"].UrgentShipment = byStore["_#store#"].UrgentShipment + cnt>		
</cfloop>

<!-- NeedToReFund  -->
<cfset NeedToReFund = 0>
<cfquery name="sqlNeedToReFund" datasource="#request.dsn#">
	SELECT a.store, COUNT(*) AS cnt
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.paid = '1'
		AND i.shipped = '0'
		AND i.ShippedTime IS NULL
		AND i.drefund IS NOT NULL
	GROUP BY a.store
	ORDER BY a.store
</cfquery>
<cfloop query="sqlNeedToReFund">
	<cfset NeedToReFund = NeedToReFund + cnt>
	<cfset byStore["_#store#"].NeedToReFund = byStore["_#store#"].NeedToReFund + cnt>		
</cfloop>

<!--- Paid and Shipped--->
<cfset pain_and_shippedYesterday= 0>
<cfset pain_and_shippedLastWeek = 0>
<cfset pain_and_shippedThisMonth = 0>

<cfquery name="sqlpain_and_shippe" datasource="#request.dsn#">
	SELECT a.store, i.ShippedTime AS dt,  COUNT(*) AS cnt
	FROM items i
	INNER JOIN accounts a ON i.aid = a.id	
			WHERE i.shipped = '1'
				AND i.paid = '1'
	GROUP BY a.store, i.ShippedTime
</cfquery>
<cfloop query="sqlpain_and_shippe">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset pain_and_shippedYesterday = pain_and_shippedYesterday + cnt>
		<cfset byStore["_#store#"].pain_and_shippedYesterday = byStore["_#store#"].pain_and_shippedYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset pain_and_shippedLastWeek = pain_and_shippedLastWeek + cnt>
		<cfset byStore["_#store#"].pain_and_shippedLastWeek = byStore["_#store#"].pain_and_shippedLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset pain_and_shippedThisMonth = pain_and_shippedThisMonth + cnt>
		<cfset byStore["_#store#"].pain_and_shippedThisMonth = byStore["_#store#"].pain_and_shippedThisMonth + cnt>
	</cfif>
</cfloop>

<!--- UNSOLD --->
<cfset unsoldYesterday = 0>
<cfset unsoldLastWeek = 0>
<cfset unsoldThisMonth = 0>
<cfset needReturn = 0>

<cfquery name="sqlUnSold" datasource="#request.dsn#">
	SELECT a.store, e.dtend AS dt,  COUNT(*) AS cnt
	FROM items i
		INNER JOIN accounts a ON i.aid = a.id
		INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
	WHERE
		(i.status = 8)
			AND
		(
			e.hbuserid = ''
				OR
			e.hbuserid IS NULL
				OR
			i.dcalled IS NOT NULL
		)
		AND e.dtend >= '2005-12-20'
	GROUP BY a.store, e.dtend
	ORDER BY a.store, e.dtend
</cfquery>
<cfloop query="sqlUnSold">
	<cfset dateFix = ParseDateTime(toString(dt))>
	<cfif dateFix EQ yesterday>
		<cfset unsoldYesterday = unsoldYesterday + cnt>
		<cfset byStore["_#store#"].unsoldYesterday = byStore["_#store#"].unsoldYesterday + cnt>
	</cfif>
	<cfif DateDiff("d", dateFix, Now()) LTE 7>
		<cfset unsoldLastWeek = unsoldLastWeek + cnt>
		<cfset byStore["_#store#"].unsoldLastWeek = byStore["_#store#"].unsoldLastWeek + cnt>
	</cfif>
	<cfif (Month(dateFix) EQ Month(Now())) AND (Year(dateFix) EQ Year(Now()))>
		<cfset unsoldThisMonth = unsoldThisMonth + cnt>
		<cfset byStore["_#store#"].unsoldThisMonth = byStore["_#store#"].unsoldThisMonth + cnt>		
	</cfif>
	<cfset needReturn = needReturn + cnt>
	<cfset byStore["_#store#"].needReturn = byStore["_#store#"].needReturn + cnt>			
</cfloop>

<!--- NEDD CALL --->



<!-- update overview -->
<cfscript>
	overview_new = StructNew();
	overview_new.calculatedOn			= Now();
	overview_new.salesYesterday	= salesYesterday;
	overview_new.salesLastWeek = salesLastWeek;
	overview_new.salesThisMonth	= salesThisMonth;
	overview_new.createdYesterday = createdYesterday;
	overview_new.createdLastWeek = createdLastWeek;
	overview_new.createdThisMonth = createdThisMonth;
	overview_new.receivedYesterday = receivedYesterday;
	overview_new.receivedLastWeek = receivedLastWeek;
	overview_new.receivedThisMonth = receivedThisMonth;
	overview_new.soldYesterday = soldYesterday;
	overview_new.soldLastWeek = soldLastWeek;
	overview_new.soldThisMonth = soldThisMonth;
	overview_new.soldSumYesterday = soldSumYesterday;
	overview_new.soldSumLastWeek = soldSumLastWeek;
	overview_new.soldSumThisMonth = soldSumThisMonth;			
	overview_new.awaitingPayment = awaitingPayment;
	overview_new.awaitingShipment = awaitingShipment;
	overview_new.UrgentShipment = UrgentShipment;
	overview_new.NeedToReFund = NeedToReFund;		
	overview_new.pain_and_shippedYesterday = pain_and_shippedYesterday;
	overview_new.pain_and_shippedLastWeek = pain_and_shippedLastWeek;
	overview_new.pain_and_shippedThisMonth = pain_and_shippedThisMonth;
	overview_new.unsoldYesterday = unsoldYesterday;
	overview_new.unsoldLastWeek = unsoldLastWeek;
	overview_new.unsoldThisMonth = unsoldThisMonth;
	overview_new.needReturn = needReturn;
	overview_new.byStore = byStore;
</cfscript>

<cflock scope="application" timeout="10" type="exclusive">
	<cfset application.overview_new = Duplicate(overview_new)>
</cflock>


