<cfif NOT isAllowed("System_Settings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfoutput>
<font size="4"><strong>Manage eBay Synchronization Task</strong></font><br>
<hr size="1" style="color: Black;" noshade><br>
<table>
<tr height="30"><td valign="middle" colspan="3">
	Status: <i><cfif _vars.system.schtask_runat EQ "none">NOT Scheduled<cfelse>Scheduled at #TimeFormat(_vars.system.schtask_runat)#</cfif></i><br>
	Time Now: #dateformat(now(),'long')# <i>#TimeFormat(now())#</i>
</td></tr>
<tr height="30"><td valign="middle" colspan="3">
	<a href="index.cfm?act=admin.api.schedule&action=run" onClick="return confirm('This operation might take couple of minutes. Continue?');">Run Now</a>
</td></tr>
<tr height="30"><td valign="middle" colspan="3">
	<a href="index.cfm?act=admin.api.schedule&action=delete">Stop AutoRun</a>
</td></tr>
<form action="index.cfm?act=admin.api.schedule" method="post">
<input type="hidden" name="action" value="update">
<tr height="30">
	<td valign="middle">Schedule everyday at</td>
	<td>
	<select name="starttime">
		<cfloop index="i" from="0" to="23">
		<option value="#i#,0"<cfif _vars.system.schtask_runat EQ CreateTime(i,0,0)> selected</cfif>>#TimeFormat(CreateTime(i,0,0))#</option>
		<option value="#i#,30"<cfif _vars.system.schtask_runat EQ CreateTime(i,30,0)> selected</cfif>>#TimeFormat(CreateTime(i,30,0))#</option>
		</cfloop>
	</select>
	</td>
	<td><input type="submit" value="Schedule"></td>
</tr>
</form>
<cfif FileExists("#request.basepath#ia_scheduled_task_061006.html")>
<tr height="30"><td valign="middle" colspan="3">
	<a href="ia_scheduled_task_061006.html" target="_blank">View Results of Last Run at #DateFormat(_vars.system.schtask_lastrun)# #TimeFormat(_vars.system.schtask_lastrun)#</a>
</td></tr>
</cfif>
</table>
</cfoutput>
