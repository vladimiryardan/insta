<cfsetting requesttimeout="360">
<cfparam name="attributes.SiteID" default="0">
<cfoutput><h3>GetCategories for CategorySiteID = #attributes.SiteID#</h3></cfoutput>
<cfscript>
	_ebay.CallName = "GetCategories";
	_ebay.ThrowOnError = false;
	_ebay.XMLRequest = '
<?xml version="1.0" encoding="utf-8"?>
<GetCategoriesRequest xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>
	<CategorySiteID>#attributes.SiteID#</CategorySiteID>
</GetCategoriesRequest>';
</cfscript>
<cfinclude template="../../api/act_call.cfm">

<cfif _ebay.Ack EQ "failure">
	<cfoutput><li style="color:red;">List of categories NOT updated due to API call failure.</li>#err_detail#</cfoutput>
<cfelseif NOT isDefined("attributes.ForceRead") AND (_ebay.xmlResponse.GetCategoriesResponse.CategoryVersion.xmlText EQ _vars.ebayCatalog["Site_#attributes.SiteID#_Version"])>
	<cfoutput><li>List of categories not require update. Current Version is #_ebay.xmlResponse.GetCategoriesResponse.CategoryVersion.xmlText#</li></cfoutput>
<cfelse>
	<cfoutput><li>Updating list of categories. Current Version is #_ebay.xmlResponse.GetCategoriesResponse.CategoryVersion.xmlText#. Local Version is #_vars.ebayCatalog["Site_#attributes.SiteID#_Version"]#</li></cfoutput>
	<cfscript>
		_ebay.XMLRequest = '
	<?xml version="1.0" encoding="utf-8"?>
	<GetCategoriesRequest xmlns="urn:ebay:apis:eBLBaseComponents">
		<RequesterCredentials>
			<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
		</RequesterCredentials>
		<CategorySiteID>#attributes.SiteID#</CategorySiteID>
		<DetailLevel>ReturnAll</DetailLevel>
		<LevelLimit>7</LevelLimit>
	</GetCategoriesRequest>';
	</cfscript>	
	<cfinclude template="../../api/act_call.cfm">
	
	
	<cfif _ebay.Ack EQ "failure">
		<cfoutput><li style="color:red;">List of categories NOT updated due to API call failure.</li></cfoutput>
	<cfelse>
		
		<cfquery datasource="#request.dsn#">
			DELETE FROM ebcategories
			WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.SiteID#">
		</cfquery>
		
		<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.GetCategoriesResponse.CategoryArray.xmlChildren)#">
			<cfset Category = _ebay.xmlResponse.GetCategoriesResponse.CategoryArray.xmlChildren[i]>
			<!--- vlad changes 20110510
			CategoryArray.Category.Expired: only returned if true. Not returned if false or if not set by eBay.
			CategoryArray.Category.Virtual: Will not be returned if false. 
			CategoryArray.Category.LeafCategory: If true, indicates that the category indicated in CategoryID is a leaf category, Will not be returned if false. 
			--->			
			<cfif not isdefined("Category.Expired.xmlText") AND not isdefined("Category.Virtual.xmlText")>
				<cfif isdefined("Category.LeafCategory.xmlText")>
					<cfset suffix = "">
				<cfelse>
					<cfset suffix = " -->">
				</cfif>
				<cftry>
                	<cfquery datasource="#request.dsn#">
						INSERT INTO ebcategories
						(
							CategoryID,
							CategoryLevel,
							CategoryName,
							CategoryParentID,
							SiteID
						)
						VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#Category.CategoryID.xmlText#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#Category.CategoryLevel.xmlText#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Category.CategoryName.xmlText##suffix#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#Category.CategoryParentID.xmlText#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.SiteID#">
						)
					</cfquery>                
                <cfcatch type="Any" >
                	<cfdump var="[#Category.CategoryID.xmlText#]">]<br><br>
                	<cfdump var="[#Category.CategoryLevel.xmlText#]">]<br><br>
                	<cfdump var="[#Category.CategoryName.xmlText##suffix#]"><br><br>
                	<cfdump var="[#Category.CategoryParentID.xmlText#]"><br><br>
                	<cfdump var="[#attributes.SiteID#]"><br><br>
  
                	<cfabort>
                </cfcatch>
                </cftry>

			</cfif>
			<cfflush interval="10">
			<cfif isdefined("url.debug")>
				#Category.CategoryName.xmlText##suffix#<br>
			</cfif>
			
		</cfloop>
		
		<cfset attr = StructNew ()>
		<cfset attr.name = "ebayCatalog.Site_#attributes.SiteID#_Version">
		<cfset attr.avalue = _ebay.xmlResponse.GetCategoriesResponse.CategoryVersion.xmlText>
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
		<cfset attr = StructNew ()>
		<cfset attr.name = "ebayCatalog.Site_#attributes.SiteID#_RetrievedOn">
		<cfset attr.avalue = "#Now()#">
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
		<cfoutput>
			<li>List of categories updated. #ArrayLen(_ebay.xmlResponse.GetCategoriesResponse.CategoryArray.xmlChildren)# categories affected</li>
			<li>Script ended Successfully</li>
		</cfoutput>
		
	</cfif>
</cfif>
