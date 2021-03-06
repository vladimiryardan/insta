<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.ship_dimensionid" default="0">
<cfparam name="attributes.ship_dimension_name" default="">
<cfparam name="attributes.ship_dimension_length" default="">
<cfparam name="attributes.ship_dimension_width" default="">
<cfparam name="attributes.ship_dimension_heigth" default="">
<cfparam name="attributes.ProcessMessage" default="">
<cfparam name="attributes.mode" default="Add">



<!---<cfset newID = insertResult.generated_Key> MYSQL --->
<!---<cfset newID = insertResult.identitycol> MSSQL--->



<cfif isdefined("attributes.submitted")>
	
	<cfif attributes.mode is "add">
		<cftry>
        	<cfquery datasource="#request.dsn#" result="insertResult">
				insert into ship_dimensions
				(				
					ship_dimension_name,
					ship_dimension_length,
					ship_dimension_width,
					ship_dimension_heigth
				)
				values
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_dimension_name#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_dimension_length#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_dimension_width#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_dimension_heigth#">			
				)
			</cfquery>
			<cfset attributes.ship_dimensionid = insertResult.identitycol>    
			<cfset attributes.ProcessMessage = "Dimension Inserted" >    
        <cfcatch type="Any" >
        	<cfset attributes.ProcessMessage = "Please enter a number in Width, Length, Height">
        </cfcatch>
        </cftry>

		
		
		
	</cfif>
	

</cfif>
	
	
	
	
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
					<td><input type="text" name="ship_dimension_name" required="true" value=""></td>
				</tr>
				
				<!--- length --->
				<tr class="trAltEven">
					<td class="floatRight">Length: </td>
					<td><input type="text" name="ship_dimension_length" required="true" value=""></td>
				</tr>

				<!--- Width --->
				<tr class="trAltOdd">
					<td class="floatRight">Width: </td>
					<td><input type="text"  name="ship_dimension_width" required="true" value=""></td>
				</tr>

				<!--- heigth --->
				<tr class="trAltEven">
					<td class="floatRight">Heigth: </td>
					<td><input type="text" name="ship_dimension_heigth"  required="true" value=""></td>
				</tr>
																
				<tr>
					<td></td>
					<td>
						<br><br>
						<input type="submit" value="Save">
						<input type="hidden" name="submitted" value="#attributes.mode#">
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
