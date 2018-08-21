<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfscript>
	theMessage = _vars.emails.return_message;
	theMessage = ReplaceNoCase(theMessage, "{ME}", "#session.user.first# #session.user.last#", "ALL");
	theMessage = ReplaceNoCase(theMessage, "{High Bidder}", "#attributes.hbuserid#", "ALL");
	theMessage = ReplaceNoCase(theMessage, "{Reference Number}", "#attributes.item#", "ALL");
</cfscript>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Return Item Emailer:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br>
	<br>
	<cfif isDefined ("attributes.sent")><font style="color:red;">Your message was sent to #attributes.sent# user(s).</font><br><br></cfif>
	Title and Message Below:<br><br>
	<form method="post" action="index.cfm?act=management.returnemail&email=#attributes.email#">
	Title: <input type="text" name="emailtitle" value="Item Return Information from Instant Auctions" size="100">
	<br><br>
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
<cfoutput>
<br><br>
	<center><input type="submit" value="Send Email"></center>
	</form>
	</table></td></tr></table>
	<br><br>
</td></tr>
</table>
</cfoutput>
