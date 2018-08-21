<cfset buyerPaid = 0>
<cfoutput query="sqlItem" group="item">
	<cfset buyerPaid = buyerPaid + val(AmountPaid) - val(price)>
</cfoutput>
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
	
	<cfif isdefined("theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText")>
		<cfset totalSum = Val(theXML.xmlRoot.NegotiatedRates.NetSummaryCharges.GrandTotal.MonetaryValue.xmlText)>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"width="32%"><b>Negotiated Rate</b></td>
			<td >#totalSum#</td>
		</tr>
	<cfelse>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" width="32%"><b>Negotiated Rate</b></td>
			<td>UNDEFINED</td>
		</tr>					
	</cfif>	
		
	<form action="" method="post" name="frm">
	<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
		<input type="hidden" name="accept" value="1">
		<input type="hidden" name="ShipmentDigest" value="#theXML.xmlRoot.ShipmentDigest.xmlText#">
		<input type="hidden" name="CustomerContext" value="#theXML.xmlRoot.Response.TransactionReference.CustomerContext.xmlText#">
		<input type="hidden" name="ShipCharge" value="#totalSum#">
		<input type="submit" value="Generate Label">
	</td></tr>
	

	</form>
	</table>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--//
if(confirm("Total charge for package: #DollarFormat(totalSum)#, Buyer paid #DollarFormat(buyerPaid)#, Continue?"))
	document.frm.submit();
//-->
</script>
</cfoutput>
