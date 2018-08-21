<cfparam name="attributes.SiteID">
<cfparam name="attributes.AttributeSetID">
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT AttributeSystemVersion, AttributeData
	FROM attributescs
	WHERE AttributeSetID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.AttributeSetID#">
		AND SiteID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">
</cfquery>
<!--- setting lister.AttributeSystemVersion SHOULD BE UPDATED ONCE PER DAY --->
<cfset AttributeDataExists = FALSE>
<cfif (sqlTemp.RecordCount GT 0) AND (sqlTemp.AttributeSystemVersion EQ _vars.lister.AttributeSystemVersion)>
	<cfif Right(sqlTemp.AttributeData, 4) EQ ".xml">
		<cfif FileExists(sqlTemp.AttributeData)>
			<!---
			<cffile action="read" file="#sqlTemp.AttributeData#" variable="variables.AttributeData">
			--->
			<cfset xmlIS = XMLParse("#sqlTemp.AttributeData#")>
			<cfset AttributeDataExists = TRUE>
		</cfif>
	<cfelse>
		<cfset xmlIS = XMLParse(sqlTemp.AttributeData)>
		<cfset AttributeDataExists = TRUE>
	</cfif>
</cfif>
<cfif NOT AttributeDataExists>
	<cfscript>
		attributes.CallName = "GetAttributesCS";
		xmlDoc = xmlNew();
		xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "#attributes.CallName#Request");
		StructInsert(xmlDoc.xmlRoot.xmlAttributes, "xmlns", "urn:ebay:apis:eBLBaseComponents");
		xmlDoc.xmlRoot.RequesterCredentials = xmlElemNew(xmlDoc, "RequesterCredentials");
		xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken = xmlElemNew(xmlDoc, "eBayAuthToken");
		xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken.xmlText = _ebay.RequestToken;

		xmlDoc.xmlRoot.AttributeSetID = xmlElemNew(xmlDoc, "AttributeSetID");
		xmlDoc.xmlRoot.AttributeSetID.xmlText = attributes.AttributeSetID;

		xmlDoc.xmlRoot.SiteID = xmlElemNew(xmlDoc, "SiteID");
		xmlDoc.xmlRoot.SiteID.xmlText = attributes.SiteID;

		xmlDoc.xmlRoot.DetailLevel = xmlElemNew(xmlDoc, "DetailLevel");
		xmlDoc.xmlRoot.DetailLevel.xmlText = "ReturnAll";
	</cfscript>

	<cfset _ebay.XMLRequest = toString(xmlDoc)>
	<cfset _ebay.CallName = attributes.CallName>
	<cfset _ebay.ThrowOnError = false>
	<cfset _ebay.SiteID = attributes.SiteID>

	<cfquery name="sqlEBAccount" datasource="#request.dsn#">
		SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
			a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
		FROM auctions u
			INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
		WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfscript>
		_ebay.UserID			= sqlEBAccount.UserID;
		_ebay.UserName			= sqlEBAccount.UserName;
		_ebay.Password			= sqlEBAccount.Password;
		_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
		_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
		_ebay.CertificateName	= sqlEBAccount.CertificateName;
		_ebay.RequestToken		= sqlEBAccount.RequestToken;
	</cfscript>
	<cfinclude template="../../api/act_call.cfm">
	<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
		<cfset attr = StructNew ()>
		<cfset attr.name = "lister.AttributeSystemVersion">
		<cfset attr.avalue = "#_ebay.xmlResponse.xmlRoot.AttributeSystemVersion.xmlText#">
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">

		<cfset variables.AttributeData = Replace(_ebay.xmlResponse.xmlRoot.AttributeData.xmlText, "&lt;", "<", "ALL")>
		<cfset variables.AttributeData = Replace(variables.AttributeData, "&gt;", ">", "ALL")>
		<!---cfset variables.AttributeData = Replace(variables.AttributeData, "&amp;", "&", "ALL")--->
		<cfset variables.AttributeData = Replace(variables.AttributeData, "&quot;", '"', "ALL")>
		<cfset variables.AttributeData = Replace(variables.AttributeData, "&apos;", "'", "ALL")>

		<cfquery datasource="#request.dsn#">
			DELETE FROM attributescs
			WHERE AttributeSetID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.AttributeSetID#">
				AND SiteID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">
		</cfquery>

		<cfif Len(variables.AttributeData) GT 65535>
			<cfset sqlStringAttributeData = "#request.basepath#site\admin\auctions\GetAttributesCS\#attributes.SiteID#_#attributes.AttributeSetID#.xml">
			<cffile action="write" file="#sqlStringAttributeData#" output="#AttributeData#" charset="utf-8" nameconflict="overwrite">
			<cfset xmlIS = XMLParse("#sqlStringAttributeData#")>
		<cfelse>
			<cfset sqlStringAttributeData = variables.AttributeData>
			<cfset xmlIS = XMLParse(variables.AttributeData)>
		</cfif>
		
		
		<cfquery datasource="#request.dsn#">
			INSERT INTO attributescs
			(SiteID, AttributeSetID, AttributeSystemVersion, AttributeData)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">,
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.AttributeSetID#">,
				<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.AttributeSystemVersion.xmlText#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#sqlStringAttributeData#">
			)
		</cfquery>
	<cfelse>
		<cfif isDefined("_ebay.XMLResponse.xmlRoot.Errors.LongMessage.xmlText")>
			<cfoutput><h1 style="color:red;">#_ebay.XMLResponse.xmlRoot.Errors.LongMessage.xmlText#</h1></cfoutput>
		<cfelse>
			<cfdump var="#_ebay#">
		</cfif>
		<cfabort>
	</cfif>
</cfif>
