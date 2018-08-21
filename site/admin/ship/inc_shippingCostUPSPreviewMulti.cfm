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
<!---<cfparam name="attributes.INTERNAL_ITEMSKU2" default="#sqlItem.internal_itemSKU2#">--->
<!---<cfparam name="attributes.LID" default="#sqlItem.lid#">--->
<cfparam name="attributes.PackageType" default="02">
<cfparam name="attributes.OversizePackage" default="0">
<cfparam name="attributes.DeclaredValue" default="#pageData.DeclaredValue#">
<cfparam name="attributes.Weight" default="#pagedata.Weight#">

<!---<cfparam name="attributes.Weight_oz" default="#sqlItem.Weight_oz#">--->

<cfparam name="form.dformWeight" default="#pagedata.Weight#">
<cfparam name="form.dformWeightOZ" default="#sqlItem.weight_oz#">
<cfparam name="attributes.width" default="#sqlitem.Width#">
<cfparam name="attributes.height" default="#sqlitem.Height#">
<cfparam name="attributes.depth" default="#sqlitem.depth#">

<!---<cfparam name="attributes.width" default="#form.dWidth#">
<cfparam name="attributes.height" default="#form.dHeight#">
<cfparam name="attributes.depth" default="#form.dLength#">--->


<!--- hack 0 weight --->
<cfif attributes.weight eq 0 or not isnumeric(attributes.weight)>
	<cfset attributes.weight = "1">
</cfif>

<cfif form.dformWeight eq 0 or not isnumeric(form.dformWeight)>
	<cfset form.dformWeight = "1">
</cfif>

<cfif form.dformWeightOZ eq 0 or not isnumeric(form.dformWeightOZ)>
	<cfset form.dformWeightOZ = sqlItem.weight_oz>
</cfif>

<cfif isdefined("form.dformWeight")>
	<cfset attributes.weight = form.dformWeight>
</cfif>

<cfif isdefined("form.dUPSService") and form.dUPSService neq "">
	<cfset attributes.UPSService = form.dUPSService>
</cfif>

<cfif isdefined("form.dHeight")>
	<cfset attributes.height = form.dHeight>
</cfif>
<cfif isdefined("form.dWidth")>
	<cfset attributes.width = form.dWidth>
</cfif>

<cfif isdefined("form.dLength")>
	<cfset attributes.depth = form.dLength>
	
	<cfif isdefined("form.length") and isnumeric(form.length)>
		<cfset attributes.length = form.length >
	</cfif>

</cfif>

 
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
				<StateProvinceCode>#ucase(parseState(attributes.TO_State))#</StateProvinceCode>
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
				<Value><![CDATA[#left(session.combined,30)#]]></Value>
				
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
				<Weight>#attributes.weight#</Weight>
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
</ShipmentConfirmRequest>
'>




<!---https://www.ups.com/ups.app/xml/ShipConfirm--->
<!---<cfset upsShipUrl = "https://temp-onlinetools.ups.com/ups.app/xml/ShipConfirm">--->
<cfset upsShipUrl = "https://www.ups.com/ups.app/xml/ShipConfirm">
<cfhttp url="#upsShipUrl#" method="POST" charset="utf-8" port="443">
	<cfhttpparam name="request" value="#XMLRequest#" type="XML">
</cfhttp>

<cfset goodXML = TRUE>
<cftry>
	<cfset theXML = XMLParse( ToString(cfhttp.Filecontent) )>
	<cfcatch type="any">
		<cfset goodXML = FALSE>

	</cfcatch>
</cftry>


<cfoutput>

	<cfif goodXML>
		<cfif theXML.xmlRoot.Response.ResponseStatusDescription.xmlText EQ "failure">
			<h3 style="color:red;">Fail to calculate shipping cost in UPS</h3>
			<cfif structkeyexists(theXML.xmlRoot.Response,"Error")>#theXML.xmlRoot.Response.Error.ErrorDescription.XmlText#</cfif>
		<cfelse>
			<!--- display price preview here --->

					<tr>
						<td width="30%">
						<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" >
						<tr <!---bgcolor="##F0F1F3"---> bgcolor="##FFFB9E"><td colspan="2"  align="left"><b>UPS Shipment Charges Preview</b></td></tr>
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
							<td valign="middle" ><b>UPS Service</b></td>
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


						<cfif isdefined("theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText")>
							<cfset totalSum = Val(theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)>
							<tr bgcolor="##FFFFFF">
								<td valign="middle"width="32%"><b>Negotiated Rate</b></td>
								<td >#totalSum#</td>
							</tr>
						<cfelse>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="32%"><b>Negotiated Rate</b></td>
								<td>UNDEFINED</td>
							</tr>					
						</cfif>
						
												
						</table>







				<!---<cfoutput>
					
					<cfset bgcolorUPS = "">
					<cfset bgcolorUSPS = "">
					<!---<cfif isdefined("totalSum") and isdefined("uspsPriceDisplay") >
						<cfif totalSum lt uspsPriceDisplay>
							<cfset bgcolorUPS = "green">
							<cfset bgcolorUSPS = "red">
						<cfelse>
							<cfset bgcolorUPS = "red">
							<cfset bgcolorUSPS = "green">
						</cfif>
					</cfif>--->
										
					<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
						<!---<tr bgcolor="##FFFFFF">
							<td width="32%">
								UPS Negoiated Rates
								<cfif isdefined("totalSum")>
									<br><span style="color:#bgcolorUPS#;font-weight:bold">#dollarformat(totalSum)#</span>
								</cfif>
							</td>
							
							<td>
								USPS
								<cfif isdefined("uspsPriceDisplay")>
									<br>
									<span style="color:#bgcolorUSPS#;font-weight:bold">#dollarformat(uspsPriceDisplay)#</span>
								</cfif>
							</td>
						</tr>--->		
								
						<!--- catch the negotiated rates if available --->
						<cfif isdefined("theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText")>
							<cfset totalSum = Val(theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)>
							<tr bgcolor="##FFFFFF">
								<td valign="middle"width="32%"><b>Negotiated Rate</b></td>
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
				</cfoutput>	--->

		</cfif>
	<cfelse>
		<cfdump var="#cfhttp#">
		<h3 style="color:red;">Fail to calculate shipping cost 1001.</h3>
	</cfif>
</cfoutput>

