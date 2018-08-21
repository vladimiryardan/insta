<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>


<cfinclude template="config.cfm" >

<cfquery name="get_item" datasource="#request.dsn#">
	SELECT items.weight, ebitems.price, items.byrStateOrProvince, items.byrPostalCode, items.weight_oz
	
	FROM items
	LEFT JOIN ebitems ON ebitems.ebayitem = items.ebayitem
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	
</cfquery>

<cfset fedexShipper = new FedexShipper(
	key = "#DeveloperKey#",
	password = "#Password#",
	accountNo = "#AccountNumber#",
	meterNo = "#MeterNumber#",
	sandbox = "#fedexSandbox#"
) />

	<!--- default value for dimension and weight --->
	
		<cfparam name="form.dWidth" default="1" >
		<cfparam name="form.dHeight" default="1" >
		<cfparam name="form.dLength" default="1" >
		
		<cfparam name="form.dformWeight" default="#get_item.weight#">
		<cfparam name="form.dformWeightoz" default="#get_item.weight_oz#">
		

		<!---<cfparam name="form.dServiceType" default="FEDEX_GROUND">--->

	<!--- oz to lbs gets the value from method post--->
	<cfset finalWeight = form.dformWeight + (form.dformWeightoz / 16) >
<cfif not isnumeric(finalWeight) or finalWeight lt 1  >
	<cfset finalWeight = 1 >
</cfif>	
	

		

		<cfset result = fedexShipper.getRatesByOneRate(
			shipperZip = "#_vars.upsFrom.ZIPCode#",
			shipperState = "#_vars.upsFrom.State#",
			shipperCountry = "US",
			shipToZip = "#get_item.byrPostalCode#",
			shipToState = "#parseState(get_item.byrStateOrProvince)#",
			shipToCountry = "US",
			pkgWeight = "#finalWeight#",
			pkgValue = "#get_item.price#",
			shipToResidential = "true",
			fedexServiceType="GROUND_HOME_DELIVERY",
			pkgLength="#form.dLength#",
			pkgWidth="#form.dWidth#",
			pkgHeight="#form.dHeight#"
			
		) />





<cfif result.success is "yes">		
				<cfoutput >
					<table width="100%" border="0" cellpadding="4" cellspacing="1">
					<tr>
						<td width="32%">
							<table width="100%" border="0" cellpadding="4" cellspacing="1" bgcolor="##aaaaaa" >
							<tr bgcolor="##dca4f9"><td colspan="2"  align="left"><b>Fedex Preview</b></td></tr>
						
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Billing Weight</b></td>
								<td>
									#finalWeight# LBS ( #finalWeight * 16# ounces)
								</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total</b></td>
								<td>#result.rates[1].total#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Surcharges</b></td>
								<td>#result.rates[1].surcharges[1].amount#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Discount</b></td>
								<td>#result.rates[1].discount#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total Net Charge</b></td>
								<td>#result.rates[1].totalnetcharge#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total Base Charge</b></td>
								<td>#result.rates[1].totalbasecharge#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total Net Freight</b></td>
								<td>#result.rates[1].totalnetfreight#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total Rebates</b></td>
								<td>#result.rates[1].totalrebates#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total Surcharges</b></td>
								<td>#result.rates[1].totalsurcharges#</td>
							</tr>
							
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Total taxes</b></td>
								<td>#result.rates[1].totaltaxes#</td>
							</tr>
							<tr bgcolor="##FFFFFF">
								<td valign="middle" width="37%"><b>Type</b></td>
								<td>#result.rates[1].type#</td>
							</tr>
						
							
							

							<!--- add some spacing --->
							<div style="padding-top:10px;background-color:##fff"></div>

						</td>
					</tr>
				</table>	
					
				</cfoutput>
					

	<cfelse>
	
     	<table width="100%" border="0" cellpadding="4" cellspacing="1" >
     	      
     		<tr bgcolor="##D4CCBF">
     			<td colspan="2" align="left">
     				<b>
     					Fedex Preview Error
     				</b>
     			</td>
     		</tr>
     	</table>
     	
     	<!---dump the error --->
		<cfdump var="#result#">
	
	</cfif>




	<cfoutput>
	
	
	<div style="float:right">
		<form method="post" id="previewForm" 
		<!---onsubmit="return recalculateShipping(this)"---> 
		action="<cfoutput>http<cfif cgi.HTTPS EQ 'on'>s</cfif>://#cgi.server_name##cgi.path_info#<cfif cgi.query_string NEQ ''>?#cgi.query_string#</cfif></cfoutput>">
			<input type="button" id="recalc" name="button" value="Preview Shipping cost based on inputs" >
				<input type="hidden" id="dformMailClass" name="dformMailClass" value="">
				<input type="hidden" id="dformWeight" name="dformWeight" value="">
				<input type="hidden" id="dformWeightOZ" name="dformWeightOZ" value="" >
				<input type="hidden" id="dUPSService" name="dUPSService" value="" >
				<input type="hidden" id="dInsuredMail" name="dInsuredMail" value="" >
				
				<input type="hidden" id="xWidth" name="dWidth" value="0" >
				<input type="hidden" id="xHeight" name="dHeight" value="0" >
				<input type="hidden" id="xLength" name="dLength" value="0" >	
					
				<input type="hidden" id="mode" name="mode" value="previewShippingPrice" >
		</form>
	</div>
	
	
	<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
	<script type="text/javascript">
		
		$(function(){
			
			$('##recalc').click(function(){
				var form = recalculateShipping(this)
				
				$('##previewForm').submit();
			})
				function recalculateShipping(theform){
					 
					 var weight = 0;
					 //USPS
					 //dWeight
					 //WeightOz
					 //MailClass.val()
						if($('##dWeight').length){
							$('##dformWeight').val($('##dWeight').val());
						}
						if($('##WeightOz').length){
							$('##dformWeightOZ').val($('##WeightOz').val());
							
						}
						if($('##MailClass').length){
							$('##dformMailClass').val($('##MailClass').val());
						}
				
					 //UPS
					 //UPSService
					 //Weight
					 	if($('##Weight').length){
							$('##dformWeight').val($('##Weight').val());
						}
						if($('##UPSService').length){
							$('##dUPSService').val($('##UPSService').val());
						}
						if($('##InsuredMail').length){
							$('##dInsuredMail').val($('##InsuredMail').val());
						}
				
						if($('##dWidth').length){
							$('##xWidth').val( $('##dWidth').val() );
						}	
						if($('##cHeight').length){
							$('##xHeight').val( $('##cHeight').val() );
						}	
						if($('##ddepth').length){
							$('##xLength').val( $('##ddepth').val() );
						}						
				
						return true;
				}
					/*	
					to retain the form values we will use the form values and set it via javascript when the page finish loading.
				*/
				
				/* fedex hold the preview values */
				<cfif isdefined("form.dWidth")>
					$('##dWidth').val(#form.dWidth#);
				</cfif>
				
				<cfif isdefined("form.dHeight") >
					$('##cHeight').val(#form.dHeight#);
				</cfif>
				
				<cfif isdefined("form.dLength")>
					$('##ddepth').val(#form.dLength#);
				</cfif>		
						
				<cfif isdefined("form.dformWeight") >
					$('##dWeight').val(#form.dformWeight#);
				</cfif>
				
				<cfif isdefined("form.dformWeightOZ")>
					$('##WeightOz').val(#form.dformWeightOZ#);
				</cfif>				
						
				
		})
	
	</script>
	
</cfoutput>