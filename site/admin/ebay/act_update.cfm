<cfif NOT isAllowed("Full_Access")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.edit" default="">
<cfif ListFindNoCase("Header,Description,SellWithUs,Payment,Shipping,AboutUs", attributes.edit)>
	<cfquery datasource="#request.dsn#">
		UPDATE ebaccounts
		SET Template#attributes.edit# = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.avalue#">
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.eBayAccount#">
	</cfquery>
<cfelse>
	<cfquery datasource="#request.dsn#">
		UPDATE ebaccounts
		SET DeveloperName	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.DeveloperName#">,
			ApplicationName	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ApplicationName#">,
			CertificateName	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.CertificateName#">,
			UserID			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.UserID#">,
			UserName		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.UserName#">,
			Password		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.Password#">,
			RequestToken	= <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Trim(attributes.RequestToken)#">,
			watermark		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.watermark#">,
			location		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.location#">,
			paypal			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.paypal#">
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.eBayAccount#">
	</cfquery>
</cfif>
<cfset _machine.cflocation = "index.cfm?dsp=admin.ebay.list">
