<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfscript>
	countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
	MailClassList	= "PRIORITY,Priority Mail;FIRST,First Class Mail;LIBRARYMAIL,Library Mail;MEDIAMAIL,Media Mail;PARCELPOST,Parcel Post;EXPRESS,Express Mail;ExpressMailInternational,Express Mail International;PriorityMailInternational,Priority Mail International;PRIORITY:RegionalRateBoxA,Priority Mail Regional Rate Box A;PRIORITY:RegionalRateBoxB,Priority Mail Regional Rate Box B;PRIORITY:RegionalRateBoxC,Priority Mail Regional Rate Box C;PRIORITY:LargeFlatRateBox,Priority Mail Large Flat Rate Box;PRIORITY:MediumFlatRateBox,Priority Mail Medium Flat Rate Box;PRIORITY:SmallFlatRateBox,Priority Mail Small Flat Rate Box;PRIORITY:FlatRatePaddedEnvelope,Priority Mail Padded Flat Rate Envelope;PRIORITY:FlatRateEnvelope,Priority Mail Flat Rate Envelope 12.5 x 9.5 inches;PRIORITY:FlatRateLegalEnvelope,Legal Flat Rate Envelope 15 x 9.5 inches;";
	InsuredMailList	= "OFF,None;ENDICIA,Endicia Insurace;ON,USPS Insurance";
	
/* FOR ILLUSTRATION ONLY. THE STRING SHOULD BE ONE STRAIGHT LINE
MailClassList	= "PRIORITY,Priority Mail;
	FIRST,First Class Mail;
	LIBRARYMAIL,Library Mail;
	MEDIAMAIL,Media Mail;
	PARCELPOST,Parcel Post;
	EXPRESS,Express Mail;
	ExpressMailInternational,Express Mail International;
	PriorityMailInternational,Priority Mail International;
	PRIORITY:RegionalRateBoxA,Priority Mail Regional Rate Box A;
	PRIORITY:RegionalRateBoxB,Priority Mail Regional Rate Box B;
	PRIORITY:RegionalRateBoxC,Priority Mail Regional Rate Box C;
	PRIORITY:LargeFlatRateBox,Priority Mail Large Flat Rate Box;
	PRIORITY:MediumFlatRateBox,Priority Mail Medium Flat Rate Box;
	PRIORITY:SmallFlatRateBox,Priority Mail Small Flat Rate Box;
	PRIORITY:FlatRatePaddedEnvelope,Priority Mail Padded Flat Rate Envelope;
	PRIORITY:FlatRateEnvelope,Priority Mail Flat Rate Envelope 12.5 x 9.5 inches;
	PRIORITY:FlatRateLegalEnvelope,Legal Flat Rate Envelope 15 x 9.5 inches;";
	InsuredMailList	= "OFF,None;ENDICIA,Endicia Insurace;ON,USPS Insurance";*/	
	
</cfscript>


<cfquery name="sqlItem" datasource="#request.dsn#" maxrows="1">
	SELECT i.item, i.weight, i.shipnote, i.ebayitem,
		e.hbemail, e.price, e.title,
		i.byrName, i.byrStreet1, i.byrStreet2, i.byrCountry, i.byrPostalCode, i.byrCityName, i.byrStateOrProvince,
		i.byrPhone, i.offebay, i.ebayFixedPricePaid, i.ebayTxnid, t.byremail,
		i.internal_itemSKU, i.internal_itemSKU2, i.lid, i.weight_oz,i.depth, 
		i.height, i.width
	FROM items i
		LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
		LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
	WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>



<cfparam name="attributes.Test" default="NO">
<cfif isNumeric(sqlItem.ebayitem)>

	<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
		SELECT AmountPaid FROM ebtransactions
		WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlItem.ebayitem#">
		ORDER BY tid DESC
	</cfquery>

	<!--- override the sqlTransaction query if its a fixed price multi qty fixed item  --->
	<cfif sqlitem.offebay eq 2>
		<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
			SELECT ebayFixedPricePaid as AmountPaid FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
	</cfif>
<cfelse>
	<cfscript>
		sqlTransaction = QueryNew("AmountPaid");
		QueryAddRow(sqlTransaction);
		QuerySetCell(sqlTransaction, "AmountPaid", "");
	</cfscript>
