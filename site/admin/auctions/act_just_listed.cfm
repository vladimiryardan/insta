<cfparam name="attributes.sandbox" default="false">
<cfif attributes.sandbox>
	<cfquery datasource="#request.dsn#">
		UPDATE auctions
		SET sandbox = <cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
<cfelse>
	<cfquery datasource="#request.dsn#" name="sqlReserve">
		SELECT ReservePrice, Title, GalleryImage, LocalPickUp, PackedWeight, PackedWeight_oz
		FROM auctions
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET listcount = listcount + 1,
			exception  = 0,
			startprice = '#sqlReserve.ReservePrice#',
			paid = '0', paidtime = NULL,
			shipped = '0', shippedtime = NULL,
			ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfif sqlReserve.LocalPickUp EQ "0">
		<cfset PackagingHandlingCosts = getVar('Shipping.PackagingHandlingCosts', '150', 'NUMBER') + (sqlReserve.PackedWeight + sqlReserve.PackedWeight_oz/16) * getVar('Shipping.PackagingHandlingPerPound', '0.25', 'NUMBER')>
	<cfelseif isDefined("_ebay.xmlResponse.xmlRoot.ShippingDetails.CalculatedShippingRate.PackagingHandlingCosts.xmlText")>
		<cfset PackagingHandlingCosts = _ebay.xmlResponse.xmlRoot.ShippingDetails.CalculatedShippingRate.PackagingHandlingCosts.xmlText>
	<cfelse>
		<cfset PackagingHandlingCosts = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		INSERT INTO ebitems
		(itemxml, ebayitem, itemid, dtwhen, status, dtstart, dtend, price, bidcount, ReservePrice, GalleryURL, PackagingHandlingCosts, title)
		VALUES
		(
			'',
			<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">,
			GETDATE(),
			'syncronized',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(_ebay.xmlResponse.xmlRoot.StartTime.xmlText)#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromEBay(_ebay.xmlResponse.xmlRoot.EndTime.xmlText)#">,
			0,
			0,
			'#sqlReserve.ReservePrice#',
			<cfif sqlReserve.GalleryImage GT 0>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#_layout.ia_images##attributes.item#/#sqlReserve.GalleryImage#.jpg">,
			<cfelse>
				NULL,
			</cfif>
			<cfqueryparam cfsqltype="cf_sql_float" value="#PackagingHandlingCosts#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlReserve.Title#">
		)
	</cfquery>
	<cfquery datasource="#request.dsn#">
		DELETE FROM queue
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfscript>
		fChangeStatus(attributes.item, 4); // AUCTION LISTED
		LogAction("just listed item #attributes.item# as #_ebay.xmlResponse.xmlRoot.ItemID.xmlText#");
		if(ListFindNoCase("AddItem,RelistItem", attributes.CallName)){
			if(attributes.CallName EQ "AddItem"){
				gid = 2; // eBay Fees for AddItem
			}else{
				gid = 3; // eBay Fees for RelistItem
			}
			Fees = _ebay.xmlResponse.xmlRoot.Fees.xmlChildren;
			for(i=1; i LTE ArrayLen(Fees); i=i+1){
				fee = Val(Fees[i].Fee.xmlText);
				feeName = Fees[i].Name.xmlText;
				if((fee GT 0) AND (feeName NEQ "ListingFee")){
					LogDynamicIRE(gid, feeName, fee, attributes.item, _ebay.xmlResponse.xmlRoot.ItemID.xmlText);
				}
			}
		}
	</cfscript>
</cfif>
