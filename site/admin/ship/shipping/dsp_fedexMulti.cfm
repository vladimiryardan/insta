<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<!--- 
##################
Getting and converting to oz
##################
 --->
<cfquery name="get_item" datasource="#request.dsn#">
	SELECT items.weight, ebitems.price, items.byrStateOrProvince, items.byrPostalCode, items.weight_oz, items.lid
	
	FROM items
	LEFT JOIN ebitems ON ebitems.ebayitem = items.ebayitem
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	
</cfquery>

<!---Fedex SHIPPING Handler--->
<cfparam name="form.fedexServiceType" default="" >
<cfparam name="attributes.FedexShippingSuccess" default="false" >
<cfparam name="attributes.MailClass" default="GROUND" >	

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
			ponumber="#REReplace(get_item.lid,"[^0-9A-Za-z ]","","all")#",
			orderid = "#attributes.item#"
		) />
		<!---#attributes.item#--->
	
		<cfif fedexReply.SUCCESS is "yes">
			<!--- good process --->

			<cfset xmlResponse = xmlparse(fedexReply.RAWRESPONSE) >
			<cfset netCharge = xmlResponse["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]["ProcessShipmentReply"].CompletedShipmentDetail.ShipmentRating.ShipmentRateDetails.TotalNetCharge.Amount.xmlText>
			
			<cfset LogAction("generated Fedex label #fedexReply.TRACKINGNUMBER# for items #session.combined#")>		
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
							
				WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
			</cfquery>	
			
			

			
			<cfset attributes.FedexShippingSuccess = true >
			<cflocation url="index.cfm?dsp=admin.ship.fedex.FedexMulti&item=#attributes.item#&FedexShippingSuccess=true&netCharge=#netCharge#&TRACKINGNUMBER=#fedexReply.TRACKINGNUMBER#" addtoken="false" >
			
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
	##########
	End of Form Handler
	##########
	--->
	
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
				<cfloop list="#session.combined#" index="i">
				<h4 style="padding-left:20px">
					Item:
					#i#
				</h4>
				</cfloop>	
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
		

		<script language="javascript" type="text/javascript">
				
				alert('Congratulations! Fedex Label generated successfully.\n\n Final Postage:\t $#attributes.netCharge#\  Please click OK to open label for print.');
				LabelWin = window.open("index.cfm?dsp=admin.ship.fedex.fedexPrintLabel&itemid=#attributes.item#", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
				LabelWin.opener = self;
				LabelWin.focus();
				window.location = "index.cfm?act=admin.api.complete_sale_multilabel&shipped=1&items=#session.combined#&nextdsp=admin.ship.awaiting&fedexID=#TRACKINGNUMBER#";
		</script>
	</cfoutput>
	
	<!--- ONCE LABEL GENERATED, CLEAR COMBINED QUEUE --->
	<cfset session.combined = "">
	

	
<cfelse>
		
		
		<cfscript>
			countriesList	= "XX,SELECT ONE;US,United States;CA,Canada";
			provincesList	= "XX,SELECT ONE;AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon";
			//20111129 vlad added in the statelist (Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine etc) //Ohio,Ohio;Texas,Texas;Iowa,Iowa;Utah,Utah;Maine,Maine;California,California;Canarias,Canarias;Cheshire,Cheshire;Colorado,Colorado;Estado de Mexico,Estado de Mexico;Florida,Florida;Georgia,Georgia;Hawaii,Hawaii;Hong Kong,Hong Kong;Iceland,Iceland;Illinois,Illinois;INDIANA,INDIANA;Israel,Israel;KANSAS,KANSAS;KENTUCKY,KENTUCKY;Lancashire,Lancashire;Madrid,Madrid;MAINE,MAINE;Maryland,Maryland;MASSACHUSETTS,MASSACHUSETTS;MICHIGAN,MICHIGAN;MINNESOTA,MINNESOTA;Missouri,Missouri;MONTANA,MONTANA;NEVADA,NEVADA;NEW JERSEY,NEW JERSEY;NEW MEXICO,NEW MEXICO;New South Wales,New South Wales;New York,New York;North Carolina,North Carolina;Norway,Norway;Nunavut,Nunavut;Odessa,Odessa;Oklahoma,Oklahoma;Ontario,Ontario;OREGON,OREGON;PENNSYLVANIA,PENNSYLVANIA;Picardie,Picardie;Puerto Rico,Puerto Rico;Queensland,Queensland;SOUTH CAROLINA,SOUTH CAROLINA;Swansea,Swansea;Tennessee,Tennessee;Washington,Washington;Varese,Varese;Vermont,Vermont;Victoria,Victoria;Virginia,Virginia;WEST VIRGINIA,WEST VIRGINIA;WISCONSIN,WISCONSIN;WYOMING,WYOMING;
			statesList		= "XX,SELECT ONE;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming;";

			
		</cfscript>
		
		<cfquery name="sqlItem" datasource="#request.dsn#" >
			SELECT i.item, 
				i.weight,
				i.weight_oz, 
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
				i.EBAYFIXEDPRICEPAID,
				i.depth,
				i.width,
				i.height,
				i.shipnote
				
			FROM items i
				INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
				INNER JOIN accounts a ON a.id = i.aid
				LEFT JOIN ebtransactions t ON t.itmItemID = i.ebayitem
				LEFT JOIN ebtransactions tid ON tid.transactionid = i.ebayTxnid <!--- this is added for mixed multi item --->		
			WHERE i.item IN(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
		</cfquery>

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
				pageData.MailClass			=	attributes.MailClass;
				pageData.Weight				=	sqlItem.weight;	
				pageData.WeightOz			=	sqlItem.weight_oz;		
				
				pageData.depth				=	sqlItem.depth;
				pageData.width				=	sqlItem.width;
				pageData.height				=	sqlItem.height;
				
				pageData.PackageType		=	"2";
				pageData.DeclaredValue		=	sqlItem.price;
				if(sqlItem.price GT 100){
				pageData.InsuredMail	=	"ENDICIA";
				}else{
				pageData.InsuredMail	=	"OFF";
				}
			
				pageData.OversizePackage	=	"0";
				pageData.TO_Company			=	sqlItem.byrName;
				pageData.TO_Attention		=	"";
				pageData.TO_Firm			=	"";
				pageData.TO_Address1		=	sqlItem.byrStreet1;
				pageData.TO_Address2		=	sqlItem.byrStreet2;
				pageData.TO_Address3		=	"";
				pageData.TO_Country			=	sqlItem.byrCountry;
				pageData.TO_ZIPCode			=	sqlItem.byrPostalCode;
				pageData.TO_City			=	sqlItem.byrCityName;
				pageData.TO_Province		=	sqlItem.byrStateOrProvince;
				pageData.TO_State			=	sqlItem.byrStateOrProvince;
				pageData.TO_Telephone		=	sqlItem.byrPhone;
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
	
	<cfoutput>
	
		<table width="100%" style="text-align: justify;">
				<tr><td>
				<font size="4"><strong>Fedex Label:</strong></font><br>
					<hr size="1" style="color: Black;" noshade>
						<strong>Administrator:</strong> #session.user.first# #session.user.last#
				<br><br>
					</hr>
				</td>
			</tr>		
		</table>
		
		
		

 	   		<cftry>
	    		<cfinclude template="../inc_shippingCostUPSPreviewMulti.cfm">
	    	<cfcatch type="Any">
	    		UPS: Error
	    		#cfcatch.message#<br>
	    	</cfcatch>
	    	</cftry>
	    
	    	<cftry>
	    		<cfinclude template="../usps/inc_shippingCostUSPSPreviewMulti.cfm">
	    	<cfcatch type="Any">
	    		USPS: Error
	    		#cfcatch.message#<br>
	    	</cfcatch>
	    	</cftry>
	
	    	<cftry>
	    		<cfinclude template="inc_fedexPreviewMulti.cfm">
	    	<cfcatch type="Any">
	    		FEDEX: Error
	    		#cfcatch.message#<br>
	    	</cfcatch>
	    	</cftry>


</cfoutput>


	<cfoutput>

	<style type="text/css">
		##comlist{background-color:##AAAAAA;}
		##comlist th{background-color:##F0F1F3; font-weight:bold; text-align:center;}
		##comlist td{background-color:white; width:10%; text-align:center;}
		##comlist th a, ##comlist th a:visited{color:red;}
		##comlist th a:hover{color:green;}
	</style>


	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<form method="POST" action="index.cfm?dsp=#attributes.dsp#&item=#attributes.item#">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Item Details</b></td></tr>
		<tr bgcolor="##FFFFFF"><td colspan="2">
			<table cellpadding="3" cellspacing="1" id="comlist">
			<tr>
				<th colspan="2">Item Owner</td>
				<th>Item Number</td>
				<th>eBay Number</td>
				<th>Created On</td>
				<th>Weight</th>
				<th>Value</th>
				<th>Bidder</th>
			</tr>
			</cfoutput>
			<cfoutput query="sqlItem" group="item">
			<tr>
				<td><a href="mailto:#sqlItem.hbemail#?subject=Instant Auctions: Item #item#"><img src="#request.images_path#emailblue.gif" align="middle" border=0></a></td>
				<td><a href="index.cfm?dsp=account.edit&id=#aid#">#first# #last#</a></td>
				<td><a href="index.cfm?dsp=management.items.edit&item=#item#">#item#</a></td>
				<td align="center"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#ebayitem#" target="_blank">#ebayitem#</a></td>
				<td align="center">#DateFormat(dcreated)# #TimeFormat(dcreated)#</td>
				<td align="center">#weight#</td>
				<td align="right">#DollarFormat(price)#</td>
				<td>#hbuserid#</td>
			</tr>
			</cfoutput>
			<cfoutput>
			</table>
		</td></tr>
		
		<!--- get dimensions --->
		<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
			Select * from ship_dimensions
			order by ship_dimension_name asc
		</cfquery>
		
		<form method="POST" action="">
		<input type="hidden" name="item" value="#sqlItem.item#">
		<input type="hidden" name="internal_itemSKU" value="#sqlItem.internal_itemSKU#">
		<input type="hidden" name="internal_itemSKU2" value="#sqlItem.internal_itemSKU2#">
		<input type="hidden" name="lid" value="#sqlItem.lid#">
		<input type="hidden" name="mode" value="FEDEXconfirm">
		<input type="hidden" name="ShipperNumber" value="#pageData.ShipperNumber#">
			
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>General</b></td></tr>
		
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
		
		<input type="hidden" name="ShipperNumber"  value="#pageData.ShipperNumber#">
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Residential Address</b></td>
			<td>
				  <select name="ResidentialAddress" id="residentialAddress" style="width:50px">
				    <option value="True">Yes</option> 
				    <option value="False">No</option> 
				  </select>	&nbsp&nbsp&nbsp Ground Home Delivery must be Residential Address
			</td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Company or Name:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Company" value="#pageData.TO_Company#" style="font-size: 11px; width:273px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Company:</b></td>
			<td><input type="text" size="40" maxlength="45" name="TO_Firm" value="#pageData.TO_Firm#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Attention:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Attention" value="#pageData.TO_Attention#" style="font-size: 11px; width:273px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Street/Address 1:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Address1" value="#pageData.TO_Address1#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Room/Floor/Address 2:</b></td>
			<td valign="middle"><b>Department/Address 3</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_Address2" value="#pageData.TO_Address2#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Address3" value="#pageData.TO_Address3#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Country:</b></td>
			<td valign="middle"><b>Postal/ZIP Code &reg;</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td>
				<cfif ListFindNoCase("US,CA", pageData.TO_Country)>
					<select name="TO_Country" onChange="fSateProvince(this.value)" style="width:277px">
					#SelectOptions(pageData.TO_Country, countriesList)#
					</select>
				<cfelse>
					<input type="text" size="40" maxlength="80" name="TO_Country" value="#pageData.TO_Country#" style="font-size: 11px;">
				</cfif>
			</td>
			<td><input type="text" size="40" maxlength="80" name="TO_ZIPCode" value="#pageData.TO_ZIPCode#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>City:</b></td>
			<td valign="middle"><b id="spOBJ">State</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_City" value="#pageData.TO_City#" style="font-size: 11px;"></td>
			<td><!-- DEBUG STATE "#pageData.TO_State#" --><span style="color:blue">[#trim(parseState(pageData.TO_State))#](#pageData.TO_State#)</span>
				<select name="TO_State" size="1" style="width:223px;">
				#SelectOptions(parseState(pageData.TO_State), statesList)#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Telephone:</b></td>
			<td valign="middle"><b>E-mail Address:</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_Telephone" value="#pageData.TO_Telephone#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Email" value="#pageData.TO_Email#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Package</b></td></tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Fedex Service:</b></td>
			<td>
				  <select name="fedexServiceType" id="fedexServiceType" style="width:277px;">
				    <option value="FEDEX_2_DAY" <cfif form.fedexServiceType is "FEDEX_2_DAY">selected</cfif> >FEDEX_2_DAY</option>
				    <option value="FEDEX_2_DAY_AM" <cfif form.fedexServiceType is "FEDEX_2_DAY_AM">selected</cfif> >FEDEX_2_DAY_AM</option>
				    <option value="FEDEX_GROUND" <cfif form.fedexServiceType is "FEDEX_GROUND">selected</cfif>>FEDEX_GROUND</option>
				    <option value="GROUND_HOME_DELIVERY" selected="selected"<cfif form.fedexServiceType is "GROUND_HOME_DELIVERY">selected</cfif>>GROUND_HOME_DELIVERY</option>
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
			<td valign="middle"><b>Width (W):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Width" id="dWidth" value="#pageData.width#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Height (H):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Height" id="cHeight" value="#pageData.height#" style="font-size: 11px;"></td>
		</tr>	
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Length (L):</b></td>
			<td><input type="text" size="40" maxlength="80" name="depth" id="ddepth" value="#pageData.depth#" style="font-size: 11px;"></td>
		</tr>	
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Declared Value:</b></td>
			<td><input type="text" size="40" maxlength="80" name="DeclaredValue" value="#pageData.DeclaredValue#" style="font-size: 11px;"></td>
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
		
		
		<cfset bgcolorUPS = "">
		<cfset bgcolorUSPS = "">
		<cfset bgcolorFedex = "">
		
		<cfif isdefined("totalSum") and isdefined("uspsPriceDisplay")>
			<cfif totalSum and uspsPriceDisplay>
				<cfset bgcolorUPS = "red">
				<cfset bgcolorUSPS = "green">
			<cfelse>
				<cfset bgcolorUPS = "green">
				<cfset bgcolorUSPS = "red">
			</cfif>
		</cfif>
		<tr bgcolor="##FFFFFF">
			<td colspan="3" height="50px" background-color="gray">
				
				<cfset upsRatePreview = 0>
				<cfset uspsRatePreview = 0>
				<cfset fedexRatePreview = 0>
				<cfset shippingRatesArray = ArrayNew(1)>
				
				
				<!--- ups --->
				<cfif isdefined("totalSum")>
					<cfset upsRatePreview = totalSum>
					<cfset ArrayAppend(shippingRatesArray, "#upsRatePreview#")>
				<cfelse>
					<!--- error in rate preview --->
					<cfset totalSum = 0>					
				</cfif>
			
				<!--- usps --->
				<cfif isdefined("uspsPriceDisplay")>
                	<cfset uspsRatePreview = uspsPriceDisplay>
                	<cfset ArrayAppend(shippingRatesArray, "#uspsRatePreview#")>
                <cfelse>
                	<!--- error in rate preview --->
                	<cfset USPSPRICEDISPLAY = 0>
                </cfif>
			
				<!--- fedex --->
				<cfif  isdefined("result") and structKeyExists(result,'rates')>
					<cfset fedexRatePreview = result.rates[1].totalnetcharge>	
					<cfset ArrayAppend(shippingRatesArray, "#fedexRatePreview#")> 
				<cfelse>
					<!--- error in rate preview --->
					<cfset fedexRatePreview = 0>
				</cfif>
				
				<cfset ArraySort(shippingRatesArray, "numeric", "asc") >

				
				<cfscript>
					
					shipStruct = structnew();
					shipStruct.fedex = {price = fedexRatePreview, department = "fedex"};
					shipStruct.ups = {price = totalSum, department = "ups"};
					shipStruct.usps = {price = uspsPriceDisplay, department="usps"};
					shippingSorted = structSort(shipStruct, "numeric", "asc", "price");
				</cfscript>

				<cfloop from="1" to="#arrayLen(shippingSorted)#" index="x">
						<cfif x eq 1>
							<cfset color = "green" >
						</cfif>
						
						<cfif x eq 2>
							<cfset color = "##feb300" >
						</cfif>
						
						<cfif x eq 3>
							<cfset color = "red" >
						</cfif>		
						
			
						<cfif shipStruct[shippingSorted[x]].department is "ups">
							<div style="color:##FEB300;" class="shippingRate">
							UPS#dollarformat(shipStruct[shippingSorted[x]].price)#
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
				
	
		<tr bgcolor="##F0F1F3">
			<td colspan="2" align="center">
			<input type="hidden" name="OversizePackage" value="#pageData.OversizePackage#">
			<input type="submit" class="shippingButton" style="color:white; background-color:##d227f4;" name="submit" value="Request Fedex Label">
			<br><hr>
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:blue;" value="Go to USPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.usps.request_multilabel&item=#attributes.item#';">
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:##feb300;" value="Go to UPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.confirm_multilabel&item=#attributes.item#';">
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
		       
		       $('##cHeight').val(heigth);
		       $('##dWidth').val(width);
		       $('##ddepth').val(length);
      
		    });
		});
		
		
	</script>

		
		
</cfoutput>

</cfif><!--- shipping success --->