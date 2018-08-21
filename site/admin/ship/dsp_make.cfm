<cfset TrackingNumber = theXML.xmlRoot.ShipmentResults.PackageResults.TrackingNumber.xmlText>
<cfset binaryData = toBinary(theXML.xmlRoot.ShipmentResults.PackageResults.LabelImage.GraphicImage.xmlText)>
<!---<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.gif" output="#binaryData#">--->
<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.gif" output="#binaryData#">
<!--- original HTML from UPS
<cfset binaryData = toBinary(theXML.xmlRoot.ShipmentResults.PackageResults.LabelImage.HTMLImage.xmlText)>
<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.html" output="#binaryData#">
--->
<!--- resize & rotate
<cfscript>
	myImage = CreateObject("Component","Image");
	myImage.readImage("#request.basepath#ups\label#TrackingNumber#.gif");
//	myImage.scalePixels(613, 350);
	myImage.rotate(90, true);
	myImage.writeImage("#request.basepath#ups\label#TrackingNumber#.jpg", "jpg");
</cfscript>
<cffile action="delete" file="#request.basepath#ups\label#TrackingNumber#.gif">
--->
<!---<cfset binaryData = '<IMG SRC="./label#TrackingNumber#.gif" height="330"><IMG SRC="./sticker.jpg" height="330"><script type="text/javascript" language="javascript1.2">window.print();</script>'>--->
<cfset binaryData = '<IMG SRC="./label#TrackingNumber#.gif" height="540" width="960" align="center" style="padding-left: 10px;"><script type="text/javascript" language="javascript1.2">window.print();</script>'>
<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.html" output="#binaryData#">
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET ShipCharge = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ShipCharge#">,
		tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TrackingNumber#">
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>


<!---vry:20110816 if this is amazon item lets update the amazon item to be: tracking_generated --->
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
					tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TrackingNumber#">,
					ShipCharge = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ShipCharge#">

				WHERE byrCompanyName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlAmazonItem.amazon_item_amazonorderid#">
			</cfquery>

		</cfif>
</cfif>

<cfset LogAction("generated UPS label #TrackingNumber# for item #sqlItem.item#")>
<cfset LogIRE(2, attributes.ShipCharge, sqlItem.item, sqlItem.ebayitem)><!--- IRE: UPS Labels --->

<!---
<cfoutput><br clear="all"><a href="ups\label#TrackingNumber#.html" target="_blank">View Label</a><br clear="all"></cfoutput>
--->
<cfoutput>
<!--- 20120131 if this is a fixed price item we need to use the transactionid of the item not the transactionid of the ebtransactions coz there are a lot of records in the ebtransactions  --->
<cfif sqlItem.offebay eq 2>
	<cfset d_transactionid = sqlItem.ebayTxnid>
<cfelse>
	<cfset d_transactionid = sqlItem.TransactionID>
</cfif>
<script language="javascript" type="text/javascript">
<!--//
LabelWin = window.open("ups/label#TrackingNumber#.html", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
LabelWin.opener = self;
LabelWin.focus();
window.location = "index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#sqlItem.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=#d_transactionid#&nextdsp=admin.ship.gl&upsID=#theXML.xmlRoot.ShipmentResults.ShipmentIdentificationNumber.xmlText#";
//-->
</script>
<br>If the page does not redirect you then please <a href="index.cfm?act=admin.api.complete_sale&shipped=1&itemid=#sqlItem.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=#d_transactionid#&nextdsp=admin.ship.gl&upsID=#theXML.xmlRoot.ShipmentResults.ShipmentIdentificationNumber.xmlText#">CLICK HERE TO MARK THIS ITEM AS SHIPPED ON EBAY</a>. Thank you.<br>
</cfoutput>

<!--- Send email to buyer --->
<cfif sqlItem.hbemail NEQ "">
	<cfscript>
		shipLink = "http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#TrackingNumber#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12";
		shipLink = '<a href="#shipLink#">#shipLink#</a>';
		eBayLink = "http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#";
		eBayLink = '<a href="#eBayLink#">#eBayLink#</a>';
		theMessage = _vars.emails.shipped_message;
		theMessage = ReplaceNoCase(theMessage, "{Buyer ID}", sqlItem.hbuserid, "ALL");
		theMessage = ReplaceNoCase(theMessage, "{Title}", sqlItem.title, "ALL");
		theMessage = ReplaceNoCase(theMessage, "{eBay Link}", eBayLink, "ALL");
		theMessage = ReplaceNoCase(theMessage, "{eBay Number}", sqlItem.ebayitem, "ALL");
		theMessage = ReplaceNoCase(theMessage, "{Shipper}", "UPS", "ALL");
		theMessage = ReplaceNoCase(theMessage, "{Tracking Number}", TrackingNumber, "ALL");
		theMessage = ReplaceNoCase(theMessage, "{Shipper Link}", shipLink, "ALL");
	</cfscript>

	<cftry>
    	<cfmail 
    	from="#_vars.mails.from#"
		to="#sqlItem.hbemail#"
		bcc="#_vars.emails.BCC_Item_Shipped#"
		subject="Your item has been shipped! eBay Item #sqlItem.ebayitem# #sqlItem.title#" type="html">#theMessage#</cfmail>
    <cfcatch type="Any" >
    </cfcatch>
    </cftry>


</cfif>
