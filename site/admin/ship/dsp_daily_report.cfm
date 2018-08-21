<cfparam name="attributes.repday" default="#Now()#">

<cfquery name="sqlAll" datasource="#request.dsn#">
	SELECT COUNT(i.item) AS cnt
	FROM items i
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
		AND DAY(i.ShippedTime) = #Day(attributes.repday)#
</cfquery>

<cfquery name="sqlAllMTD" datasource="#request.dsn#">
	SELECT COUNT(i.item) AS cnt
	FROM items i
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
</cfquery>

<cfquery name="sqlUPS" datasource="#request.dsn#">
	SELECT COUNT(DISTINCT i.item) AS cnt, SUM(i.ShipCharge) AS shipcharges, SUM(x.AmountPaid) AS AmountPaid, SUM(x.TransactionPrice) AS sales
	FROM items i
		LEFT JOIN
	(
		SELECT i.ebayitem, MAX(t.AmountPaid) AS AmountPaid, MAX(t.TransactionPrice) AS TransactionPrice
		FROM ebtransactions t INNER JOIN items i ON i.ebayitem = t.itmItemID
			AND YEAR(i.ShippedTime) = #Year(attributes.repday)#
			AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
			AND DAY(i.ShippedTime) = #Day(attributes.repday)#
			AND i.shipper = 'UPS'
		GROUP BY i.ebayitem
	) x ON i.ebayitem = x.ebayitem
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
		AND DAY(i.ShippedTime) = #Day(attributes.repday)#
		AND i.shipper = 'UPS'
</cfquery>

<!---
<cfquery name="sqlNonUPS" datasource="#request.dsn#">
	SELECT COUNT(DISTINCT i.item) AS cnt, SUM(x.AmountPaid) AS AmountPaid, SUM(x.TransactionPrice) AS sales
	FROM items i
		LEFT JOIN
	(
		SELECT i.ebayitem, MAX(t.AmountPaid) AS AmountPaid, MAX(t.TransactionPrice) AS TransactionPrice
		FROM ebtransactions t INNER JOIN items i ON i.ebayitem = t.itmItemID
			AND YEAR(i.ShippedTime) = #Year(attributes.repday)#
			AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
			AND DAY(i.ShippedTime) = #Day(attributes.repday)#
			AND i.shipper IS NULL
			AND i.vehicle = "0"
		GROUP BY i.ebayitem
	) x ON i.ebayitem = x.ebayitem
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
		AND DAY(i.ShippedTime) = #Day(attributes.repday)#
		AND i.shipper IS NULL
		AND i.vehicle = "0"
</cfquery>
--->

<cfquery name="sqlUPSMTD" datasource="#request.dsn#">
	SELECT COUNT(DISTINCT i.item) AS cnt, SUM(i.ShipCharge) AS shipcharges, SUM(x.AmountPaid) AS AmountPaid, SUM(x.TransactionPrice) AS sales
	FROM items i
		LEFT JOIN
	(
		SELECT i.ebayitem, MAX(t.AmountPaid) AS AmountPaid, MAX(t.TransactionPrice) AS TransactionPrice
		FROM ebtransactions t INNER JOIN items i ON i.ebayitem = t.itmItemID
			AND YEAR(i.ShippedTime) = #Year(attributes.repday)#
			AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
			AND i.shipper = 'UPS'
		GROUP BY i.ebayitem
	) x ON i.ebayitem = x.ebayitem
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
		AND i.shipper = 'UPS'

</cfquery>

<cfquery name="sqlNonUPSMTD" datasource="#request.dsn#">
	SELECT COUNT(DISTINCT i.item) AS cnt, SUM(x.AmountPaid) AS AmountPaid, SUM(x.TransactionPrice) AS sales
	FROM items i
		LEFT JOIN
	(
		SELECT i.ebayitem, MAX(t.AmountPaid) AS AmountPaid, MAX(t.TransactionPrice) AS TransactionPrice
		FROM ebtransactions t INNER JOIN items i ON i.ebayitem = t.itmItemID
			AND YEAR(i.ShippedTime) = #Year(attributes.repday)#
			AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
			AND i.shipper IS NULL
			AND i.vehicle = '0'
		GROUP BY i.ebayitem
	) x ON i.ebayitem = x.ebayitem
	WHERE YEAR(i.ShippedTime) = #Year(attributes.repday)#
		AND MONTH(i.ShippedTime) = #Month(attributes.repday)#
		AND i.shipper IS NULL
		AND i.vehicle = '0'
</cfquery>

<cfquery name="sqlEnded" datasource="#request.dsn#">
	SELECT COUNT(e.itemid) AS cnt
	FROM ebitems e
	WHERE YEAR(e.dtend) = #Year(attributes.repday)#
		AND MONTH(e.dtend) = #Month(attributes.repday)#
		AND DAY(e.dtend) = #Day(attributes.repday)#
</cfquery>

<cfquery name="sqlActual" datasource="#request.dsn#">
	SELECT
		SUM(CASE WHEN PackagingHandlingCosts >0 THEN 1 ELSE 0 END) AS cnt_with,
		AVG(PackagingHandlingCosts) AS avg_ship,
		SUM(PackagingHandlingCosts) AS sum_ship
	FROM ebitems
	WHERE YEAR(dtend) = #Year(attributes.repday)#
		AND MONTH(dtend) = #Month(attributes.repday)#
		AND DAY(dtend) = #Day(attributes.repday)#
</cfquery>

