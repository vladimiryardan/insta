<cfoutput>
	


<!--- get dimensions --->
<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
	Select * from ship_dimensions
	order by ship_dimension_name asc
</cfquery>	
	
	
<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
<form method="POST" action="">

<tr><td>
	<table width="100%" border="0" cellpadding="4" cellspacing="1">
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Company or Name:</b></td>
		<td><input type="text" size="35" maxlength="35" name="TO_Company" value="#pageData.TO_Company#" style="font-size: 11px;"></td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Attention:</b></td>
		<td><input type="text" size="40" maxlength="80" name="TO_Attention" value="#pageData.TO_Attention#" style="font-size: 11px;"></td>
	</tr>
		
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Attention Name:</b></td>
		<td><input type="text" size="35" maxlength="35" name="TO_AttentionName" value="#pageData.TO_Attention#" style="font-size: 11px;"></td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Street/Address 1:</b></td>
		<td><input type="text" size="40" maxlength="80" name="TO_Address1" value="" style="font-size: 11px;"></td>
	</tr>
	
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Room/Floor/Address 2:</b></td>
		<td valign="middle"><b>Department/Address 3</b></td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td><input type="text" size="40" maxlength="80" name="TO_Address2" value="" style="font-size: 11px;"></td>
		<td><input type="text" size="40" maxlength="80" name="TO_Address3" value="" style="font-size: 11px;"></td>
	</tr>
	
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Country:</b></td>
		<td valign="middle"><b>Postal/ZIP Code &reg;</b></td>
	</tr>
	
	<tr bgcolor="##FFFFFF">
		<td>
			<select name="TO_Country" size="1">
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
		<td><!-- DEBUG STATE "#pageData.TO_State#" --><span style="color:blue">(#pageData.TO_State#)</span>
			<select name="TO_State" size="1">
			#SelectOptions(pageData.TO_State, statesList)#
			</select>
		</td>
	</tr>
	
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Telephone:</b></td>
		<td valign="middle"><b>E-mail Address:</b></td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td><input type="text" size="40" maxlength="80" name="TO_Telephone" value="" style="font-size: 11px;"></td>
		<td><input type="text" size="40" maxlength="80" name="TO_Email" value="" style="font-size: 11px;"></td>
	</tr>
	
	<tr bgcolor="##F0F1F3"><td colspan="2"><b>Package</b></td></tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>UPS Service:</b></td>
		<td>
			<select name="UPSService" size="1">
			#SelectOptions(pageData.UPSService, upsServices)#
			</select>
		</td>
	</tr>
	
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Weight (pounds):</b></td>
		<td><input type="text" size="5" maxlength="5" name="Weight" value="#pageData.Weight#" style="font-size: 11px;"></td>
	</tr>	
	
		<!---/
			Added dimensions Ends
		/ --->	
	<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Dimensions:</b></td>
			<td>
				<select name="shippingDimensions" id="shippingDimensions">
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
			<td valign="middle"><b>Height (in):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Height" id="Height" value="#pageData.height#" style="font-size: 11px;"></td>
		</tr>	
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Width (in):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Width" id="Width" value="#pageData.Width#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Length (i):</b></td>
			<td><input type="text" size="40" maxlength="80" name="depth" id="depth" value="#pageData.depth#" style="font-size: 11px;"></td>
		</tr>
		<!---/
			Added dimensions Ends
		/ --->
			
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Package Type:</b></td>
		<td>
			<select name="PackageType" size="1">
			#SelectOptions(pageData.PackageType, packageTypes)#
			</select>
		</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td valign="middle"><b>Declared Value:</b></td>
		<td><input type="text" size="10" maxlength="10" name="DeclaredValue" value="#pageData.DeclaredValue#" style="font-size: 11px;"></td>
	</tr>
	
	<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
		<input type="submit" value="Request Label">
		
		<!--- custom item number --->
		<input type="hidden" name="item" value="911.00000.000">
				
		<input type="hidden" name="ShipperNumber" value="#pageData.ShipperNumber#">	
		<input type="hidden" name="internal_itemSKU" value="">
		<input type="hidden" name="internal_itemSKU2" value="">
		<input type="hidden" name="lid" value="">			
		<input type="hidden" name="confirm" value="1">
		<input type="hidden" name="OversizePackage" value="#pageData.OversizePackage#">
				
	</td></tr>
	</form>
	</table>
</td></tr>
</table>


<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
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
