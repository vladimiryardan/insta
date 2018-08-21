<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">
<cfscript>
	countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
	provincesList	= "XX,SELECT ONE;AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon";
	//20111129 vlad added in the statelist (Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine etc) //Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine;California,California;Canarias,Canarias;Cheshire,Cheshire;Colorado,Colorado;Estado de Mexico,Estado de Mexico;Florida,Florida;Georgia,Georgia;Hawaii,Hawaii;Hong Kong,Hong Kong;Iceland,Iceland;Illinois,Illinois;INDIANA,INDIANA;Israel,Israel;KANSAS,KANSAS;KENTUCKY,KENTUCKY;Lancashire,Lancashire;Madrid,Madrid;MAINE,MAINE;Maryland,Maryland;MASSACHUSETTS,MASSACHUSETTS;MICHIGAN,MICHIGAN;MINNESOTA,MINNESOTA;Missouri,Missouri;MONTANA,MONTANA;NEVADA,NEVADA;NEW JERSEY,NEW JERSEY;NEW MEXICO,NEW MEXICO;New South Wales,New South Wales;New York,New York;North Carolina,North Carolina;Norway,Norway;Nunavut,Nunavut;Odessa,Odessa;Oklahoma,Oklahoma;Ontario,Ontario;OREGON,OREGON;PENNSYLVANIA,PENNSYLVANIA;Picardie,Picardie;Puerto Rico,Puerto Rico;Queensland,Queensland;SOUTH CAROLINA,SOUTH CAROLINA;Swansea,Swansea;Tennessee,Tennessee;Washington,Washington;Varese,Varese;Vermont,Vermont;Victoria,Victoria;Virginia,Virginia;WEST VIRGINIA,WEST VIRGINIA;WISCONSIN,WISCONSIN;WYOMING,WYOMING;
	statesList		= "XX,SELECT ONE;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming;";
	upsServices		= "01,Next Day Air;02,2nd Day Air;03,Ground;07,Worldwide Express;08,Worldwide Expedited;11,Standard;12,3-Day Select;13,Next Day Air Saver;14,Next Day Air Early A.M.;54,Worldwide Express Plus;59,2nd Day Air A.M.;92,SurePost Less than 1 lb;93,SurePost 1 lb or Greater";
	packageTypes	= "01,Letter/Express Envelope;02,Package;03,Tube;04,Pak;21,Express Box;24,25KG Box;25,10KG Box";
</cfscript>

<cfquery name="sqlItem" datasource="#request.dsn#" maxrows="1">
	SELECT i.weight, i.ebayitem, i.shipper, i.tracking, i.aid, i.item, i.dcreated, i.shipnote,
		a.email, a.first, a.last, e.title, e.hbuserid, e.hbemail, e.price, i.byrName, i.byrStreet1, i.byrStreet2,
		i.byrCountry, i.byrPostalCode, i.byrCityName, i.byrStateOrProvince, i.byrPhone, t.TransactionID, t.AmountPaid,
		i.offebay, i.ebayFixedPricePaid, i.ebayTxnid, t.byremail, i.internal_itemSKU, i.internal_itemSKU2, i.lid, i.weight_oz, i.depth, 
		i.height, i.width
	FROM items i
		INNER JOIN accounts a ON a.id = i.aid
		LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
		LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
	WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		AND
		(
			(
				( t.stsCompleteStatus = 'Complete'
				AND t.stsCheckoutStatus = 'CheckoutComplete'
				AND t.stseBayPaymentStatus = 'NoPaymentFailure'
				)
				OR t.stsPaymentMethodUsed != 'PayPal'
			)
			OR
			i.offebay = 1
			or
			i.offebay = 2 <!--- this are fixed price items with multi txns --->
		)
	ORDER BY t.tid DESC
</cfquery>

<!--- if this is a fixed price item and offebay is 2 we will need to parse hbuserid and get the ebayitem and set the sqlitem.ebayitem --->
<cfif sqlItem.offebay eq 2>
	<!--- get the ebayitem --->
	<cfset theEbayitem = #trim(ListGetAt(sqlItem.hbuserid, 1 ,"."))#>
	<cfset sqlItem.ebayitem = theEbayitem >
</cfif>


<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>UPS Label:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
	<!---Item Owner
	<b>Item Owner:</b> <a href="index.cfm?dsp=account.edit&id=#sqlItem.aid#">#sqlItem.first# #sqlItem.last#</a>
	<a href="mailto:#sqlItem.email#?subject=Instant Auctions: Item #sqlItem.item#"><img src="#request.images_path#emailblue.gif" align="middle" border=0></a>
	<br><br>
	--->
