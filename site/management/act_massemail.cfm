<cfquery name="sqlAccounts" datasource="#request.dsn#">
SELECT * FROM accounts;
</cfquery>
<cfloop query="sqlAccounts">
	<cfif Trim(sqlAccounts.email) NEQ "">
		<cfmail 
		from="#_vars.mails.from#" 
		to="#sqlAccounts.email#" subject="#attributes.emailtitle#">
Dear #sqlAccounts.first# #sqlAccounts.last#,

#attributes.emailmsg#

--
Instant Auctions Support Team
http://www.instantauctions.net/
		</cfmail>
	</cfif>
</cfloop>
<cfset _machine.cflocation = "index.cfm?dsp=management.massemail&sent=#sqlAccounts.RecordCount#">
