<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfscript>
	countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
	provincesList	= "AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon";
	statesList		= "AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming";
	upsServices		= "01,Next Day Air;02,2nd Day Air;03,Ground;07,Worldwide Express;08,Worldwide Expedited;11,Standard;12,3-Day Select;13,Next Day Air Saver;14,Next Day Air Early A.M.;54,Worldwide Express Plus;59,2nd Day Air A.M.";
	packageTypes	= "01,Letter/Express Envelope;02,Package;03,Tube;04,Pak;21,Express Box;24,25KG Box;25,10KG Box";
</cfscript>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Ship Package:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
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
		<cfscript>
			pageData = StructNew();
			
			pageData.ShipperNumber		=	_vars.ups.ShipperNumber;
			pageData.TO_Company			=	"";
			pageData.TO_Attention		= 	"";
			
			pageData.UPSService				=	"03";
			pageData.Weight					=	"";
			pageData.PackageType			=	"2";
			pageData.DeclaredValue			=	"";
			pageData.OversizePackage		=	"0";

			pageData.packing_and_materials	=	0;
	
			pageData.TO_Company				=	"";
			pageData.TO_Attention		=	"";
			pageData.TO_AddressLine1		=	"";
			pageData.TO_AddressLine2		=	"";
			pageData.TO_AddressLine3		=	"";
			pageData.TO_Country			=	"US";
			pageData.TO_ZIPCode			=	"";
			pageData.TO_City				=	"";
			pageData.TO_State	=	"";
			pageData.TO_PhoneNumber			=	"";
			pageData.TO_FaxNumber			=	"";
			
			pageData.height				=	"";
			pageData.depth				=	"";
			pageData.width				=	"";	
			pageData.OversizePackage	=	"0";
					
		</cfscript>
	</cfif>
	<cfinclude template="dsp_package_form.cfm">
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
