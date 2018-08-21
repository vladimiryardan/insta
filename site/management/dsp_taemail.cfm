<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfset html2parse = "">
<cfscript>
	theMessage = _vars.emails.taemail_message;
	theMessage = ReplaceNoCase(theMessage, "{ME}", "#session.user.first# #session.user.last#", "ALL");
	theMessage = ReplaceNoCase(theMessage, "{aid}", attributes.aid, "ALL");
	theStoreMessage = ReplaceNoCase(theMessage, "{UPS_Store}", "", "ALL");
	theMessage = ReplaceNoCase(theMessage, "{UPS_Store}", html2parse, "ALL");

	theStoreMessage = _vars.emails.taemail2ups_message;
	theStoreMessage = ReplaceNoCase(theStoreMessage, "{ME}", "#session.user.first# #session.user.last#", "ALL");
	theStoreMessage = ReplaceNoCase(theStoreMessage, "{aid}", attributes.aid, "ALL");
</cfscript>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Trading Assistant Emailer:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br>
	<br>
	<cfif isDefined ("attributes.sent")><font style="color:red;">Your message was sent to #attributes.sent# user(s).</font><br><br></cfif>
	Title and Message Below:<br><br>
	<form method="post" action="index.cfm?act=management.taemail&aid=#attributes.aid#">
	To Account: #attributes.aid#<br><br>
	Title: <input type="text" name="emailtitle" value="#getVar('emails.taemail_title', 'Follow-Up Email from EBay Trading Assistant Instant Online Consignment', 'STRING')#" size="70">
	<br><br>
	Dear &lt;User Name&gt;,<br>
</cfoutput>
		<cfscript>
			basePath = Left(cgi.script_name, FindNoCase('index.cfm', cgi.script_name)-1) & "FCKeditor/";
			fckEditor = createObject("component", "#basePath#fckeditor");
			fckEditor.instanceName	= "emailmsg";
			fckEditor.value			= theMessage;
			fckEditor.basePath		= basePath;
			fckEditor.width			= 700;
			fckEditor.height		= 400;
			fckEditor.toolbarSet	= "Auction";
			fckEditor.create();
		</cfscript>
		<cfset theEmail = Left(session.user.first, 1) & session.user.last & "@instantauctions.net">
<cfoutput>
	#session.user.first# #session.user.last#<br>
	#theEmail#<br>
	<a href="http://www.instantauctions.net">http://instantauctions.net</a><br>
<br><br>
</cfoutput>
<cfif isDefined("storeEmail")>
<cfoutput>
	<hr>
	To UPS Store: #storeEmail#<br><br>
	<br>
	Dear UPS Store Employee,<br>
	<input type="hidden" name="storeEmail" value="#storeEmail#">
</cfoutput>
		<cfscript>
			basePath = Left(cgi.script_name, FindNoCase('index.cfm', cgi.script_name)-1) & "FCKeditor/";
			fckEditor = createObject("component", "#basePath#fckeditor");
			fckEditor.instanceName	= "emailmsg2";
			fckEditor.value			= theStoreMessage;
			fckEditor.basePath		= basePath;
			fckEditor.width			= 700;
			fckEditor.height		= 400;
			fckEditor.toolbarSet	= "Auction";
			fckEditor.create();
		</cfscript>
		<cfset theEmail = Left(session.user.first, 1) & session.user.last & "@instantauctions.net">
<cfoutput>
	#session.user.first# #session.user.last#<br>
	#theEmail#<br>
	<a href="http://www.instantauctions.net">http://instantauctions.net</a><br>
<br><br>
</cfoutput>
</cfif>
<cfoutput>
	<center><input type="submit" value="Send Email"></center>
	</form>
	</table></td></tr></table>
	<br><br>
</td></tr>
</table>
</cfoutput>
