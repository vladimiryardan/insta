<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="session.combined">
<cfscript>
	countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
	provincesList	= "XX,SELECT ONE;AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon";
	statesList		= "XX,SELECT ONE;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming";
	upsServices		= "01,Next Day Air;02,2nd Day Air;03,Ground;07,Worldwide Express;08,Worldwide Expedited;11,Standard;12,3-Day Select;13,Next Day Air Saver;14,Next Day Air Early A.M.;54,Worldwide Express Plus;59,2nd Day Air A.M.";
	packageTypes	= "01,Letter/Express Envelope;02,Package;03,Tube;04,Pak;21,Express Box;24,25KG Box;25,10KG Box";
</cfscript>

<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT i.weight, i.title, i.ebayitem, i.shipper, i.tracking, i.aid, i.item, i.dcreated,
		a.email, a.first, a.last, e.title, e.hbuserid, e.hbemail, e.price, i.byrName, i.byrStreet1, i.byrStreet2,
		i.byrCountry, i.byrPostalCode, i.byrCityName, i.byrStateOrProvince, i.byrPhone, t.TransactionID, t.AmountPaid,
		i.depth,i.width,i.height,i.weight_oz
	FROM items i
		INNER JOIN accounts a ON a.id = i.aid
		INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
		LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
		LEFT JOIN ebtransactions tid ON tid.transactionid = i.ebayTxnid <!--- this is added for mixed multi item --->
	WHERE i.item IN(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
	<!--- offebay doesn't need the stsCompleteStatus and others --->
		<!---	if i.offebay != '2'
		begin
		END--->
		AND (
			(
				( t.stsCompleteStatus = 'Complete'
				AND t.stsCheckoutStatus = 'CheckoutComplete'
				AND t.stseBayPaymentStatus = 'NoPaymentFailure'
				)
				OR t.stsPaymentMethodUsed != 'PayPal'
			)
			<!--- we added this for fixed price mulit txn item coz it generates a unique ebay item. but the ebayitem generated is dummy --->
			or
			(

				tid.stsCompleteStatus = 'Complete' AND tid.stsCheckoutStatus = 'CheckoutComplete' AND tid.stseBayPaymentStatus = 'NoPaymentFailure'
			)
		)


	ORDER BY i.item, t.tid DESC
</cfquery>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>UPS Label:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
</cfoutput>

<cfset drawForm = "confirm">
<cfif isDefined("attributes.confirm")><!--- Perform call --->
	<cfinclude template="act_confirm_multilabel.cfm">
<cfelseif isDefined("attributes.accept")><!--- Perform call --->
	<cfinclude template="act_accept_multilabel.cfm">
</cfif>
<cfif drawForm EQ "confirm">
	<cfif isDefined("attributes.confirm")><!--- re-draw submitted values --->
		<cfset pageData = StructNew()>
		<cfloop index="i" list="ShipperNumber,UPSService,Weight,PackageType,DeclaredValue,OversizePackage">
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
		<cfscript>
			pageData = StructNew();
			pageData.ShipperNumber		=	_vars.ups.ShipperNumber;
			pageData.UPSService			=	"03";
			pageData.Weight				=	sqlItem.weight;
			pageData.PackageType		=	"2";
			pageData.DeclaredValue		=	sqlItem.price;
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
			pageData.TO_Email			=	sqlItem.hbemail;
			pageData.WeightOz			=	sqlItem.weight_oz;
			
			pageData.Width			=	sqlItem.width;
			pageData.height			=	sqlItem.height;
			pageData.depth			=	sqlItem.depth;
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
	<cfinclude template="dsp_confirm_multilabel.cfm">
<cfelseif drawForm EQ "accept">
	<cfinclude template="dsp_accept_multilabel.cfm">
<cfelse>
	<cfinclude template="dsp_make_multilabel.cfm">
</cfif>
<cfoutput>
</td></tr>
</table>
<br>
</cfoutput>
