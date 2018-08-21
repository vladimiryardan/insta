<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.subdescription_id" default="0">
<cfparam name="attributes.subdescription_name" default="0">
<cfparam name="attributes.subdescription_text" default="">
<cfparam name="attributes.subdescription_category" default="">
<cfparam name="attributes.PROCESSMESSAGE" default="">
<cfparam name="attributes.mode" default="Add">




<cfif isdefined("attributes.submitted")>
	
	<cfif attributes.mode is "add">
		<cftry>
        	<cfquery datasource="#request.dsn#" result="insertResult">
			
				INSERT INTO subdescriptions
				           (
							   	subdescription_name
							   ,subdescription_text
							   ,subdescription_category
				           )
				     VALUES
				           (
				           	<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_name#">,
				           	<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_text#">,
				           	<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subdescription_category#">
				           )			

			</cfquery>
			<cfset attributes.subdescription_id = insertResult.identitycol>    
			<cfset attributes.ProcessMessage = "Sub Description Inserted" >    
        <cfcatch type="Any" >
        	<cfset attributes.ProcessMessage = "Error!">
        </cfcatch>
        </cftry>

		
		
		
	</cfif>
	

</cfif>
	
	
	
	
<cfoutput>

<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>New Subdescription:</strong></font><br>
	
	
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<span class="floatRight"><a href="index.cfm?dsp=management.items.subDescriptions.subDescriptionsList">Sub Description List</a></span>
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
					<td><input type="text" name="subdescription_name" required="true" value=""></td>
				</tr>
				
				<!--- length --->
				<tr class="trAltEven">
					<td class="floatRight">Category: </td>
					<td>						
						<select name="subdescription_category" data-clue="itemCondition"  required="true" >
							<option value="">Select Item Condition</option>
							<option value="New" >New</option>
							<option value="New (Other) Opened" >New (Other) Opened</option>
							<option value="USED" >USED</option>
							<option value="AS-IS" >AS-IS</option>
							<option value="SELLER REFURBISHED" >SELLER REFURBISHED</option>
							<option value="NEW WITHOUT TAGS" >NEW WITHOUT TAGS</option>
							<option value="NEW WITH DEFECT" >NEW WITH DEFECT</option>
							<option value="New With Box"  >New With Box</option>
							<option value="New With Tags"  >New With Tags</option>
							<option value="New Without Box"  >New Without Box</option>
							<option value="Preowned"  >Preowned</option>
							<option value="Amazon"  >Amazon</option>
							<option value="Craiglist"  >Craiglist</option>
		
						</select>
					</td>
				</tr>

				<!--- subdescription_text --->
				<tr class="trAltOdd">
					<td class="floatRight">Sub Description: </td>
					<td>

						<textarea name="subdescription_text" rows="5" cols="40" style="font-size: 11px;"  required="true" ></textarea>

							
					</td>
				</tr>

																
				<tr>
					<td></td>
					<td>
						<br><br>
						<input type="submit" value="Save">
						<input type="hidden" name="submitted" value="#attributes.mode#">
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
