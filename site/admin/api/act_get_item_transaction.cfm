<cfparam name="attributes.ebayitem">
<cfparam name="attributes.CallName" default="GetItemTransactions">

<cfquery name="sqlEData" datasource="#request.dsn#">
	SELECT a.ebayaccount
	FROM auctions a
		INNER JOIN items i ON a.itemid = i.item
	WHERE i.ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
</cfquery>
<cfif sqlEData.RecordCount EQ 0>
	<cfset ebID = 0>
<cfelse>
	<cfset ebID = sqlEData.ebayaccount>
</cfif>
<cfquery datasource="#request.dsn#" name="sqlEBAccount">
	SELECT eBayAccount, UserID, UserName, Password,
		DeveloperName, ApplicationName, CertificateName, RequestToken
	FROM ebaccounts
	WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#ebID#">
</cfquery>
<cfscript>
	_ebay.UserID			= sqlEBAccount.UserID;
	_ebay.UserName			= sqlEBAccount.UserName;
	_ebay.Password			= sqlEBAccount.Password;
	_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
	_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
	_ebay.CertificateName	= sqlEBAccount.CertificateName;
	_ebay.RequestToken		= sqlEBAccount.RequestToken;
</cfscript>
<cfscript>
	attributes.CallName = "GetItemTransactions";
	xmlDoc = xmlNew();
	xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "#attributes.CallName#Request");
	StructInsert(xmlDoc.xmlRoot.xmlAttributes, "xmlns", "urn:ebay:apis:eBLBaseComponents");
	xmlDoc.xmlRoot.RequesterCredentials = xmlElemNew(xmlDoc, "RequesterCredentials");
	xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken = xmlElemNew(xmlDoc, "eBayAuthToken");
	xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken.xmlText = _ebay.RequestToken;

	xmlDoc.xmlRoot.ItemID = xmlElemNew(xmlDoc, "ItemID");
	xmlDoc.xmlRoot.ItemID.xmlText = attributes.ebayitem;

	xmlDoc.xmlRoot.ModTimeFrom = xmlElemNew(xmlDoc, "ModTimeFrom");
	xmlDoc.xmlRoot.ModTimeFrom.xmlText = DateTimeToEBay(DateAdd("d", -28, Now()));

	xmlDoc.xmlRoot.ModTimeTo = xmlElemNew(xmlDoc, "ModTimeTo");
	xmlDoc.xmlRoot.ModTimeTo.xmlText = DateTimeToEBay(Now());

	xmlDoc.xmlRoot.DetailLevel = xmlElemNew(xmlDoc, "DetailLevel");
	xmlDoc.xmlRoot.DetailLevel.xmlText = "ReturnAll";
</cfscript>

<!---<cfdump var="#xmlDoc#">--->



<cfset _ebay.XMLRequest = toString(xmlDoc)>
<cfset _ebay.CallName = attributes.CallName>
<cfset _ebay.ThrowOnError = false>

<cfinclude template="../../api/act_call.cfm">

<cfif NOT isDefined("_ebay.xmlResponse") OR (_ebay.Ack EQ "failure")>
	<cfif request.emails.error NEQ "">
		<cfmail 
		from="#_vars.mails.from#" 
		to="#request.emails.error#" 
		subject="ERROR IN act_get_item_transaction for ebayitem=#attributes.ebayitem#" type="html">
			#_ebay.xmlResponse.xmlRoot.Errors.LongMessage#
		</cfmail>
	</cfif>