</cfif>
<cfif isNumeric(sqlTransaction.AmountPaid) AND (sqlItem.price EQ sqlTransaction.AmountPaid) and (sqlItem.weight gte "2")>
	<cfparam name="attributes.MailClass" default="PRIORITY">
<cfelseif isNumeric(sqlTransaction.AmountPaid) AND (sqlItem.price EQ sqlTransaction.AmountPaid)>
	<cfparam name="attributes.MailClass" default="FIRST">
<cfelseif sqlItem.byrCountry EQ "US">
	<cfparam name="attributes.MailClass" default="PRIORITY">
<cfelse>
	<cfparam name="attributes.MailClass" default="PriorityMailInternational">
</cfif>

<cfif isDefined("attributes.submit")>
	<cfinclude template="dsp_create_label.cfm">
	<!--- re-draw submitted values --->
	<cfset pageData = StructNew()>
	<!---:vladedit: 2015708 - added vars for dimension computation --->
	<cfloop index="i" list="Test,MailClass,Weight,WeightOz,DeclaredValue,InsuredMail,height,depth,width">
		<cfif isDefined("attributes.#i#")>
			<cfset pageData[i] = attributes[i]>
		<cfelse>
			<cfset pageData[i] = "UNDEFINED">
		</cfif>
	</cfloop>
	<cfloop index="i" list="Name,Firm,Address1,Address2,Address3,City,Province,Country,PostalCode,Phone,Email">
		<cfif isDefined("attributes.TO_#i#")>
			<cfset pageData["TO_#i#"] = attributes["TO_#i#"]>
		<cfelse>
			<cfset pageData["TO_#i#"] = "UNDEFINED">
		</cfif>
	</cfloop>
<cfelse>

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

	<!--- setup default values --->
	<cfscript>
		pageData = StructNew();
		pageData.Test				=	attributes.Test;
		pageData.MailClass			=	attributes.MailClass;
		pageData.Weight				=	sqlItem.weight;
		pageData.WeightOz			=	sqlItem.weight_oz;
		
		pageData.height				=	sqlItem.height;
		pageData.depth				=	sqlItem.depth;
		pageData.width				=	sqlItem.width;
			
		//pageData.DeclaredValue		=	sqlItem.price;
		pageData.DeclaredValue		=	declaredValue;
		if(sqlItem.price GT 100){
			pageData.InsuredMail	=	"ENDICIA";
		}else{
			pageData.InsuredMail	=	"OFF";
		}

		pageData.TO_Name			=	sqlItem.byrName;
		pageData.TO_Firm			=	"";
		pageData.TO_Address1		=	sqlItem.byrStreet1;
		pageData.TO_Address2		=	sqlItem.byrStreet2;
		pageData.TO_Address3		=	"";
		pageData.TO_City			=	sqlItem.byrCityName;
		pageData.TO_Province		=	sqlItem.byrStateOrProvince;
		pageData.TO_Country			=	sqlItem.byrCountry;
		pageData.TO_PostalCode		=	ListFirst(sqlItem.byrPostalCode, "-");
		pageData.TO_Phone			=	sqlItem.byrPhone;
		//vlad changed this 20120131 to catch offebay: 0 is ebay sold, 1 is amazon, 2 is ebay sold but fixed price multi txn. 1&2 no emails
		if (sqlItem.offebay eq 0){
			pageData.TO_Email			=	sqlItem.hbemail;
		}else if(sqlItem.offebay eq 2){
				pageData.TO_Email			=	sqlItem.byremail;
		}else{
			pageData.TO_Email			=	"";
		}
	</cfscript>
</cfif>
<cfswitch expression="#pageData.TO_Country#">
	<cfcase value="AA"><cfset pageData.TO_Country = "AA"></cfcase>
	<cfcase value="AR"><cfset pageData.TO_Country = "Argentina"></cfcase>
	<cfcase value="AU"><cfset pageData.TO_Country = "Australia"></cfcase>
	<cfcase value="AT"><cfset pageData.TO_Country = "Austria"></cfcase>
	<cfcase value="BE"><cfset pageData.TO_Country = "Belgium"></cfcase>
	<cfcase value="BR"><cfset pageData.TO_Country = "Brazil"></cfcase>
