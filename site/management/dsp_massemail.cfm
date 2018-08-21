<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Mass Emailer:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br>
	<br>
	<cfif isDefined ("attributes.sent")><font style="color:red;">Your message was sent to #attributes.sent# user(s).</font><br><br></cfif>
	Enter Title and Message Below:<br><br>
	<form method="post" action="index.cfm?act=management.massemail">
	Title: <input type="text" name="emailtitle">
	<br><br>Dear First Last,<br><br>
	<textarea name="emailmsg" rows="10" cols="80"></textarea>
	<br><br>--<br>Instant Auctions Support Team<br>http://www.instantauctions.net<br><br>
	<center><input type="submit" value="Send Email" onClick="return confirm('This email will be sent to ALL users.  Continue?');"></center>
	</form>
	</table></td></tr></table>
	<br><br>
</td></tr>
</table>

</cfoutput>
