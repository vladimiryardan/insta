<cfquery name="sqlItem" datasource="#request.dsn#" maxrows="1">
	<!---    SELECT i.item, i.weight, i.shipnote, i.ebayitem,
	        e.hbemail, e.price, e.title,
	        i.byrName, i.byrStreet1, i.byrStreet2, i.byrCountry, i.byrPostalCode, i.byrCityName,
	i.byrStateOrProvince, i.byrPhone,
	        t.TransactionID, i.offebay
	    FROM items i
	        INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
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
	        )
	    ORDER BY t.AmountPaid DESC, t.byrName DESC--->
	SELECT i.weight, i.ebayitem, i.shipper, i.tracking, i.aid, i.item, i.dcreated, i.shipnote,
	a.email, a.first, a.last, e.title, e.hbuserid, e.hbemail, e.price, i.byrName, i.byrStreet1,
	i.byrStreet2,
	i.byrCountry, i.byrPostalCode, i.byrCityName, i.byrStateOrProvince, i.byrPhone, t.TransactionID,
	t.AmountPaid, i.offebay, i.ebayFixedPricePaid, i.ebayTxnid, i.internal_itemSKU, i.internal_itemSKU2,
	i.lid, i.weight_oz, i.height, i.depth, i.width
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
	i.offebay = 2 <!--- this are fixed price items with multi txns 20120131--->
	)
	ORDER BY t.tid DESC
</cfquery>

<!--- if this is a fixed price item and offebay is 2 we will need to parse hbuserid and get the ebayitem and set the sqlitem.ebayitem --->
<cfif sqlItem.offebay eq 2>
	<!--- get the ebayitem --->
	<cfset theEbayitem = #trim(ListGetAt(sqlItem.hbuserid, 1 ,"."))#>
	<cfset sqlItem.ebayitem = theEbayitem >
</cfif>

<cfset _vars.upsFrom.Telephone = ReReplace(_vars.upsFrom.Telephone, "[^0-9]", "", "all")>
<cfset attributes.TO_Phone = ReReplace(attributes.TO_Phone, "[^0-9]", "", "all")>
<cfif attributes.TO_Country EQ "US">
	<cfset XML_TO_Country = "United States">
<cfelseif attributes.TO_Country EQ "CA">
	<cfset XML_TO_Country = "Canada">
<cfelse>
	<cfset XML_TO_Country = attributes.TO_Country>
</cfif>
<cfset FIX_Description = Replace(Left(attributes.item & " " & sqlItem.title, 50), "&", "", "ALL")>
<!--- pkdaddy126 (16.05.2007 19:21:27): Explaniation of Contents needs to just say "Merchandise"
everytime
<cfset FIX_ContentsExplanation = Replace(Left(sqlItem.title, 25), "&", "", "ALL")>
<cfset FIX_ContentsExplanation = Replace(FIX_ContentsExplanation, "%", "", "ALL")>
--->
<cfset FIX_ContentsExplanation = "Merchandise">
<cfparam name="attributes.Test" default="NO">
<cfset attributes.FromName = _vars.upsFrom.Company>
<!--- TRICK --->
<cfif attributes.InsuredMail EQ "OFF">
	<cfset attributes.FromCompany = _vars.upsFrom.Company>
<cfelse>
	<cfset attributes.FromCompany = "Endicia Insured">
</cfif>

<cfset mailpieceshape = "PARCEL">
<cfset dMailClass = trim(attributes.MailClass)>


<!--- lets check if it has a mailpiece shape --->
<cfif FindNoCase(":", attributes.MailClass)>
	<cfset dMailClass = listfirst(attributes.MailClass,":")>
	<cfset mailpieceshape = listlast(attributes.MailClass,":")>
</cfif>

