<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfset LogAction("edited item #attributes.item#")>

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

<cfset attributes.startprice_real = REReplace(attributes.startprice_real, "[^0-9\.]*", "", "ALL")>
<cfif attributes.startprice_real EQ "">
	<cfset attributes.startprice_real = 0>
</cfif>
<cfset attributes.startprice = REReplace(attributes.startprice, "[^0-9\.]*", "", "ALL")>
<cfif attributes.startprice EQ "">
	<cfset attributes.startprice = 0>
</cfif>
<cfset attributes.buy_it_now = REReplace(attributes.buy_it_now, "[^0-9\.]*", "", "ALL")>
<cfif attributes.buy_it_now EQ "">
	<cfset attributes.buy_it_now = 0>
</cfif>
<cfparam name="attributes.commission" default="0">
<cfif isAllowed("Items_EditCommission")>
	<cfset attributes.commission = REReplace(ListFirst(attributes.commission, "."), "[^0-9]*", "", "ALL")>
	<cfif attributes.commission EQ "">
		<cfset attributes.commission = 0>
	</cfif>
</cfif>
<cfparam name="attributes.offebay" default="0">
<cfparam name="attributes.bold" default="0">
<cfparam name="attributes.border" default="0">
<cfparam name="attributes.highlight" default="0">
<cfparam name="attributes.vehicle" default="0">
<cfparam name="attributes.width" default="1">
<cfparam name="attributes.height" default="1">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.label_printed" default="0">
<cfparam name="attributes.internal_itemSKU" default="00001">
<cfparam name="attributes.internal_itemSKU2" default="00001">
<cfparam name="attributes.itemCondition" default="">
<cfparam name="attributes.itemManual" default="">
<cfparam name="attributes.itemComplete" default="">
<cfparam name="attributes.itemTested" default="">
<cfparam name="attributes.retailPackingIncluded" default="">
<cfparam name="attributes.specialNotes" default="">
<cfparam name="attributes.internalShipToLocations" default="Worldwide">
<cfparam name="attributes.upc" default="">
<cfparam name="attributes.customer_returned" default="">

<cfparam name="attributes.mpnBrand" default="">
<cfparam name="attributes.mpnNum" default="">
<cfparam name="attributes.sub_description" default="">
<cfparam name="attributes.dummy" default="0">
<cfparam name="attributes.isbn" default="">
<cfparam name="attributes.model2" default="">

<cfquery datasource="#request.dsn#" name="sqlOldItem">
	SELECT offebay, status, ebayitem
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET
	<cfif isAllowed("Items_EditDescriptions")>
		title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.title#">,
		description = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.description#">,
	</cfif>
		age = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.age#">,
	<cfif isAllowed("Items_EditCommission")>
		commission = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.commission#">,
	</cfif>
		startprice_real = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.startprice_real#">,
	<cfif isAllowed("Items_EditDescriptions")>
		startprice = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.startprice#">,
	</cfif>
		buy_it_now = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.buy_it_now#">,
		weight = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.weight#" null="#IIF(Trim(attributes.weight) EQ '', DE('YES'), DE('NO'))#">,
		width = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.width#">,
		height = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.height#">,
		depth = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.depth#">,
		offebay = '#attributes.offebay#',
		bold = '#attributes.bold#',
		border = '#attributes.border#',
		highlight = '#attributes.highlight#',
		vehicle = '#attributes.vehicle#',
		label_printed = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.label_printed#">,
		weight_oz = <cfif Len(attributes.weight_oz)>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.weight_oz#">
					<cfelse>
						0
					</cfif>,
		internal_itemSKU = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.internal_itemSKU#">,
		internal_itemSKU2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.internal_itemSKU2#">,

		internal_itemCondition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemCondition#">,
		itemManual = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemManual#">,
		itemComplete = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemComplete#">,
		itemTested = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemTested#">,
		retailPackingIncluded =	<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.retailPackingIncluded#">,
		specialNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.specialNotes#">,
		internalShipToLocations = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.internalShipToLocations#">,
		upc=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.upc#">,
		customer_returned=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.customer_returned#">,
		mpnbrand=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.mpnbrand#">,
		mpnNum=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.mpnNum#">,
		sub_description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.sub_description#">,
		dummy=<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.dummy#">,
		isbn=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.isbn#">,
		model2=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.model2#">

	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfif (attributes.offebay NEQ "1") AND (sqlOldItem.offebay EQ "1")>
	<cfif sqlOldItem.ebayitem EQ "">
		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET status = '3',
				dreceived = GETDATE()
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
	<cfelse>
		<cfset attributes.ebayitem = sqlOldItem.ebayitem>
		<cfinclude template="act_add_ebay.cfm">
	</cfif>
</cfif>
<cfif (attributes.offebay EQ "1") AND (sqlOldItem.offebay NEQ "1")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET status = '10',
			paid = '1',
			PaidTime = GETDATE()
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>
<cfif (attributes.offebay EQ "1") AND (sqlOldItem.offebay EQ "1")>
	<cfset attributes.price = REReplace(attributes.price, "[^0-9\.]*", "", "ALL")>
	<cfif attributes.price EQ "">
		<cfset attributes.price = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		UPDATE records
		SET finalprice = '#attributes.price#',
			dended = <cfif isDate(attributes.dended)>'#attributes.dended#'<cfelse>GETDATE()</cfif>
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>

<cfparam name="attributes.returned" default="0">
<cfscript>
if(attributes.returned NEQ "na"){
	if((attributes.returned EQ "1") AND (sqlOldItem.status NEQ "9")){
		fChangeStatus (attributes.item, 9); // RETURNED TO CLIENT
	}else if((attributes.returned EQ "0") AND (sqlOldItem.status EQ "9")){
		fChangeStatus (attributes.item, 8); // DID NOT SELL
	}
}
</cfscript>

<cfinclude template="act_recalculate_fees.cfm">

<cfset _machine.cflocation = "index.cfm?dsp=management.items.edit&msg=1&item=#attributes.item#">
