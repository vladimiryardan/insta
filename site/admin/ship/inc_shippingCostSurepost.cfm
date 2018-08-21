<cfparam name="attributes.item" default="#sqlItem.item#">

<cfif not isdefined("pageData.UPSService")>
	<cfset pageData.UPSService = "03">
</cfif>



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
<cfparam name="attributes.Weight" default="#sqlItem.Weight#" >
<cfparam name="attributes.Weight_oz" default="#sqlItem.Weight_oz#">

<cfparam name="attributes.height" default="#sqlItem.height#">
<cfparam name="attributes.depth" default="#sqlItem.depth#">
<cfparam name="attributes.width" default="#sqlItem.width#">


<!--- hack 0 weight --->
<cfif attributes.weight eq 0 or not isnumeric(attributes.weight)>
	<cfset attributes.weight = "1">
</cfif>


<cfif isdefined("form.dformWeight")>
	<cfset attributes.weight = form.dformWeight>
</cfif>

<cfif isdefined("form.dUPSService") and form.dUPSService neq "">
	<cfset attributes.UPSService = form.dUPSService>
</cfif>


<!--- get surepost price --->
<cfset surepostPrice = returnSurepostPrice(attributes.TO_ZIPCODE,attributes.Weight)>


<!---
<!--- SUREPOST --->
<CFSET XMLREQUEST = '<?xml version="1.0"?>
<AccessRequest xml:lang="en-US">
  <AccessLicenseNumber>#_vars.ups.AccessLicenseNumber#</AccessLicenseNumber>
  <UserId>#_vars.ups.UserId#</UserId>
  <Password>#_vars.ups.Password#</Password>
