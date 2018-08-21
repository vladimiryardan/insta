<!---<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>--->
<cfparam name="attributes.item" default="#sqlItem.item#">

<cfif not isdefined("pageData.UPSService")>
	<cfset pageData.UPSService = "03">
</cfif>

<!---<!--- get the item info --->
<cfquery name="uspsItemInfo" datasource="#request.dsn#">
		 select * from items
		 where item = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#sqlItem.item#">
</cfquery>--->


<cfparam name="txtResidentialAddress" default="<ResidentialAddress></ResidentialAddress>" >
<cfset trimmedItemNumber = #right(sqlItem.item, len(sqlItem.item)+4)#>
<cfparam name="attributes.ShipperNumber" default="#_vars.ups.ShipperNumber#">
<cfparam name="attributes.TO_COMPANY" default="#sqlItem.byrName#">
<cfparam name="attributes.TO_ATTENTION" default="">
<cfparam name="attributes.TO_TELEPHONE" default="#sqlItem.byrPhone#">
<cfparam name="attributes.TO_Address1" default="#sqlItem.byrStreet1#">
<cfparam name="attributes.TO_Address2" default="#sqlItem.byrStreet1#">
<cfparam name="attributes.TO_Address3" default="">
<cfparam name="attributes.TO_CITY" default="#sqlItem.byrCityName#">
<cfparam name="attributes.TO_STATE" default="#sqlItem.byrStateOrProvince#">
<cfparam name="attributes.TO_ZIPCODE" default="#sqlItem.byrPostalCode#">
<cfparam name="attributes.TO_COUNTRY" default="#sqlItem.byrCountry#">
<cfparam name="attributes.UPSService" default="#pageData.UPSService#">
<cfparam name="attributes.INTERNAL_ITEMSKU2" default="#sqlItem.internal_itemSKU2#">
<cfparam name="attributes.LID" default="#sqlItem.lid#">
<cfparam name="attributes.PackageType" default="02">
<cfparam name="attributes.OversizePackage" default="0">
<cfparam name="attributes.DeclaredValue" default="#pageData.DeclaredValue#">
<cfparam name="attributes.Weight" default="#sqlItem.Weight#">
<cfparam name="attributes.Weight_oz" default="#sqlItem.Weight_oz#">

<cfparam name="attributes.height" default="#sqlItem.height#">
<cfparam name="attributes.depth" default="#sqlItem.depth#">
<cfparam name="attributes.width" default="#sqlItem.width#">



<cfif isdefined("form.dformWeight") and isnumeric(form.dformWeight)>
	<cfset attributes.weight = form.dformWeight >
</cfif>

<cfif isdefined("form.dUPSService") and form.dUPSService neq "">
	<cfset attributes.UPSService = form.dUPSService>
</cfif>

<!--- hack 0 weight --->
<cfif not isnumeric(attributes.weight) or attributes.weight lte 0>
	<cfset attributes.weight = "1">
</cfif>

<!--- 20160915
added For discount display
	<RateInformation> 
		<NegotiatedRatesIndicator /> 
	</RateInformation>	 
- Added dimensions
     <Dimensions>
       <UnitOfMeasurement>IN</UnitOfMeasurement>
       <Length>#attributes.depth#</Length>
       <Width>#attributes.width#</Width>
       <Height>#attributes.height#</Height>
     </Dimensions>	
	--->



<cfset XMLRequest = '
<?xml version="1.0"?>
<AccessRequest xml:lang="en-US">
	<AccessLicenseNumber>#_vars.ups.AccessLicenseNumber#</AccessLicenseNumber>
	<UserId>#_vars.ups.UserId#</UserId>
	<Password>#_vars.ups.Password#</Password>