<cfquery name="sqlActualThisMonth" datasource="#request.dsn#">
	SELECT
		SUM(CASE WHEN PackagingHandlingCosts >0 THEN 1 ELSE 0 END) AS cnt_with,
		AVG(PackagingHandlingCosts) AS avg_ship,
		SUM(PackagingHandlingCosts) AS sum_ship
	FROM ebitems
	WHERE YEAR(dtend) = #Year(attributes.repday)#
		AND MONTH(dtend) = #Month(attributes.repday)#
</cfquery>

<cfoutput>
<table>
<tr><td colspan="2">
	<b>End of Day - Shipping Department<br>
	#DateFormat(attributes.repday, "mmmm d, yyyy")#</b><br><br>
</td></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td>Items Ending Today:</td>
	<td align="right">#sqlEnded.cnt#</td>
</tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td><strong>Number of Items Shipped:</strong></td>
	<td align="right"><strong>#sqlAll.cnt#</strong></td>
</tr>
<tr>
	<td>Number of UPS Items:</td>
	<td align="right">#sqlUPS.cnt#</td>
</tr>
<tr>
	<td>Total UPS Amount Received:</td>
	<td align="right">#DollarFormat(Val(sqlUPS.AmountPaid) - Val(sqlUPS.sales))#</td>
</tr>
<tr>
	<td>Total Cost of UPS Items:</td>
	<td align="right">#DollarFormat(sqlUPS.shipcharges)#</td>
</tr>
<tr>
	<td><strong>Total Handling off UPS Items:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlUPS.AmountPaid) - Val(sqlUPS.sales) - Val(sqlUPS.shipcharges))#</strong></td>
</tr>
<!---
<tr>
	<td><strong>Estimated Total Handling:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlUPS.AmountPaid) - Val(sqlUPS.sales) - Val(sqlUPS.shipcharges) + (3 * Val(sqlNonUPS.cnt)))#</strong></td>
</tr>
--->
<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td><strong>Actual Handling Per item:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlActual.avg_ship))#</strong></td>
</tr>
<tr>
	<td><strong>Total Items W/Actual Handling:</strong></td>
	<td align="right"><strong>#Val(sqlActual.cnt_with)#</strong></td>
</tr>
<tr>
	<td><strong>Total Handling:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlActual.sum_ship))#</strong></td>
</tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td><strong>MTD: Actual Handling Per item:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlActualThisMonth.avg_ship))#</strong></td>
</tr>
<tr>
	<td><strong>MTD: Total Items W/Actual Handling:</strong></td>
	<td align="right"><strong>#Val(sqlActualThisMonth.cnt_with)#</strong></td>
</tr>
<tr>
	<td><strong>MTD: Total Handling:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlActualThisMonth.sum_ship))#</strong></td>
</tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td><strong>MTD: UPS Items Shipped:</strong></td>
	<td align="right"><strong>#sqlUPSMTD.cnt#</strong></td>
</tr>
<tr>
	<td><strong>MTD: UPS Shipping Charges:</strong></td>
	<td align="right"><strong>#DollarFormat(Val(sqlUPSMTD.shipcharges))#</strong></td>
</tr>
<tr>
	<td><strong>MTD: Total Handling:</strong></td>
	<td align="right"><strong><cfif Val(sqlNonUPSMTD.cnt) EQ 0>N/A<cfelse>#DollarFormat(Val(sqlUPSMTD.AmountPaid) - Val(sqlUPSMTD.sales) - Val(sqlUPSMTD.shipcharges) + (3 * Val(sqlNonUPSMTD.cnt)))#</cfif></strong></td>
</tr>
<tr>
	<td><strong>MTD: Items Shipped:</strong></td>
	<td align="right"><strong>#sqlAllMTD.cnt#</strong></td>
</tr>
<tr>
	<td><strong>MTD: Average Handling</strong></td>
	<td align="right"><strong><cfif Val(sqlAllMTD.cnt) EQ 0>N/A<cfelse>#DollarFormat((Val(sqlUPSMTD.AmountPaid) - Val(sqlUPSMTD.sales) - Val(sqlUPSMTD.shipcharges)) / Val(sqlAllMTD.cnt))#</cfif></strong></td>
</tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr>
	<td><strong>MTD: Expected Handling Per item</strong></td>
	<td align="right"><strong><cfif Val(sqlAllMTD.cnt) EQ 0>DollarFormat(Val(sqlActualThisMonth.avg_ship)/2)<cfelse>#DollarFormat((Val(sqlActualThisMonth.avg_ship)+(Val(sqlUPSMTD.AmountPaid) - Val(sqlUPSMTD.sales) - Val(sqlUPSMTD.shipcharges)) / Val(sqlAllMTD.cnt))/2)#</cfif></strong></td>
</tr>
<tr>
	<td><strong>MTD: Expected Handling</strong></td>
	<td align="right"><strong><cfif Val(sqlAllMTD.cnt) EQ 0>DollarFormat(sqlAllMTD.cnt*Val(sqlActualThisMonth.avg_ship)/2)<cfelse>#DollarFormat(sqlAllMTD.cnt*(Val(sqlActualThisMonth.avg_ship)+(Val(sqlUPSMTD.AmountPaid) - Val(sqlUPSMTD.sales) - Val(sqlUPSMTD.shipcharges)) / Val(sqlAllMTD.cnt))/2)#</cfif></strong></td>
</tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2"><strong>Notes:</strong></td></tr>
</table>
</cfoutput>