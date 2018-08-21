<cfoutput>
	
<!--- whose logged in and using the scanner? Get the account--->
<cfif isValid("email", session.user.email) >
	<cfset alertReceiver = session.user.email >
<cfelse>
	<cfset alertReceiver = "bigbluewholesale@aol.com" >
</cfif>			
	
<cftry>
	<cfcontent reset="yes">
	<cfparam name="attributes.items" default="">
	<cfparam name="attributes.lid" default="">
	
	
	
	
	<cfset logAttr2 = "">	
	<cfsavecontent variable="logAttr" >
		<cfdump var="#attributes#">
	</cfsavecontent>
	
	<cfset fileNameRandom = DateFormat(now(),
				            "yyMMdd"
				            ) 
				            & "_" &
				        TimeFormat(
				            now(),
				            "HHmmss"
				            ) >
	
	       
	
	
	
	<cfset attributes.lid = URLDecode(attributes.lid)>
	<cfif (attributes.lid NEQ "") AND (attributes.items NEQ "")>
		<cfif (Len(attributes.lid) EQ 2) AND isNumeric(Left(attributes.lid, 1))>
			<cfset attributes.lid = "0" & attributes.lid>
		</cfif>
		<cfif NOT ListFindNoCase("LISTA,LISTB,LISTC,PAKA,PAKB,PAKC", attributes.lid)>
			<cfquery datasource="#request.dsn#" result="qry">
				UPDATE items
				SET dpacked = GETDATE()
				WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
					AND lid IS NULL
			</cfquery>
			
			<!---<cfsavecontent variable="logAttr2" >
				<cfdump var="#qry#">
				query executed
			</cfsavecontent>--->
	
		</cfif>
		<cfloop index="itemid" list="#attributes.items#">
			
			<!--- check the item number for bad format --->
			<!---<cfthrow type="Application" message = "#attributes.items# - #attributes.lid# ">--->
			
			<cfset itemidParsed = replace(itemid,".","","all")>
			<cfif isnumeric(itemidParsed)>
				<!--- good run. do nothing --->
			<cfelse>
				<cfthrow type="Application" message="#attributes.lid# - #attributes.items# Error">
			</cfif>
			
			
			<cfset fChangeLocation(itemid, attributes.lid)>
			<cfif attributes.lid EQ "RTC">
				<cfset fChangeStatus(itemid, 9)>
			<cfelseif attributes.lid EQ "DTC">
				<cfset fChangeStatus(itemid, 13)>
			<cfelseif attributes.lid EQ "RELOT">
				<cfset fChangeStatus(itemid, 14)>
			</cfif>
		</cfloop>
		~DB UPDATED: {#attributes.lid#} -> {#attributes.items#}
	<cfelse>
		~UPDATE FAILED: {#attributes.lid#} -> {#attributes.items#}
	</cfif>
	
	<!--- enable this to debug this page --->
	<!---<cffile action="append"
		file="#getdirectoryFromPath(getcurrentTemplatePath() )#/logs/#fileNameRandom#.html"
		output="~#logAttr#~#logAttr2#">--->	

<!--- send alerts when LID is over 6 Characters or all numeric  --->
<cfif len(attributes.lid) gte 7 or isnumeric(attributes.lid) >
	
	<cfmail from="#_vars.mails.from#" 
			to="#alertReceiver#" 
			cc="bigbluewholesale@aol.com"
			type="html"
			subject="LID Alert" 
			>
			
			LID is over 6 Characters or all numeric<br>
			
			LID: #attributes.lid# <BR>
			ITEMS: #attributes.items# <BR>
			
		</cfmail>	
		
		
</cfif>


<cfcatch type="Any" >
	
	
	<cfmail from="#_vars.mails.from#" 
		to="#alertReceiver#" 
		type="html"
		subject="LID Alert" 
		cc="bigbluewholesale@aol.com" 	
		>
		
		LID error. Bad scan process.<br>
		
		LID: #attributes.lid# <BR>
		ITEMS: #attributes.items# <BR>		
		
	</cfmail>
	
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
</cfoutput>
<cfabort>



