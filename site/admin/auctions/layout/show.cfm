<cfinclude template="../get_item.cfm">
<cfif sqlAuction.RecordCount EQ 1>
	<cfif isDefined("attributes.layout")>
		<cfset sqlAuction.layout = attributes.layout>
	</cfif>
	<cfscript>
		PaymentMethods = "";
		for(i=1; i LTE ListLen(sqlAuction.PaymentMethods); i=i+1){
			if(i GT 1){
				if(i EQ ListLen(sqlAuction.PaymentMethods)){
					PaymentMethods = PaymentMethods & " or ";
				}else{
					PaymentMethods = PaymentMethods & ", ";
				}
			}
			switch(ListGetAt(sqlAuction.PaymentMethods, i)){
				case "MOCC": m = "Money Order/Cashiers Checks"; break;
				case "VisaMC": m = "Visa/Mastercard"; break;
				case "AmEx": m = "American Express"; break;
				case "Discover": m = "Discover"; break;
				case "PersonalCheck": m = "Personal Check"; break;
				default: m = ListGetAt(sqlAuction.PaymentMethods, i); break;
			}
			PaymentMethods = PaymentMethods & m;
		}
		sqlAuction.PaymentMethods = PaymentMethods;
	</cfscript>
	<cfinclude template="#sqlAuction.layout#/_header.cfm">
	<cfinclude template="common/template.cfm">
	<cfinclude template="#sqlAuction.layout#/_footer.cfm">
<cfelse>
	<cfoutput><h1 style="color:red;">LISTING NOT FOUND</h1></cfoutput>
</cfif>
