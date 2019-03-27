<cftransaction>
	<cfquery datasource="#request.dsn#">
		INSERT INTO ebaccounts
		(
			DeveloperName, ApplicationName, CertificateName,
			UserID, UserName, Password, RequestToken,
			TemplateHeader, TemplateDescription, TemplateSellWithUs,
			TemplatePayment, TemplateShipping, TemplateAboutUs
		)
		SELECT
			'ENTER NEW VALUE HERE' AS DeveloperName,
			'ENTER NEW VALUE HERE' AS ApplicationName,
			'ENTER NEW VALUE HERE' AS CertificateName,
			'ENTER NEW VALUE HERE' AS UserID,
			'ENTER NEW VALUE HERE' AS UserName,
			'' AS Password,
			'ENTER NEW VALUE HERE' AS RequestToken,
			TemplateHeader, TemplateDescription, TemplateSellWithUs,
			TemplatePayment, TemplateShipping, TemplateAboutUs
		FROM ebaccounts
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.eBayAccount#">
	</cfquery>
	<cfquery datasource="#request.dsn#" name="sqlNew">
		SELECT MAX(eBayAccount) AS eBayAccount
		FROM ebaccounts
	</cfquery>
</cftransaction>
<cfset _machine.cflocation = "index.cfm?dsp=admin.ebay.edit&eBayAccount=#sqlNew.eBayAccount#">
