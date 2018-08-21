
<cfif NOT isAllowed("System_Settings")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfquery name="sqlSetting" datasource="#request.dsn#">
	SELECT name, avalue, readonly, type, description
	FROM settings
	WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.name#">
</cfquery>
<cfset avalue = HTMLEditFormat(sqlSetting.avalue)>
<cfoutput>
<font size="4"><strong>Edit Application Setting</strong></font><br>
<hr size="1" style="color: Black;" noshade><br>
</cfoutput>
<cfif sqlSetting.readonly>
	<cfoutput>
	#sqlSetting.name# = #avalue#
	</cfoutput>
<cfelse>
	<cfoutput>
	<table>
	<form action="index.cfm?act=admin.updatesetting" method="post">
	<input type="hidden" name="name" value="#sqlSetting.name#">
	</cfoutput>
	<cfswitch expression="#sqlSetting.type#">
		<cfcase value="STRING,EMAIL,NUMBER" delimiters=",">
			<cfoutput>
			<tr>
				<td valign="top"><b>#sqlSetting.name#</b></td>
				<td><input type="text" name="avalue" value="#avalue#" size="50">
				</td>
			</tr>
			</cfoutput>
		</cfcase>
		<cfcase value="HTML">
			<cfoutput>
			<tr>
				<td valign="top" colspan="2"><b>#sqlSetting.name#</b><br><br>
			</cfoutput>
			<cfscript>
				basePath = Left(cgi.script_name, FindNoCase('index.cfm', cgi.script_name)-1) & "FCKeditor/";
				fckEditor = createObject("component", "#basePath#fckeditor");
				fckEditor.instanceName	= "avalue";
				fckEditor.value			= sqlSetting.avalue;
				fckEditor.basePath		= basePath;
				fckEditor.width			= 700;
				fckEditor.height		= 400;
				fckEditor.toolbarSet	= "Auction";
				fckEditor.create();
			</cfscript>
			<cfoutput>
				</td>
			</tr>
			</cfoutput>
		</cfcase>
		<cfdefaultcase>
			<cfoutput><textarea name="avalue" cols="80" rows="10">#avalue#</textarea></cfoutput>
		</cfdefaultcase>
	</cfswitch>
	<cfoutput>
	<tr>
		<td valign="top"><br><b>Description</b></td>
		<td valign="top"><br>#sqlSetting.description#</td>
	</tr>
	<tr><td colspan="2">
		<input type="submit" value="Update">
	</td></tr>
	</form>
	</table>
	</cfoutput>
</cfif>
