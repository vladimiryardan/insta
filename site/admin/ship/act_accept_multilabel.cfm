<cfset XMLRequest = '
<?xml version="1.0"?>
<AccessRequest xml:lang="en-US">
	<AccessLicenseNumber>#_vars.ups.AccessLicenseNumber#</AccessLicenseNumber>
	<UserId>#_vars.ups.UserId#</UserId>
	<Password>#_vars.ups.Password#</Password>
</AccessRequest>
<?xml version="1.0"?>
<ShipmentAcceptRequest>
	<Request>
		<TransactionReference>
			<CustomerContext>#attributes.CustomerContext#</CustomerContext>
			<XpciVersion>1.0001</XpciVersion>
		</TransactionReference>
		<RequestAction>ShipAccept</RequestAction>
		<RequestOption>01</RequestOption>
	</Request>
	<ShipmentDigest>#attributes.ShipmentDigest#</ShipmentDigest>
</ShipmentAcceptRequest>
'>

<cfset upsShipUrl = "https://temp-onlinetools.ups.com/ups.app/xml/ShipAccept">
<!---https://www.ups.com/ups.app/xml/ShipAccept--->
<cfhttp url="#upsShipUrl#" method="POST" charset="utf-8" port="443"
>
	<cfhttpparam name="request" value="#XMLRequest#" type="XML"> 
</cfhttp>

<cfset theXML = XMLParse(ToString(cfhttp.Filecontent))>

<cfif theXML.xmlRoot.Response.ResponseStatusDescription.xmlText EQ "failure">
	<cfoutput><h1 style="color:red;">Failure: #theXML.xmlRoot.Response.Error.ErrorDescription.xmlText#</h1></cfoutput>
<cfelse>
	<cfset drawForm = "make">
</cfif>
