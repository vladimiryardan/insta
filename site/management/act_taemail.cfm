<cfquery name="sqlAccounts" datasource="#request.dsn#">
SELECT * FROM accounts WHERE id = '#attributes.aid#';
</cfquery>
<cfset theEmail = Left(session.user.first, 1) & session.user.last & "@instantauctions.net">
<cfloop query="sqlAccounts">
	<cfif Trim(sqlAccounts.email) NEQ "">
		<cfmail 
		from="#_vars.mails.from#" 
		bcc="#_vars.emails.BCC_TAEmail#" 
		to="#sqlAccounts.email#" subject="#attributes.emailtitle#" type="html">
Dear #sqlAccounts.first# #sqlAccounts.last#,<br>
<br>
#attributes.emailmsg#
<br>
#session.user.first# #session.user.last#<br>
#theEmail#<br>
<a href="http://www.instantauctions.net">http://instantauctions.net</a><br>
		</cfmail>
	</cfif>
</cfloop>

<cfif isDefined("attributes.emailmsg2") AND isDefined("attributes.storeEmail")>
		<cfmail 
		from="#_vars.mails.from#" 
		bcc="#_vars.emails.BCC_TAEmail#" 
		to="#attributes.storeEmail#" 
		subject="#attributes.emailtitle#" type="html">
Dear UPS Store Employee,<br>
<br>
#attributes.emailmsg2#
<br>
#session.user.first# #session.user.last#<br>
#theEmail#<br>
<a href="http://www.instantauctions.net">http://instantauctions.net</a><br>
		</cfmail>
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=management.accounts">
