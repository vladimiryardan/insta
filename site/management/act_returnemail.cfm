<cfif Trim(attributes.email) NEQ "">
	<cfmail 
	from="#_vars.mails.from#" 
	to="#attributes.email#" 
	subject="#attributes.emailtitle#">#attributes.emailmsg#</cfmail>
</cfif>
<cfset _machine.cflocation = "index.cfm?dsp=management.items">