<cfoutput>
	<cfsavecontent variable="XMLRequest" >
		<LabelRequest Test="#attributes.Test#" ImageFormat="GIF"  >
			<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
			<AccountID>#_vars.endicia.AccountID#</AccountID>
			<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
			<MailClass>#trim(dMailClass)#</MailClass>
			<MailpieceShape>#trim(mailpieceshape)#</MailpieceShape>
			<DateAdvance>0</DateAdvance>
			<WeightOz>#(attributes.Weight*16+attributes.WeightOz)#</WeightOz>
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
			<ReferenceID>#attributes.item#</ReferenceID>
			<PartnerCustomerID>#attributes.item#</PartnerCustomerID>
			<PartnerTransactionID>#attributes.item#</PartnerTransactionID>
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
			<FromCompany><![CDATA[[#sqlItem.item#][#sqlItem.lid#]]]></FromCompany>
			<FromCity>#_vars.upsFrom.City#</FromCity>
			<FromState>#_vars.upsFrom.State#</FromState>
			<FromPostalCode>#_vars.upsFrom.ZIPCode#</FromPostalCode>
			<FromZIP4></FromZIP4>
			<FromPhone>#_vars.upsFrom.Telephone#</FromPhone>
			<CustomsDescription1><![CDATA[ #FIX_Description# ]]></CustomsDescription1>
			<CustomsCountry1>United States</CustomsCountry1>
			<CustomsQuantity1>1</CustomsQuantity1>
			<CustomsValue1>#attributes.DeclaredValue#</CustomsValue1>
			<CustomsWeight1>#(attributes.Weight*16+attributes.WeightOz)#</CustomsWeight1>
			<ResponseOptions PostagePrice="true"></ResponseOptions>
			<cfif trim(attributes.MailClass) EQ "MEDIAMAIL">
				 <!---do nothing --->
			<cfelse>	
				<SortType>Non-Presorted</SortType>
				<EntryFacility>Other</EntryFacility>
			</cfif>
		</LabelRequest>
		
	</cfsavecontent>
</cfoutput>
<!---Note:No SortType or EntryFacility should be included for any mail class except ParcelSelect --->

<!---
<cfsavecontent variable="XMLRequest" >
	<LabelRequest Test="#attributes.Test#" ImageFormat="GIF"  >
	<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
	<AccountID>#_vars.endicia.AccountID#</AccountID>
	<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
	
	
	<MailClass>#trim(dMailClass)#</MailClass>
	<MailpieceShape>#trim(mailpieceshape)#</MailpieceShape>
	<DateAdvance>0</DateAdvance>
	<WeightOz>#(attributes.Weight*16+attributes.WeightOz)#</WeightOz>
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
	<ReferenceID>#attributes.item#</ReferenceID>
	<PartnerCustomerID>#attributes.item#</PartnerCustomerID>
	<PartnerTransactionID>#attributes.item#</PartnerTransactionID>
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
	<FromCompany><![CDATA[[#sqlItem.item#][#sqlItem.lid#]]]></FromCompany>
	<FromCity>#_vars.upsFrom.City#</FromCity>
	<FromState>#_vars.upsFrom.State#</FromState>
	<FromPostalCode>#_vars.upsFrom.ZIPCode#</FromPostalCode>
	<FromZIP4></FromZIP4>
	<FromPhone>#_vars.upsFrom.Telephone#</FromPhone>
	<CustomsDescription1><![CDATA[ #FIX_Description# ]]></CustomsDescription1>
	<CustomsCountry1>United States</CustomsCountry1>
	<CustomsQuantity1>1</CustomsQuantity1>
	<CustomsValue1>#attributes.DeclaredValue#</CustomsValue1>
	<CustomsWeight1>#(attributes.Weight*16+attributes.WeightOz)#</CustomsWeight1>
	<ResponseOptions PostagePrice="true"></ResponseOptions>
	
	<!---No SortType or EntryFacility should be included for any mail class except ParcelSelect.--->
	<cfif trim(dMailClass) is "ParcelSelect"> 
		<SortType>Nonpresorted</SortType>
		<EntryFacility>Other</EntryFacility>
	</cfif>
	
</LabelRequest>
</cfsavecontent>--->

<!---
##### NOTE: BE CAREFUL WITH THE LETTER CASE IN THE XMLREQUEST ELEMENT. SPECIALLY THE MAILPIECESHAPE LETTER CASING. WRONG LETTER CASING GIVES YOU DIFFERENT RATE RESULT
 CODE HERE IS FROM ENDICIA BUT ERRORS ON 20161109
<cfset XMLRequest = '
<LabelRequest Test="#attributes.Test#" ImageFormat="GIF"  >
	<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
	<AccountID>#_vars.endicia.AccountID#</AccountID>
	<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
	<MailClass>#trim(dMailClass)#</MailClass>
	<MailPieceShape>#trim(mailpieceshape)#</MailPieceShape>
	<DateAdvance>0</DateAdvance>
	<WeightOz>#(attributes.Weight*16+attributes.WeightOz)#</WeightOz>
	<IncludePostage>TRUE</IncludePostage>
	<Stealth>TRUE</Stealth>
	<Services InsuredMail="#attributes.InsuredMail#" SignatureConfirmation="OFF" />
	
	<Value>#attributes.DeclaredValue#</Value>
	<Description><![CDATA#trim(FIX_Description)#]]></Description>
	<ReferenceID>#attributes.item#</ReferenceID>
	<PartnerCustomerID>#attributes.item#</PartnerCustomerID>
	<PartnerTransactionID>#attributes.item#</PartnerTransactionID>
	<ToName>#attributes.TO_Name#</ToName>
	<ToAddress1>#attributes.TO_Address1#</ToAddress1>
	<ToAddress2>#attributes.TO_Address2#</ToAddress2>
	<ToAddress3>#attributes.TO_Address3#</ToAddress3>
	<ToCity>#attributes.TO_City#</ToCity>	
	<ToState>#attributes.TO_Province#</ToState>
	<ToPostalCode>#attributes.TO_PostalCode#</ToPostalCode>
	
	<FromCompany>[#sqlItem.item#][#sqlItem.lid#]></FromCompany>
		<ReturnAddress1>#trim(_vars.upsFrom.address1)#</ReturnAddress1>
		<FromCity>#trim(_vars.upsFrom.city)#</FromCity>
		<FromState>#_vars.upsFrom.State#</FromState>
		<FromPostalCode>#_vars.upsFrom.ZIPCode#</FromPostalCode>
		<FromPhone>#_vars.upsFrom.Telephone#</FromPhone>
		<ResponseOptions PostagePrice="true" />
</LabelRequest>
'>--->


<!--- ResponseOptions is added 20150605 so that the zone will be returned in the response --->


<!---<cfset XMLRequest = Replace(XMLRequest, "", "", "all")>--->
<cfset XMLRequest = Replace(XMLRequest, "	", "", "all")>

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




<!---from post -> Changed to get. not secure--->
<cfhttp url="#_vars.endicia.url#/GetPostageLabelXML?labelRequestXML" port="#port#" 
		method="post" 
		charset="utf-8">
	<cfhttpparam name="Host" value="#host#" type="HEADER">
	<cfhttpparam name="Content-Type" value="application/x-www-form-urlencoded" type="HEADER">
	<cfhttpparam name="Content-Length" value="#Len(XMLRequest)#" type="HEADER">
	<cfhttpparam name="labelRequestXML" value="#XMLRequest#" type="formfield" >
</cfhttp>



<!---unComment for debugging--->
<!---
<cfoutput>
	<cfdump var="#_vars.endicia.url#"><br>
	<cfdump var="#_vars.endicia.url#/GetPostageLabelXML"><br>
	<cfdump var="#host#"><br>
	<cfdump var="#Len(XMLRequest)#"><br>
	<cfdump var="#XMLRequest#"><br>
	<cfdump var="#cfhttp#"><br>
	<cfabort>
</cfoutput>--->


<cfif cfhttp.Mimetype EQ "text/xml">
	<cfset xmlResponse = XMLParse(cfhttp.FileContent)>
	
	<cfif xmlResponse.xmlRoot.Status.xmlText NEQ "0">
		<cfoutput>
			<h3 style="color:red; margin-bottom:0px; padding-bottom:0px;">
				Error Occured. Code
				#xmlResponse.xmlRoot.Status.xmlText#
				<cfdump var="#xmlResponse#">
			</h3>
			<pre style="color:red;">#xmlResponse.xmlRoot.ErrorMessage.xmlText#</pre>
			<textarea cols="80" rows="10">
				#XMLRequest#
			</textarea>
		</cfoutput>
	<cfelse>
		<cfset request.show_form = FALSE>
		<cfset binaryData = toBinary(xmlResponse.xmlRoot.Base64LabelImage.xmlText)>


<!---<cfsavecontent variable="theContent">
	#binaryData#<br>
	#xmlResponse.xmlRoot.Base64LabelImage.xmlText#
	#request.basepath#usps\#sqlItem.item#.gif
	<br>
	<br>
	vlad - vlad

</cfsavecontent>--->

<!---<CFFILE ACTION="write" FILE="#request.basepath#\logtofile.txt"
OUTPUT="

	#xmlResponse.xmlRoot.Base64LabelImage.xmlText#
	#request.basepath#usps\#sqlItem.item#.gif
	vlad - vlad
">--->





		<cffile action="write" addnewline="no" file="#request.basepath#usps\#sqlItem.item#.gif"
		        output="#binaryData#">
		<!--- resize & rotate --->

		<!--- vlad changed this coz it errors in some instances 20120428. added a cflock coz there is issue in some images
		<cflock timeout="5" throwontimeout="No" name="myLock" type="EXCLUSIVE">
		<cfscript>
			myImage = CreateObject("Component", "Image");
			myImage.readImage("#request.basepath#usps\#sqlItem.item#.gif");
			myImage.rotate(-90, true);
			//    myImage.scalePixels(495, 330);
			myImage.writeImage("#request.basepath#usps\#sqlItem.item#.jpg", "jpg");
		</cfscript>
		</cflock>
		--->


			<!--- there was a disk space problem --->
	        <!--- vlad wanted to use this code but it seems the problem didn't go away.lets use cflock 20120428 --->
			<cflock timeout="5" throwontimeout="No" name="myLock" type="EXCLUSIVE">
				<cfset myImage=ImageNew("#request.basepath#usps\#sqlItem.item#.gif")>
				<cfset ImageRotate(#myImage#,-90)>
				<cfimage action="write" source="#myImage#" destination="#request.basepath#usps\#sqlItem.item#.jpg" overwrite="yes" >
			</cflock>
<!---		<cftry>
        <cfcatch type="Any" >
			<cffile action = "copy" destination = "#request.basepath#usps\#sqlItem.item#.jpg" source="#request.basepath#usps\#sqlItem.item#.gif">
			<cflock timeout="5" throwontimeout="No" name="myLock" type="EXCLUSIVE">
				<cfset myImage=ImageNew("#request.basepath#usps\#sqlItem.item#.jpg")>
				<cfset ImageRotate(#myImage#,-90)>
				<cfimage action="write" source="#myImage#" destination="#request.basepath#usps\#sqlItem.item#.jpg" overwrite="yes" >
			</cflock>
        </cfcatch>
        </cftry>--->




		<!--- TODO: UNCOMMENT IN FUTURE, IF WORKS OK
		<cffile action="delete" file="#request.basepath#usps\#sqlItem.item#.gif">
		--->
		<cfif StructKeyExists(xmlResponse.xmlRoot, "PIC")>
			<cfset uspsID = xmlResponse.xmlRoot.PIC.xmlText>
		<cfelseif StructKeyExists(xmlResponse.xmlRoot, "CustomsNumber")>
			<cfset uspsID = xmlResponse.xmlRoot.CustomsNumber.xmlText>
		<cfelseif StructKeyExists(xmlResponse.xmlRoot, "TrackingNumber")>
			<cfset uspsID = xmlResponse.xmlRoot.TrackingNumber.xmlText>
		<cfelse>
			<cfset uspsID = "UNKNOWN">
		</cfif>
		
		<!--- usps zone added 2050605 --->
		<cfset usps_zone = "">
		<cfif StructKeyExists(xmlResponse.xmlRoot.PostagePrice.Postage, "Zone")>
			<cfset usps_zone = xmlResponse.xmlRoot.PostagePrice.Postage.Zone.xmlText>
		</cfif>	



		
		<cfif attributes.Test NEQ "YES">
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET ShipCharge = <cfqueryparam cfsqltype="cf_sql_float"
			              value="#xmlResponse.xmlRoot.FinalPostage.xmlText#">
				,
				tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#uspsID#">,
				usps_zone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#usps_zone#">,
				shipper='USPS',
				weight = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Weight#">,
				weight_oz =  <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.WeightOz#">,
				Height = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Height#">,
				depth = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.depth#">,
				Width = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Width#">
							
				WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlItem.item#">
			</cfquery>
			<!---vry:20110816 if this is amazon item lets update the amazon item to be: tracking_generated
			--->
			<cfif sqlItem.offebay eq 1>
				<cfquery name="sqlAmazonItem" datasource="#request.dsn#" maxrows="1">
					select items_itemid,amazon_item_amazonorderid from amazon_items
					where items_itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
				</cfquery>
				<cfif sqlAmazonItem.recordcount gte 1>
					<cfquery datasource="#request.dsn#">
						Update amazon_items
						set local_status = 'tracking_generated'
						where items_itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
					</cfquery>
					<!--- 20120202: update the other items which has the same buyer company name.
					patrick need this for multi order of amazon. automate marking of  paid and shipped for amazon order multi--->
					<cfquery datasource="#request.dsn#">
						UPDATE items
						SET lid = 'P&S',<!--- paid and shipped --->
						status = 11, <!--- paid and shipped --->
						dlid = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						shipped = '1',
						paid = '1',
						ShippedTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#uspsID#">,
						
						ShipCharge = <cfqueryparam cfsqltype="cf_sql_float" value="#xmlResponse.xmlRoot.FinalPostage.xmlText#">
						WHERE byrCompanyName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlAmazonItem.amazon_item_amazonorderid#">
					</cfquery>
				</cfif>
			</cfif>

			<cfset LogAction("generated USPS label #uspsID# for item #sqlItem.item#")>
			<cfset LogIRE(1, xmlResponse.xmlRoot.FinalPostage.xmlText, sqlItem.item, sqlItem.ebayitem)><!---
                                                                                              IRE:
                                                                                              USPS
                                                                                              Labels
                                                                                               --->
			<cfset attr = StructNew()>
			<cfset attr.name = "endicia.PostageBalance">
			<cfset attr.avalue = "#xmlResponse.xmlRoot.PostageBalance.xmlText#">
			<cfmodule template="../../act_updatesetting.cfm" attributecollection="#attr#">
		</cfif>
		<cfoutput>

<!--- 20120131 if this is a fixed price item we need to use the transactionid of the item not the transactionid of the ebtransactions coz there are a lot of records in the ebtransactions  --->
<cfif sqlItem.offebay eq 2>
	<cfset d_transactionid = sqlItem.ebayTxnid>
<cfelse>
	<cfset d_transactionid = sqlItem.TransactionID>
</cfif>
			<script language="javascript" type="text/javascript">
				<!--//
							alert('Congratulations! Label generated successfully.\n\n    Final Postage:\t $#xmlResponse.xmlRoot.FinalPostage.xmlText#\n    Postage Balance:\t $#xmlResponse.xmlRoot.PostageBalance.xmlText#\n\nPlease click OK to open label for print.');
							LabelWin = window.open("index.cfm?dsp=admin.ship.usps.print_label&itemid=#sqlItem.item#", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
							LabelWin.opener = self;
							LabelWin.focus();
				<cfif attributes.Test NEQ "YES">
					//20101215 due to an error in usps and the item is not an ebay the act complete is not being updated coz the record is not found. Vlad uses attributes.item replacing sqlItem.item
							window.location = "index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#attributes.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=#d_transactionid#&nextdsp=admin.ship.gl&uspsID=#uspsID#";
				</cfif>
						//-->
			</script>
			<div style="margin:20px 20px 20px 20px;">
				
				
				<h4>
					Final Postage:
					#xmlResponse.xmlRoot.FinalPostage.xmlText#
				</h4>
				<h4>
					Postage Balance:
					#xmlResponse.xmlRoot.PostageBalance.xmlText#
				</h4>
				<h4>
					Tracking Number:
					#uspsID#
				</h4>
				
				<cfif attributes.Test NEQ "YES">
					<cfoutput>
						If the page does not redirect you then please
						<a style="color:##006600; font-weight:bold;"
						   href="index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#attributes.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=#d_transactionid#&nextdsp=admin.ship.gl&uspsID=#uspsID#">
							CLICK HERE TO MARK THIS ITEM AS SHIPPED ON EBAY
						</a>. Thank you.
					</cfoutput>
					<!--- Send email to buyer --->
					<cfquery name="sqlEmail" datasource="#request.dsn#" maxrows="1">
						SELECT e.hbuserid, e.hbemail, i.ebayitem, e.title
						FROM items i
						INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
						WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlItem.item#">
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

						<cftry>
	              			<cfmail server="#_vars.mails.server#" port="#_vars.mails.port#" from="#_vars.mails.from#"
							        to="#sqlEmail.hbemail#" bcc="#_vars.emails.BCC_Item_Shipped#"
							        subject="Your item has been shipped! eBay Item #sqlEmail.ebayitem# #sqlEmail.title#"
							        type="html">
								#theMessage#
							</cfmail>
                        <cfcatch type="Any" >
                        </cfcatch>
                        </cftry>
					</cfif>
				</cfif>
			</div>
		</cfoutput>
	</cfif>
<cfelse>
	<cfoutput>
		<h3 style="color:red; margin-bottom:0px; padding-bottom:0px;">
			Bad Response
		</h3>#cfhttp.FileContent#
	</cfoutput>
</cfif>