<cfelse>

	<cfloop index="i" from="1" to="#_ebay.xmlResponse.xmlRoot.ReturnedTransactionCountActual.xmlText#">


		<cfset Transaction = _ebay.xmlResponse.xmlRoot.TransactionArray.xmlChildren[i]>
		<cfoutput><li>ItemID = #_ebay.xmlResponse.xmlRoot.Item.ItemID.xmlText#</li></cfoutput>


		<cfquery datasource="#request.dsn#">
			INSERT INTO ebtransactions
			(
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
<!---
				itmStartTime,
				itmEndTime,
--->
				itmTitle,
				stseBayPaymentStatus,
				stsCheckoutStatus,
				stsLastTimeModified,
				stsPaymentMethodUsed,
				stsCompleteStatus,
				stsBuyerSelectedShipping,
				TransactionID,
				TransactionPrice,
				BestOfferSale,
				extExternalTransactionID,
				extExternalTransactionTime,
				extFeeOrCreditAmount,
				extPaymentOrRefundAmount,
				PaidTime,
				ShippedTime,
					itmSKU,<!--- 20111207 vlad added  --->
					itmQuantitySold,
					salesRecord,
					ListingType,
					itemQtyForSale
			)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.AmountPaid.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.AdjustmentAmount.xmlText#">,
				<cfloop index="i" list="Name,Street1,Street2,CityName,StateOrProvince,Country,CountryName,Phone,PostalCode,AddressID,AddressOwner,AddressStatus,ExternalAddressID,CompanyName,AddressRecordType">
					<cfif StructKeyExists (Transaction.Buyer.BuyerInfo.ShippingAddress, i)>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Buyer.BuyerInfo.ShippingAddress[i].xmlText#">,
					<cfelse>
						NULL,
					</cfif>
				</cfloop>
				<cfif StructKeyExists (Transaction.ShippingDetails, "ShipmentTrackingNumber")>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.ShippingDetails.ShipmentTrackingNumber.xmlText#">,
				<cfelse>
					NULL,
				</cfif>
				<cfif StructKeyExists (Transaction.ShippingDetails, "ShippingServiceUsed")>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.ShippingDetails.ShippingServiceUsed.xmlText#">,
				<cfelse>
					NULL,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.CreatedDate.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.Item.ItemID.xmlText#">,
<!---
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(_ebay.xmlResponse.xmlRoot.Item.ListingDetails.StartTime.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(_ebay.xmlResponse.xmlRoot.Item.ListingDetails.EndTime.xmlText)#">,
--->
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.xmlResponse.xmlRoot.Item.Title.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.eBayPaymentStatus.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.CheckoutStatus.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.Status.LastTimeModified.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.PaymentMethodUsed.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.CompleteStatus.xmlText#">,
				<cfif Transaction.Status.BuyerSelectedShipping.xmlText EQ "true">1<cfelse>0</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.TransactionID.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.TransactionPrice.xmlText#">,
				<cfif Transaction.BestOfferSale.xmlText EQ "true">1<cfelse>0</cfif>,
				<cfif StructKeyExists (Transaction, "ExternalTransaction")>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.ExternalTransaction.ExternalTransactionID.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.ExternalTransaction.ExternalTransactionTime.xmlText)#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.ExternalTransaction.FeeOrCreditAmount.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.ExternalTransaction.PaymentOrRefundAmount.xmlText#">,
				<cfelse>
					NULL,
					NULL,
					NULL,
					NULL,
				</cfif>
				<cfif StructKeyExists (Transaction, "PaidTime")>
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.PaidTime.xmlText)#">,
				<cfelse>
					NULL,
				</cfif>
				<cfif StructKeyExists (Transaction, "ShippedTime")>
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.ShippedTime.xmlText)#">,
				<cfelse>
					NULL,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.xmlResponse.xmlRoot.Item.SKU.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.xmlResponse.xmlRoot.Item.SellingStatus.QuantitySold.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.xmlResponse.xmlRoot.Item.ShippingDetails.SellingManagerSalesRecordNumber.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.xmlResponse.xmlRoot.Item.ListingType.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#_ebay.xmlResponse.xmlRoot.Item.Quantity.xmlText#">
			)
		</cfquery>

		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET item = item
			<cfloop index="i" list="Name,Street1,Street2,CityName,StateOrProvince,Country,Phone,PostalCode,CompanyName">
				<cfif StructKeyExists (Transaction.Buyer.BuyerInfo.ShippingAddress, i) AND (Transaction.Buyer.BuyerInfo.ShippingAddress[i].xmlText NEQ "")>
					, byr#i# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Buyer.BuyerInfo.ShippingAddress[i].xmlText#">
				</cfif>
			</cfloop>
			<cfif StructKeyExists (Transaction, "PaidTime")>
				, PaidTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.PaidTime.xmlText)#">
				, paid = '1'
			<cfelse>
				, PaidTime = NULL
				, paid = '0'
			</cfif>
			<cfif StructKeyExists (Transaction, "ShippedTime")>
				, ShippedTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.ShippedTime.xmlText)#">
				, shipped = '1'
			<cfelse>
				, ShippedTime = NULL
				, shipped = '0'
			</cfif>
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.Item.ItemID.xmlText#">
		</cfquery>
		<h1>VLAD ABORTED</h1>
		<cfabort>


	</cfloop>
</cfif>