</AccessRequest>
<?xml version="1.0"?>
<RatingServiceSelectionRequest xml:lang="en-US">
  <Request>
    <TransactionReference>
      <CustomerContext>#attributes.item#</CustomerContext>
      <XpciVersion>1.0</XpciVersion>
    </TransactionReference>
    <RequestAction>Rate</RequestAction>
    <RequestOption>Rate</RequestOption>
  </Request>
  <PickupType><Code>01</Code>
    <Description>Daily Pickup</Description>
  </PickupType>
  <Shipment>
    <Description>#attributes.item#</Description>
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
				<StateProvinceCode>#_vars.upsFrom.State#</StateProvinceCode>
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
				<StateProvinceCode>#attributes.TO_State#</StateProvinceCode>
				<PostalCode>#attributes.TO_ZIPCode#</PostalCode>
				<CountryCode>#attributes.TO_Country#</CountryCode>
				#txtResidentialAddress#
			</Address>
		</ShipTo>
		
	<RateInformation>
		<NegotiatedRatesIndicator></NegotiatedRatesIndicator>
	</RateInformation>   
	
	<Service>
		<Code>#attributes.UPSService#</Code>
	</Service>
    
	<Package>
		<ReferenceNumber>
			<Code>PC</Code>
			<Value><![CDATA[#trimmedItemNumber# ###attributes.internal_itemSKU2### #attributes.lid#]]></Value>
		</ReferenceNumber>
		<PackagingType>
			<Code>#attributes.PackageType#</Code>
		</PackagingType>
		<PackageWeight>
			<UnitOfMeasurement>
				<Code>LBS</Code>
			</UnitOfMeasurement>
			<Weight>#attributes.Weight#</Weight>
		</PackageWeight>
'>


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
</RatingServiceSelectionRequest>
'>


<cfhttp url="https://onlinetools.ups.com/ups.app/xml/Rate" method="POST" charset="utf-8" port="443">
	<cfhttpparam name="request" value="#XMLRequest#" type="XML">
</cfhttp>--->

<!---<cfset goodXML = TRUE>
<cftry>
	<cfset theXML = XMLParse(ToString(cfhttp.Filecontent))>
	<cfcatch type="any">
		<cfset goodXML = FALSE>
	</cfcatch>
</cftry>--->




<cfoutput>
<!---
	<cfif goodXML>
		<cfif theXML.xmlRoot.Response.ResponseStatusDescription.xmlText EQ "failure">
			<h3 style="color:red;">Fail to calculate shipping cost in UPS</h3>
			<cfif structkeyexists(theXML.xmlRoot.Response,"Error")>#theXML.xmlRoot.Response.Error.ErrorDescription.XmlText#</cfif>
		<cfelse>
			<!--- display price preview here --->
						<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" >

						<tr <!---bgcolor="##F0F1F3"---> bgcolor="##D4CCBF"><td colspan="2"  align="left"><b>UPS Surepost Charges Preview</b></td></tr>
						<tr bgcolor="##FFFFFF">
							<td valign="middle"	 width="32%"><b>Billing Weight</b></td>
							<td>
								#theXML.xmlRoot.RatedShipment.BillingWeight.Weight.xmlText# #theXML.xmlRoot.RatedShipment.BillingWeight.UnitOfMeasurement.Code.xmlText#
								<cfif #theXML.xmlRoot.RatedShipment.BillingWeight.UnitOfMeasurement.Code.xmlText# is "LBS">
									(equal to #theXML.xmlRoot.RatedShipment.BillingWeight.Weight.xmlText*16# Oz)
								</cfif>
							</td>
						</tr>

						
						<cfset totalSum = 1000000><!--- to make it noticeable if TotalCharges not found in ShipmentCharges --->
						<cfloop index="i" from="1" to="#ArrayLen(theXML.xmlRoot.RatedShipment.xmlChildren)#">
							<cfif theXML.xmlRoot.RatedShipment.xmlChildren[i].xmlName EQ "TotalCharges">
								<cfset totalSum = Val(theXML.xmlRoot.RatedShipment.xmlChildren[i].MonetaryValue.xmlText)>
							</cfif>
							
							<cfif structkeyExists(theXML.xmlRoot.RatedShipment.xmlChildren[i],"MonetaryValue") >
								<tr bgcolor="##FFFFFF">
									<td valign="middle" ><b>#theXML.xmlRoot.RatedShipment.xmlChildren[i].xmlName#</b></td>
									<td align="left">#dollarformat(theXML.xmlRoot.RatedShipment.xmlChildren[i].MonetaryValue.xmlText)#</td>
								</tr>
							</cfif>
							<!---
							DEBUGGING PART
							<br>----------------------------------------------------<br>							
							<cfdump var="#theXML.xmlRoot.RatedShipment.xmlChildren[i]#">							
							--->
						</cfloop>
													
						<!--- INCLUDE NEGOTIATED RATES --->
						<tr bgcolor="##F8F6F9">
							<td valign="middle" ><b>Negotiated Rates</b></td>
							<td align="left">#dollarformat(theXML.xmlRoot.RatedShipment.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)#</td>
						</tr>	
														
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
						<tr bgcolor="##F8F6F9">
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

						
	
			
		</cfif>
	<cfelse>
		<h3 style="color:red;">Fail to calculate UPS Surepost.</h3>
	</cfif>--->
	
	
						<!--- 
						surepost display
						 --->
						<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" > 
						<tr bgcolor="##D4CCBF">
							<td colspan="2"  align="left"><b>UPS Surepost Charges Preview</b></td>
						</tr>	
						<tr bgcolor="##fff">
							<td valign="middle"	 width="32%">
								<strong>Surepost Price</strong>
							</td>
							<td>
								#dollarFormat(surepostPrice.price)#
							</td>					
						</tr>
						<tr bgcolor="##F8F6F9">
							<td valign="middle"	 width="32%">
								<strong>Surepost Zone</strong>
							</td>
							<td>
								#surepostPrice.zone#
							</td>					
						</tr>
						<!--- dont show it for now --->
						<!---<tr bgcolor="##fff">
							<td valign="middle"	 width="32%">
								<strong>Surepost Price (10%)</strong>
							</td>
							<td>
								<!--- discounted 10% --->
								#dollarFormat(surepostPrice.price - (surepostPrice.price * .1) )#
								
							</td>					
						</tr>--->															
						</table>	
<!--- add some spacing --->
<div style="padding-top:10px;background-color:##fff"></div>
</cfoutput>




