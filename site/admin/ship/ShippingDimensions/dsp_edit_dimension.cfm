<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.ship_dimensionid" default="0">
<cfparam name="attributes.ship_dimension_name" default="">
<cfparam name="attributes.ship_dimension_length" default="">
<cfparam name="attributes.ship_dimension_width" default="">
<cfparam name="attributes.ship_dimension_heigth" default="">
<cfparam name="attributes.ProcessMessage" default="">




<cfif isdefined("attributes.submitted")>
	
	<cfquery datasource="#request.dsn#" result="insertResult">
		update ship_dimensions							
			set 
			ship_dimension_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimension_name#">,
			ship_dimension_length = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimension_length#">,
			ship_dimension_width = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimension_width#">,
			ship_dimension_heigth = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimension_heigth#">
		
		where ship_dimensionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimensionid#"> 
	</cfquery>	
		
	<cfset attributes.ProcessMessage = "Dimension Updated" >
</cfif>	

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT
	ship_dimensions.ship_dimensionid,
	ship_dimensions.ship_dimension_name,
	ship_dimensions.ship_dimension_length,
	ship_dimensions.ship_dimension_width,
	ship_dimensions.ship_dimension_heigth
	
	FROM [ship_dimensions]
	
	where ship_dimensionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_dimensionid#">
</cfquery>



	

	
	
		
	
<cfoutput>

<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>New Dimension:</strong></font><br>
	
	
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<span class="floatRight"><a href="index.cfm?dsp=admin.ship.shippingDimensions.dimensionList">Dimension List</a></span>
	<br><br>
	
	<tr bgcolor="##D4CCBF">
		<td align="left" colspan="2">
		<cfif attributes.ProcessMessage neq "">
			<span class="greenbg">#attributes.ProcessMessage#</span>
		<cfelse>
			<b>Enter Shipping Dimension</b>
		</cfif>
		</td>
	</tr>

	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
	
	
	
		<form action="index.cfm?dsp=#attributes.dsp#" method="post" >
			<table>
				<!--- name --->
				<tr class="trAltOdd">
					<td class="floatRight">Name: </td>
					<td><input type="text" name="ship_dimension_name" required="true" value="#sqlTemp.ship_dimension_name#"></td>
				</tr>
				
				<!--- length --->
				<tr class="trAltEven">
					<td class="floatRight">Length: </td>
					<td><input type="text" name="ship_dimension_length" required="true" value="#sqlTemp.ship_dimension_length#"></td>
				</tr>

				<!--- Width --->
				<tr class="trAltOdd">
					<td class="floatRight">Width: </td>
					<td><input type="text"  name="ship_dimension_width" required="true" value="#sqlTemp.ship_dimension_width#"></td>
				</tr>

				<!--- heigth --->
				<tr class="trAltEven">
					<td class="floatRight">Heigth: </td>
					<td><input type="text" name="ship_dimension_heigth"  required="true" value="#sqlTemp.ship_dimension_heigth#"></td>
				</tr>
																
				<tr>
					<td></td>
					<td>
						<input type="submit" value="Save">
						<input type="hidden" name="submitted" value="save">
						<input type="hidden" name="ship_dimensionid" value="#attributes.ship_dimensionid#">	
					</td>
				</tr>
			</table>
			
			
		</form>	
			
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
	