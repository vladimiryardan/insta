
<!--- this is used in different fedex call. careful --->
<cfset fedexSandbox = "#trim(_vars.fedex.sandbox.Flag)#" >


<cfif fedexSandbox is "true">
	
	<!---Required for All Web Services--->
	<cfset DeveloperKey  = "i0rGzvR2cgLxYAJ6" >
	
	<!---Required for FedEx Web Services for Intra Country Shipping in US and Global--->
	<cfset AccountNumber = "510087240" >
	<cfset MeterNumber = "119023288" >
	<cfset Password = "2TrQHIZGtP0W9UCjFzjABysbE" >
	


<cfelse>
	<!--- PRODUCTION CONFIG --->
	<cfset DeveloperKey  = "#_vars.fedex.key#" >
	
	<!---Required for FedEx Web Services for Intra Country Shipping in US and Global--->
	<cfset AccountNumber = "#trim(_vars.fedex.accountNumber)#" >
	<cfset MeterNumber = "#trim(_vars.fedex.MeterNumber)#" >
	<cfset Password = "#trim(_vars.fedex.password)#" >

	 
</cfif>




