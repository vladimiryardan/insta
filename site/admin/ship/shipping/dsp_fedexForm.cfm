

	<cfif NOT isAllowed("Listings_CreateLabel")>
		<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
	</cfif>

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

	<!--- 
	############
	fedex shipping form post 
	############
	--->

	<!---Fedex SHIPPING Handler--->
	<cfparam name="form.fedexServiceType" default="" >
	<cfparam name="attributes.FedexShippingSuccess" default="false" >
	<cfinclude template="config.cfm" >
		<cfif isdefined("form.mode") and form.mode is "FEDEXconfirm">
			
			<!--- checking numeric --->		
			<cfif not isnumeric(form.weight)>
				<cfset form.weight = 0>
			</cfif>
			<cfif not isnumeric(form.weightOz)>
				<cfset form.weightOz = 0>
			</cfif>
					
			<cfset finalWeight = form.weight + (form.weightOz / 16) >
	
			<cfset fedexShipper = new FedexShipper(
				key = "#DeveloperKey#",
				password = "#Password#",
				accountNo = "#AccountNumber#",
				meterNo = "#MeterNumber#",
				sandbox = "#fedexSandbox#"
			) />
		
		

		
        	<cfset fedexReply = fedexShipper.processShipmentRequest(
				shipperName = "#_vars.fedex.shipperName#",
				shipperCompany = "#_vars.fedex.shipperCompany#",
				shipperPhone = "#_vars.fedex.shipperPhone#",
				shipperAddress1 = "#_vars.fedex.shipperAddress1#",
				shipperCity = "#_vars.fedex.shipperCity#",
				shipperState = "#_vars.fedex.shipperState#",
				shipperZip = "#_vars.fedex.shipperZip#",
				shipperCountry = "#_vars.fedex.shipperCountry#",
				shipperIsResidential = false,
				
				shipToName = "#form.TO_Company#",
				shipToCompany = "#form.TO_Company#",
				shipToPhone = "#form.TO_Telephone#",
				shipToEmail = "#form.TO_Email#",
				shipToAddress1 = "#form.TO_Address1#",
				shipToCity = "#form.TO_City#",
				shipToState = "#form.TO_State#",
				shipToZip = "#form.TO_ZIPCode#",
				shipToCountry = "#form.TO_Country#",
				shipToResidential = "#form.ResidentialAddress#",
				
				weight = "#finalWeight#",
				length = "#form.depth#",
				width = "#form.Width#",
				height = "#form.Height#",
				packagingType = "YOUR_PACKAGING",
				shippingMethod = "#form.fedexServiceType#",
				shipDate = Now(),
				paymentType = "SENDER",
				billingAct = "#AccountNumber#",
				
				imageType = "PNG",
				labelDirectory = ExpandPath('./site/admin/ship/fedex/Labels/'),
				labelFileName = "#attributes.item#",
				labelStockType = "PAPER_4X6",
				returnRawResponse = "true",
				ponumber="#REReplace(sqlItem.lid,"[^0-9A-Za-z ]","","all")#",
				orderid = "#sqlitem.item#"
				
			) />        
       <cftry>
        <cfcatch type="Any" >
        	Fedex Error
        	<cfset fedexReply.SUCCESS = false>
        </cfcatch>
        </cftry>

		

		<!---#attributes.item#--->

		<cfif fedexReply.SUCCESS is "yes">
			<!--- good process --->

			<cfset xmlResponse = xmlparse(fedexReply.RAWRESPONSE) >
			<cfset netCharge = xmlResponse["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]["ProcessShipmentReply"].CompletedShipmentDetail.ShipmentRating.ShipmentRateDetails.TotalNetCharge.Amount.xmlText>

			
			<cfset imageSrc = "#ExpandPath('./site/admin/ship/fedex/Labels/')##attributes.item#.png" >

		    <cfimage action="read" name="fedexImage" source="#imageSrc#" >
	    	<cfset imagerotate(fedexImage,90)>
	    	<cfimage action="write" destination="#imageSrc#" 
		    	overwrite="yes" 
		    	source="#fedexImage#"  >		

				
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET ShipCharge = <cfqueryparam cfsqltype="cf_sql_float"
			              value="#netCharge#">
				,
				tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fedexReply.TRACKINGNUMBER#">,
				
				shipper='FEDEX',
				weight = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Weight#">,
				weight_oz =  <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.WeightOz#">,
				Height = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Height#">,
				depth = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.depth#">,
				Width = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Width#">
							
				WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
			</cfquery>		
			
			

			<cfset attributes.FedexShippingSuccess = true >
			<cflocation url="index.cfm?dsp=admin.ship.fedex.FedexForm&item=#attributes.item#&FedexShippingSuccess=true&netCharge=#netCharge#&TRACKINGNUMBER=#fedexReply.TRACKINGNUMBER#" addtoken="false" >
			
		<cfelse>
			<cfdump var="#fedexReply#">
			<cfoutput>
				<div style="width:100%;background: ##e06d6d;height:50px;text-align:center;padding-top:20px">
					<h3>Failed to ship!</h3>
				</div>
				
			</cfoutput>
			
		</cfif>	

	</cfif>

	<!--- 
	############
	fedex shipping form post 
	ENDS
	############
	--->

	<cfif attributes.FedexShippingSuccess>

	<cfoutput>
		<div style="">
			<div>
				<h4 style="padding-left:20px">
					Item:
					#attributes.item#
				</h4>
			</div>
			
			<div>
				<h4 style="padding-left:20px">
					Shipping Rate:
					#dollarFormat(attributes.netCharge)#
				</h4>
			</div>
			
			<div>
				<h4 style="padding-left:20px">
					Tracking Number:
					#attributes.TRACKINGNUMBER#
				</h4>
			</div>
			
			<div style="text-align:center;padding-top:20px">
				<cfset imageLink = "#request.base#/site/admin/ship/fedex/Labels/#attributes.item#.png">
			
				<a href="#imageLink#" target="_blank" >
					<img src="#imageLink#" height="360"/>
				</a>
			</div>
			<div style="text-align:center;padding-top:20px">
				
			<button style="margin-bottom:10px;" 
			        onclick="document.location = 'index.cfm?dsp=admin.ship.awaiting';">
				Go to Shipping list
			</button>
			</div>
		</div>
		


	<!---
		this is a fixed price item we need to use the transactionid of the item not the transactionid of the ebtransactions coz 
		there are a lot of records in the ebtransactions  
	--->
	<cfif sqlItem.offebay eq 2>
		<cfset d_transactionid = sqlItem.ebayTxnid>
	<cfelse>
		<cfset d_transactionid = sqlItem.TransactionID>
	</cfif>	

		<script language="javascript" type="text/javascript">
				
				alert('Congratulations! Fedex Label generated successfully.\n\n Final Postage:\t $#attributes.netCharge#\  Please click OK to open label for print.');
				LabelWin = window.open("index.cfm?dsp=admin.ship.fedex.fedexPrintLabel&itemid=#attributes.item#", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
				LabelWin.opener = self;
				LabelWin.focus();
				window.location = "index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#attributes.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=#d_transactionid#&nextdsp=admin.ship.gl&fedexID=#TRACKINGNUMBER#";
				
				<!---/* 
				window.location = "index.cfm?act=admin.api.complete_sale
				shipped=1
				itemid=#attributes.item#
				ebayitem=#sqlItem.ebayitem#
				TransactionID=#d_transactionid#
				nextdsp=  go to shipping list find the shipping list
				fedexID=#fedexid#";
				*/--->
		</script>
				
	</cfoutput>


	<cfelse>



		<cfparam name="attributes.item">
		<cfscript>
			countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
			provincesList	= "XX,SELECT ONE;AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon";
			//20111129 vlad added in the statelist (Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine etc) //Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine;California,California;Canarias,Canarias;Cheshire,Cheshire;Colorado,Colorado;Estado de Mexico,Estado de Mexico;Florida,Florida;Georgia,Georgia;Hawaii,Hawaii;Hong Kong,Hong Kong;Iceland,Iceland;Illinois,Illinois;INDIANA,INDIANA;Israel,Israel;KANSAS,KANSAS;KENTUCKY,KENTUCKY;Lancashire,Lancashire;Madrid,Madrid;MAINE,MAINE;Maryland,Maryland;MASSACHUSETTS,MASSACHUSETTS;MICHIGAN,MICHIGAN;MINNESOTA,MINNESOTA;Missouri,Missouri;MONTANA,MONTANA;NEVADA,NEVADA;NEW JERSEY,NEW JERSEY;NEW MEXICO,NEW MEXICO;New South Wales,New South Wales;New York,New York;North Carolina,North Carolina;Norway,Norway;Nunavut,Nunavut;Odessa,Odessa;Oklahoma,Oklahoma;Ontario,Ontario;OREGON,OREGON;PENNSYLVANIA,PENNSYLVANIA;Picardie,Picardie;Puerto Rico,Puerto Rico;Queensland,Queensland;SOUTH CAROLINA,SOUTH CAROLINA;Swansea,Swansea;Tennessee,Tennessee;Washington,Washington;Varese,Varese;Vermont,Vermont;Victoria,Victoria;Virginia,Virginia;WEST VIRGINIA,WEST VIRGINIA;WISCONSIN,WISCONSIN;WYOMING,WYOMING;
			statesList		= "XX,SELECT ONE;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming;";
			upsServices		= "01,Next Day Air;02,2nd Day Air;03,Ground;07,Worldwide Express;08,Worldwide Expedited;11,Standard;12,3-Day Select;13,Next Day Air Saver;14,Next Day Air Early A.M.;54,Worldwide Express Plus;59,2nd Day Air A.M.;92,SurePost Less than 1 lb;93,SurePost 1 lb or Greater";
			packageTypes	= "01,Letter/Express Envelope;02,Package;03,Tube;04,Pak;21,Express Box;24,25KG Box;25,10KG Box";
		</cfscript>
		
		

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
			pageData.Weightoz				=	sqlItem.weight_oz;
			
			
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

	<cfif sqlItem.RecordCount EQ 0>
		<cfoutput><div>DATA FOR ITEM #attributes.item# NOT FOUND, OR TRANSACTION IS NOT COMPLETE</div></cfoutput>
	<cfelse>
		<cfif isNumeric(sqlItem.ebayitem)>
			<cfset itmItemID = sqlItem.ebayitem>
		<cfelse>
			<cfset itmItemID = 0>
		</cfif>
	<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
		SELECT *
		FROM ebtransactions
		WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#itmItemID#">
		ORDER BY tid DESC
	</cfquery>
	<!--- override the sqlTransaction query if its a fixed price multi qty fixed item  --->
	<cfif sqlitem.offebay eq 2>
		<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
			SELECT ebayFixedPricePaid as AmountPaid FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
	</cfif>

	<cfoutput>

		<table width="100%" style="text-align: justify;">
			<tr><td>
				<font size="4"><strong>Fedex Label:</strong></font><br>
					<hr size="1" style="color: Black;" noshade>
						<strong>Administrator:</strong> #session.user.first# #session.user.last#
			<br><br>
					</hr>
		</table>


   <cftry>
   		<cfinclude template="../inc_shippingCostUPSPreview.cfm" >
   <cfcatch type="Any" >
   		UPS: Error
   		<cfdump var="#cfcatch.message#">
   </cfcatch>
   </cftry>
 
	<cftry>
    	<cfinclude template="../usps/inc_shippingCostUSPSPreview.cfm" >    
    <cfcatch type="Any" >
    	USPS: Error
    	<cfdump var="#cfcatch.message#">
    </cfcatch>
    </cftry>

	<cftry>
    	<cfinclude template="inc_fedexPreview.cfm" >    
    <cfcatch type="Any" >
    	FEDEX: Error
    	<cfdump var="#cfcatch.message#">
    </cfcatch>
    </cftry>



	<!--- get dimensions --->
	<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
		Select * from ship_dimensions
		order by ship_dimension_name asc
	</cfquery>


	</cfoutput>
	<!---End--->

	<cfoutput>
			
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	
	<!--- FORM START --->
	<form method="POST" action="">
		<input type="hidden" name="item" value="#sqlItem.item#">
		<input type="hidden" name="internal_itemSKU" value="#sqlItem.internal_itemSKU#">
		<input type="hidden" name="internal_itemSKU2" value="#sqlItem.internal_itemSKU2#">
		<input type="hidden" name="lid" value="#sqlItem.lid#">
		<input type="hidden" name="mode" value="FEDEXconfirm">


	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
	
		<tr bgcolor="##D4CCBF"><td colspan="2"><b>General</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Item Number:</b></td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlItem.item#">#sqlItem.item#</a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>eBay Number:</b></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#" target="_blank">#sqlItem.ebayitem#</a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Description:</b></td>
			<td>#sqlItem.title#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Final Price:</b></td>
			<td>#DollarFormat(sqlItem.price)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Amount Paid:</b></td>
			<td><cfif isNumeric(sqlTransaction.AmountPaid)>#DollarFormat(sqlTransaction.AmountPaid)#<cfelse>N/A</cfif></td>
		</tr>
		<cfif sqlItem.shipnote NEQ "">
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Ship Note:</b></td>
				<td style="background-color:yellow;">#sqlItem.shipnote#</td>
			</tr>
		</cfif>
	<!---
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Created On:</b></td>
				<td>#DateFormat(sqlItem.dcreated)# #TimeFormat(sqlItem.dcreated)#</td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Shipper:</b></td>
				<td><input type="text" size="40" maxlength="80" name="ShipperNumber" value="#pageData.ShipperNumber#" style="font-size: 11px;"></td>
			</tr>
	---><input type="hidden" name="ShipperNumber" id="shipperNumber" value="#pageData.ShipperNumber#">
			<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Residential Address</b></td>
				<td>
					  <select name="ResidentialAddress" id="ResidentialAddress" style="width:50px">
					    <option value="True">Yes</option> 
					    <option value="False">No</option> 
					  </select>	&nbsp&nbsp&nbsp Ground Home Delivery must be Residential Address
				</td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Company or Name:</b></td>
				<td><input type="text" size="40" maxlength="80" name="TO_Company" value="#pageData.TO_Company#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Attention:</b></td>
				<td><input type="text" size="40" maxlength="80" name="TO_Attention" value="#pageData.TO_Attention#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Street/Address 1:</b></td>
				<td><input type="text" size="40" maxlength="80" name="TO_Address1" value="#pageData.TO_Address1#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##FFFFFF" style="width:277px;">
				<td valign="middle"><b>Room/Floor/Address 2:</b></td>
				<td valign="middle"><b>Department/Address 3</b></td>
			</tr>
			<tr bgcolor="##FFFFFF" >
				<td><input type="text" size="40" maxlength="80" name="TO_Address2" value="#pageData.TO_Address2#" style="font-size: 11px; width:277px;"></td>
				<td><input type="text" size="40" maxlength="80" name="TO_Address3" value="#pageData.TO_Address3#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##FFFFFF" >
				<td valign="middle"><b>Country:</b></td>
				<td valign="middle"><b>Postal/ZIP Code &reg;</b></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td>
					<select name="TO_Country" size="1" style="width:277px;">
					#SelectOptions(pageData.TO_Country, countriesList)#
					</select>
				</td>
				<td><input type="text" size="40" maxlength="80" name="TO_ZIPCode" value="#pageData.TO_ZIPCode#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>City:</b></td>
				<td valign="middle"><b>State/Prov</b></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td><input type="text" size="40" maxlength="80" name="TO_City" value="#pageData.TO_City#" style="font-size: 11px; width:277px;"></td>
				<td>
				
					<!-- DEBUG STATE "#pageData.TO_State#" --><span style="color:blue">[#trim(parseState(pageData.TO_State))#](#pageData.TO_State#)</span>
					<select name="TO_State" size="1" style="width:250px;">
					#SelectOptions(parseState(pageData.TO_State), statesList)#
					</select>
				</td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Telephone:</b></td>
				<td valign="middle"><b>E-mail Address:</b></td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td><input type="text" size="40" maxlength="80" name="TO_Telephone" value="#pageData.TO_Telephone#" style="font-size: 11px; width:277px;"></td>
				<td><input type="text" size="40" maxlength="80" name="TO_Email" value="#pageData.TO_Email#" style="font-size: 11px; width:277px;"></td>
			</tr>
			<tr bgcolor="##F0F1F3"><td colspan="2"><b>Package</b></td></tr>
			
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Fedex Service:</b></td>
				<td>
					  <select name="fedexServiceType" id="FedexServiceType" style="width:277px;">
					    <option value="FEDEX_2_DAY" <cfif form.fedexServiceType is "FEDEX_2_DAY">selected</cfif> >FEDEX_2_DAY</option>
					    <option value="FEDEX_2_DAY_AM" <cfif form.fedexServiceType is "FEDEX_2_DAY_AM">selected</cfif> >FEDEX_2_DAY_AM</option>
					    <option value="FEDEX_GROUND" <cfif form.fedexServiceType is "FEDEX_GROUND">selected</cfif>>FEDEX_GROUND</option>
					    <option value="GROUND_HOME_DELIVERY"selected="selected" <cfif form.fedexServiceType is "GROUND_HOME_DELIVERY">selected</cfif>>GROUND_HOME_DELIVERY</option>
					    <option value="STANDARD_OVERNIGHT" <cfif form.fedexServiceType is "STANDARD_OVERNIGHT">selected</cfif>>STANDARD_OVERNIGHT</option>
					  </select>
				</td>
			</tr>
			
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Weight:</b></td>
				<td>
					<input type="text" size="2" maxlength="3" name="Weight" id="dWeight" value="#pageData.weight#" style="font-size: 11px; width:60px;" required="true">
					<b>pounds</b>
					and
					<input type="text" size="5" maxlength="5" name="WeightOz" id="WeightOz" value="#pageData.WeightOz#" style="font-size: 11px; width:60px;" required="true">
					<b>ounces</b>
				</td>
			</tr>
			
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Dimensions:</b></td>
				<td>
					<select name="shippingDimensions" id="shippingDimensions" style="width:277px;">
						<option value="" selected="selected" >--Select--</option>
						<cfloop query="get_ShipDimensions">
							<option 
								value="#get_ShipDimensions.ship_dimensionid#"
								data-width="#get_ShipDimensions.ship_dimension_width#"
								data-length="#get_ShipDimensions.ship_dimension_length#"
								data-height="#get_ShipDimensions.ship_dimension_heigth#">	
								#get_ShipDimensions.ship_dimension_name#						
							</option>
						</cfloop>
					</select>
					<span class="floatRight"><a href="index.cfm?dsp=admin.ship.shippingDimensions.dimensionList">Dimension List</a></span>
				</td>
				
			</tr>	
			
					
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Width (W):</b></td>
				<td><input type="text" size="40" maxlength="80" name="width" id="Width" value="#pageData.Width#" style="font-size: 11px;"></td>
			</tr>
			
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Height (H):</b></td>
				<td><input type="text" size="40" maxlength="80" name="height" id="Height" value="#pageData.height#" style="font-size: 11px;"></td>
			</tr>	
			
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Length (L):</b></td>
				<td><input type="text" size="40" maxlength="80" name="depth" id="depth" value="#pageData.depth#" style="font-size: 11px;"></td>
			</tr>				
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Package Type:</b></td>
				<td>
					<select name="PackageType" size="1" style="width:277px;">
					#SelectOptions(pageData.PackageType, packageTypes)#
					</select>
				</td>
			</tr>
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Declared Value:</b></td>
				<td><input type="text" size="40" maxlength="80" name="DeclaredValue" value="#pageData.DeclaredValue#" style="font-size: 11px;"></td>
			</tr>
			

		<tr bgcolor="##FFFFFF">
			<td colspan="3" height="50px" background-color="gray">
				
				<cfset upsRatePreview = 0>
				<cfset uspsRatePreview = 0>
				<cfset fedexRatePreview = 0>
				<cfset shippingRatesArray = ArrayNew(1)>
				
				<cfif isdefined("totalSum")>
					<cfset upsRatePreview = totalSum>
					<cfset ArrayAppend(shippingRatesArray, "#upsRatePreview#")>
				</cfif>
			
				
				<cfif isdefined("uspsPriceDisplay")>
					<cfset uspsRatePreview = uspsPriceDisplay>
					 <cfset ArrayAppend(shippingRatesArray, "#uspsRatePreview#")> 
				</cfif>
			

				<cfif structKeyExists(result,'rates')>
					<cfset fedexRatePreview = result.rates[1].totalnetcharge>	
					<cfset ArrayAppend(shippingRatesArray, "#fedexRatePreview#")> 
				</cfif>
				
				<cfset ArraySort(shippingRatesArray, "numeric", "asc") >
			
				<cfparam name="totalSum" default="0" >
				<cfparam name="USPSPRICEDISPLAY" default="0" >
				<cfscript>
					
					shipStruct = structnew();
					shipStruct.fedex = {price = fedexRatePreview, department = "fedex"};
					shipStruct.ups = {price = totalSum, department = "ups"};
					shipStruct.usps = {price = uspsPriceDisplay, department="usps"};
					shippingSorted = structSort(shipStruct, "numeric", "asc", "price");
				</cfscript>

				<cfloop from="1" to="#arrayLen(shippingSorted)#" index="x">
							
			
						<cfif shipStruct[shippingSorted[x]].department is "ups">
							<div style="color:##FEB300;" class="shippingRate">
							UPS #dollarformat(shipStruct[shippingSorted[x]].price)#
							</div>
							
						</cfif>
			
						
						<cfif shipStruct[shippingSorted[x]].department is "usps">
						
							<div style="color:##0000FF;" class="shippingRate">
								USPS #dollarformat(uspsPriceDisplay)#
							</div>
							
						</cfif>
						
						<cfif shipStruct[shippingSorted[x]].department is "fedex">
							
							<div style="color:##d227f4;" class="shippingRate">
							FEDEX #dollarformat(fedexRatePreview)#
							</div>	
											
						</cfif>
										
				</cfloop>	

										

			</td>
		</tr>		
				
	<!---
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Oversize Package:</b></td>
				<td>
					<select name="OversizePackage" size="1">
					#SelectOptions(pageData.OversizePackage, "0,Normal;1,Oversize 1;2,Oversize 2;3,Oversize 3")#
					</select>
				</td>
			</tr>
	--->
	<input type="hidden" name="OversizePackage" value="#pageData.OversizePackage#">
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
			<input type="submit" class="shippingButton" style="color:white; background-color:##d227f4;" name="submit" value="Request Fedex Label">
			<br><hr>
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:blue;" value="Go to USPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.usps.request_label&item=#attributes.item#';">
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:##feb300;" value="Go to UPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.confirm&item=#attributes.item#';">
		</td>
		</tr>


	<!--- catch PO box in ups --->	
	<cfif lcase(pageData.TO_Address1).startsWith("po") or lcase(pageData.TO_Address1).startsWith("p.o") or lcase(pageData.TO_Address1) contains "p.o box" >
		<tr><td colspan="2" align="center"><div style="color:white;background-color:##E81747;padding:10px;font-weight:bold">ALERT! The Address is possibly a PO box. UPS does not ship to PO box.</div>
	</td></tr>
	</cfif>

		</form>
		</table>
	</td></tr>
	</table>
	</cfoutput>
	</cfif>
	<cfparam name="attributes.maximize" default="false">
	<cfif attributes.maximize>
	<cfoutput>
		
		
		<script language="javascript" type="text/javascript">
		<!--
			top.window.moveTo(0,0);
			if(document.all){
				top.window.resizeTo(screen.availWidth,screen.availHeight);
			}else if(document.layers || document.getElementById){
				if((top.window.outerHeight < screen.availHeight) || (top.window.outerWidth < screen.availWidth)){
					top.window.outerHeight = screen.availHeight;
					top.window.outerWidth = screen.availWidth;
				}
			}
		//-->
	
		</script>
		</cfoutput>
	</cfif>



	
	<cfoutput>


	<script type="text/javascript">
		
			var mytext = document.getElementById("dWeight");
			mytext.focus();
			
			// JavaScript using jQuery
			$(function(){
			    $('##shippingDimensions').change(function(){
			       var selected = $(this).find('option:selected');
			       var width = selected.data('width'); 
			       var length = selected.data('length');
			       var heigth = selected.data('height');
			       
			       $('##Height').val(heigth);
			       $('##Width').val(width);
			       $('##depth').val(length);
	      
			    });
			});
			
			
	</script>
	</cfoutput>

	</cfif><!--- shipping success --->