<cfif not isdefined("pageData.WeightOz")>
	<cfset pageData.WeightOz = 0>
</cfif>

<cfif not isdefined("pageData.TO_PostalCode") and isdefined("pageData.TO_ZIPCODE")>
	<cfset pageData.TO_PostalCode = ListFirst(pageData.TO_ZIPCODE, "-")>
</cfif>


<cfset attributes.weight = "#(pageData.Weight*16+pageData.WeightOz)#" >

<!---Hack weight --->
<cfif attributes.weight eq 0 or not isnumeric(attributes.weight)>
	<cfset attributes.weight = "1">
</cfif>
<!---end --->

<cfparam name="attributes.mailClass1" default="PRIORITY" ><!--- first = first class mail --->
<!--- we are calculating oz --->



<!---<cfparam name="attributes.mailClass1" default="FIRST" >---><!--- weight should not exceed 13 ounces --->
<!---<cfparam name="attributes.weight" default="#(pageData.Weight*16+pageData.WeightOz)#" ><!--- default is 1 pound = 16 onzes --->--->
<cfparam name="attributes.MailpieceShape" default="Parcel" ><!--- Shape of the mailpiece. --->
<cfparam name="attributes.Machinable" default="True" >
<cfparam name="attributes.TO_PostalCode" default="#pageData.TO_PostalCode#" >
<cfparam name="attributes.dInsuredMail" default="OFF" >
<cfparam name="attributes.Weight" default="#sqlItem.Weight#">


<cfparam name="form.dWidth" default="1" >
<cfparam name="form.dHeight" default="1" >
<cfparam name="form.dLength" default="1" >



<cfif isdefined("form.dformMailClass") and form.dformMailClass neq "" >
	<cfset attributes.mailClass1 = form.dformMailClass >
	<cfif FindNoCase(":", form.dformMailClass)>
		<cfset attributes.mailClass1 = listfirst(form.dformMailClass,":")>
		<cfset attributes.MailpieceShape = listlast(form.dformMailClass,":")>
</cfif>



</cfif>
<cfif isnumeric("form.dformWeight")>
	<cfset attributes.weight = form.dformWeight * 16 >
</cfif>
<cfif isdefined("form.dformWeightOZ") and isnumeric(form.dformWeightOZ)>
	<cfset attributes.weight += form.dformWeightOZ >
</cfif>
<cfif isdefined("form.dInsuredMail") and form.dInsuredMail neq "">
	<cfset attributes.dInsuredMail = form.dInsuredMail >
<cfelse>
	<cfset attributes.dInsuredMail = "OFF" >
</cfif>

<cfset postageRateRequestXML = '
<PostageRateRequest>
<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
<CertifiedIntermediary>
<AccountID>#_vars.endicia.AccountID#</AccountID>
<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
</CertifiedIntermediary>
<MailClass>#attributes.mailClass1#</MailClass>
<WeightOz>#attributes.weight#</WeightOz>
<MailpieceShape>#attributes.MailpieceShape#</MailpieceShape>
<Machinable>#attributes.Machinable#</Machinable>
<Services DeliveryConfirmation="OFF" SignatureConfirmation="OFF"/>
<FromPostalCode>#_vars.upsFrom.ZIPCode#</FromPostalCode>
<ToPostalCode>#attributes.TO_PostalCode#</ToPostalCode>
<ResponseOptions PostagePrice="TRUE"/>
</PostageRateRequest>'>

<!---<cfif Left(_vars.usps.url, 5) EQ "https">
	<cfset port = "443">
	<cfset host = "LabelServer.Endicia.com">
<cfelse>
	<cfset port = "80">
	<cfset host = "www.envmgr.com">
</cfif>--->

<cfif Left(_vars.endicia.url, 5) EQ "https">
	<cfset port = "443">
	<cfset host = "LabelServer.Endicia.com">
<cfelse>
	<cfset port = "80">
	<cfset host = "LabelServer.Endicia.com">
</cfif>


<!---<cfhttp url="#_vars.endicia.url#/CalculatePostageRateXML" <!---port="#port#"---> method="post" charset="utf-8">--->
<cfhttp url="#_vars.endicia.url#/CalculatePostageRateXML" <!---port="#port#"---> method="post" charset="utf-8">
	<cfhttpparam name="Host" value="#host#" type="HEADER">
	<cfhttpparam name="Content-Type" value="application/x-www-form-urlencoded" type="HEADER">
	<cfhttpparam name="Content-Length" value="#Len(postageRateRequestXML)#" type="HEADER">
	<cfhttpparam name="postageRateRequestXML" value="#postageRateRequestXML#" type="formfield">
</cfhttp>
<!---<cfdump var="#port#">
<cfdump var="#_vars.endicia.url#">
<cfdump var="#host#">--->
<cfset goodXML = TRUE>
<cftry>
	<cfset xmlResponse = XMLParse(ToString(cfhttp.Filecontent))>
	<cfcatch type="any">
		<cfset goodXML = FALSE>
	</cfcatch>
</cftry>

<!---<cfdump var="#cfhttp.Filecontent#">--->

<cfoutput>

	<cfif goodXML>
		<cfif xmlResponse.xmlRoot.Status.xmlText NEQ "0">
			<h3 style="color:red;">Fail to calculate shipping cost in USPS</h3>
			<cfif structkeyexists(xmlResponse.XmlRoot,"ErrorMessage")>#xmlResponse.XmlRoot.ErrorMessage.XmlText#</cfif>
		<cfelse>
			<!--- display price preview here --->

					<tr>
						<td width="30%">
							<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" >
							<tr bgcolor="##8DD0FC"><td colspan="2"  align="left"><b>USPS Shipment Charges Preview</b></td></tr>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Billing Weight</b></td>
								<td><cftry>
                                    	#theXML.xmlRoot.BillingWeight.Weight.xmlText# #theXML.xmlRoot.BillingWeight.UnitOfMeasurement.Code.xmlText#                                
                                    <cfcatch type="Any" >
                                    	Undefined
                                    </cfcatch>
                                    </cftry></td>
							</tr>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" ><b>Mail Class</b></td>
								<td align="left">#xmlResponse.xmlRoot.PostagePrice.MailClass.xmlText#</td>
							</tr>
							<cfif structkeyexists(xmlResponse.XmlRoot.PostagePrice.Postage,"MailService")>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" ><b>Mail Service</b></td>
								<td align="left">#xmlResponse.xmlRoot.PostagePrice.Postage.MailService.xmlText#</td>
							</tr>
							</cfif>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" ><b>Price</b></td>
								<td align="left">
									#dollarformat(xmlResponse.xmlRoot.PostagePrice.XmlAttributes.TotalAmount)#
									<cfset uspsPriceDisplay = xmlResponse.xmlRoot.PostagePrice.XmlAttributes.TotalAmount >
								</td>
							</tr>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" ><b>Zone</b></td>
								<td align="left">#xmlResponse.xmlRoot.Zone.xmlText#</td>
							</tr>							
							
							</table>

							<!--- add some spacing --->
							<div style="padding-top:10px;b ackground-color:##fff"></div>

						</td>
					</tr>

		</cfif>
	<cfelse>
		<h3 style="color:red;">Fail to calculate shipping cost</h3>
	</cfif>
		
</cfoutput>



