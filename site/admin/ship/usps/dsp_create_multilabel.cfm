<cfset _vars.upsFrom.Telephone = ReReplace(_vars.upsFrom.Telephone, "[^0-9]", "", "all")>
<cfset attributes.TO_Phone = ReReplace(attributes.TO_Phone, "[^0-9]", "", "all")>
<cfif attributes.TO_Country EQ "US">
	<cfset XML_TO_Country = "United States">
<cfelseif attributes.TO_Country EQ "CA">
	<cfset XML_TO_Country = "Canada">
<cfelse>
	<cfset XML_TO_Country = attributes.TO_Country>
</cfif>
<cfset FIX_Description = Left("Items " & session.combined, 50)><!---Replace(Left(attributes.item & " " & sqlItem.title, 50), "&", "", "ALL")--->
<!--- pkdaddy126 (16.05.2007 19:21:27): Explaniation of Contents needs to just say "Merchandise" everytime
<cfset FIX_ContentsExplanation = Replace(Left(sqlItem.title, 25), "&", "", "ALL")>
<cfset FIX_ContentsExplanation = Replace(FIX_ContentsExplanation, "%", "", "ALL")>
---><cfset FIX_ContentsExplanation = "Merchandise">
<cfparam name="attributes.Test" default="NO">
<cfset attributes.FromName = _vars.upsFrom.Company>
<!--- TRICK --->
<cfif attributes.InsuredMail EQ "OFF">
	<cfset attributes.FromCompany = _vars.upsFrom.Company>
<cfelse>
	<cfset attributes.FromCompany = "Endicia Insured">
