<!--- TODO: CALL THIS FILE ONLY ONCE PER DAY FROM SCHEDULED TASK --->
<cfscript>
	attributes.FileName = "syi_attributes.xsl";
	attributes.CallName = "GetAttributesXSL";
	xmlDoc = xmlNew();
	xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "#attributes.CallName#Request");
	StructInsert(xmlDoc.xmlRoot.xmlAttributes, "xmlns", "urn:ebay:apis:eBLBaseComponents");
	xmlDoc.xmlRoot.RequesterCredentials = xmlElemNew(xmlDoc, "RequesterCredentials");
	xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken = xmlElemNew(xmlDoc, "eBayAuthToken");
	xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken.xmlText = _ebay.RequestToken;
</cfscript>
<cfset _ebay.XMLRequest = toString(xmlDoc)>
<cfset _ebay.CallName = attributes.CallName>
<cfset _ebay.ThrowOnError = false>

<cfinclude template="../../api/act_call.cfm">

<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
	<cfoutput><h2>Check attributes XSL file</h2><p>Local version: #_vars.lister.XSLFileVersion#<br> Remote version: #_ebay.xmlResponse.xmlRoot.XSLFile.FileVersion.xmlText#</p></cfoutput>
	<cfif _vars.lister.XSLFileVersion NEQ _ebay.xmlResponse.xmlRoot.XSLFile.FileVersion.xmlText>
		<cfscript>
	
			xmlDoc.xmlRoot.FileName = xmlElemNew(xmlDoc, "FileName");
			xmlDoc.xmlRoot.FileName.xmlText = attributes.FileName;

			xmlDoc.xmlRoot.FileVersion = xmlElemNew(xmlDoc, "FileVersion");
			xmlDoc.xmlRoot.FileVersion.xmlText = _ebay.xmlResponse.xmlRoot.XSLFile.FileVersion.xmlText;
	
			xmlDoc.xmlRoot.DetailLevel = xmlElemNew(xmlDoc, "DetailLevel");
			xmlDoc.xmlRoot.DetailLevel.xmlText = "ReturnAll";

			StructDelete(_ebay, "xmlResponse");
		</cfscript>
	
		<cfset _ebay.XMLRequest = toString(xmlDoc)>
		<cfset _ebay.CallName = attributes.CallName>
		<cfset _ebay.ThrowOnError = false>
	
		<cfinclude template="../../api/act_call.cfm">
		<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
			<cfset attr = StructNew ()>
			<cfset attr.name = "lister.XSLFileVersion">
			<cfset attr.avalue = "#_ebay.xmlResponse.xmlRoot.XSLFile.FileVersion.xmlText#">
			<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
			<cffile action="write" file="#request.basepath#site\admin\auctions\#attributes.FileName#" output="#toBinary(_ebay.xmlResponse.xmlRoot.XSLFile.FileContent.xmlText)#">
			<cfoutput><p>#attributes.FileName# updated successfully!</p></cfoutput>
		</cfif>
	</cfif>
</cfif>
