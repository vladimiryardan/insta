
<cfparam name="attributes.itemid">
<cfparam name="attributes.ebayitem">
<cfparam name="attributes.TransactionID">
<cfparam name="attributes.nextdsp" default="admin.ship.awaiting">
<cfset _machine.cflocation = "index.cfm?dsp=#attributes.nextdsp#">
<cfif ISDEFINED("attributes.email_xml")>
	<cfmail 
	from="#_vars.mails.from#" 
	to="#attributes.email_xml#" 
	subject="BEGIN act_complete_sale" type="html">
	<cfdump var="#attributes#">
	</cfmail>
</cfif>

<cfset LogAction("changed payment/shipment status for item #attributes.itemid#... ")>


<!--- check if its fixedprice offebay --->

<cfquery name="chkListingType" datasource="#request.dsn#">
	select offebay from items
	where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
</cfquery>


<cfif chkListingType.offebay eq 2>
	<!--- for fixed price patrick says its always bigbluewholesale2010--->
	<cfquery name="sqlEBAccount" datasource="#request.dsn#">
		SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
			a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
		FROM ebaccounts a
		WHERE a.eBayAccount = 22
	</cfquery>
<cfelse>
	<!--- for auctions --->
	<cfquery name="sqlEBAccount" datasource="#request.dsn#">
	SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
		a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
	FROM auctions u
		INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
	WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
</cfif>




<cfif chkListingType.offebay neq 1><!--- dont do call on amazon --->
		<cfscript>
			_ebay.UserID			= sqlEBAccount.UserID;
			_ebay.UserName			= sqlEBAccount.UserName;
			_ebay.Password			= sqlEBAccount.Password;
			_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
			_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
			_ebay.CertificateName	= sqlEBAccount.CertificateName;
			_ebay.RequestToken		= sqlEBAccount.RequestToken;
		</cfscript>
		<cfset _ebay.CallName ="CompleteSale">

		<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
		<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
			<RequesterCredentials>
				<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
			</RequesterCredentials>
			<ItemID>#attributes.ebayitem#</ItemID>
			<TransactionID>#attributes.TransactionID#</TransactionID>'>


		<cfif isDefined("attributes.paid")>
			<cfif attributes.paid EQ "1">
				<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
			<Paid>true</Paid>'>
			<cfelse>
				<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
			<Paid>false</Paid>'>
			</cfif>
		</cfif>

		<!---
		<cfif isDefined("attributes.uspsID")>
		 <cfset _ebay.XMLRequest = _ebay.XMLRequest & '
		    <Shipment>
		    <Notes> #attributes.uspsID# </Notes>
		    <ShipmentTrackingDetails>
		      <ShipmentTrackingNumber> #attributes.uspsID# </ShipmentTrackingNumber>
		      <ShippingCarrierUsed> USPS </ShippingCarrierUsed>
		    </ShipmentTrackingDetails>
		  </Shipment>'>
		</cfif>
		--->


		<cfif isDefined("attributes.shipped")>
			<cfif attributes.shipped EQ "1">
				<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
			<Shipped>true</Shipped>'>
			<cfelse>
				<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
			<Shipped>false</Shipped>'>
			</cfif>
		</cfif>

		<CFIF isDefined("attributes.uspsID")>
		<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
		  <Shipment>
		    <ShipmentTrackingDetails>
		      <ShipmentTrackingNumber> #attributes.uspsID# </ShipmentTrackingNumber>
		      <ShippingCarrierUsed>USPS</ShippingCarrierUsed>
		    </ShipmentTrackingDetails>
		  </Shipment>'>
		</CFIF>

		<CFIF isDefined("attributes.upsID")>
		<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
		  <Shipment>
		    <ShipmentTrackingDetails>
		      <ShipmentTrackingNumber> #attributes.upsID# </ShipmentTrackingNumber>
		      <ShippingCarrierUsed>UPS</ShippingCarrierUsed>
		    </ShipmentTrackingDetails>
		  </Shipment>'>
		</CFIF>
		
		<CFIF isDefined("attributes.fedexID")>
		<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
		  <Shipment>
		    <ShipmentTrackingDetails>
		      <ShipmentTrackingNumber>#attributes.fedexID#</ShipmentTrackingNumber>
		      <ShippingCarrierUsed>fedEx</ShippingCarrierUsed>
		    </ShipmentTrackingDetails>
		  </Shipment>'>
		</CFIF>
		
		<cfset _ebay.XMLRequest = _ebay.XMLRequest & '
		</#_ebay.CallName#Request>'>

		<cfset _ebay.ThrowOnError = false>
		<cfif ISDEFINED("attributes.email_xml")>
			<cfmail 
			from="#_vars.mails.from#" 
			to="#attributes.email_xml#" 
			subject="API CALL: CompleteSale">#_ebay.XMLRequest#</cfmail></cfif>
		<cfinclude template="../../api/act_call.cfm">

		
		<cfif NOT isDefined("_ebay.xmlResponse")>
			<cfoutput><h1 style="color:red;">ERROR OCCURED: #_ebay.response#</h1></cfoutput>
			<cfset LogAction("Failed to Send tracking to ebay. #attributes.itemid#... ")>
			<cfset _machine.error_in_action = true>
		<cfelseif _ebay.Ack EQ "failure">
			<cfoutput><h1 style="color:red;">API call failed! Anyhow, item updated in local database.</h1></cfoutput>
			<cfset LogAction("API call failed to Send tracking to ebay. #attributes.itemid#... ")>
			<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.Errors)#">
				<cfoutput>
				<h2 style="color:red;">#_ebay.xmlResponse.xmlRoot.Errors[i].SeverityCode.xmlText#: #_ebay.xmlResponse.xmlRoot.Errors[i].ShortMessage.xmlText#</h2>
				#_ebay.xmlResponse.xmlRoot.Errors[i].LongMessage.xmlText#
				</cfoutput>
			</cfloop>
			<cfset _machine.error_in_action = true>
			<cfif isDefined("attributes.fullErrorDetails")><cfdump var="#_ebay#"></cfif>
		<cfelse>
			<cfset LogAction("#attributes.itemid# Success in passing tracking to ebay")>
		</cfif>
		

		
		
		<cfif ISDEFINED("attributes.email_xml")>
			<cfmail from="#_vars.mails.from#" 
			to="#attributes.email_xml#" 
			subject="AFTER CALL" type="html">
			<cfdump var="#_ebay#"></cfmail></cfif>
			
