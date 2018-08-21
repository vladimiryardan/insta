<cfset TrackingNumber = theXML.xmlRoot.ShipmentResults.PackageResults.TrackingNumber.xmlText>
<cfset binaryData = toBinary(theXML.xmlRoot.ShipmentResults.PackageResults.LabelImage.GraphicImage.xmlText)>
<!---<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.gif" output="#binaryData#">--->
<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.jpg" output="#binaryData#">
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
<!--- :vladedit: 20160930 - printer not liking gif
<cfset binaryData = '<IMG SRC="./label#TrackingNumber#.gif" height="423"><script type="text/javascript" language="javascript1.2">window.print();</script>'>
--->
<cfset binaryData = '<IMG SRC="./label#TrackingNumber#.jpg" height="423"><script type="text/javascript" language="javascript1.2">window.print();</script>'>

<cffile action="write" addnewline="no" file="#request.basepath#ups\label#TrackingNumber#.html" output="#binaryData#">

<cfquery datasource="#request.dsn#">
	UPDATE items
	SET ShipCharge = <cfqueryparam cfsqltype="cf_sql_float" value="#attributes.ShipCharge#">,
		tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TrackingNumber#">,
		combined = 1
	WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
</cfquery>
<cfset LogAction("generated UPS label #TrackingNumber# for items #session.combined#")>
<cfsilent>
	<cfset firstitem = sqlItem.item>
	<cfoutput query="sqlItem" group="item">
		<cfif firstitem EQ item>
			<cfset LogIRE(2, attributes.ShipCharge, sqlItem.item, sqlItem.ebayitem)><!--- IRE: UPS Labels --->
		<cfelse>
			<cfset LogIRE(2, 0, sqlItem.item, sqlItem.ebayitem)><!--- IRE: UPS Labels --->
		</cfif>
	</cfoutput>
</cfsilent>

<!---
<cfoutput><br clear="all"><a href="ups\label#TrackingNumber#.html" target="_blank">View Label</a><br clear="all"></cfoutput>
--->
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
LabelWin = window.open("ups/label#TrackingNumber#.html", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
LabelWin.opener = self;
LabelWin.focus();
window.location = "index.cfm?act=admin.api.complete_sale_multilabel&shipped=1&items=#session.combined#&nextdsp=admin.ship.awaiting&upsID=#theXML.xmlRoot.ShipmentResults.ShipmentIdentificationNumber.xmlText#";
//-->
</script>
<br>If the page does not redirect you then please <a href="index.cfm?act=admin.api.complete_sale_multilabel&shipped=1&items=#session.combined#&nextdsp=admin.ship.awaiting&upsID=#theXML.xmlRoot.ShipmentResults.ShipmentIdentificationNumber.xmlText#">CLICK HERE TO MARK ITEMS AS SHIPPED ON EBAY</a>. Thank you.<br>
</cfoutput>

<!--- Send email to buyer --->
<cfoutput query="sqlItem" group="item">
	<cfif hbemail NEQ "">
		<cfscript>
			shipLink = "http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#TrackingNumber#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12";
			shipLink = '<a href="#shipLink#">#shipLink#</a>';
			eBayLink = "http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#ebayitem#";
			eBayLink = '<a href="#eBayLink#">#eBayLink#</a>';
			theMessage = _vars.emails.shipped_message;
			theMessage = ReplaceNoCase(theMessage, "{Buyer ID}", hbuserid, "ALL");
			theMessage = ReplaceNoCase(theMessage, "{Title}", title, "ALL");
			theMessage = ReplaceNoCase(theMessage, "{eBay Link}", eBayLink, "ALL");
			theMessage = ReplaceNoCase(theMessage, "{eBay Number}", ebayitem, "ALL");
			theMessage = ReplaceNoCase(theMessage, "{Shipper}", "UPS", "ALL");
			theMessage = ReplaceNoCase(theMessage, "{Tracking Number}", TrackingNumber, "ALL");
			theMessage = ReplaceNoCase(theMessage, "{Shipper Link}", shipLink, "ALL");
		</cfscript>
		<cfmail from="#_vars.mails.from#"
			to="#hbemail#"
			bcc="#_vars.emails.BCC_Item_Shipped#"
			subject="Your item has been shipped! eBay Item #ebayitem# #title#" 
			type="html">#theMessage#</cfmail>
	</cfif>
</cfoutput>
<cfset session.combined = ""><!--- ONCE LABEL GENERATED, CLEAR COMBINED QUEUE --->
