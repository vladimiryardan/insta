<!--- here is where the amazon items_itemid will be updated --->
<cfif NOT isAllowed("Items_ChangeStatus") AND NOT isAllowed("Items_NormalChangeStatus")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<!--- manage items permission --->
<cfif not isAllowed("Items_EditDescriptions")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfoutput>
	hello!
</cfoutput>
<!--- ABORT - ABORT - ABORT REMOVE THIS LATER
<cfabort> --->


<cfparam name="attributes.byrOrderQtyToShip" default="1" >
<cfparam name="attributes.txnid" default="" >
<cfparam name="attributes.d_ebayitem" default="" >
<cfparam name="attributes.d_tid" default="" >
<cfparam name="attributes.d_itmsku" default="" >
<cfparam name="attributes.itemCondition" default="Ebay Fixed price Multi transactions">


<!--- generate a unique id not in ebay --->
<cfset createObject("java", "java.lang.Thread").sleep(JavaCast("int", 1000))><!--- sleep for 1 sec to avoid concurrent calls problem  --->
<cfset theEbayId = DateDiff("s", "12-31-1979 00:00:00", now())>


<cfif isdefined("attributes.INSTAITEMS")>
<cfset LogAction("Ebay Transaction id #attributes.d_tid# linked to insta items  #attributes.INSTAITEMS#")>

<cfquery name="get_ebaydtls" datasource="#request.dsn#">
SELECT tid
,paidtime
,TransactionID
,itmItemID
,ShippedTime
,stsCheckoutStatus
,ListingType
,itmSKU
,AmountPaid
,AdjustmentAmount
,byrName
,byrStreet1
,byrStreet2
,byrCityName
,byrStateOrProvince
,byrCountry
,byrCountryName
,byrPhone
,byrPostalCode
,byrAddressID
,byrAddressOwner
,byrAddressStatus
,byrExternalAddressID
,byrCompanyName
,byrAddressRecordType
,shdShipmentTrackingNumber
,shdShippingServiceUsed
,CreatedDate
,itmStartTime
,itmEndTime
,itmTitle
,stseBayPaymentStatus
,stsLastTimeModified
,stsPaymentMethodUsed
,stsCompleteStatus
,stsBuyerSelectedShipping
,TransactionPrice
,BestOfferSale
,extExternalTransactionID
,extExternalTransactionTime
,extFeeOrCreditAmount
,extPaymentOrRefundAmount
,itmQuantitySold
,salesRecord
,byremail

from  ebtransactions
where tid = '#attributes.d_tid#'
</cfquery>



