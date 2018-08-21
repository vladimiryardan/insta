<cfparam name="attributes.lid_filter" default="notshipped">
<cfquery name="sqlTemp" datasource="#request.dsn#" >
SET ANSI_WARNINGS OFF<!--- 20120202: we must include this coz if there are no records returned it will err and says that the sqlTemp is undefined --->
SELECT
e1.*,
i.title,
e.galleryurl,
i.item,
i.shipnote,
i.lid,
i.weight,
e1.amountpaid as price,
i.ebayitem,
e.title AS etitle,
e1.byrName as hbuserid,
e1.BYRCOUNTRY
from ebtransactions e1 inner join
(
	SELECT itmItemID, MAX(ShippedTime) AS ShippedTime, MAX(PaidTime) AS PaidTime, MAX(transactionid) AS transactionid, max(tid) as tid2
	FROM ebtransactions
	WHERE (ListingType = 'FixedPriceItem' or  ListingType = 'StoresFixedPrice')
	and  stsCheckoutStatus  = 'CheckoutComplete' and PaidTime IS NOT NULL <!---and itmitemid = '150716001270'--->
	GROUP BY itmItemID
	<!---order by itmItemID,tid desc--->

) e2 on e2.tid2 = e1.tid
LEFT JOIN items i ON e1.itmSKU = i.item
LEFT JOIN ebitems e ON e1.itmItemID = e.ebayitem
where 1=1
order by e2.tid2 desc

</cfquery>

<cfoutput>
<style type="text/css">
.btmborder{
	border-bottom: 2px dashed ##9EB5C5;
}
</style>
<h3>SHIPPING LIST - #UCase(DateFormat(Now(), "mmmm d, yyyy"))# #TimeFormat(Now())#</h3>
<table>
</cfoutput>





<cfoutput query="sqlTemp" ><!--- sqltemp contains fixed price items which has multiple sales --->
	<cfquery name="sqlTempDetails" datasource="#request.dsn#" ><!--- this query contains the ebayitems which are purchase and fixed price --->
	SELECT e1.*,
	i.title,
	e.galleryurl,
	i.item,
	i.shipnote,
	i.lid,
	i.weight,
	e1.amountpaid as price,
	i.ebayitem,
	e.title AS etitle,
	e1.byrName as hbuserid,
	e1.BYRCOUNTRY,
	i2.lid as lid2,
	i2.internal_itemSKU as internal_itemSKUI2,
	i2.item as item2,
	i2.dlid,
	i2.INTERNAL_ITEMSKU,
	i2.startprice AS reserve
	from ebtransactions e1 inner join
	(
		SELECT itmItemID, MAX(ShippedTime) AS ShippedTime, MAX(PaidTime) AS PaidTime, MAX(transactionid) AS transactionid, max(tid) as tid2
		FROM ebtransactions
		WHERE
		(ListingType = 'FixedPriceItem' or  ListingType = 'StoresFixedPrice') and
		stsCheckoutStatus  = 'CheckoutComplete'
		and PaidTime IS NOT NULL
		and itmitemid = '#sqlTemp.itmitemid#'
		GROUP BY itmItemID,transactionid <!---HAVING COUNT(transactionid) > 1---><!--- by having this group by we are able to get items which has more than one purchase --->

	) e2 on e2.tid2 = e1.tid
	LEFT JOIN items i ON e1.itmSKU = i.item
	LEFT JOIN ebitems e ON e1.itmItemID = e.ebayitem
	LEFT JOIN ebtransactions_lti lti ON e1.itmitemid = lti.ebayitem_lti and e1.TransactionID = lti.transactionid_lti
	LEFT JOIN items i2 ON lti.itemid_lti = i2.item



	order by e2.paidtime desc <!--- we need to order by paidtime desc coz we need the most oldest at the last --->
	</cfquery>


		<cfloop query="sqlTempDetails">
			<!--- Check for last row. the last row is the first buyer and its already linked to the system then we dont want to display the last --->
			<cfif (sqlTempDetails.CurrentRow lt sqlTempDetails.RecordCount)>
					<cfif attributes.lid_filter eq "notshipped" and sqlTempDetails.lid2 neq 'p&s' >
						<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('D1D2D3'))#" >
							<td class="btmborder"><cfif sqlTempDetails.galleryurl EQ ""><img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg"><cfelse><a href="#sqlTempDetails.galleryurl#" target="_blank"><img src="#sqlTempDetails.galleryurl#" width=80 border=1></cfif></td>
							<td class="btmborder"><b><font size=2>#item2#<br>LID: #lid2#<br>#DateFormat(dlid)#<br>#hbuserid#<cfif Trim(sqlTempDetails.byrCountry) NEQ ""> (#sqlTempDetails.byrCountry#)</cfif></font></b></td>
							<td class="btmborder">
							<font size=2>#title#</font><br />
							<hr />
							<font size=2>#internal_itemSKU#</font><br />
							<hr />
							<font size=2>#etitle#</font>
							<hr />
							<font size=2>#etitle#</font>
							</td>
							<td class="btmborder"><font size=2>#weight# lbs.</font></td>
							<td class="btmborder"><font size=2>#DollarFormat(price)#<cfif (reserve NEQ 0) AND (price GTE reserve)> -R</cfif></font></td>
						</tr>
						<cfif sqlTempDetails.shipnote NEQ ""><tr><td class="btmborder" align="right"><b>Note:</b></td><td colspan="4" class="btmborder"><b>#shipnote#</b></td></tr></cfif>
					</cfif><!--- not shipped only --->
				</cfif><!--- Check for last row.--->
		</cfloop>
</cfoutput>
<cfoutput></table></cfoutput>