</AccessRequest>
<?xml version="1.0"?>
<ShipmentConfirmRequest xml:lang="en-US">
	<Request>
		<RequestAction>ShipConfirm</RequestAction>
		<RequestOption>nonvalidate</RequestOption>
		<TransactionReference>
			<CustomerContext>#attributes.item#</CustomerContext>
			<XpciVersion>1.0001</XpciVersion>
		</TransactionReference>
	</Request>
	<LabelSpecification>
		<LabelPrintMethod>
			<Code>GIF</Code>
		</LabelPrintMethod>
		<HTTPUserAgent>Mozilla/4.5</HTTPUserAgent>
		<LabelImageFormat>
			<Code>GIF</Code>
		</LabelImageFormat>
	</LabelSpecification>
	<Shipment>
		<RateInformation> 
			<NegotiatedRatesIndicator /> 
		</RateInformation>			
		<Shipper>
			<Name>#_vars.upsFrom.Company#</Name>
			<AttentionName>#_vars.upsFrom.Attention#</AttentionName>
			<PhoneNumber>#REReplace(_vars.upsFrom.Telephone, "[^0-9]*", "", "ALL")#</PhoneNumber>
			<ShipperNumber>#attributes.ShipperNumber#</ShipperNumber>
			<Address>
				<AddressLine1>#_vars.upsFrom.Address1#</AddressLine1>
				<AddressLine2>#_vars.upsFrom.Address2#</AddressLine2>
				<AddressLine3>#_vars.upsFrom.Address3#</AddressLine3>
				<City>#_vars.upsFrom.City#</City>
				<StateProvinceCode>#ucase(_vars.upsFrom.State)#</StateProvinceCode>
				<PostalCode>#_vars.upsFrom.ZIPCode#</PostalCode>
				<CountryCode>#_vars.upsFrom.Country#</CountryCode>
			</Address>
		</Shipper>
		<ShipTo>
			<CompanyName><![CDATA[ #attributes.TO_Company# ]]></CompanyName>
			<AttentionName>#attributes.TO_Attention#</AttentionName>
			<PhoneNumber>#REReplace(attributes.TO_Telephone, "[^0-9]*", "", "ALL")#</PhoneNumber>
			<Address>
				<AddressLine1>#attributes.TO_Address1#</AddressLine1>
				<AddressLine2>#attributes.TO_Address2#</AddressLine2>
				<AddressLine3>#attributes.TO_Address3#</AddressLine3>
				<City>#attributes.TO_City#</City>
				<StateProvinceCode>#ucase(attributes.TO_State)#</StateProvinceCode>
				<PostalCode>#attributes.TO_ZIPCode#</PostalCode>
				<CountryCode>#attributes.TO_Country#</CountryCode>
				#txtResidentialAddress#
			</Address>
		</ShipTo>
		<PaymentInformation>
			<Prepaid>
				<BillShipper>
					<AccountNumber>#attributes.ShipperNumber#</AccountNumber>
				</BillShipper>
			</Prepaid>
		</PaymentInformation>
		<Service>
			<Code>#attributes.UPSService#</Code>
		</Service>
		<Package>
			<ReferenceNumber>
				<Code>PC</Code>
				<Value><![CDATA[#trimmedItemNumber#]]></Value>
			</ReferenceNumber>
			<PackagingType>
				<Code>#attributes.PackageType#</Code>
			</PackagingType>


     <Dimensions>
       <UnitOfMeasurement>IN</UnitOfMeasurement>
       <Length>#attributes.depth#</Length>
       <Width>#attributes.width#</Width>
       <Height>#attributes.height#</Height>
     </Dimensions>
     			
			<PackageWeight>
				<UnitOfMeasurement>
					<Code>LBS</Code>
				</UnitOfMeasurement>
				<Weight>#attributes.Weight#</Weight>
			</PackageWeight>
'>

<!---
20161005 - 
<ReferenceNumber>
	<Code>PC</Code>
	<Value><![CDATA[#trimmedItemNumber# ###attributes.internal_itemSKU2### #attributes.lid#]]></Value>
</ReferenceNumber>
--->
<cfif attributes.OversizePackage NEQ 0>
	<cfset XMLRequest = XMLRequest & '
			<OversizePackage>#attributes.OversizePackage#</OversizePackage>
'>
</cfif>


<cftry><cfset attributes.DeclaredValue = Val(attributes.DeclaredValue)><cfcatch type="any"><cfset attributes.DeclaredValue = 0></cfcatch></cftry>
<cfif attributes.DeclaredValue GT 0>
	<cfset XMLRequest = XMLRequest & '
			<PackageServiceOptions>
				<InsuredValue>
					<CurrencyCode>USD</CurrencyCode>
					<MonetaryValue>#attributes.DeclaredValue#</MonetaryValue>
				</InsuredValue>
			</PackageServiceOptions>
'>
</cfif>
<cfset XMLRequest = XMLRequest & '
		</Package>
	</Shipment>
</ShipmentConfirmRequest>
'>

 



<!---<cfhttp url="https://www.ups.com/ups.app/xml/ShipConfirm" method="POST" charset="utf-8" port="443">
	<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
	<cfhttpparam type="Header" name="TE" value="deflate;q=0">

	
	<cfhttpparam name="request" value="#XMLRequest#" type="XML">
</cfhttp>--->
<cfhttp url="https://temp-onlinetools.ups.com/ups.app/xml/ShipConfirm" method="POST" charset="utf-8" port="443">
	<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
	<cfhttpparam type="Header" name="TE" value="deflate;q=0">

	
	<cfhttpparam name="request" value="#XMLRequest#" type="XML">
</cfhttp>


	
<cfset goodXML = TRUE>
<cftry>
	<cfset theXML = XMLParse(ToString(cfhttp.Filecontent))>
	<cfcatch type="any">
		<cfset goodXML = FALSE>
		<cfdump var="#cfhttp#">
	</cfcatch>
</cftry>

<cfoutput>

	<cfif goodXML>
		<cfif theXML.xmlRoot.Response.ResponseStatusDescription.xmlText EQ "failure">
			<h3 style="color:red;">Fail to calculate shipping cost in UPS</h3>
			<cfif structkeyexists(theXML.xmlRoot.Response,"Error")>#theXML.xmlRoot.Response.Error.ErrorDescription.XmlText#</cfif>
			<cfset totalsum = 0><!--- just return 0 for invalid xml--->
		<cfelse>
			<!--- display price preview here --->


						<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" >
						<!---<tr bgcolor="##F0F1F3" ><td colspan="2" align="center"><h3>Shipping Cost Preview</h3></td></tr>--->
						<!---<tr bgcolor="##FFFFFF">
							<td valign="middle" align="left"><b>Shipment Identification Number</b></td>
							<td>#theXML.xmlRoot.ShipmentIdentificationNumber.xmlText#</td>
						</tr>--->
						<!---<tr bgcolor="##FFFFFF">
							<td valign="middle"  align="left"><b>ItemID</b></td>
							<td>#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#</td>
						</tr>--->

						<tr bgcolor="##fffb9e"><td colspan="2"  align="left"><b>UPS Shipment Charges Preview</b></td></tr>
						<tr bgcolor="##FFFFFF">
							<td valign="middle"	 width="37%"><b>Billing Weight</b></td>
							<td>
								#theXML.xmlRoot.BillingWeight.Weight.xmlText# #theXML.xmlRoot.BillingWeight.UnitOfMeasurement.Code.xmlText#
								<cfif #theXML.xmlRoot.BillingWeight.UnitOfMeasurement.Code.xmlText# is "LBS">
									(equal to #theXML.xmlRoot.BillingWeight.Weight.xmlText*16# Oz)
								</cfif>
							</td>
						</tr>
						<cfset totalSum = 1000000><!--- to make it noticeable if TotalCharges not found in ShipmentCharges --->
						<cfloop index="i" from="1" to="#ArrayLen(theXML.xmlRoot.ShipmentCharges.xmlChildren)#">
						<cfif theXML.xmlRoot.ShipmentCharges.xmlChildren[i].xmlName EQ "TotalCharges">
							<cfset totalSum = Val(theXML.xmlRoot.ShipmentCharges.xmlChildren[i].MonetaryValue.xmlText)>
						</cfif>
						<tr bgcolor="##FFFFFF">
							<td valign="middle" ><b>#theXML.xmlRoot.ShipmentCharges.xmlChildren[i].xmlName#</b></td>
							<td align="left">#dollarformat(theXML.xmlRoot.ShipmentCharges.xmlChildren[i].MonetaryValue.xmlText)#</td>
						</tr>
						</cfloop>
						<!--- package type --->
						<tr bgcolor="##FFFFFF">
							<td valign="middle" >UPS Service</td>
							<td align="left">
							<cfswitch expression="#attributes.UPSService#" >
								<cfcase value="01" >
									Next Day Air
								</cfcase>
								<cfcase value="02" >
									2nd Day Air
								</cfcase>
								<cfcase value="03" >
									Ground
								</cfcase>
								<cfcase value="07" >
									Worldwide Express
								</cfcase>
								<cfcase value="08" >
									Worldwide Expedited
								</cfcase>
								<cfcase value="11" >
									Standard
								</cfcase>
								<cfcase value="12" >
									3-Day Select
								</cfcase>
								<cfcase value="13" >
									Next Day Air Saver
								</cfcase>
								<cfcase value="14" >
									Next Day Air Early A.M.
								</cfcase>
								<cfcase value="54" >
									Worldwide Express Plus
								</cfcase>
								<cfcase value="59" >
									2nd Day Air A.M.
								</cfcase>
								<cfdefaultcase>
									undefined
								</cfdefaultcase>
							</cfswitch>
							</td>
						</tr>
						<tr bgcolor="##FFFFFF">
							<td valign="middle" >Calc Weight</td>
							<td>
								<cftry>
                                	<cfset calcWeight = (attributes.width * attributes.height * attributes.depth) / 166>	                                
                                <cfcatch type="Any" >
                                	<cfset calcWeight = 0>
                                </cfcatch>
                                </cftry>							
								#NumberFormat(calcWeight, '9.99')# pounds
							</td>
						</tr>

						
						</table>



			<cfquery name="Check_upsDiscount" datasource="#request.dsn#" >
			    SELECT *
			    FROM [upsdiscounts]
			    WHERE 1=1
			    and
			    <cfqueryparam value="#pageData.Weight#" cfsqltype="cf_sql_numeric" > >= upsdiscount_from  
			    AND 
			    <cfqueryparam value="#pageData.Weight#" cfsqltype="cf_sql_numeric" > <= upsdiscount_to
			    
			    order by [upsdiscount_percentage] asc
			</cfquery>

			<cfif Check_upsDiscount.recordCount gte 1>	
				<cfset upsDiscountType = Check_upsDiscount.upsdiscount_name>
				<cfset upsDiscountVal = totalSum * Check_upsDiscount.upsdiscount_percentage / 100 >	
				<cfset upsTotalWithDiscount = dollarFormat( totalSum - upsDiscountVal )>	
				<cfset upsWeightDiscountFrom = Check_upsDiscount.upsdiscount_from >
				<cfset upsWeightDiscountTo =  Check_upsDiscount.upsdiscount_to >
				<cfset upsWeightDiscountRate =  Check_upsDiscount.upsdiscount_percentage >
			<cfelse>
				<cfset upsDiscountType = "0">
				<cfset upsDiscountVal = "">	
				<cfset upsTotalWithDiscount = 0 >
				<cfset upsWeightDiscountFrom = "">
				<cfset upsWeightDiscountTo =  "">
				<cfset upsWeightDiscountRate =  Check_upsDiscount.upsdiscount_to >		
			</cfif>


 
				<!--- 
				1-5 pounds 5.8% , 
				 6-10 pounds 8.3%, 
				 11-20 pounds,  10.8%, 
				 21-30 pounds 13.3%, 
				 31-150 pounds 15.8%--->

				<cfoutput>
					<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td>
							<table width="100%" border="0" cellpadding="4" cellspacing="1">
								
				<!---		
							No Longer needed because of Negotiated rates display	
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Discount:</b></td>
								<td>
									#dollarFormat(upsDiscountVal)# 
								</td>
							</tr>	
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Discount Type:</b></td>
								<td>
									#upsDiscountType# 
								</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Rate:</b></td>
								<td>
									<cfif upsWeightDiscountFrom neq "">#upsWeightDiscountRate#%</cfif>
								</td>
							</tr>	
										
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Weight:</b></td>
								<td>
									<cfif upsWeightDiscountFrom neq ""> #upsWeightDiscountFrom#-#upsWeightDiscountTo# pounds</cfif>
								</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Total with Discount:</b></td>
								<td>
									#upsTotalWithDiscount#
								</td>
							</tr>--->
							
							</td>			
						</tr>
						
						<!--- catch the negotiated rates if available --->
						<cfif isdefined("theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText")>
							<cfset totalSum = Val(theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)>
							<tr bgcolor="##FFFFFF">
								<td valign="middle"width="37%"><b>Negotiated Rate</b></td>
								<td >#totalSum#</td>
							</tr>
						<cfelse>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Negotiated Rate</b></td>
								<td>UNDEFINED</td>
							</tr>					
						</cfif>
								
						</table>	
					</table>
				</cfoutput>	


		</cfif>
	<cfelse>
		<h3 style="color:red;">Fail to calculate shipping cost 1001.</h3>
	</cfif>
<!--- add some spacing --->
<!---<div style="padding-top:10px;background-color:##fff"></div>--->
</cfoutput>



	
<!---<cfdump var="#theXML#">--->