<!--- here is where the amazon items_itemid will be updated --->
<cfif NOT isAllowed("Items_ChangeStatus") AND NOT isAllowed("Items_NormalChangeStatus")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<!--- manage items permission --->
<cfif not isAllowed("Items_EditDescriptions")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<!---get_amazondtls--->
<cfparam name="attributes.byrOrderQtyToShip" default="1" >
<cfparam name="attributes.instaItemid" default="" >
<cfparam name="attributes.txnid" default="" >
<cfparam name="attributes.d_ebayitem" default="" >
<cfparam name="attributes.d_tid" default="" >
<cfparam name="attributes.d_itmsku" default="" >
<cfparam name="attributes.offebay" default="2"><!--- off ebay 2 but really sold in ebay --->
<cfparam name="attributes.itemCondition" default="Ebay Fixed price Multi transactions">
<cfset loopcount = 1><!--- since this is expecting a single link we will set loopcount to 1. in multi item linking this varies from 1 to n --->

<!--- to be consistent with attrib attributes.item--->
<cfset attributes.item = attributes.instaItemid>
<cfset LogAction("edited item #attributes.instaItemid# linked to ebay #attributes.d_ebayitem#-#attributes.d_tid#")>

<!--- generate a unique id not in ebay --->
<cfset createObject("java", "java.lang.Thread").sleep(JavaCast("int", 1000))><!--- sleep for 1 sec to avoid concurrent calls problem  --->
<cfset theEbayId = DateDiff("s", "12-31-1979 00:00:00", now())>
<cfset theEbayId = "#theEbayId#00#loopcount#">



<cftransaction>
<!--- check ebtransactions_lti if record already exists  --->
<cfquery name="get_lti" datasource="#request.dsn#">
	select * from ebtransactions_lti
	where
	transactionid_lti = '#attributes.txnid#'
	and ebayitem_lti = '#attributes.d_ebayitem#'
</cfquery>
<cfif get_lti.recordcount gte 1>
<!--- do update --->
<!--- link to insta itemid: here we will save this  --->
<cfquery datasource="#request.dsn#">
	UPDATE ebtransactions_lti
	set itemid_lti = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	where transactionid_lti = '#attributes.txnid#' and ebayitem_lti = '#attributes.d_ebayitem#'
</cfquery>
<cfelse>
<!--- do insert --->
	<cfquery datasource="#request.dsn#">
		insert into ebtransactions_lti
		(transactionid_lti,ebayitem_lti,itemid_lti)
		values(
		#attributes.txnid#,
		#attributes.d_ebayitem#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		)
	</cfquery>
</cfif>


<!--- get the amazon details --->
<!--- This will be the link the amazon item to insta item. --->
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


<!--- update to internal_itemCondition --->
<cfquery datasource="#request.dsn#">
	update items
	set internal_itemCondition = '#attributes.itemCondition#',
	status = '10',<!--- update to awaiting shipment --->
	Internal_itemsku = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_ebaydtls.itmSKU#">,
	paid = '1',
	offebay = '#attributes.offebay#', <!--- set to 2 for item ebay sold but multi qty and fixed price --->
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
	ebayitem = '#theEbayId#',
	ebayTxnid = '#attributes.txnid#',
	ebayFixedPricePaid = '#get_ebaydtls.AmountPaid#'
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfquery name="chkEbitems" datasource="#request.dsn#">
	SELECT * FROM ebitems
	WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#">
</cfquery>
<!--- to create a good record of linking item we will insert an ebayitem --->
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
		WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.d_ebayitem#">
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
		itemxml
		)
		values(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.d_ebayitem#.#attributes.txnid#">,
		'#get_EbitemDetails.dtwhen#',
		<cfqueryparam cfsqltype="cf_sql_bigint" value="#theEbayId#">,
		'#get_EbitemDetails.dtstart#',
		'#get_EbitemDetails.dtend#',
		'#get_ebaydtls.AmountPaid#',
		'#get_EbitemDetails.title#',
		'#get_ebaydtls.byremail#',
		'#get_EbitemDetails.description#',
		'#get_EbitemDetails.primarycategoryid#',
		'#get_EbitemDetails.timeleft#',
		'#get_EbitemDetails.status#',
		'#get_EbitemDetails.GalleryURL#',
		'#get_EbitemDetails.PackagingHandlingCosts#',
		''
		)
	</cfquery>
<cfelse>
	<h1>Error in inserting the ebay ID! Please try again.</h1>
	<cfabort>
</cfif>

<cfquery name="sqlRecord" datasource="#request.dsn#">
	SELECT * FROM records
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfif sqlRecord.RecordCount EQ 0>
	<cfquery name="sqlRecord" datasource="#request.dsn#">
		INSERT INTO records
		(itemid, [desc], aid, dstarted, dended, checksent, highbidder)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">,
			'AUTO-GENERATED DESCRIPTION FOR MISSING RECORD',
			<cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(attributes.item, 2, '.')#">,
			NULL, NULL, '0', ''
		)
	</cfquery>
</cfif>

<!--- update records. this is also done in update item when editing --->
<cfset attributes.price = REReplace(get_ebaydtls.TransactionPrice, "[^0-9\.]*", "", "ALL")>
<cfif attributes.price EQ "">
	<cfset attributes.price = 0>
</cfif>
<cfquery datasource="#request.dsn#">
	UPDATE records
	SET finalprice = '#attributes.price#',
		dended = <cfif isDate(get_ebaydtls.paidtime)>'#get_ebaydtls.paidtime#'<cfelse>'#get_ebaydtls.paidtime#'</cfif>
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
</cftransaction>



<!--- if btn_save redirects to list of awaiting fixed price --->
<cfif isdefined("attributes.btn_save")>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.awaitingFixedPrice">
<cfelse><!--- if note save go to generate label --->
	<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.gl_lti&item=#instaItemid#&ship_list=all">
</cfif>