</cfif>
<!--- GENERATE ENDICIA LABEL --->
<cfset XMLRequest ='
<LabelRequest Test="#attributes.Test#" ImageFormat="GIF" LabelType="DEFAULT" LabelSize="4X6">
	<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
	<AccountID>#_vars.endicia.AccountID#</AccountID>
	<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
	<MailClass>#attributes.MailClass#</MailClass>
	<DateAdvance>0</DateAdvance>
	<WeightOz>#(attributes.Weight*16+attributes.WeightOz)#</WeightOz>
	<PackageSize>REGULAR</PackageSize>
	<IncludePostage>TRUE</IncludePostage>
	<Stealth>TRUE</Stealth>
	<Services InsuredMail="#attributes.InsuredMail#" SignatureConfirmation="OFF" />
	<TrackingType>PIC</TrackingType>
	<BarcodeFormat>CONCATENATED</BarcodeFormat>
	<Value>#attributes.DeclaredValue#</Value>
	<Description><![CDATA[ #FIX_Description# ]]></Description>
	<OriginCountry>United States</OriginCountry>
	<ContentsType>OTHER</ContentsType>
	<ContentsExplanation>#FIX_ContentsExplanation#</ContentsExplanation>
	<ReferenceID>#Left(session.combined, 50)#</ReferenceID>
	<PartnerCustomerID>#Left(session.combined, 25)#</PartnerCustomerID>
	<PartnerTransactionID>#Left(session.combined, 25)#</PartnerTransactionID>
	<ToName>#attributes.TO_Name#</ToName>
	<ToCompany>#attributes.TO_Firm#</ToCompany>
	<ToAddress1><![CDATA[ #attributes.TO_Address1# ]]></ToAddress1>
	<ToAddress2><![CDATA[ #attributes.TO_Address2# ]]></ToAddress2>
	<ToAddress3><![CDATA[ #attributes.TO_Address3# ]]></ToAddress3>
	<ToCity>#attributes.TO_City#</ToCity>
	<ToCountry>#XML_TO_Country#</ToCountry>
	<ToState>#attributes.TO_Province#</ToState>
	<ToPostalCode>#attributes.TO_PostalCode#</ToPostalCode>
	<ToZIP4>0000</ToZIP4>
	<ToDeliveryPoint>00</ToDeliveryPoint>
	<ToEMail>#attributes.TO_Email#</ToEMail>
	<ToPhone>#attributes.TO_Phone#</ToPhone>
	<FromName>#attributes.FromName#</FromName>
	<ReturnAddress1>#_vars.upsFrom.Address1#</ReturnAddress1>
	<FromCompany>[#Left(session.combined, 25)#][#sqlItem.lid#]</FromCompany>
	<FromCity>#_vars.upsFrom.City#</FromCity>
	<FromState>#_vars.upsFrom.State#</FromState>
	<FromPostalCode>#_vars.upsFrom.ZIPCode#</FromPostalCode>
	<FromZIP4></FromZIP4>
	<FromPhone>     #_vars.upsFrom.Telephone#</FromPhone>'>
<cfloop query="sqlItem">
	<cfset FIX_Item_Description = Replace(Left(item & " " & title, 50), "&", "", "ALL")>
	<cfset XMLRequest ='#XMLRequest#
	<CustomsDescription#CurrentRow#><![CDATA[ #FIX_Item_Description# ]]></CustomsDescription#CurrentRow#>
	<CustomsCountry#CurrentRow#>United States</CustomsCountry#CurrentRow#>
	<CustomsQuantity#CurrentRow#>1</CustomsQuantity#CurrentRow#>
	<CustomsValue#CurrentRow#>#price#</CustomsValue#CurrentRow#>
	<CustomsWeight#CurrentRow#>#(weight*16)#</CustomsWeight#CurrentRow#>
'>
</cfloop>
	<cfset XMLRequest ='#XMLRequest#
</LabelRequest>
'>
<cfset XMLRequest = Replace(XMLRequest, "
", "", "all")>
<cfset XMLRequest = Replace(XMLRequest, "	", "", "all")>

<cfif Left(_vars.endicia.url, 5) EQ "https">
	<cfset port = "443">
	<cfset host = "LabelServer.Endicia.com">
<cfelse>
	<cfset port = "80">
	<cfset host = "LabelServer.Endicia.com">
</cfif>

<cfhttp url="#_vars.endicia.url#/GetPostageLabelXML" port="#port#" method="post" charset="utf-8">
	<cfhttpparam name="Host" value="#host#" type="HEADER">
	<cfhttpparam name="Content-Type" value="application/x-www-form-urlencoded" type="HEADER">
	<cfhttpparam name="Content-Length" value="#Len(XMLRequest)#" type="HEADER">
	<cfhttpparam name="labelRequestXML" value="#XMLRequest#" type="formfield">
</cfhttp>



<cfif cfhttp.Mimetype EQ "text/xml">
	<cfset xmlResponse = XMLParse( toString(cfhttp.FileContent) )>
	<cfif xmlResponse.xmlRoot.Status.xmlText NEQ "0">
		<cfoutput>
		<h3 style="color:red; margin-bottom:0px; padding-bottom:0px;">Error Occured. Code #xmlResponse.xmlRoot.Status.xmlText#</h3>
		<pre style="color:red;">#xmlResponse.xmlRoot.ErrorMessage.xmlText#</pre>
		<textarea cols="80" rows="10">#XMLRequest#</textarea>
		</cfoutput>
	<cfelse>
		<cfset request.show_form = FALSE>
		<cfset binaryData = toBinary(xmlResponse.xmlRoot.Base64LabelImage.xmlText)>
		<cfloop query="sqlItem">
			<cffile action="write" addnewline="no" file="#request.basepath#usps\#item#.gif" output="#binaryData#">
		</cfloop>
		<!--- resize & rotate --->
		<cfscript>
			myImage = CreateObject("Component","Image");
			myImage.readImage("#request.basepath#usps\#sqlItem.item#.gif");
			myImage.rotate(-90, true);
		//	myImage.scalePixels(495, 330);
		//	myImage.writeImage("#request.basepath#usps\#sqlItem.item#.jpg", "jpg");
		</cfscript>
		<cfloop query="sqlItem">
			<cfset myImage.writeImage("#request.basepath#usps\#item#.jpg", "jpg")>
			<!--- DO WE NEED THIS?
			<cfif FileExists("#request.basepath#usps\#item#.gif")>
				<cffile action="delete" file="#request.basepath#usps\#item#.gif">
			</cfif>
			--->
		</cfloop>
		<cfif StructKeyExists(xmlResponse.xmlRoot, "PIC")>
			<cfset uspsID = xmlResponse.xmlRoot.PIC.xmlText>
		<cfelseif StructKeyExists(xmlResponse.xmlRoot, "CustomsNumber")>
			<cfset uspsID = xmlResponse.xmlRoot.CustomsNumber.xmlText>
		<cfelseif StructKeyExists(xmlResponse.xmlRoot, "TrackingNumber")>
			<cfset uspsID = xmlResponse.xmlRoot.TrackingNumber.xmlText>
		<cfelse>
			<cfset uspsID = "UNKNOWN">
			<cfif request.emails.error NEQ "">
				<cfmail server="#_vars.mails.server#" port="#_vars.mails.port#" from="#_vars.mails.from#" to="#request.emails.error#" subject="IA UNKNOWN Tracking Number. USPS Debug Info" type="html"><cfdump var="#xmlResponse#"></cfmail>
			</cfif>
		</cfif>
		<cfif attributes.Test NEQ "YES">
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET ShipCharge = <cfqueryparam cfsqltype="cf_sql_float" value="#xmlResponse.xmlRoot.FinalPostage.xmlText#">,
				tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#uspsID#">
				WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
			</cfquery>
			<cfset LogAction("generated USPS label #uspsID# for items #session.combined#")>
			<cfsilent>
				<cfset firstitem = sqlItem.item>
				<cfoutput query="sqlItem" group="item">
					<cfif firstitem EQ item>
						<cfset LogIRE(1, xmlResponse.xmlRoot.FinalPostage.xmlText, item, ebayitem)><!--- IRE: USPS Labels --->
					<cfelse>
						<cfset LogIRE(1, 0, item, ebayitem)><!--- IRE: USPS Labels --->
					</cfif>
				</cfoutput>
			</cfsilent>
			<cfset attr = StructNew ()>
			<cfset attr.name = "endicia.PostageBalance">
			<cfset attr.avalue = "#xmlResponse.xmlRoot.PostageBalance.xmlText#">
			<cfmodule template="../../act_updatesetting.cfm" attributecollection="#attr#">
		</cfif>
		<cfoutput>
		<script language="javascript" type="text/javascript">
		<!--//
			alert('Congratulations! Label generated successfully.\n\n    Final Postage:\t $#xmlResponse.xmlRoot.FinalPostage.xmlText#\n    Postage Balance:\t $#xmlResponse.xmlRoot.PostageBalance.xmlText#\n\nPlease click OK to open label for print.');
			LabelWin = window.open("index.cfm?dsp=admin.ship.usps.print_label&itemid=#sqlItem.item#", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
			LabelWin.opener = self;
			LabelWin.focus();
			<cfif attributes.Test NEQ "YES">
				window.location = "index.cfm?act=admin.api.complete_sale_multilabel&shipped=1&items=#session.combined#&nextdsp=admin.ship.awaiting&uspsID=#uspsID#";
			</cfif>
		//-->
		</script>
		<div style="margin:20px 20px 20px 20px;">
			<h4>Final Postage:  #xmlResponse.xmlRoot.FinalPostage.xmlText#</h4>
			<h4>Postage Balance: #xmlResponse.xmlRoot.PostageBalance.xmlText#</h4>
			<h4>Tracking Number: #uspsID#</h4>
			
			
			<cfif attributes.Test NEQ "YES">
						If the page does not redirect you then please <a style="color:##006600; font-weight:bold;" href="index.cfm?act=admin.api.complete_sale_multilabel&shipped=1&items=#session.combined#&nextdsp=admin.ship.awaiting&uspsID=#uspsID#">CLICK HERE TO MARK THIS ITEM AS SHIPPED ON EBAY</a>. Thank you.
				<!--- Send email to buyer --->
				<cfloop query="sqlItem">
					<cfquery name="sqlEmail" datasource="#request.dsn#" maxrows="1">
						SELECT e.hbuserid, e.hbemail, i.ebayitem, e.title
						FROM items i
							INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
						WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item#">
					</cfquery>
					<cfif sqlEmail.hbemail NEQ "">
						<cfscript>
							shipLink = "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#uspsID#";
							shipLink = '<a href="#shipLink#">#shipLink#</a>';
							eBayLink = "http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlEmail.ebayitem#";
							eBayLink = '<a href="#eBayLink#">#eBayLink#</a>';
							theMessage = _vars.emails.shipped_message;
							theMessage = ReplaceNoCase(theMessage, "{Buyer ID}", sqlEmail.hbuserid, "ALL");
							theMessage = ReplaceNoCase(theMessage, "{Title}", sqlEmail.title, "ALL");
							theMessage = ReplaceNoCase(theMessage, "{eBay Link}", eBayLink, "ALL");
							theMessage = ReplaceNoCase(theMessage, "{eBay Number}", sqlEmail.ebayitem, "ALL");
							theMessage = ReplaceNoCase(theMessage, "{Shipper}", "USPS", "ALL");
							theMessage = ReplaceNoCase(theMessage, "{Tracking Number}", uspsID, "ALL");
							theMessage = ReplaceNoCase(theMessage, "{Shipper Link}", shipLink, "ALL");
						</cfscript>
						<cfmail server="#_vars.mails.server#" port="#_vars.mails.port#" from="#_vars.mails.from#"
							to="#sqlEmail.hbemail#"
							bcc="#_vars.emails.BCC_Item_Shipped#"
							subject="Your item has been shipped! eBay Item #sqlEmail.ebayitem# #sqlEmail.title#" type="html">#theMessage#</cfmail>
					</cfif>
				</cfloop>
			</cfif>


		</div>
		</cfoutput>
		<cfset session.combined = ""><!--- ONCE LABEL GENERATED, CLEAR COMBINED QUEUE --->
	</cfif>
<cfelse>
	<cfoutput>
	<h3 style="color:red; margin-bottom:0px; padding-bottom:0px;">Bad Response</h3>
	#cfhttp.FileContent#
	</cfoutput>
</cfif>
