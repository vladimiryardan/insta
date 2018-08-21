<cfset TrackingNumber = theXML.xmlRoot.ShipmentResults.PackageResults.TrackingNumber.xmlText>

	<cfquery datasource="#request.dsn#" name="sqlInsert">
		INSERT INTO ups
		(
			aid, TO_CompanyName, TO_AttentionName, TO_AddressLine1, TO_AddressLine2, TO_AddressLine3,
			TO_CountryCode, TO_PostalCode, TO_City, TO_StateProvinceCode, TO_PhoneNumber, TO_FaxNumber,
			DeclaredValue, OversizePackage, PackageType, TotalCharges, TrackingNumber, UPSService, Weight,
			packing_and_materials, ship_handling_cost, ship_cost_per_pound
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.ACCOUNTID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_Company#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_Attention#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_AddressLine1#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_AddressLine2#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_AddressLine3#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_Country#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_ZIPCode#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_City#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_State#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_Telephone#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.TO_FaxNumber#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#attributes.DeclaredValue#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.OversizePackage#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PackageType#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#attributes.TotalCharges#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#TrackingNumber#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.UPSService#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Weight#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="0">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#_vars.pricing.ship_handling_cost#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#_vars.pricing.ship_cost_per_pound#">
		)
		
		SELECT @@IDENTITY AS uid
	</cfquery>
	<cfset binaryData = toBinary(theXML.xmlRoot.ShipmentResults.PackageResults.LabelImage.GraphicImage.xmlText)>
	<cffile action="write" addnewline="no" file="#request.basepath#ship_labels\ups\#sqlInsert.uid#.gif" output="#binaryData#">
<cftry>
	<cfcatch type="any">
		<cfset binaryData = toBinary(theXML.xmlRoot.ShipmentResults.PackageResults.LabelImage.GraphicImage.xmlText)>
		<cfset sqlInsert = StructNew()>
		<cfset sqlInsert.uid = GetTickCount()>
		<cffile action="write" addnewline="no" file="#request.basepath#ship_labels\errors\#sqlInsert.uid#.gif" output="#binaryData#">
		<cffile action="write" addnewline="no" file="#request.basepath#ship_labels\ups\#sqlInsert.uid#.gif" output="#binaryData#">
		<cfset LogAction("error generating UPS label #TrackingNumber#")>
	</cfcatch>
</cftry>

<cfset LogAction("generated UPS label #TrackingNumber#")>

<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
LabelWin = window.open("index.cfm?dsp=admin.pos.ups_print&uid=#sqlInsert.uid#", "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
LabelWin.opener = self;
LabelWin.focus();
window.location = "index.cfm?dsp=admin.pos.ups_list";
//-->
</script>
<br>If the page does not redirect you then please <a href="index.cfm?dsp=admin.pos.ups_list">CLICK HERE</a>. Thank you.<br>
</cfoutput>
