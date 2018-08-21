<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfinclude template="config.cfm" >

<cfquery name="get_item" datasource="#request.dsn#">
	SELECT items.weight, ebitems.price, items.byrStateOrProvince, items.byrPostalCode
	
	FROM items
	LEFT JOIN ebitems ON ebitems.ebayitem = items.ebayitem
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	
</cfquery>


<cfset fedexShipper = new FedexShipper(
	key = "#DeveloperKey#",
	password = "#Password#",
	accountNo = "#AccountNumber#",
	meterNo = "#MeterNumber#",
	sandbox = true
) />

<cfset result = fedexShipper.getRatesByOneRate(
	shipperZip = "#_vars.upsFrom.ZIPCode#",
	shipperState = "#_vars.upsFrom.State#",
	shipperCountry = "US",
	shipToZip = "#get_item.byrPostalCode#",
	shipToState = "#get_item.byrStateOrProvince#",
	shipToCountry = "US",
	pkgWeight = "#get_item.weight#",
	pkgValue = "#get_item.price#",
	shipToResidential = true
) />

<!---<cfdump var="#result#">
--->
<!---
result.rates
result.response
--->

<cfif result.success is "yes">	
	<cfdump var="#result#">
	
<cfoutput>
	
	

		
	<!---	<cfloop from="1" to="#arraylen(result.rates)#" index="c">
			<cfdump var="#result.rates[c].discount#"><br>	
			
			<cfloop from="1" to="#arraylen(result.rates[c].SURCHARGES)#" index="s">
				<cfdump var="#result.rates[c].SURCHARGES[s].type#">
			</cfloop>	
			<cfdump var="#result.rates[c].TOTALBASECHARGE#">
			<cfdump var="#result.rates[c].TOTALNETCHARGE#">
			<cfdump var="#result.rates[c].TOTALNETCHARGE#">
			<cfdump var="#result.rates[c].TOTALREBATES#">
			<cfdump var="#result.rates[c].TOTALSURCHARGES#">
			<cfdump var="#result.rates[c].TOTALTAXES#">
			<cfdump var="#result.rates[c].TYPE#">
		
		</cfloop>--->
		
	
		<!--- loop again --->

		
		<!---	
		Discount: result.rates[c].discount.xmltext<br>
		Type: ?
		<br><br>-------------------------------	--->
	
	
	
</cfoutput>
	
<cfelse>
	<!--- failed call --->
	<cfdump var="#result#">
	
</cfif>

<cfdump var="#Application#">

<cfdump var="#Server#">
<cfdump var="#Client#">
<cfdump var="#Client#">