</cfoutput>

<cfset drawForm = "confirm">
<cfif isDefined("attributes.confirm")><!--- Perform call --->
	<cfinclude template="act_confirm.cfm">
<cfelseif isDefined("attributes.accept")><!--- Perform call --->
	<cfinclude template="act_accept.cfm">
</cfif>
<cfif drawForm EQ "confirm">
	<cfif isDefined("attributes.confirm")><!--- re-draw submitted values --->
		<cfset pageData = StructNew()>
		<cfloop index="i" list="ShipperNumber,UPSService,Weight,PackageType,DeclaredValue,OversizePackage,height,width,depth">
			<cfif isDefined("attributes.#i#")>
				<cfset pageData[i] = attributes[i]>
			<cfelse>
				<cfset pageData[i] = "UNDEFINED">
			</cfif>
		</cfloop>
		<cfloop index="i" list="Company,Attention,Address1,Address2,Address3,Country,ZIPCode,City,State,Telephone,Email">
			<cfif isDefined("attributes.TO_#i#")>
				<cfset pageData["TO_#i#"] = attributes["TO_#i#"]>
			<cfelse>
				<cfset pageData["TO_#i#"] = "UNDEFINED">
			</cfif>
		</cfloop>
	<cfelse><!--- setup default values --->

	<!---vry added this code to handle price of amazon and set the declared value  --->
	<cfif sqlItem.offebay eq 1>
		<cfquery name="sqlAmazonItem" datasource="#request.dsn#" maxrows="1">
			select amazon_item_ordertotal_amount from amazon_items
			where items_itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfif sqlAmazonItem.recordcount gte 1>
			<cfset declaredValue = sqlAmazonItem.amazon_item_ordertotal_amount >
		<cfelse>
			<cfset declaredValue = sqlItem.price >
		</cfif>
		
		
		<!--- :vladedit: 20160622. offebay but not amazon --->
		<cfif declaredValue eq "">
			<cfquery datasource="#request.dsn#" name="sqlRecord">
				SELECT finalprice, dended
				FROM records
				WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
			</cfquery>
			<cfset declaredValue = sqlRecord.finalprice >
		</cfif>
		
	<!--- vlad added 20120131 --->
	<cfelseif sqlItem.offebay eq 2>
		<cfset declaredValue = sqlItem.ebayFixedPricePaid >
	<cfelse>
		<cfset declaredValue = sqlItem.price >
	</cfif>



		<cfscript>
			pageData = StructNew();
			pageData.ShipperNumber		=	_vars.ups.ShipperNumber;
			pageData.UPSService			=	"03";
			
			pageData.Weight				=	sqlItem.weight;
			pageData.WeightOz			=	sqlItem.weight_oz;
			
			pageData.height				=	sqlItem.height;
			pageData.depth				=	sqlItem.depth;
			pageData.width				=	sqlItem.width;
			
			pageData.PackageType		=	"2";
			pageData.DeclaredValue		=	declaredValue;
			pageData.OversizePackage	=	"0";

			pageData.TO_Company			=	sqlItem.byrName;
			pageData.TO_Attention		=	"";
			pageData.TO_Address1		=	sqlItem.byrStreet1;
			pageData.TO_Address2		=	sqlItem.byrStreet2;
			pageData.TO_Address3		=	"";
			pageData.TO_Country			=	sqlItem.byrCountry;
			pageData.TO_ZIPCode			=	sqlItem.byrPostalCode;
			pageData.TO_City			=	sqlItem.byrCityName;
			pageData.TO_State			=	sqlItem.byrStateOrProvince;
			pageData.TO_Telephone		=	sqlItem.byrPhone;
			//vlad changed this 20120131 to catch offebay: 0 is ebay sold, 1 is amazon, 2 is ebay sold but fixed price multi txn. 1&2 no emails
			if (sqlItem.offebay eq 0){
				pageData.TO_Email			=	sqlItem.hbemail;
			}else if(sqlItem.offebay eq 2){
				pageData.TO_Email			=	sqlItem.byremail;
			}
			else{
				pageData.TO_Email			=	"";
			}

		</cfscript>
	</cfif>
	<cfinclude template="dsp_confirm.cfm">
<cfelseif drawForm EQ "accept">
	<cfinclude template="dsp_accept.cfm">
<cfelse>
	<cfinclude template="dsp_make.cfm">
</cfif>
<cfoutput>
</td></tr>
</table>
<br>
</cfoutput>
