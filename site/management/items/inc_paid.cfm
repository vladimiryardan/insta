<cfif sqlItem.paid EQ "">
	<cfoutput>N/A</cfoutput>
<cfelse>
	<cfoutput>
	#YesNoFormat(sqlItem.paid)#
	&nbsp;&nbsp;&nbsp;
	<a href="index.cfm?act=admin.api.complete_sale&paid=<cfif sqlItem.paid>0<cfelse>1</cfif>&itemid=#sqlItem.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=0&nextdsp=#URLEncodedFormat('management.items.edit&item=#sqlItem.item#')#" onClick="return confirm('Are you sure to change item status on eBay?');">Mark as <cfif sqlItem.paid>NOT </cfif>Paid</a>
	&nbsp;<br><br>
	<form action="index.cfm?act=admin.api.revise_status" method="post" onSubmit="return confirm('Are you sure to change item status on eBay?')">
	<input type="hidden" name="itemid" value="#attributes.item#">
	<input type="hidden" name="ebayitem" value="#sqlItem.ebayitem#">
	<input type="hidden" name="TransactionID" value="<cfif isDefined("sqlTransaction.TransactionID") AND (sqlTransaction.TransactionID NEQ "")>#sqlTransaction.TransactionID#<cfelse>0</cfif>">
	<input type="submit" value="Mark" style="width:50px;">
	<select name="StatusIs">
		<option value="1"<cfif sqlItem.paid> selected</cfif>>not paid</option>
		<option value="2"<cfif NOT sqlItem.paid> selected</cfif>>paid</option>
	</select>
	with:
	<select name="PaymentMethodUsed">
		<option value="MOCC">Money Order/Cashiers Check</option>
		<option value="CashInPerson">Cash-in-person</option>
		<option value="CCAccepted">Credit Card</option>
		<option value="PersonalCheck">Personal check</option>
		<option value="VisaMC">Visa/Mastercard</option>
		<option value="CashOnPickup">Payment on Delivery</option>
		<option value="AmEx">American Express</option>
		<option value="PaymentSeeDescription">Payment See Description</option>
	</select>
	</form>
	</cfoutput>
</cfif>
