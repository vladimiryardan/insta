<!---
revision:
Date: 20111207 - added insert of itmsku and quantitysold
--->
<!---<cfdump var="#_ebay#">--->


<cfoutput><ul></cfoutput>
<!---
<cfdump var="#_ebay#">
<cfdump var="#xmlparse(_ebay.RESPONSE)#">
<cfabort>
--->

<!---_ebay.xmlResponse.GetSellerTransactionsResponse.TransactionArray.transaction--->
<!---<cfloop index="i" from="1" to="#_ebay.xmlResponse.xmlRoot.ReturnedTransactionCountActual.xmlText#">--->
<!---<cfset Transaction = _ebay.xmlResponse.xmlRoot.TransactionArray.xmlChildren[i]>--->
<cfif structkeyExists(_ebay.xmlResponse.GetSellerTransactionsResponse,"TransactionArray")>
	<cfloop index="i" from="1" to="#arraylen(_ebay.xmlResponse.GetSellerTransactionsResponse.TransactionArray.transaction)#">
		<cfset Transaction = _ebay.xmlResponse.xmlRoot.TransactionArray.transaction[i]>
	
		
		<!---<cfset eb_item = _ebay.xmlResponse.xmlRoot.item.xmlChildren[i]>--->
		<cfoutput>
			<li>ItemID = #Transaction.Item.ItemID.xmlText#</li>
		<ul>
		</cfoutput>
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
				itmStartTime,
				itmEndTime,
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
					<cfif isdefined("Transaction.Item.SKU.xmlText")>itmSKU,</cfif><!--- 20111207 vlad added  --->
					itmQuantitySold,
					salesRecord,
					ListingType,
					byrEmail
					<cfif isdefined("Transaction.Variation.VariationTitle")>
	                ,ebayVariationTitle
	                </cfif>
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
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.Item.ListingDetails.StartTime.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.Item.ListingDetails.EndTime.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Item.Title.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.eBayPaymentStatus.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.CheckoutStatus.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.Status.LastTimeModified.xmlText)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.PaymentMethodUsed.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Status.CompleteStatus.xmlText#">,
				<cfif Transaction.Status.BuyerSelectedShipping.xmlText EQ "true">1<cfelse>0</cfif>,
				
				<!---20170630 fix. some items don't have transactionid and buggigng the whole sync--->
				<cfif structkeyExists(Transaction,"TransactionID")>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.TransactionID.xmlText#">,
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
				</cfif>
				
				<cfqueryparam cfsqltype="cf_sql_float" value="#Transaction.TransactionPrice.xmlText#">,
				<cfif isdefined("Transaction.BestOfferSale.xmlText") and Transaction.BestOfferSale.xmlText EQ "true">1<cfelse>0</cfif>,
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
					<cfif isdefined("Transaction.Item.SKU.xmlText")><!--- multi qty is not yet done lets add catch here for now 20120119 vry --->
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Item.SKU.xmlText#">,
					</cfif>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.QuantityPurchased.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.ShippingDetails.SellingManagerSalesRecordNumber.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Item.ListingType.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Buyer.Email.xmlText#">
	                <cfif isdefined("Transaction.Variation.VariationTitle")>
	                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Variation.VariationTitle.xmlText#">
	                </cfif>
	
			)
		</cfquery>
		<cfquery datasource="#request.dsn#" name="sqlTemp">
			SELECT item FROM items
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET listcount = listcount
			<cfloop index="i" list="Name,Street1,Street2,CityName,StateOrProvince,Country,Phone,PostalCode,CompanyName">
				<cfif StructKeyExists (Transaction.Buyer.BuyerInfo.ShippingAddress, i) AND (Transaction.Buyer.BuyerInfo.ShippingAddress[i].xmlText NEQ "")>
					, byr#i# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Transaction.Buyer.BuyerInfo.ShippingAddress[i].xmlText#">
				</cfif>
			</cfloop>
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
		</cfquery>
		<cfif StructKeyExists(Transaction, "PaidTime")
			AND (
				((Transaction.Status.CompleteStatus.xmlText EQ "Complete") AND (Transaction.Status.PaymentMethodUsed.xmlText EQ "PayPal"))
				OR
				(Transaction.Status.PaymentMethodUsed.xmlText NEQ "PayPal")
			)>
			<cfoutput><li><b>Paid with #Transaction.Status.PaymentMethodUsed.xmlText#</b></li></cfoutput>
	
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET paid = '1',
					PaidTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.PaidTime.xmlText)#">
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
			</cfquery>
	
			<!---
			vlad added this to get the correct final price of fixed items which is completed and paid
			date: 20101015
			-- check if item is fixed price. if item is fixed price and ebay item complete and paid then
			-- ideally we want to update the price of records table to set the final price but if we do it the update of records table here it will be overwritten by other call after this line.
			-- what we want is update the ebitems table and set the price coz this is the basis of instantonlineconsignment.com\site\api\dsp_run_synch.cfm to update the final price of records table
			--->
			<cfquery datasource="#request.dsn#" name="rs_GetItem">
				select * from items WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
			</cfquery>
	
				<cfif rs_GetItem.recordcount gte 1>
						<cfif StructKeyExists (Transaction, "item") and lcase(#Transaction.Item.ListingType.xmlText#) eq "fixedpriceitem" ><!--- for fixed item only --->
							<!--- update the records table
							<cfquery datasource="#request.dsn#">
							update records
							set finalprice = '#Transaction.TransactionPrice.xmlText#'
							where ebayitem = '#rs_GetItem.ebayitem#'
							</cfquery>	--->
							<cfquery datasource="#request.dsn#">
								update ebitems
								set price = '#Transaction.TransactionPrice.xmlText#'
								where ebayitem = '#rs_GetItem.ebayitem#'
							</cfquery>
	
							<cfquery datasource="#request.dsn#">
								insert into vladmonitorfixedpriceitem
								(ebayitem,price)
								values
								('#rs_GetItem.ebayitem#','#Transaction.TransactionPrice.xmlText#')
							</cfquery>
	
	
					</cfif>
				</cfif>
	
			<cfscript>
				if(sqlTemp.RecordCount EQ 1){
					fChangeStatus(sqlTemp.item, 10); // Awaiting Shipment
				}
			</cfscript>
		<!--- Defect : 36 - Awaiting Shipment Statuses from eBay --->
		<cfelse>
			<cfoutput><li><b>NOT paid</b></li></cfoutput>
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET paid = '0',
					PaidTime = NULL
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
			</cfquery>
			<cfscript>
				if(sqlTemp.RecordCount EQ 1){
					fChangeStatus(sqlTemp.item, 5); // Awaiting Payment
				}
			</cfscript>
		<!--- / Defect : 36 - Awaiting Shipment Statuses from eBay --->
		</cfif>
		<cfif StructKeyExists (Transaction, "ShippedTime")>
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET shipped = '1',
					ShippedTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(Transaction.ShippedTime.xmlText)#">
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Transaction.Item.ItemID.xmlText#">
			</cfquery>
			<cfscript>
				if(sqlTemp.RecordCount EQ 1){
					fChangeStatus(sqlTemp.item, 11); // Paid and Shipped
				}
			</cfscript>
		</cfif>
		<cfoutput><li>AmountPaid=#Transaction.AmountPaid.xmlText#</li></cfoutput>
		<cfoutput><li>ShipmentTrackingNumber=<cfif StructKeyExists (Transaction.ShippingDetails, "ShipmentTrackingNumber")>#Transaction.ShippingDetails.ShipmentTrackingNumber.xmlText#<cfelse>NULL</cfif></li></cfoutput>
		<cfoutput><li>ShippingServiceUsed=<cfif StructKeyExists (Transaction.ShippingDetails, "ShippingServiceUsed")>#Transaction.ShippingDetails.ShippingServiceUsed.xmlText#<cfelse>NULL</cfif></li></cfoutput>
		<cfoutput><li>eBayPaymentStatus=#Transaction.Status.eBayPaymentStatus.xmlText#</li></cfoutput>
		<cfoutput><li>CheckoutStatus=#Transaction.Status.CheckoutStatus.xmlText#</li></cfoutput>
		<cfoutput><li>PaymentMethodUsed=#Transaction.Status.PaymentMethodUsed.xmlText#</li></cfoutput>
		<cfoutput><li>CompleteStatus=#Transaction.Status.CompleteStatus.xmlText#</li></cfoutput>
		<cfoutput><li>PaidTime=<cfif StructKeyExists (Transaction, "PaidTime")>#Transaction.PaidTime.xmlText#<cfelse>NULL</cfif></li></cfoutput>
		<cfoutput><li>ShippedTime=<cfif StructKeyExists (Transaction, "ShippedTime")>#Transaction.ShippedTime.xmlText#<cfelse>NULL</cfif></li></cfoutput>
		<cfoutput><li>Price=<cfif StructKeyExists (Transaction, "TransactionPrice")>#Transaction.TransactionPrice.xmlText#<cfelse>NULL</cfif></li></cfoutput>
		<cfoutput><li>Listing Type=<cfif StructKeyExists (Transaction, "item")>#Transaction.Item.ListingType.xmlText#<cfelse>NULL</cfif></li></cfoutput>
	
	
		<cfoutput></ul></cfoutput>
	</cfloop>
	<cfoutput></ul></cfoutput>
</cfif>
