<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>


<!---delete handler --->
<cfif isdefined("attributes.submitted")>
	
	<cfif isdefined("attributes.ship_dimensionid")>
		<!---delete selected --->	
		<cfloop index="i" list="#attributes.ship_dimensionid#"> 
			<cfquery datasource="#request.dsn#">
				delete from ship_dimensions
				where ship_dimensionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">				
			</cfquery>
		</cfloop>
	</cfif>
</cfif>


<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT
	ship_dimensions.ship_dimensionid,
	ship_dimensions.ship_dimension_name,
	ship_dimensions.ship_dimension_length,
	ship_dimensions.ship_dimension_width,
	ship_dimensions.ship_dimension_heigth
	
	FROM [ship_dimensions]
	
	order by ship_dimension_name asc
</cfquery>


<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Shipping Dimensions:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>


	<form action="index.cfm?dsp=#attributes.dsp#" method="post">
		
	
	<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Name</td>
			<td class="ColHead" width="100">Length</td>
			<td class="ColHead" width="100">Width</td>
			<td class="ColHead" width="100">Height</td>
			<td class="ColHead" width="50"></td>
			<td class="ColHead" width="50"></td>
		</tr>
</cfoutput>




<!--- DISPLAY DIMENSIONS --->
<cfoutput query="sqlTemp">
	
		<tr <cfif CurrentRow mod 2 IS 0> bgcolor="##ECE9F3"<cfelse>bgcolor="##FFFFFF"</cfif> >
			
			<td><a href="index.cfm?dsp=admin.ship.shippingDimensions.edit_dimension&ship_dimensionid=#sqlTemp.ship_dimensionid#">#sqlTemp.ship_dimension_name#</a></td>
			<td align="center">#sqlTemp.ship_dimension_length#</td>
			<td align="center">#sqlTemp.ship_dimension_width#</td>
			<td align="center">#sqlTemp.ship_dimension_heigth#</td>
			<td align="center"><a href="index.cfm?dsp=admin.ship.shippingDimensions.edit_dimension&ship_dimensionid=#sqlTemp.ship_dimensionid#">Edit</a></td>
			<td align="center"><a href="##"><input type="checkbox" name="ship_dimensionid" value="#sqlTemp.ship_dimensionid#"</a></td>
						
		</tr>		
</cfoutput>



<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td colspan="5" class="ColHead">
				<a href="index.cfm?dsp=admin.ship.ShippingDimensions.new_dimension&mode=Add">Create New Dimension</a>
			</td>
			
			<td colspan="1" class="ColHead">
				<input type="submit" name="submit" value="Delete Selected" >
				<input type="hidden" name="submitted" value="1">
			</td>	
					
		</tr>
		</table>
	</td></tr>
	</table>
</form>	
	
	
	
</td></tr>
</table>
</cfoutput>
