<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>



<cfparam name="attributes.subdescription_id" default="0">
<cfparam name="attributes.subdescription_name" default="0">
<cfparam name="attributes.subdescription_text" default="">
<cfparam name="attributes.subdescription_category" default="">
<cfparam name="attributes.PROCESSMESSAGE" default="">



<cfif isdefined("attributes.submitted")>
	
	<cfquery datasource="#request.dsn#" result="insertResult">
		update subdescriptions						
			set 
			
		   	subdescription_name = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_name#">
		   ,subdescription_text = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_text#">
		   ,subdescription_category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_category#">
			
			where subdescription_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_id#"> 

	</cfquery>	
		
	<cfset attributes.ProcessMessage = "Sub Decription Updated" >
</cfif>	

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT subdescription_id
	      ,subdescription_text
	      ,subdescription_category
	      ,subdescription_name
	  FROM subdescriptions
	
	where subdescription_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subdescription_id#">
</cfquery>



	

	
	
		
	
<cfoutput>

<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>New Dimension:</strong></font><br>
	
	
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
		<span class="floatRight"><a href="index.cfm?dsp=management.items.subDescriptions.subDescriptionsList">Sub Description List</a></span>
	<br><br>
	
	<tr bgcolor="##D4CCBF">
		<td align="left" colspan="2">
		<cfif attributes.ProcessMessage neq "">
			<span class="greenbg">#attributes.ProcessMessage#</span>
		<cfelse>
			<b>Enter Sub Descriptions</b>
		</cfif>
		</td>
	</tr>

	<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
	


		<form action="index.cfm?dsp=management.items.subDescriptions.edit_subDescription&subdescription_id=#attributes.subdescription_id#" method="post" >
			<table>
				<!--- name --->
				<tr class="trAltOdd">
					<td class="floatRight">Name: </td>
					<td><input type="text" name="subdescription_name" required="true" value="#sqlTemp.subdescription_name#"></td>
				</tr>
				
				<!--- length --->
				<tr class="trAltEven">
					<td class="floatRight">Category: </td>
					<td>						
						<select name="subdescription_category" data-clue="itemCondition"  required="true" >
							<option value="">Select Item Condition</option>
							<option value="New" <cfif #lcase(sqlTemp.subdescription_category)# is "New">selected</cfif> >New</option>
							<option value="New (Other) Opened"  <cfif #lcase(sqlTemp.subdescription_category)# is "New (Other) Opened">selected</cfif> >New (Other) Opened</option>
							<option value="USED"  <cfif #lcase(sqlTemp.subdescription_category)# is "USED">selected</cfif> >USED</option>
							<option value="AS-IS" <cfif #lcase(sqlTemp.subdescription_category)# is "AS-IS">selected</cfif> >AS-IS</option>
							<option value="SELLER REFURBISHED" <cfif #lcase(sqlTemp.subdescription_category)# is "SELLER REFURBISHED">selected</cfif> >SELLER REFURBISHED</option>
							<option value="NEW WITHOUT TAGS" <cfif #lcase(sqlTemp.subdescription_category)# is "NEW WITHOUT TAGS">selected</cfif> >NEW WITHOUT TAGS</option>
							<option value="NEW WITH DEFECT" <cfif #lcase(sqlTemp.subdescription_category)# is "NEW WITH DEFECT">selected</cfif> >NEW WITH DEFECT</option>
							<option value="New With Box"  <cfif #lcase(sqlTemp.subdescription_category)# is "New With Box">selected</cfif>>New With Box</option>
							<option value="New With Tags"  <cfif #lcase(sqlTemp.subdescription_category)# is "New With Tags">selected</cfif>>New With Tags</option>
							<option value="New Without Box" <cfif #lcase(sqlTemp.subdescription_category)# is "New Without Box">selected</cfif>  >New Without Box</option>
							<option value="Preowned" <cfif #lcase(sqlTemp.subdescription_category)# is "Preowned">selected</cfif> >Preowned</option>
							<option value="Amazon"  <cfif #lcase(sqlTemp.subdescription_category)# is "Amazon">selected</cfif> >Amazon</option>
							<option value="Craiglist"  <cfif #lcase(sqlTemp.subdescription_category)# is "Craiglist">selected</cfif> >Craiglist</option>
		
						</select>
					</td>
				</tr>

				<!--- subdescription_text --->
				<tr class="trAltOdd">
					<td class="floatRight">Sub Description: </td>
					<td>

						<textarea name="subdescription_text" rows="5" cols="40" style="font-size: 11px;"  required="true" >#sqlTemp.subdescription_text#</textarea>

							
					</td>
				</tr>

																
				<tr>
					<td></td>
					<td>
						<br><br>
						<input type="submit" value="Save">
							<input type="hidden" name="submitted" value="1">
						<input type="hidden" name="subdescription_id" value="#attributes.subdescription_id#">	
					</td>
				</tr>
			</table>

			
		</form>	
		
			
	
		
			
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
	