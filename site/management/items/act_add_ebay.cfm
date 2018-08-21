<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">
<cfparam name="attributes.ebayitem">

<cfset LogAction("assigned auction #attributes.ebayitem# to item #attributes.item#")>

<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&item=#attributes.item#">

<cfquery datasource="#request.dsn#" name="sqlEBAY">
	SELECT ReservePrice, price, dtend, hbuserid
	FROM ebitems
	WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
</cfquery>

<cfinclude template="../../admin/api/act_get_item_transaction.cfm">

<cfquery datasource="#request.dsn#" name="sqlTransactions">
	SELECT MAX(PaidTime) AS paid, MAX(ShippedTime) AS shipped
	FROM ebtransactions
	WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
</cfquery>

<cfquery datasource="#request.dsn#">
	UPDATE ebitems
	SET itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	WHERE ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
</cfquery>
<cfquery name="sqlListed" datasource="#request.dsn#">
	SELECT COUNT(ebayitem) AS cnt
	FROM ebitems
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET listcount = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlListed.cnt#">,
		startprice = '#sqlEBAY.ReservePrice#',
		<cfif sqlTransactions.paid EQ "">
			paid = '0',
			PaidTime = NULL,
		<cfelse>
			paid = '1',
			PaidTime = <cfqueryparam cfsqltype="cf_sql_date" value="#sqlTransactions.paid#">,
		</cfif>
		<cfif sqlTransactions.shipped EQ "">
			shipped = '0',
			ShippedTime = NULL,
		<cfelse>
			shipped = '1',
			ShippedTime = <cfqueryparam cfsqltype="cf_sql_date" value="#sqlTransactions.shipped#">,
		</cfif>
		ebayitem = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.ebayitem#">
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfscript>
	if(sqlEBAY.dtend GT Now()){ // auction is not ended
		fChangeStatus (attributes.item, 4); // AUCTION LISTED
	}else if((sqlEBAY.price LT sqlEBAY.ReservePrice) OR (sqlEBAY.hbuserid EQ "")){ // reserve not met or no high bidder
		fChangeStatus (attributes.item, 8); // DID NOT SELL
	}else if (sqlTransactions.paid EQ ""){ // item is NOT PAID
		fChangeStatus (attributes.item, 5); // AWAITING PAYMENT
	}else if (sqlTransactions.shipped EQ ""){ // item is NOT SHIPPED
		fChangeStatus (attributes.item, 10); // AWAITING SHIPMENT
	}else {
		fChangeStatus (attributes.item, 11); // PAID AND SHIPPED
	}
</cfscript>
