<cfflush interval="10">
<cfsetting requesttimeout="1960">

<cfoutput>
	Date run: #now()# <br>
</cfoutput>
<cfset startTime = getTickCount() />

		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item AS itemid
			,i.ebayitem
			,e.title
			,e.dtstart
			,e.dtend, i.listcount
			,e.price AS finalprice,
			i.internal_itemSKU, a.listingtype, status.status as istatus
			,i.lid 
			,i.paidtime
			,CONVERT(date, e.ebay_quantity_updated) as ebay_quantity_updated  
			,CONVERT(date, getdate()) as dateNow <!--- datepart only --->
			
						
			FROM items i
				INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
				INNER JOIN auctions a ON i.item = a.itemid
				INNER JOIN status status ON i.status = status.id
			WHERE 
				a.listingtype =  '1' and <!--- display only fixed price items --->	
				i.offebay = '0' and 
				i.internal_itemSKU != '' and<!---don't display null --->
				(
					i.status = 4 or 
					i.status = 10 or 
					i.status = 8 or
					i.status = 5 or 
					(	
						i.status = 11  and 
						i.paidtime > (GetDate()-90) 
					) or 
					i.paidtime is null 
				)<!--- Auction Listed --->
				
				<!--- 
				don't include if the item is already updated today.
				comment this out if you want to run in every item.
				if the ebay_quantity_updated is less than current datetime then it has been probably updated during scheduled task call
				and ebay_quantity_updated < CONVERT(date, getdate())
				--->
				
				<!--- ||||| for targeting 1 item  ||||||--->
				<!---and i.ebayitem = '311712138438'---> 
				
		</cfquery>
		
		
	


<cfset totalItems = 0 >
<cfoutput query="sqlTemp">	
	
		<!---
		<cfquery datasource="#request.dsn#" name="sqlRecord">
			SELECT finalprice, dended
			FROM records
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.itemid#">
		</cfquery>
		--->	
		<!---<cfdump var="#sqlTemp.dtend#"> <cfdump var="#datediff("d",now(),sqlTemp.dtend)#"><br>--->


		<!--- only new items needs to be checked --->
		<cfif isdate(sqltemp.dtend) 
			and datediff("d",now(),sqlTemp.dtend) gt -1><!--- 1 days from the date end ---> <!---and datediff("d",now(),sqlTemp.dtend) gt -1--->
			
				<cfset _ebay.CallName ="GetItem">
				<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
				<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
					<RequesterCredentials>
						<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
					</RequesterCredentials>
					<ItemID>#sqlTemp.ebayitem#</ItemID>
				</#_ebay.CallName#Request>'>
				
				
				<cfhttp url="#_ebay.URL#" method="POST" charset="utf-8" timeout="3600"> 
					<cfhttpparam name="X-EBAY-API-SESSION-CERTIFICATE" value="#_ebay.DeveloperName#;#_ebay.ApplicationName#;#_ebay.CertificateName#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-COMPATIBILITY-LEVEL" value="#_ebay.CompatibilityLevel#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-CALL-NAME" value="#_ebay.CallName#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-DEV-NAME" value="#_ebay.DeveloperName#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-APP-NAME" value="#_ebay.ApplicationName#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-CERT-NAME" value="#_ebay.CertificateName#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-SITEID" value="#_ebay.SiteID#" type="HEADER"> 
					<cfhttpparam name="X-EBAY-API-DETAIL-LEVEL" value="16" type="HEADER"> 
					<cfhttpparam name="request" value="#_ebay.XMLRequest#" type="XML">
				</cfhttp>
				
				<cfquery datasource="#request.dsn#" name="sqlLog">
						SELECT COUNT(*) AS cnt FROM ebapilogcall
						WHERE callname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.CallName#">
							AND dwhen = <cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">
					</cfquery>
					<cfif sqlLog.cnt EQ 0>
						<cfquery datasource="#request.dsn#">
							INSERT INTO ebapilogcall (callname, dwhen, callcount)
							VALUES (
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.CallName#">,
								<cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">,
								1
							)
						</cfquery>
					<cfelse>
						<cfquery datasource="#request.dsn#">
								UPDATE ebapilogcall
								SET callcount = callcount + 1
								WHERE callname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_ebay.CallName#">
									AND dwhen = <cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">
						</cfquery>
					</cfif>						
				
		        	<cfset ebayResponse = xmlparse(cfhttp.FileContent)>
					<cfset qty = 0 >
					<cfif ebayResponse.GetItemResponse.Ack.XmlText EQ "failure">
						<!---<cfoutput><h3 style="color:red;">Error while retrieving auction #sqlTemp.ebayitem#. Details: #err_detail#</h3></cfoutput>--->	
						Error: #sqlTemp.ebayitem#	<br>				
					<cfelse>
						<cfset qty = ebayResponse.GetItemResponse.Item.Quantity.xmlText>
						
						<cfif isdefined("ebayResponse.GetItemResponse.Item.SellingStatus.QuantitySold.xmlText") and
							isnumeric(ebayResponse.GetItemResponse.Item.SellingStatus.QuantitySold.xmltext) >
							<cfif qty gt 1>						
								<cfset qty = qty - ebayResponse.GetItemResponse.Item.SellingStatus.QuantitySold.xmltext>
							</cfif>								
						</cfif>						
						
						<cfquery datasource="#request.dsn#">
							update ebitems
							set ebay_quantity = #qty#,
							ebay_quantity_updated = getdate()
							where ebayitem = #sqlTemp.ebayitem#
						</cfquery>
						
						<!--- if item already ended --->
						<cfif isdefined("ebayResponse.GetItemResponse.Item.SellingStatus.ListingStatus.xmlText")
						and ebayResponse.GetItemResponse.Item.SellingStatus.ListingStatus.xmlText is "completed" >
							<cfquery datasource="#request.dsn#">
								update ebitems
								set ebay_quantity = 0,
								ebay_quantity_updated = getdate()
								where ebayitem = #sqlTemp.ebayitem#
							</cfquery>
						</cfif>
				
					</cfif> 
					
				#sqlTemp.ebayitem# - #qty# ebay_quantity_updated: #ebay_quantity_updated# - dateNow: #dateNow#<br>----------<br><!---spacer --->	
			<cftry>							               
		    <cfcatch type="Any" >
		    	0  <!--- display zero --->
		    </cfcatch>
		    </cftry>
			<cfset totalItems += 1 >	    			
		</cfif>
				    
</cfoutput>    

<cfoutput>
	<!--- PAGE TIMER --->
	<cfset eTime = getTickCount() />	
	<cfset intRunTimeInSeconds = DateDiff(
	"s",
	GetPageContext().GetFusionContext().GetStartTime(),
	Now()
	) />
	<h3>
		Total Items Called: #totalItems#<br>
		Page Processing Time #intRunTimeInSeconds# Seconds! (#(eTime-startTime)/1000#)
	</h3>
	
	<cfmail from="#_vars.mails.from#" 
			to="BigBlueWAlerts@gmail.com"
			type="html"
			subject="Ebay Quantity Call run #dateformat(now(),'yyyy-mm-dd')#" 
			>
		
			Ebay Qunatity Success run.<br><br>

			#dateformat(now(),'yyyy-mm-dd')# #TimeFormat(now(),'short')#
			
			<br>
			Thank You - Big Blue Wholesale<br>
			http://www.instantonlineconsignment.com/<br>
	</cfmail>


</cfoutput>