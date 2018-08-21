<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
pageData
<cfparam name="session.combined">
<cfparam name="attributes.Width" default="#pageData.Width#">
<cfparam name="attributes.height" default="#pageData.height#">
<cfparam name="attributes.depth" default="#pageData.depth#">

<cfif sqlItem.RecordCount EQ 0>
	<cfoutput><div>DATA FOR ANY OF #session.combined# ITEMS FOUND, OR TRANSACTIONS ARE NOT COMPLETE</div></cfoutput>
<cfelse>


	<cfoutput>
	<style type="text/css">
		##comlist{background-color:##AAAAAA;}
		##comlist th{background-color:##F0F1F3; font-weight:bold; text-align:center;}
		##comlist td{background-color:white; width:10%; text-align:center;}
		##comlist th a, ##comlist th a:visited{color:red;}
		##comlist th a:hover{color:green;}
	</style>
	


	<cfinclude template="inc_shippingCostUPSPreviewMulti.cfm" >
	<cfinclude template="usps/inc_shippingCostUSPSPreviewMulti.cfm" >
	<cfinclude template="fedex/inc_fedexPreviewMulti.cfm" >
	
	<!--- get dimensions --->
	<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
	Select * from ship_dimensions
	order by ship_dimension_name asc
	</cfquery>
	
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<form method="POST" action="">
	<input type="hidden" name="confirm" value="1">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
			
        	<!--- catch PO box in ups --->
        	<cfif lcase(pageData.TO_Address1).startsWith("po") or lcase(pageData.TO_Address1).startsWith("p.o") 
        	      or lcase(pageData.TO_Address1) contains "p.o box">
        		<tr>
        			<td colspan="2" align="center">
        				<div style="color:white;background-color:##E81747;padding:10px;font-weight:bold">
        					ALERT! The Address is possibly a PO box. UPS does not ship to PO box.
        				</div>
        			</td>
        		</tr>
        	</cfif>
        
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>General</b></td></tr>
		<tr bgcolor="##FFFFFF"><td colspan="2">
			<table cellpadding="3" cellspacing="1" id="comlist">
			<tr>
				<th colspan="2">Item Owner</td>
				<th>Item Number</td>
				<th>eBay Number</td>
				<th>Created On</td>
				<th>Weight</th>
				<th>Value</th>
				<th>Bidder</th>
			</tr>
			</cfoutput>
			<cfoutput query="sqlItem" group="item">
			<tr>
				<td><a href="mailto:#sqlItem.email#?subject=Instant Auctions: Item #item#"><img src="#request.images_path#emailblue.gif" align="middle" border=0></a></td>
				<td><a href="index.cfm?dsp=account.edit&id=#aid#">#first# #last#</a></td>
				<td><a href="index.cfm?dsp=management.items.edit&item=#item#">#item#</a></td>
				<td align="center"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#ebayitem#" target="_blank">#ebayitem#</a></td>
				<td align="center">#DateFormat(dcreated)# #TimeFormat(dcreated)#</td>
				<td align="center">#weight#</td>
				<td align="right">#DollarFormat(price)#</td>
				<td>#hbuserid#</td>
			</tr>
			</cfoutput>
			
			<cfoutput>
			</table>
		</td></tr>
	
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Shipper:</b></td>
			<td><input type="text" size="40" maxlength="80" name="ShipperNumber" value="#pageData.ShipperNumber#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><label for="ResidentialAddress"><b>Residential Address:</b></label></td>
			<td><input type="checkbox" name="ResidentialAddress" id="ResidentialAddress" value="1"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Company or Name:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Company" value="#pageData.TO_Company#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Attention:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Attention" value="#pageData.TO_Attention#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Street/Address 1:</b></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Address1" value="#pageData.TO_Address1#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Room/Floor/Address 2:</b></td>
			<td valign="middle"><b>Department/Address 3</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_Address2" value="#pageData.TO_Address2#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Address3" value="#pageData.TO_Address3#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Country:</b></td>
			<td valign="middle"><b>Postal/ZIP Code &reg;</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td>
				<select name="TO_Country" size="1" style="width:278px;">
			<cftry>
				#SelectOptions(pageData.TO_Country, countriesList)#
			<cfcatch type="Any">
				UNDEFINED
				#cfcatch.message#<br>
			</cfcatch>
	    	</cftry>
				</select>
			</td>
			<td><input type="text" size="40" maxlength="80" name="TO_ZIPCode" value="#pageData.TO_ZIPCode#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>City:</b></td>
			<td valign="middle"><b>State/Prov</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_City" value="#pageData.TO_City#" style="font-size: 11px;"></td>
			<td><!-- DEBUG STATE "#pageData.TO_State#" --><span style="color:blue">[#trim(parseState(pageData.TO_State))#](#pageData.TO_State#)</span>
				<select name="TO_State" size="1" style="width:223px;">
				#SelectOptions(parseState(pageData.TO_State), statesList)#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Telephone:</b></td>
			<td valign="middle"><b>E-mail Address:</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_Telephone" value="#pageData.TO_Telephone#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Email" value="#pageData.TO_Email#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Package</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>UPS Service:</b></td>
			<td>
				<select name="UPSService" size="1" style="width:277px;">
				#SelectOptions(pageData.UPSService, upsServices)#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Weight (pounds):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Weight" id="dWeight" value="#pageData.Weight#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Width (WD):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Width" id="dWidth" value="#pageData.width#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Height (hgt):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Height" id="cHeight" value="#pageData.height#" style="font-size: 11px;"></td>
		</tr>	
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Length (LEN):</b></td>
			<td><input type="text" size="40" maxlength="80" name="depth" id="ddepth" value="#pageData.depth#" style="font-size: 11px;"></td>
		</tr>
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Package Type:</b></td>
			<td>
				<select name="PackageType" size="1" style="width:277px;">
				#SelectOptions(pageData.PackageType, packageTypes)#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Declared Value:</b></td>
			<td><input type="text" size="40" maxlength="80" name="DeclaredValue" value="#pageData.DeclaredValue#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Dimensions:</b></td>
			<td>
				<select name="shippingDimensions" id="shippingDimensions" style="width:278px;">
					<option value="" selected="selected" >--Select--</option>
					<cfloop query="get_ShipDimensions">
						<option 
							value="#get_ShipDimensions.ship_dimensionid#"
							data-width="#get_ShipDimensions.ship_dimension_width#"
							data-length="#get_ShipDimensions.ship_dimension_length#"
							data-height="#get_ShipDimensions.ship_dimension_heigth#">	
							#get_ShipDimensions.ship_dimension_name#						
						</option>
					</cfloop>
				</select>
				<span class="floatRight"><a href="index.cfm?dsp=admin.ship.shippingDimensions.dimensionList">Dimension List</a></span>
			</td>
		</tr>	
		
		<!---<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Oversize Package:</b></td>
			<td>
				<select name="OversizePackage" size="1">
				#SelectOptions(pageData.OversizePackage, "0,Normal;1,Oversize 1")#<!--- ;2,Oversize 2;3,Oversize 3 --->
				</select>
			</td>
		</tr>--->
		
		
		<cfset bgcolorUPS = "">
		<cfset bgcolorUSPS = "">
		<cfset bgcolorFedex = "">
		

		<cfif isdefined("totalSum") and isdefined("uspsPriceDisplay")>
			<cfif totalSum and uspsPriceDisplay>
				<cfset bgcolorUPS = "red">
				<cfset bgcolorUSPS = "green">
			<cfelse>
				<cfset bgcolorUPS = "green">
				<cfset bgcolorUSPS = "red">
			</cfif>
		</cfif>
		<tr bgcolor="##FFFFFF">
			<td colspan="3" height="50px" background-color="gray">
				
				<cfset upsRatePreview = 0>
				<cfset uspsRatePreview = 0>
				<cfset fedexRatePreview = 0>
				<cfset shippingRatesArray = ArrayNew(1)>
				
				<cfif isdefined("totalSum")>
					<cfset upsRatePreview = totalSum>
					<cfset ArrayAppend(shippingRatesArray, "#upsRatePreview#")>
				</cfif>
			
				
				<cfif isdefined("uspsPriceDisplay")>
					<cfset uspsRatePreview = uspsPriceDisplay>
					 <cfset ArrayAppend(shippingRatesArray, "#uspsRatePreview#")> 
				</cfif>
			

				<cfif structKeyExists(result,'rates')>
					<cfset fedexRatePreview = result.rates[1].totalnetcharge>	
					<cfset ArrayAppend(shippingRatesArray, "#fedexRatePreview#")> 
				</cfif>
				
				<cfset ArraySort(shippingRatesArray, "numeric", "asc") >
			
				<cfparam name="totalSum" default="0" >
				<cfparam name="USPSPRICEDISPLAY" default="0" >
				<cfscript>
					shipStruct = structnew();
					shipStruct.fedex = {price = fedexRatePreview, department = "fedex"};
					shipStruct.ups = {price = totalSum, department = "ups"};
					shipStruct.usps = {price = uspsPriceDisplay, department="usps"};
					shippingSorted = structSort(shipStruct, "numeric", "asc", "price");
				</cfscript>

				<cfloop from="1" to="#arrayLen(shippingSorted)#" index="x">
						<cfif x eq 1>
							<cfset color = "green" >
						</cfif>
						
						<cfif x eq 2>
							<cfset color = "##feb300" >
						</cfif>
						
						<cfif x eq 3>
							<cfset color = "red" >
						</cfif>		
						
			
						<cfif shipStruct[shippingSorted[x]].department is "ups">
							<div style="color:##FEB300;" class="shippingRate">
							UPS#dollarformat(shipStruct[shippingSorted[x]].price)#
							</div>
							
						</cfif>
			
						
						<cfif shipStruct[shippingSorted[x]].department is "usps">
						
							<div style="color:##0000FF;" class="shippingRate">
								USPS #dollarformat(uspsPriceDisplay)#
							</div>
							
						</cfif>
						
						<cfif shipStruct[shippingSorted[x]].department is "fedex">
							
							<div style="color:##d227f4;" class="shippingRate">
							FEDEX #dollarformat(fedexRatePreview)#
							</div>	
											
						</cfif>
										
				</cfloop>	

										

			</td>
		</tr>		
		
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
			<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
				<input type="submit" class="shippingButton" style="color:white; background-color:##feb300;" value="Request UPS Label" onClick="document.location = 'index.cfm?dsp=admin.ship.confirm_multilabel&item=#attributes.item#';">
			<br><hr>
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:blue;" value="Go to USPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.usps.request_multilabel&item=#attributes.item#';">
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:##d227f4;" value="Go to FEDEX Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.fedex.FedexMulti&item=#attributes.item#';">
		</td></tr>
		
		</td></tr>
	
		</form>
		</table>
	</td></tr>
	

	</table>
	<cfparam name="attributes.maximize" default="false">
	<cfif attributes.maximize>
<cfoutput>
		
	<script language="javascript" type="text/javascript">
	<!--
		top.window.moveTo(0,0);
		if(document.all){
			top.window.resizeTo(screen.availWidth,screen.availHeight);
		}else if(document.layers || document.getElementById){
			if((top.window.outerHeight < screen.availHeight) || (top.window.outerWidth < screen.availWidth)){
				top.window.outerHeight = screen.availHeight;
				top.window.outerWidth = screen.availWidth;
			}
		}
	//-->

	</script>
	</cfoutput>
</cfif>


	<script type="text/javascript">
	var mytext = document.getElementById("dWeight");
	mytext.focus();
	
			// JavaScript using jQuery
		$(function(){
		    $('##shippingDimensions').change(function(){
		       var selected = $(this).find('option:selected');
		       var width = selected.data('width'); 
		       var length = selected.data('length');
		       var heigth = selected.data('height');
		       
		       $('##dHeight').val(heigth);
		       $('##dWidth').val(width);
		       $('##ddepth').val(length);

		    });
		});
		
</script>
	
	

	</cfoutput>
	
	
</cfif>
