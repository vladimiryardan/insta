<cfquery name="sqlCopy" datasource="#request.dsn#">
	SELECT aid, title, age, description, startprice, weight,purchase_price,internal_itemSKU,internal_itemCondition,specialNotes,upc,
			startprice_real, weight_oz, upc, mpnbrand, mpnnum, sub_description, depth, height, width, buy_it_now, model2
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<!--- get category id from auction if existing --->
<cfquery name="getCatID" datasource="#request.dsn#">
	Select CategoryID
	FROM auctions
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>







<cfscript>
	attributes.accountid = sqlCopy.aid;
	attributes.title = sqlCopy.title;
	attributes.age = sqlCopy.age;
	attributes.desc = sqlCopy.description;
	attributes.description = sqlCopy.description;
	attributes.price = sqlCopy.startprice;
	attributes.weight = sqlCopy.weight;
	attributes.purchase_price = sqlCopy.purchase_price;
	attributes.startprice = sqlCopy.startprice;
	attributes.startprice_real = sqlCopy.startprice_real;
	attributes.sku = sqlCopy.internal_itemSKU;
	//attributes.itemCondition = sqlCopy.internal_itemCondition;
	attributes.specialNotes = sqlCopy.specialNotes;
	attributes.upc = sqlCopy.upc;
	attributes.weight_oz = sqlCopy.weight_oz;
	attributes.categoryid = "75";/*custom category*/
	

	attributes.mpnbrand = sqlCopy.mpnbrand;
	attributes.mpnnum = sqlCopy.mpnnum;
	attributes.model2 = sqlCopy.model2;
	
	attributes.sub_description = sqlCopy.sub_description;/*custom category*/
	
	
	attributes.height = sqlCopy.height;
	attributes.depth = sqlCopy.depth;
	attributes.width = sqlCopy.width;
	
	if(attributes.mpnbrand is ""){
		attributes.mpnbrand = 'Does Not Apply';
	}
	if(attributes.mpnnum is ""){
		attributes.mpnnum = 'Does Not Apply';
	}
	if(attributes.upc is ""){
		attributes.upc = 'Does Not Apply';
	}
	attributes.buy_it_now = sqlCopy.buy_it_now;

</cfscript>

<cfif getCatID.recordcount gte 1>
<cfscript>
	attributes.categoryid = getCatID.CategoryID;
</cfscript>
</cfif>