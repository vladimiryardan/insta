<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfscript>
	countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
	MailClassList	= "EXPRESS,Express Mail;FIRST,First Class Mail;LIBRARYMAIL,Library Mail;MEDIAMAIL,Media Mail;PARCELPOST,Parcel Post;PRIORITY,Priority Mail;ExpressMailInternational,Express Mail International;PriorityMailInternational,Priority Mail International";
	InsuredMailList	= "OFF,None;ENDICIA,Endicia Insurace;ON,USPS Insurance";
</cfscript>

<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT i.item, 
		i.weight, 
		i.ebayitem,
		e.hbemail, 
		e.price, 
		e.title,
		i.byrName, 
		i.byrStreet1, 
		i.byrStreet2, 
		i.byrCountry, 
		i.byrPostalCode, 
		i.byrCityName, 
		i.byrStateOrProvince, 
		i.byrPhone,
		i.internal_itemSKU, 
		i.internal_itemSKU2,
		i.lid,
		i.aid,
		a.first, 
		a.last,
		i.dcreated,
		e.hbuserid,
		i.offebay,
		i.shipnote,
		i.height,
		i.width,
		i.depth,
		i.weight_oz
		
	FROM items i
		INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
		INNER JOIN accounts a ON a.id = i.aid
		LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
		LEFT JOIN ebtransactions tid ON tid.transactionid = i.ebayTxnid <!--- this is added for mixed multi item --->		
	WHERE i.item IN(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
</cfquery>

<cfparam name="attributes.Test" default="NO">
<cfif sqlItem.byrCountry EQ "US">
	<cfparam name="attributes.MailClass" default="PRIORITY">
<cfelse>
	<cfparam name="attributes.MailClass" default="PriorityMailInternational">
</cfif>

<cfif isDefined("attributes.submit")>
	<cfinclude template="dsp_create_multilabel.cfm">
	<!--- re-draw submitted values --->
	<cfset pageData = StructNew()>
	<cfloop index="i" list="Test,MailClass,Weight,WeightOz,DeclaredValue,InsuredMail">
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
	<!--- setup default values --->
	<cfscript>
		pageData = StructNew();
		pageData.Test				=	attributes.Test;
		pageData.MailClass			=	attributes.MailClass;
		pageData.Weight				=	sqlItem.weight;
		pageData.WeightOz			=	sqlItem.weight_oz;
		
		pageData.height				=	sqlItem.height;
		pageData.width				=	sqlItem.width;
		pageData.depth				=	sqlItem.depth;
		
		pageData.DeclaredValue		=	sqlItem.price;
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
		pageData.TO_Email			=	sqlItem.hbemail;
	</cfscript>
	<cfsilent>
		<cfset pageData.Weight = 0>
		<cfset pageData.DeclaredValue = 0>
		<cfoutput query="sqlItem" group="item">
			<cfset pageData.Weight = pageData.Weight + weight>
			<cfset pageData.DeclaredValue = pageData.DeclaredValue + price>
		</cfoutput>
		<cfset pageData.DeclaredValue = Round(pageData.DeclaredValue*100)/100>
	</cfsilent>
</cfif>

	<cfif sqlitem.offebay eq 2>
		<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
			SELECT ebayFixedPricePaid as AmountPaid FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlItem.item#">
		</cfquery>
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


