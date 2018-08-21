<cfif NOT isAllowed("System_ManageRoles")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>


<!---delete handler --->
<cfif isdefined("attributes.submitted")>
	
	<cfif isdefined("attributes.subdescription_id")>
		<!---delete selected --->	
		<cfloop index="i" list="#attributes.subdescription_id#"> 
			<cfquery datasource="#request.dsn#">
				delete from subdescriptions
				where subdescription_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">				
			</cfquery>
		</cfloop>
	</cfif>
</cfif>


<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT subdescription_id
	      ,subdescription_text
	      ,subdescription_category
	      ,subdescription_name
	  FROM subdescriptions
</cfquery>

<cfset colspan="5">
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>SUBDESCRIPTIONS:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>


	<form action="index.cfm?dsp=#attributes.dsp#" method="post">
		
	
	<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Name</td>
			<td class="ColHead" width="100">Category</td>
			<td class="ColHead" width="100">Text</td>
			<td class="ColHead" width="100"></td>
		</tr>
</cfoutput>




<!--- DISPLAY DIMENSIONS --->
<cfoutput query="sqlTemp">
	
		<tr <cfif CurrentRow mod 2 IS 0> bgcolor="##ECE9F3"<cfelse>bgcolor="##FFFFFF"</cfif> >
			
			<td><a href="index.cfm?dsp=management.items.subDescriptions.edit_subDescription&subdescription_id=#sqlTemp.subdescription_id#">#sqlTemp.subdescription_name#</a></td>
			<td align="center">#sqlTemp.subdescription_category#</td>
			<td align="center"><a href="index.cfm?dsp=management.items.subDescriptions.edit_subDescription&subdescription_id=#sqlTemp.subdescription_id#">Edit</a></td>
			<td align="center"><a href="##"><input type="checkbox" name="subdescription_id" value="#sqlTemp.subdescription_id#"</a></td>
						
		</tr>		
</cfoutput>



<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td colspan="3" class="ColHead">
				<a href="index.cfm?dsp=management.items.subDescriptions.new_subDescription&mode=Add">Create Subdescription</a>
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