</cfif><!--- ebay only --->


	
	
<!--- change machine location only on amazon --->
<cfif chkListingType.offebay eq 1>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.ship_sold_off">
</cfif>


<!--- UPDATE LOCAL DATABASE --->
<cfif isDefined("attributes.paid")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		<cfif attributes.paid EQ "1">
			SET paid = '1',
				PaidTime = GETDATE()
		<cfelse>
			SET paid = '0',
				PaidTime = NULL
		</cfif>
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfscript>
		if(attributes.paid EQ "1"){
			fChangeStatus(attributes.itemid, 10); // Awaiting Shipment
		}else{
			fChangeStatus(attributes.itemid, 5); // Awaiting Payment
		}
	</cfscript>
</cfif>
<cfif isDefined("attributes.upsID")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET shipped = '1',
			ShippedTime = GETDATE(),
			shipper = 'UPS',
			tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.upsID#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfscript>
		fChangeStatus(attributes.itemid, 11); // Paid and Shipped
		fChangeLocation(attributes.itemid, "P&S");
	</cfscript>
<cfelseif isDefined("attributes.uspsID")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET shipped = '1',
			ShippedTime = GETDATE(),
			shipper = 'USPS',
			tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.uspsID#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfscript>
		fChangeStatus(attributes.itemid, 11); // Paid and Shipped
		fChangeLocation(attributes.itemid, "P&S");
	</cfscript>
<cfelseif isDefined("attributes.fedexID")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET shipped = '1',
			ShippedTime = GETDATE(),
			shipper = 'fedEx',
			tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.fedexID#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfscript>
		fChangeStatus(attributes.itemid, 11); // Paid and Shipped
		fChangeLocation(attributes.itemid, "P&S");
	</cfscript>
<cfelseif isDefined("attributes.shipped")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		<cfif attributes.shipped EQ "1">
			SET shipped = '1',
				ShippedTime = GETDATE()
		<cfelse>
			SET shipped = '0',
				ShippedTime = NULL
		</cfif>
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfscript>
		if(attributes.shipped EQ "1"){
			fChangeStatus(attributes.itemid, 11); // Paid and Shipped
			fChangeLocation(attributes.itemid, "P&S");
		}else{
			fChangeStatus(attributes.itemid, 10); // Awaiting Shipment
		}
	</cfscript>
</cfif>


