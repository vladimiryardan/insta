<cfif isDefined("attributes.back")>
	<cfquery name="sqlItemSpecific" datasource="#request.dsn#">
		SELECT COUNT(*) AS cnt
		FROM category2cs
		WHERE CategoryID = (
			SELECT CategoryID
			FROM auctions
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		)
	</cfquery>
	<cfif sqlItemSpecific.cnt EQ 0>
		<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.step1&item=#attributes.item#">
	<cfelse>
		<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.item_specific&item=#attributes.item#">
	</cfif>
<cfelseif isDefined("attributes.finish")>
	<cfset _machine.cflocation = "index.cfm?dsp=management.items.awaiting_listing">
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.step3&item=#attributes.item#">
</cfif>

<cfparam name="attributes.PaymentMethods" default="">
<cfparam name="attributes.bestOffer" default="0">

<cfquery datasource="#request.dsn#">
	UPDATE auctions
	SET ListingType		= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.ListingType#">,
	<cfif isDefined("attributes.StartingPrice")>
		StartingPrice	= <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.StartingPrice#">,
	</cfif>
	<cfif isDefined("attributes.ReservePrice")>
		ReservePrice	= <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ReservePrice#">,
	</cfif>
		BuyItNowPrice	= <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.BuyItNowPrice#">,
		Duration		= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.Duration#">,
		Layout			= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.Layout#">,
		imagesLayout	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.imagesLayout#">,
		Bold			= <cfif isDefined("attributes.Bold")>'1'<cfelse>'0'</cfif>,
		Border			= <cfif isDefined("attributes.Border")>'1'<cfelse>'0'</cfif>,
		Highlight		= <cfif isDefined("attributes.Highlight")>'1'<cfelse>'0'</cfif>,
		FeaturedPlus	= <cfif isDefined("attributes.FeaturedPlus")>'1'<cfelse>'0'</cfif>,
		bestOffer		= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.bestOffer#">,
		PrivateAuctions	= '#attributes.PrivateAuctions#',
		location		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.location#">,
		PaymentMethods	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PaymentMethods#" maxlength="200">,
		WhoPaysShipping	= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.WhoPaysShipping#">,
		PackedWeight	= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.PackedWeight#">,
		PackedWeight_oz	= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.PackedWeight_oz#">,
	<cfif attributes.PackageSize EQ "-1">
		LocalPickUp		= 1,
	<cfelse>
		PackageSize		= <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.PackageSize#">,
		LocalPickUp		= 0,
	</cfif>
		ShipToLocations	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ShipToLocations#">,
<cfif isdefined("attributes.itemQty")>
		 itemQty	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemQty#">,
</cfif>
		ShippingServiceCost	= <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ShippingServiceCost#">,
		scheduledBy		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(session.user.first, 1)##Left(session.user.last, 1)#">,
		ratetable = <cfif isDefined("attributes.ratetable")>'1'<cfelse>'0'</cfif>
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<!--- UPDATE DIMENSIONS --->
<cfparam name="attributes.width" default="1">
<cfparam name="attributes.height" default="1">
<cfparam name="attributes.depth" default="1">
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET width = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.width#">,
		height = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.height#">,
		depth = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.depth#">,
		internalShipToLocations	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ShipToLocations#">
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>



<!--- vlad added this for fixed item, 30 days to get correct final price ideally if the tracking number is added the final price will be reflected.
date added: 20101015


--->
