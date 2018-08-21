<!---<cfset attributes.TotalCharges = Val(theXML.xmlRoot.ShipmentCharges.TotalCharges.MonetaryValue.xmlText)>
<cfoutput>
<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
<tr><td>
	<table width="100%" border="0" cellpadding="4" cellspacing="1">
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>General</b></td></tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Shipment Identification Number</b></td>
		<td>#theXML.xmlRoot.ShipmentIdentificationNumber.xmlText#</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>ItemID</b></td>
		<td>#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Billing Weight</b></td>
		<td>#theXML.xmlRoot.BillingWeight.Weight.xmlText# #theXML.xmlRoot.BillingWeight.UnitOfMeasurement.Code.xmlText#</td>
	</tr>
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>Shipment Charges</b></td></tr>
	<cfloop index="i" from="1" to="#ArrayLen(theXML.xmlRoot.ShipmentCharges.xmlChildren)#">
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>#theXML.xmlRoot.ShipmentCharges.xmlChildren[i].xmlName#</b></td>
		<td>#theXML.xmlRoot.ShipmentCharges.xmlChildren[i].MonetaryValue.xmlText#</td>
	</tr>
	</cfloop>
	<form action="" method="post" name="frm">
	<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
		<input type="hidden" name="accept" value="1">
		<input type="hidden" name="ShipmentDigest" value="#theXML.xmlRoot.ShipmentDigest.xmlText#">
		<input type="hidden" name="CustomerContext" value="#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#">
		<!--- for database --->
		<input type="hidden" name="TO_CompanyName" value="#HTMLEditFormat(attributes.TO_CompanyName)#">
		<input type="hidden" name="TO_AttentionName" value="#HTMLEditFormat(attributes.TO_AttentionName)#">
		<input type="hidden" name="TO_AddressLine1" value="#HTMLEditFormat(attributes.TO_AddressLine1)#">
		<input type="hidden" name="TO_AddressLine2" value="#HTMLEditFormat(attributes.TO_AddressLine2)#">
		<input type="hidden" name="TO_AddressLine3" value="#HTMLEditFormat(attributes.TO_AddressLine3)#">
		<input type="hidden" name="TO_CountryCode" value="#attributes.TO_CountryCode#">
		<input type="hidden" name="TO_PostalCode" value="#attributes.TO_PostalCode#">
		<input type="hidden" name="TO_City" value="#attributes.TO_City#">
		<input type="hidden" name="TO_StateProvinceCode" value="#attributes.TO_StateProvinceCode#">
		<input type="hidden" name="TO_PhoneNumber" value="#attributes.TO_PhoneNumber#">
		<input type="hidden" name="TO_FaxNumber" value="#attributes.TO_FaxNumber#">
		<input type="hidden" name="DeclaredValue" value="#attributes.DeclaredValue#">
		<input type="hidden" name="OversizePackage" value="#attributes.OversizePackage#">
		<input type="hidden" name="PackageType" value="#attributes.PackageType#">
		<input type="hidden" name="TotalCharges" value="#attributes.TotalCharges#">
		<input type="hidden" name="UPSService" value="#attributes.UPSService#">
		<input type="hidden" name="Weight" value="#attributes.Weight#">
		<input type="hidden" name="packing_and_materials" value="#attributes.packing_and_materials#">
		<!--- submit --->
		<input type="submit" value="Generate Label">
	</td></tr>
	</form>
	</table>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--//
if(confirm("Total charge for package: #DollarFormat(attributes.TotalCharges)#, Continue?"))
	document.frm.submit();
//-->
</script>
</cfoutput>
--->


<cfoutput>
<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
<tr><td>
	<table width="100%" border="0" cellpadding="4" cellspacing="1">
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>General</b></td></tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Shipment Identification Number</b></td>
		<td>#theXML.xmlRoot.ShipmentIdentificationNumber.xmlText#</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>ItemID</b></td>
		<td>#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Billing Weight</b></td>
		<td>#theXML.xmlRoot.BillingWeight.Weight.xmlText# #theXML.xmlRoot.BillingWeight.UnitOfMeasurement.Code.xmlText#</td>
	</tr>
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>Shipment Charges</b></td></tr>
	<cfset totalSum = 1000000><!--- to make it noticeable if TotalCharges not found in ShipmentCharges --->
	<cfloop index="i" from="1" to="#ArrayLen(theXML.xmlRoot.ShipmentCharges.xmlChildren)#">
	<cfif theXML.xmlRoot.ShipmentCharges.xmlChildren[i].xmlName EQ "TotalCharges">
		<cfset totalSum = Val(theXML.xmlRoot.ShipmentCharges.xmlChildren[i].MonetaryValue.xmlText)>
	</cfif>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>#theXML.xmlRoot.ShipmentCharges.xmlChildren[i].xmlName#</b></td>
		<td>#theXML.xmlRoot.ShipmentCharges.xmlChildren[i].MonetaryValue.xmlText#</td>
	</tr>
	</cfloop>
	
	<!--- catch the negotiated rates if available --->
	<cfif isdefined("theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText")>
		<cfset totalSum = Val(theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Negotiated Rate</b></td>
			<td>#totalSum#</td>
		</tr>		
	</cfif>
	

	
	<form action="" method="post" name="frm">
	<input type="hidden" name="item" value="#attributes.item#">
	<input type="hidden" name="accept" value="1">
	<input type="hidden" name="ShipmentDigest" value="#theXML.xmlRoot.ShipmentDigest.xmlText#">
	<input type="hidden" name="CustomerContext" value="#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#">
	<input type="hidden" name="ShipCharge" value="#totalSum#">
	<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
		<input type="submit" value="Generate Label">
	</td></tr>
	
	
		<!--- for database --->
		<input type="hidden" name="TO_Company" value="#HTMLEditFormat(attributes.TO_Company)#">
		<input type="hidden" name="TO_Attention" value="#HTMLEditFormat(attributes.TO_Attention)#">
		<input type="hidden" name="TO_AddressLine1" value="#HTMLEditFormat(attributes.TO_Address1)#">
		<input type="hidden" name="TO_AddressLine2" value="#HTMLEditFormat(attributes.TO_Address2)#">
		<input type="hidden" name="TO_AddressLine3" value="#HTMLEditFormat(attributes.TO_Address3)#">
		<input type="hidden" name="TO_Country" value="#attributes.TO_Country#">
		<input type="hidden" name="TO_ZIPCode" value="#attributes.TO_ZIPCode#">
		<input type="hidden" name="TO_City" value="#attributes.TO_City#">
		<input type="hidden" name="TO_State" value="#attributes.TO_State#">
		<input type="hidden" name="TO_Telephone" value="#attributes.TO_Telephone#">
		<input type="hidden" name="TO_FaxNumber" value="">
		<input type="hidden" name="DeclaredValue" value="#attributes.DeclaredValue#">
		<input type="hidden" name="OversizePackage" value="#attributes.OversizePackage#">
		<input type="hidden" name="PackageType" value="#attributes.PackageType#">
		<input type="hidden" name="TotalCharges" value="#totalSum#">
		<input type="hidden" name="UPSService" value="#attributes.UPSService#">
		<input type="hidden" name="Weight" value="#attributes.Weight#">
		<input type="hidden" name="packing_and_materials" value="0">
				
	</form>
	</table>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--//
if(confirm("Total charge for package: #DollarFormat(totalSum)# Continue?"))
	document.frm.submit();
//-->

</script>
</cfoutput>
