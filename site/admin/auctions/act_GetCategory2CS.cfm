<cfparam name="attributes.SiteID">
<cfparam name="attributes.CategoryID">
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT AttributeSystemVersion
	FROM category2cs
	WHERE CategoryID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.CategoryID#">
		AND SiteID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">
</cfquery>
<!--- setting lister.AttributeSystemVersion SHOULD BE UPDATED ONCE PER DAY --->
<cfif (sqlTemp.RecordCount EQ 0) OR (sqlTemp.AttributeSystemVersion NEQ _vars.lister.AttributeSystemVersion)>
	<cfscript>
		attributes.CallName = "GetCategory2CS";
		xmlDoc = xmlNew();
		xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "#attributes.CallName#Request");
		StructInsert(xmlDoc.xmlRoot.xmlAttributes, "xmlns", "urn:ebay:apis:eBLBaseComponents");
		xmlDoc.xmlRoot.RequesterCredentials = xmlElemNew(xmlDoc, "RequesterCredentials");
		xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken = xmlElemNew(xmlDoc, "eBayAuthToken");
		xmlDoc.xmlRoot.RequesterCredentials.eBayAuthToken.xmlText = _ebay.RequestToken;

		xmlDoc.xmlRoot.CategoryID = xmlElemNew(xmlDoc, "CategoryID");
		xmlDoc.xmlRoot.CategoryID.xmlText = attributes.CategoryID;

		xmlDoc.xmlRoot.SiteID = xmlElemNew(xmlDoc, "SiteID");
		xmlDoc.xmlRoot.SiteID.xmlText = attributes.SiteID;

		xmlDoc.xmlRoot.DetailLevel = xmlElemNew(xmlDoc, "DetailLevel");
		xmlDoc.xmlRoot.DetailLevel.xmlText = "ReturnAll";
	</cfscript>

	<cfset _ebay.XMLRequest = toString(xmlDoc)>
	<cfset _ebay.CallName = attributes.CallName>
	<cfset _ebay.ThrowOnError = false>
	<cfset _ebay.SiteID = attributes.SiteID>

	<cfinclude template="../../api/act_call.cfm">
	<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
		<cfset attr = StructNew ()>
		<cfset attr.name = "lister.AttributeSystemVersion">
		<cfset attr.avalue = "#_ebay.xmlResponse.xmlRoot.AttributeSystemVersion.xmlText#">
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
		<cfset swCharacteristicSet = _ebay.xmlResponse.xmlRoot.SiteWideCharacteristicSets.CharacteristicsSet>
		<cfif StructKeyExists(_ebay.xmlResponse.xmlRoot, "MappedCategoryArray")>
			<cfset MappedCategoryArray = _ebay.xmlResponse.xmlRoot.MappedCategoryArray.xmlChildren>
			<cfloop index="i" from="1" to="#ArrayLen(MappedCategoryArray)#">
				<cfquery datasource="#request.dsn#">
					DELETE FROM category2cs
					WHERE CategoryID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#MappedCategoryArray[i].CategoryID.xmlText#">
						AND csAttributeSetID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#MappedCategoryArray[i].CharacteristicsSets.AttributeSetID.xmlText#">
						AND SiteID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">
				</cfquery>
				<cfquery datasource="#request.dsn#">
					INSERT INTO category2cs
					(
						SiteID, CategoryID, AttributeSystemVersion,
						csName, csAttributeSetID, csAttributeSetVersion,
						swName, swAttributeSetID, swAttributeSetVersion
					)
					VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#MappedCategoryArray[i].CategoryID.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.AttributeSystemVersion.xmlText#">,

						<cfqueryparam cfsqltype="cf_sql_varchar" value="#MappedCategoryArray[i].CharacteristicsSets.Name.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#MappedCategoryArray[i].CharacteristicsSets.AttributeSetID.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#MappedCategoryArray[i].CharacteristicsSets.AttributeSetVersion.xmlText#">,

						<cfqueryparam cfsqltype="cf_sql_varchar" value="#swCharacteristicSet.Name.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetID.xmlText#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetVersion.xmlText#">
					)
				</cfquery>
			</cfloop>
		<cfelse><!--- MappedCategoryArray NOT EXISTS, USE SiteWideCharacteristicSets INSTEAD --->
			<cfquery datasource="#request.dsn#">
				DELETE FROM category2cs
				WHERE CategoryID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.CategoryID#">
					AND csAttributeSetID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetID.xmlText#">
					AND SiteID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">
			</cfquery>
			<cfquery datasource="#request.dsn#">
				INSERT INTO category2cs
				(
					SiteID, CategoryID, AttributeSystemVersion,
					csName, csAttributeSetID, csAttributeSetVersion,
					swName, swAttributeSetID, swAttributeSetVersion
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.SiteID#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.CategoryID#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#_ebay.xmlResponse.xmlRoot.AttributeSystemVersion.xmlText#">,

					<cfqueryparam cfsqltype="cf_sql_varchar" value="#swCharacteristicSet.Name.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetID.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetVersion.xmlText#">,

					<cfqueryparam cfsqltype="cf_sql_varchar" value="#swCharacteristicSet.Name.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetID.xmlText#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#swCharacteristicSet.AttributeSetVersion.xmlText#">
				)
			</cfquery>
		</cfif>
	</cfif>
</cfif>
