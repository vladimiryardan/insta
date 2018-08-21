<!---<cfdump var="#CGI#">--->
<!--- enable Session state management --->
<cfsetting requesttimeout="36000">

<cfflush interval="10" >
<cflock name="IAScheduledTask" timeout="60"><!--- wait up to 60 sec to check whether task is run in other session or not --->
	<cfset attr = StructNew ()>
	<cfset attr.name = "system.schtask_lastrun">
	<cfset attr.avalue = "#Now()#">
	<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
	<cfoutput><h1>STARTED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>

	<cfoutput><h1>Get Store Categories STARTED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
	<cfset attributes.SiteID = 0><!--- eBay USA --->
	<cfinclude template="../auctions/st_getstore.cfm">
	<cfset attributes.SiteID = 100><!--- eBay Motors --->
	<cfinclude template="../auctions/st_getstore.cfm">

	<!---<cfinclude template="st_getSalesRecordFixedPriceItems.cfm" >--->

	<cfinclude template="st_sync.cfm">
	<cfinclude template="st_get_just_ended.cfm">
	<cfinclude template="st_getsellertransactions.cfm">
	<cfinclude template="st_get_missed_transactions.cfm">
	<cfoutput><h1>APPLY CHANGES AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
	<cftry>
		<cfinclude template="../../api/dsp_run_synch.cfm">
		<cfquery datasource="#request.dsn#">
			UPDATE ebitems
			SET GalleryURL = SUBSTRING(itemxml, PATINDEX('%<galleryurl>%', itemxml)+12, PATINDEX('%</galleryurl>%', itemxml)-PATINDEX('%<galleryurl>%', itemxml)-12)
			WHERE GalleryURL IS NULL
				AND itemxml LIKE '%</galleryurl>%'
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE  ebitems
			SET PackagingHandlingCosts = SUBSTRING(itemxml, PATINDEX('%<internationalpackaginghandlingcosts currencyid="USD">%', itemxml)+54, PATINDEX('%</internationalpackaginghandlingcosts>%', itemxml)-PATINDEX('%<internationalpackaginghandlingcosts currencyid="USD">%', itemxml)-54)
			WHERE DATEDIFF(DAY, dtwhen , GETDATE()) < 10
				AND itemxml like '%InternationalPackagingHandlingCosts%'
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE  ebitems
			SET PackagingHandlingCosts = SUBSTRING(itemxml, PATINDEX('%<packaginghandlingcosts currencyid="USD">%', itemxml)+41, PATINDEX('%</packaginghandlingcosts>%', itemxml)-PATINDEX('%<packaginghandlingcosts currencyid="USD">%', itemxml)-41)
			WHERE DATEDIFF(DAY, dtwhen , GETDATE()) < 10
				AND itemxml like '%/PackagingHandlingCosts%'
		</cfquery>
		<cfcatch type="any">
			<!---<cfdump var="#cfcatch#">--->
			<cfdump var="#error#">
			<cfabort>
		</cfcatch>
	</cftry>
	<cftry>
		<cfinclude template="st_fixmisseditems.cfm">
		<cfcatch type="any">
			<cfoutput><h1 style="color:red">Error in st_fixmisseditems.cfm</h1></cfoutput>
			<!---<cfdump var="#cfcatch#">--->
			<cfdump var="#error#">
			<cfabort>
		</cfcatch>
	</cftry>
	<cftry>
		<cfinclude template="../../api/dsp_run_synch.cfm">
		<cfcatch type="any">
			<!---<cfdump var="#cfcatch#">--->
			<cfdump var="#error#">
			<cfabort>
		</cfcatch>
	</cftry>

<!---  Comment: VLad inserted the st_fixedItemPrice_fix.cfm coz for some reason the fixedprice item is not reflecting the correct final price   --->
<cfinclude template="st_fixedItemPrice_fix.cfm">

<!---
	<cftry>
		<cfoutput><h1>changestatus.cfm STARTED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
		<cfinclude template="../../../changestatus.cfm">
		<cfoutput><h1>changestatus.cfm FINISHED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>
--->

	<cfoutput><h1>GetAttributesXSL STARTED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
	<cfinclude template="../auctions/act_GetAttributesXSL.cfm">

	<cftry>
		<cfquery name="sqlASQData" datasource="#request.dsn#">
			SELECT eBayAccount, UserID
			FROM ebaccounts
			WHERE asq_active = 1
		</cfquery>
		<cfloop query="sqlASQData">
			<cfoutput><h1>#DateFormat(Now())# #TimeFormat(Now())# : get Ask Seller Question messages for #UserID#</h1></cfoutput>
			<cfset attributes.eBayAccount = eBayAccount>
			<cfinclude template="../../api/messages/act_synchronize.cfm">
		</cfloop>
		<cfcatch type="any">
			<cfif request.emails.error EQ "">
				<!---<cfdump var="#cfcatch#">--->
				<cfif isDefined("_ebay")>
					<!---<cfdump var="#_ebay#">--->
				</cfif>
				<cfdump var="#error#">
				<cfabort>
			<cfelse>
				<cfmail from="#_vars.mails.from#"
					to="#request.emails.error#"
					subject="ERROR IN api\messages\act_synchronize.cfm" type="html">
						<!---<cfdump var="#cfcatch#">--->
						<cfif isDefined("_ebay")>
							<!---<cfdump var="#_ebay#">--->
						</cfif>
					</cfmail>
				<cfdump var="#error#">
				<cfabort>					
			</cfif>
		</cfcatch>
	</cftry>

	<cfinclude template="st_alerts.cfm">
	

		
	<cfoutput><h1>FINISHED AT #DateFormat(Now())# #TimeFormat(Now())#</h1></cfoutput>
</cflock>
