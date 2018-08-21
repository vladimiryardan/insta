<!--- BUY POSTAGE FOR ENDICIA --->
<cfparam name="attributes.amount" default="0">
<cfset XMLRequest ='
<RecreditRequest>
	<RequesterID>#_vars.endicia.RequesterID#</RequesterID>
	<RequestID>string</RequestID>
	<CertifiedIntermediary>
		<AccountID>#_vars.endicia.AccountID#</AccountID>
		<PassPhrase>#_vars.endicia.PassPhrase#</PassPhrase>
	</CertifiedIntermediary>
	<RecreditAmount>#attributes.amount#</RecreditAmount>
</RecreditRequest>
'>

<cfset XMLRequest = Replace(XMLRequest, "
", "", "all")>
<cfset XMLRequest = Replace(XMLRequest, "	", "", "all")>
<cfdump var="#XMLRequest#">
<!---<cfhttp url="https://labelserver.endicia.com/LabelService/EwsLabelService.asmx/BuyPostageXML" port="443" method="post" charset="utf-8">--->

<cfif Left(_vars.endicia.url, 5) EQ "https">
	<cfset port = "443">
<cfelse>
	<cfset port = "80">
</cfif>

<cfhttp url="#_vars.endicia.url#/BuyPostageXML" port="#port#" method="post" charset="utf-8">	
	<cfhttpparam name="Host" value="LabelServer.Endicia.com" type="HEADER">
	<cfhttpparam name="Content-Type" value="application/x-www-form-urlencoded" type="HEADER">
	<cfhttpparam name="Content-Length" value="#Len(XMLRequest)#" type="HEADER">
	<cfhttpparam name="recreditRequestXML" value="#XMLRequest#" type="formfield">
</cfhttp>

<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.usps.buy_postage">
<cfif cfhttp.Mimetype EQ "text/xml">
	<cfset xmlResponse = XMLParse(cfhttp.FileContent)>
	<cfif xmlResponse.xmlRoot.Status.xmlText NEQ "0">
		<cfoutput>
		<h3 style="color:red; margin-bottom:0px; padding-bottom:0px;">Error Occured. Code #xmlResponse.xmlRoot.Status.xmlText#</h3>
		<pre style="color:red;">#xmlResponse.xmlRoot.ErrorMessage.xmlText#</pre>
		</cfoutput>
		<cfset _machine.error_in_action = TRUE>
	<cfelse>
		<cfset _machine.cflocation = _machine.cflocation & "&PostageBalance=" & xmlResponse.xmlRoot.CertifiedIntermediary.PostageBalance.xmlText>
		<cfset _machine.cflocation = _machine.cflocation & "&AscendingBalance=" & xmlResponse.xmlRoot.CertifiedIntermediary.AscendingBalance.xmlText>
		<cfset _machine.cflocation = _machine.cflocation & "&AccountStatus=" & xmlResponse.xmlRoot.CertifiedIntermediary.AccountStatus.xmlText>
		<cfset LogAction("bought #attributes.amount# of postage. PB/AB/AS #xmlResponse.xmlRoot.CertifiedIntermediary.PostageBalance.xmlText#/#xmlResponse.xmlRoot.CertifiedIntermediary.AscendingBalance.xmlText#/#xmlResponse.xmlRoot.CertifiedIntermediary.AccountStatus.xmlText#")>
		<cfset attr = StructNew ()>
		<cfset attr.name = "endicia.PostageBalance">
		<cfset attr.avalue = "#xmlResponse.xmlRoot.CertifiedIntermediary.PostageBalance.xmlText#">
		<cfmodule template="../../act_updatesetting.cfm" attributecollection="#attr#">
	</cfif>
<cfelse>
	<cfdump var="#cfhttp#">
	<cfset _machine.error_in_action = TRUE>
</cfif>
<!--- / BUY POSTAGE FOR ENDICIA --->