<cfset itemsCount = ListLen(attributes.INSTAITEMS) >
<cfset loopcount = 1>
<cfloop index="xitem" list="#attributes.INSTAITEMS#">
	<cftransaction>
		<!--- update to internal_itemCondition --->
		<cfquery datasource="#request.dsn#">
			update items
			set
			<!---internal_itemCondition = '#attributes.itemCondition#',--->
			status = '10',<!--- update to awaiting shipment --->
			Internal_itemsku = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.itmSKU#">,
			paid = '1',
			offebay = '2', <!--- set to 2 for item ebay sold but multi qty and fixed price --->
			PaidTime = '#get_ebaydtls.paidtime#', <!--- use the date of purchasedate from amazon --->
			byrName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrName#">,
			byrStreet1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrStreet1#">,
			byrStreet2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrStreet2#">,
			byrCityName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrCityName#">,
			byrStateOrProvince = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrStateOrProvince#">,
			byrCountry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrCountry#">,
			byrPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrPhone#">,
			byrPostalCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrPostalCode#">,
			byrCompanyName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.byrCompanyName#">,
			byrOrderQtyToShip = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.byrOrderQtyToShip#">,
			ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#00#loopcount#">,
			ebayTxnid = '#attributes.txnid#',
			ebayFixedPricePaid = '#get_ebaydtls.AmountPaid#',
			parentEbayItemFixed = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.d_ebayitem#">,
			ebaySalesRecord = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_ebaydtls.salesRecord#">,
			exception = '0'<!--- 20120615:vlad this should fix for items combined and not going to any list. --->
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">
		</cfquery>

		<!--- insert into ebitems coz this is a multi item --->
		<cfquery name="chkEbitems" datasource="#request.dsn#">
			SELECT * FROM ebitems
			WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#00#loopcount#">
		</cfquery>




		<cfif chkEbitems.RecordCount EQ 0>
			<!--- get the ebitem parent ebayitem details --->
			<cfquery name="get_EbitemDetails" datasource="#request.dsn#">
				SELECT
					itemid,
					hbuserid,
					dtwhen,
					ebayitem,
					dtstart,
					dtend,
					price,
					title,
					hbemail,
					description,
					primarycategoryid,
					timeleft,
					status,
					GalleryURL,
					PackagingHandlingCosts
			 	FROM ebitems
				WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#d_ebayitem#">
			</cfquery>

			<!--- do insert --->
			<!--- we need to do an insert in the ebitems so that the item will go to compined. the hbuserid is a combination of ebayitem_txnid. the combined page groups by hbuserid --->
			<!--- since ebayitem is a big int we will just concatenate the ebay high bidder like #d_ebayitem#.#attributes.txnid# and also check if this txn is also insert. coz it err when duplicate ebayitem # is used in insert  --->
			<cfquery datasource="#request.dsn#">
				insert into ebitems
				(
				itemid,
				hbuserid,
				dtwhen,
				ebayitem,
				dtstart,
				dtend,
				price,
				title,
				hbemail,
				description,
				primarycategoryid,
				timeleft,
				status,
				GalleryURL,
				PackagingHandlingCosts,
				itemxml,
				parentEbayItemFixed,
				ebayTransactionId
				)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.d_ebayitem#.#attributes.txnid#">,
				'#get_EbitemDetails.dtwhen#',
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#00#loopcount#">,
				'#get_EbitemDetails.dtstart#',
				'#get_EbitemDetails.dtend#',
				'#get_ebaydtls.TransactionPrice#',
				'#get_EbitemDetails.title#',
				'#get_ebaydtls.byremail#',
				'#get_EbitemDetails.description#',
				'#get_EbitemDetails.primarycategoryid#',
				'#get_EbitemDetails.timeleft#',
				'#get_EbitemDetails.status#',
				'#get_EbitemDetails.GalleryURL#',
				'#get_EbitemDetails.PackagingHandlingCosts#',
				'',
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.d_ebayitem#">,
				'#attributes.txnid#'

				)
			</cfquery>
		<cfelse>
			<!--- do an update here --->
			<cfquery datasource="#request.dsn#">
				update ebitems set
				hbuserid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.d_ebayitem#.#attributes.txnid#">,
				dtwhen = '#get_EbitemDetails.dtwhen#',
				ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#00#loopcount#">,
				dtstart = '#get_EbitemDetails.dtstart#',
				dtend '#get_EbitemDetails.dtend#',
				price = '#get_ebaydtls.TransactionPrice#',<!--- 20121023: change from amountPaid to TransactionPrice to display items selling price --->
				title = '#get_EbitemDetails.title#',
				hbemail = '#get_ebaydtls.byremail#',
				description = '#get_EbitemDetails.description#',
				primarycategoryid = '#get_EbitemDetails.primarycategoryid#',
				timeleft = '#get_EbitemDetails.timeleft#',
				status = '#get_EbitemDetails.status#',
				GalleryURL = '#get_EbitemDetails.GalleryURL#',
				PackagingHandlingCosts = '#get_EbitemDetails.PackagingHandlingCosts#',
				parentEbayItemFixed = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.d_ebayitem#">,
				ebayTransactionId = '#attributes.txnid#'
				where itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">
			</cfquery>
		</cfif>


		<cfquery name="sqlRecord" datasource="#request.dsn#">
			SELECT * FROM records
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">
		</cfquery>
		<cfif sqlRecord.RecordCount EQ 0>
			<cfquery name="sqlRecord" datasource="#request.dsn#">
				INSERT INTO records
				(itemid, [desc], aid, dstarted, dended, checksent, highbidder)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">,
					'AUTO-GENERATED DESCRIPTION FOR MISSING RECORD',
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(xitem, 2, '.')#">,
					NULL, NULL, '0', ''
				)
			</cfquery>
		</cfif>
		<!--- update records. this is also done in update item when editing --->
		<cfset attributes.price = REReplace(get_ebaydtls.TransactionPrice, "[^0-9\.]*", "", "ALL")>



		<cfif attributes.price EQ "">
			<cfset attributes.price = 0>
		<cfelse>
			<!---<cfset attributes.price = attributes.price/get_ebaydtls.itmQuantitySold >---><!--- this code didnt work coz transaction price is already spitting out the correct price per item  --->
		</cfif>




		<cfquery name="updateFprice" datasource="#request.dsn#" result="result">
			UPDATE records
			SET finalprice = '#attributes.price#',
				dended = <cfif isDate(get_ebaydtls.paidtime)>'#get_ebaydtls.paidtime#'<cfelse>'#get_ebaydtls.paidtime#'</cfif>
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xitem#">
		</cfquery>




		<cfset loopcount++>
		</cftransaction>


</cfloop>

</cfif>





<!--- if note save go to generate label --->
<!---<cfif get_ebaydtls.itmQuantitySold eq 1>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.combined">
</cfif>
--->

<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.awaitingFixedPriceV2">