<!---	<cfcase value="CA"><cfset pageData.TO_Country = "Canada"></cfcase>--->
	<cfcase value="CL"><cfset pageData.TO_Country = "Chile"></cfcase>
	<cfcase value="CN"><cfset pageData.TO_Country = "China"></cfcase>
	<cfcase value="CR"><cfset pageData.TO_Country = "Costa Rica"></cfcase>
	<cfcase value="CZ"><cfset pageData.TO_Country = "Czech Republic"></cfcase>
	<cfcase value="DK"><cfset pageData.TO_Country = "Denmark"></cfcase>
	<cfcase value="DO"><cfset pageData.TO_Country = "Dominican Republic"></cfcase>
	<cfcase value="EC"><cfset pageData.TO_Country = "Ecuador"></cfcase>
	<cfcase value="FI"><cfset pageData.TO_Country = "Finland"></cfcase>
	<cfcase value="FR"><cfset pageData.TO_Country = "France"></cfcase>
	<cfcase value="GF"><cfset pageData.TO_Country = "French Guiana"></cfcase>
	<cfcase value="DE"><cfset pageData.TO_Country = "Germany"></cfcase>
	<cfcase value="GR"><cfset pageData.TO_Country = "Greece"></cfcase>
	<cfcase value="GT"><cfset pageData.TO_Country = "Guatemala"></cfcase>
	<cfcase value="HK"><cfset pageData.TO_Country = "Hong Kong"></cfcase>
	<cfcase value="HU"><cfset pageData.TO_Country = "Hungary"></cfcase>
	<cfcase value="IN"><cfset pageData.TO_Country = "India"></cfcase>
	<cfcase value="ID"><cfset pageData.TO_Country = "Indonesia"></cfcase>
	<cfcase value="IE"><cfset pageData.TO_Country = "Ireland"></cfcase>
	<cfcase value="IL"><cfset pageData.TO_Country = "Israel"></cfcase>
	<cfcase value="IT"><cfset pageData.TO_Country = "Italy"></cfcase>
	<cfcase value="JP"><cfset pageData.TO_Country = "Japan"></cfcase>
	<cfcase value="MY"><cfset pageData.TO_Country = "Malaysia"></cfcase>
	<cfcase value="MX"><cfset pageData.TO_Country = "Mexico"></cfcase>
	<cfcase value="NL"><cfset pageData.TO_Country = "Netherlands"></cfcase>
	<cfcase value="NZ"><cfset pageData.TO_Country = "New Zealand"></cfcase>
	<cfcase value="NO"><cfset pageData.TO_Country = "Norway"></cfcase>
	<cfcase value="PA"><cfset pageData.TO_Country = "Panama"></cfcase>
	<cfcase value="PH"><cfset pageData.TO_Country = "Philippines"></cfcase>
	<cfcase value="PT"><cfset pageData.TO_Country = "Portugal"></cfcase>
	<cfcase value="PR"><cfset pageData.TO_Country = "Puerto Rico"></cfcase>
	<cfcase value="SG"><cfset pageData.TO_Country = "Singapore"></cfcase>
	<cfcase value="ES"><cfset pageData.TO_Country = "Spain"></cfcase>
	<cfcase value="ZA"><cfset pageData.TO_Country = "South Africa"></cfcase>
	<cfcase value="KR"><cfset pageData.TO_Country = "South Korea"></cfcase>
	<cfcase value="SE"><cfset pageData.TO_Country = "Sweden"></cfcase>
	<cfcase value="CH"><cfset pageData.TO_Country = "Switzerland"></cfcase>
	<cfcase value="TW"><cfset pageData.TO_Country = "Taiwan"></cfcase>
	<cfcase value="TH"><cfset pageData.TO_Country = "Thailand"></cfcase>
	<cfcase value="GB"><cfset pageData.TO_Country = "United Kingdom"></cfcase>
<!---	<cfcase value="US"><cfset pageData.TO_Country = "United States"></cfcase>--->
	<cfcase value="VE"><cfset pageData.TO_Country = "Venezuela"></cfcase>
</cfswitch>
