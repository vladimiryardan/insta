<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.tid" default="0">



<cfquery name="sqlSalesHistory" datasource="#request.dsn#">
	SELECT tid,
	AmountPaid,
	AdjustmentAmount,
	byrName,
	byrStreet1,
	byrStreet2,
	byrCityName,
	byrStateOrProvince,
	byrCountry,
	byrCountryName,
	byrPhone,
	byrPostalCode,
	byrAddressID,
	byrAddressOwner,
	byrAddressStatus,
	byrExternalAddressID,
	byrCompanyName,
	byrAddressRecordType,

	shdShipmentTrackingNumber,
	shdShippingServiceUsed,
	CreatedDate,
	itmItemID,
	itmStartTime,
	itmEndTime,
	itmTitle,stseBayPaymentStatus,stsCheckoutStatus,stsLastTimeModified,stsPaymentMethodUsed,stsCompleteStatus,stsBuyerSelectedShipping,TransactionID,TransactionPrice,BestOfferSale,extExternalTransactionID,extExternalTransactionTime,extFeeOrCreditAmount,extPaymentOrRefundAmount,PaidTime,ShippedTime,itmQuantitySold,itmSKU,salesRecord,listingtype
	from ebtransactions
	WHERE tid = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.tid#">
</cfquery>

<cfoutput>
	<font size="4"><strong>Sales History:</strong></font><br>

	<cfif sqlSalesHistory.recordcount gte 1>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="5" cellpadding="5">
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Title:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.itmTitle#</td>
			</tr>
			<tr bgcolor="##ffffff">
				<td valign="middle" align="right"><b>Item:</b></td>
				<td width="70%" align="left"><a href="index.cfm?dsp=management.items.edit&item=#sqlSalesHistory.itmSKU#">#sqlSalesHistory.itmSKU#</a></td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Ebay:</b></td>
				<td width="70%" align="left"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlSalesHistory.itmItemID#" target="_blank">#sqlSalesHistory.itmItemID#</a></td>
			</tr>
			<tr bgcolor="##ffffff">
				<td valign="middle" align="right"><b>Sales Record:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.salesRecord#</td>
			</tr>
			<tr bgcolor="##ffffff">
				<td valign="middle" align="right"><b>Quantity Sold:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.itmQuantitySold#</td>
			</tr>
			<tr bgcolor="##ffffff">
				<td valign="middle" align="right"><b>Amount Paid:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.AmountPaid#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Name:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrName#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Email:</b></td>
				<td width="70%" align="left"><!---#sqlSalesHistory.byrName#---></td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Street1:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrStreet1#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Street2:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrStreet2#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer City:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrCityName#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer State/Province:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrStateOrProvince#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Country:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrCountryName#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Buyer Postal:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.byrPostalCode#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Shipping:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.shdShippingServiceUsed#</td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Shipping Tracking:</b></td>
				<td width="70%" align="left">#sqlSalesHistory.shdShipmentTrackingNumber#</td>
			</tr>

	</table>
	<cfelse>
		<h1>No Records found.</h1>
	</cfif>
</cfoutput>