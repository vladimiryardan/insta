
<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">
<cfif sqlItem.RecordCount EQ 0>
	<cfoutput><div>DATA FOR ITEM #attributes.item# NOT FOUND, OR TRANSACTION IS NOT COMPLETE</div></cfoutput>
<cfelse>
	<cfif isNumeric(sqlItem.ebayitem)>
		<cfset itmItemID = sqlItem.ebayitem>
	<cfelse>
		<cfset itmItemID = 0>
	</cfif>
	<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
		SELECT *
		FROM ebtransactions
		WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#itmItemID#">
		ORDER BY tid DESC
	</cfquery>
	<!--- override the sqlTransaction query if its a fixed price multi qty fixed item  --->
	<cfif sqlitem.offebay eq 2>
		<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
			SELECT ebayFixedPricePaid as AmountPaid FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
	</cfif>

<cfinclude template="inc_shippingCostUPSPreview.cfm" ><!--- ups calculation include first if its a ups page --->
<cfinclude template="usps/inc_shippingCostUSPSPreview.cfm" >
<!---<cfinclude template="inc_shippingCostSurepost.cfm" >---><!---surepost --->
<cfinclude template="fedex/inc_fedexPreview.cfm" >



					

<!--- get dimensions --->
<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
	Select * from ship_dimensions
	order by ship_dimension_name asc
</cfquery>

	<cfoutput>
		


		
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<form method="POST" action="">
	<input type="hidden" name="item" value="#sqlItem.item#">
	<input type="hidden" name="internal_itemSKU" value="#sqlItem.internal_itemSKU#">
	<input type="hidden" name="internal_itemSKU2" value="#sqlItem.internal_itemSKU2#">
	<input type="hidden" name="lid" value="#sqlItem.lid#">
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
		
		<tr bgcolor="##D4CCBF"><td colspan="2"><b>General</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Item Number:</b></td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlItem.item#">#sqlItem.item#</a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>eBay Number:</b></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#" target="_blank">#sqlItem.ebayitem#</a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Description:</b></td>
			<td>#sqlItem.title#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Final Price:</b></td>
			<td>#DollarFormat(sqlItem.price)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Amount Paid:</b></td>
			<td><cfif isNumeric(sqlTransaction.AmountPaid)>#DollarFormat(sqlTransaction.AmountPaid)#<cfelse>N/A</cfif></td>
		</tr>
		<cfif sqlItem.shipnote NEQ "">
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Ship Note:</b></td>
				<td style="background-color:yellow;">#sqlItem.shipnote#</td>
			</tr>
		</cfif>
<!---
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Created On:</b></td>
			<td>#DateFormat(sqlItem.dcreated)# #TimeFormat(sqlItem.dcreated)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Shipper:</b></td>
			<td><input type="text" size="40" maxlength="80" name="ShipperNumber" value="#pageData.ShipperNumber#" style="font-size: 11px;"></td>
		</tr>
---><input type="hidden" name="ShipperNumber" value="#pageData.ShipperNumber#">
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><label for="ResidentialAddress"><b>Residential Address:</b></label></td>
			<td><input type="checkbox" name="ResidentialAddress" id="ResidentialAddress" value="1" checked="checked"></td>
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
				<select name="TO_Country" size="1" style="width:277px;">
				#SelectOptions(pageData.TO_Country, countriesList)#
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
				<select name="TO_State" size="1" style="width:250px;">
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
				<select name="UPSService"  id="UPSService" size="1" style="width:277px;">
				#SelectOptions(pageData.UPSService, upsServices)#
				</select>
			</td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Weight:</b></td>
			<td>
				<input type="text" size="2" maxlength="3" name="Weight" id="dWeight" value="#pageData.weight#" style="font-size: 11px; width:60px;" required="true">
				<b>pounds</b>
				and
				<input type="text" size="5" maxlength="5" name="WeightOz" id="WeightOz" value="#pageData.WeightOz#" style="font-size: 11px; width:60px;" required="true">
				<b>ounces</b>
			</td>
		</tr>
	
	
	
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Dimensions:</b></td>
			<td>
				<select name="shippingDimensions" id="shippingDimensions" style="width:277px;">
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
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Width (WD):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Width" id="Width" value="#pageData.Width#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Height (hgt):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Height" id="Height" value="#pageData.height#" style="font-size: 11px;"></td>
		</tr>	
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Length (LEN):</b></td>
			<td><input type="text" size="40" maxlength="80" name="depth" id="depth" value="#pageData.depth#" style="font-size: 11px;"></td>
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
			<input type="submit" class="shippingButton" style="color:white; background-color:##feb300;" name="submit" value="Request UPS Label">
			<br><hr>
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:blue;" value="Go to USPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.usps.request_label&item=#attributes.item#';">
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:##d227f4;" value="Go to FEDEX Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.fedex.FedexForm&item=#attributes.item#';">
		</td></tr>

		<input type="hidden" name="OversizePackage" value="#pageData.OversizePackage#">
			
		</form>
		</table>
	</td>
	</tr>
	</table>
	</cfoutput>
</cfif>
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

<cfoutput>




<script type="text/javascript">

	
			// JavaScript using jQuery
		$(function(){
		    $('##shippingDimensions').change(function(){
		       var selected = $(this).find('option:selected');
		       var width = selected.data('width'); 
		       var length = selected.data('length');
		       var heigth = selected.data('height');
		       
		       $('##Height').val(heigth);
		       $('##Width').val(width);
		       $('##depth').val(length);
		       
		      
		      
		    });
		});
		
</script>
</cfoutput>