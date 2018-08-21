<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<!---
<cfdump var="hello!">
<cfdump var="#form#">
--->



<!--- 
	expected format is 201.13240.266|201.13235.65 where source item|template Item Match
	The source item is what we want to duplicate.
--->
<cfoutput>
	<cfif not isdefined("form.CHECKEDITEMS")>
		<h3>Undefined Items</h3>
		<cfabort>
	</cfif>	
	<h3>Items Duplicated</h3>
	<table bgcolor="##aaaaaa" cellspacing="0" cellpadding=0 width="100%" border="1">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">
				Auctioned Item
			</td>
			<td class="ColHead">
				Template Source
			</td>
		</tr>
		
	<cfloop index="i" list="#Form.CHECKEDITEMS#" delimiters=",">
	  
		<cfset item_toAuction = listfirst(i,"|")>
		<cfset item_template = listlast(i,"|") >
			   
			<cfquery datasource="#request.dsn#" name="sqlDefault">
				SELECT item, title, description, weight, weight_oz, bold, border, highlight, startprice_real, startprice, buy_it_now, internal_itemCondition, age,
				itemManual, itemComplete, itemTested, retailPackingIncluded, specialNotes, 
				internalShipToLocations, sub_description
				FROM items
				WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_template#">
			</cfquery>
		
			<cfquery datasource="#request.dsn#" name="getWeight">
				SELECT  weight,weight_oz,startprice_real
				FROM items
				WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_template#">
			</cfquery>

			<cfset thisDescription = "#_vars.lister.descriptionBegin#">
			<cfset thisWeight = "0">
			<cfset thisWeight_oz = "0">
			<cfif getWeight.recordcount gte 1>
				<cfset thisWeight = getWeight.weight >
				<cfset thisWeight_oz = getWeight.weight_oz >
			</cfif>

			<cfif sqlDefault.recordcount gte 1 >
			
				<cfset DynamicDescription = #Replace(_vars.lister.descriptionBegin, '{Description}', sqlDefault.description, 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{internal_item_condition}', sqlDefault.internal_itemCondition, 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{item_title}', sqlDefault.title, 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{itemManual}', YesNoFormat(sqlDefault.itemManual), 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{itemComplete}', YesNoFormat(sqlDefault.itemComplete), 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{itemTested}', YesNoFormat(sqlDefault.itemTested), 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{retailPackingIncluded}', YesNoFormat(sqlDefault.retailPackingIncluded), 'ALL')#>
				<cfset DynamicDescription = #Replace(DynamicDescription, '{retailPrice}', sqlDefault.age, 'ALL')#>
				<cfset DynamicDescription =	#Replace(DynamicDescription, '{Sub_item_Description}', sqlDefault.sub_description, 'ALL')#>
				<cfif sqlDefault.specialNotes eq "">
					<cfset sqlDefault.specialNotes = "N/A">
				</cfif>
				<cfset DynamicDescription =  #Replace(DynamicDescription, '{specialNotes}', sqlDefault.specialNotes, 'ALL')#>
				<cfset thisDescription = DynamicDescription >
				<cfset thisWeight = "#sqlDefault.weight#">
			</cfif>


			<cftransaction >
				<cfquery datasource="#request.dsn#" name="getStartPrice">
						SELECT startprice_real
						FROM items
						WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_toAuction#">
				</cfquery>
				<cfquery datasource="#request.dsn#">
					DELETE FROM auctions WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_toAuction#">
				</cfquery>
				<cfquery datasource="#request.dsn#">
						INSERT INTO auctions
						(
							itemid, ebayitem, Title, SubTitle, SiteID, 
							CategoryID, StoreCategoryID, StoreCategory2ID, Description, ListingType,
							StartingPrice, ReservePrice, BuyItNowPrice, Duration, Layout, 
							Bold, Border, Highlight, FeaturedPlus, PrivateAuctions,
							PaymentMethods, WhoPaysShipping, ShippingServiceCost, PackedWeight,	PackedWeight_oz, 
							PackageSize, ready, sandbox, GalleryImage,
							imagesLayout, location, scheduledBy, ShipToLocations, AttributeSetArray, LocalPickUp, use_pictures, ebayaccount, videoURL, ConditionID, conditionName,upc
						)
						SELECT
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#item_toAuction#"> AS itemid,
							ebayitem, 
							Title, 
							SubTitle, 
							SiteID, 
							CategoryID, 
							StoreCategoryID, 
							StoreCategory2ID,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisDescription#"> As Description,
							ListingType,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getStartPrice.startprice_real#"> AS StartingPrice,
							ReservePrice, 
							
							BuyItNowPrice, Duration, Layout, Bold, Border, 
							Highlight, FeaturedPlus, PrivateAuctions, PaymentMethods, WhoPaysShipping, 
							
							ShippingServiceCost, <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisWeight#"> As PackedWeight,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisWeight_oz#"> As PackedWeight_oz,
							
							PackageSize, ready, sandbox, GalleryImage,
							imagesLayout, location, scheduledBy, ShipToLocations, AttributeSetArray, LocalPickUp,
							CASE WHEN LEN(use_pictures) > 0
								THEN use_pictures
								ELSE itemid
							END AS use_pictures, ebayaccount, videoURL,ConditionID,conditionName,upc
						FROM auctions
						WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_template#">
					</cfquery>	
			
					<cfset LogAction("duplicated auction #item_template# to #item_toAuction#")>
					<cfif FileExists("#request.basepath#images/#item_toAuction#/1.jpg")>
						<cfquery datasource="#request.dsn#">
							UPDATE auctions
							SET use_pictures = NULL
							WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item_toAuction#">
						</cfquery>
					</cfif>
						
			</cftransaction>		
		<tr>
			<td>
				#item_toAuction#
			</td>
			<td>
				#item_template#
			</td>
		</tr>
	</cfloop>
	
	</table>
</cfoutput>