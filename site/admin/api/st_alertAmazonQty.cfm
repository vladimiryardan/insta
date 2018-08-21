<!--- QTY of "1" in the AMZ --->

	
	<cfquery name="sqlTempAmz" datasource="#request.dsn#">
		SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice, e.dtend,
		i.internal_itemSKU, a.listingtype, status.status as istatus,
				(
					SELECT count(x.item) as amazonPS
					FROM items x
					WHERE x.shipped = '1' 
					AND x.paid = '1' 				
					and x.internal_itemSKU2 = i.internal_itemSKU2
					and x.ShippedTime >= DATEADD(Day, -7, GETDATE())
				) as amazonPS7
				
			,e.ebay_quantity
			,i.lid
			
			,(
				SELECT count(ii.item)
				FROM items ii
					WHERE ii.status = '3' and 
						ii.internal_itemCondition = 'amazon' and 
						ii.internal_itemSKU = i.internal_itemSKU
			) as itemreceived_count
			
			<!--- SKUFIXDIFF --->
			,(
				(
					SELECT count(*)
					FROM dbo.items i2
					where i2.internal_itemSKU = i.internal_itemSKU
					and (
						i2.internal_itemCondition != 'amazon' 
						and i2.internal_itemCondition != 'AS-IS'
						<!---and i2.internal_itemCondition != 'New with Defect' 20161014. Patrick says remove--->
					)
					and i2.offebay = '0'
					and i2.status = 16
				)
				-
				e.ebay_quantity
			) as SKUFIXDIFF
						
			,(
				SELECT count(x.item) as amazonPS
				FROM items x
				WHERE x.shipped = '1' 
				AND x.paid = '1' 				
				and x.internal_itemSKU2 = i.internal_itemSKU2
				and x.ShippedTime >= DATEADD(Day, -90, GETDATE())
			) as amazonPS
			
			,(

				SELECT top 1 e2.dtstart
				FROM  items IT		
				LEFT JOIN ebitems e2 ON e2.ebayitem = it.ebayitem					
				WHERE 
					IT.item = i.item
				
			) as oldDateCount
			
			,(
				SELECT count(*)
				FROM dbo.items i2
				where i2.internal_itemSKU = i.internal_itemSKU
				and (
					i2.internal_itemCondition != 'amazon' 
					and i2.internal_itemCondition != 'AS-IS'
					<!---and i2.internal_itemCondition != 'New with Defect' 20161014. Patrick says remove--->
				)
				and i2.offebay = '0'
				and i2.status = 16
			) as fixInventoryCount	
			
					
										
			FROM items i
				INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
				INNER JOIN auctions a ON i.item = a.itemid
				INNER JOIN status status ON i.status = status.id
			WHERE 
				a.listingtype =  '1' and <!--- display only fixed price items --->	
				i.offebay = '0' and 
				i.internal_itemSKU != '' and<!---don't display null --->
				i.status = 4 

								
	</cfquery>



<cfoutput>

		<h3>Review Listing Title - QTY +/- -1 and Dummy</h3> <!----1 or higher -2 --->
		<cfset countx = 0 >
		<cfloop query="sqlTempAmz">

			
			<!--- set initial to false --->
			<cfset daysCount = 0 >	
				<cfif isdate(sqlTempAmz.dtend)>
					<!--- we need to query again for  --->
					  SELECT dtend
					  FROM [items]
						inner join ebitems  on ebitems.itemid = items.item					
					<cfset daysCount = DateDiff("d", sqlTempAmz.dtend, now() )>
				</cfif>
			
			<cfif SKUFIXDIFF lte -1 and lid is "dummy" and daysCount  >
				#sqlTempAmz.itemid# - #sqlTempAmz.title#   -- #dateformat(sqlTempAmz.dtend,"medium" )# <br>
				<cfset countx++ >
			</cfif>
			
		</cfloop>
		
		<br>#countx# records
</cfoutput>

<cfabort>


<!--- alert 1 --->
<cfif _vars.Alert_AmazonQty.email neq "">	
	<cfmail	
	from="#_vars.mails.from#"
	to="#_vars.Alert_AmazonQty.email#"

	subject="#_vars.Alert_AmazonQty.subject#" 
	type="html">

		The Fixed items with  QTY of 1 in the AMZ"<br> 	
		<cfloop query="sqlTempAmz">
			<cfif itemreceived_count eq 1>
				#sqlTempAmz.itemid# - #sqlTempAmz.title# <br>
			</cfif>
			
		</cfloop>
		
	


	</cfmail>
				
</cfif>	


<!--- alert 2  --->
<cfif _vars.Alert_dummylid.email neq "">	
	<cfmail	
	from="#_vars.mails.from#"
	to="#_vars.Alert_dummylid.email#"
	cc="vladimiryardan@gmail.com"
	subject="#_vars.Alert_dummylid.subject#" 
	type="html">

		<br>
		<h3>Review Listing Title - QTY +/- -1 and Dummy</h3> <!----1 or higher -2 --->
		<cfset countx = 0 >
		<cfloop query="sqlTempAmz">
			<!--- set initial to false --->
			<cfset daysCount = 0 >
			<cfif isdate(dtend) >
				<cfset daysCount = DateDiff("d", sqlTempAmz.dtend, now() ) >
			</cfif>
			
			<cfif SKUFIXDIFF lte -1 and lid is "dummy" and daysCount >
				#sqlTempAmz.itemid# - #sqlTempAmz.title# <br>
				<cfset countx++ >
			</cfif>
			
		</cfloop>
		
		<br>#countx# records
	</cfmail>
				
</cfif>	




<!--- alert 3 --->	
<cfif _vars.Alert_ps90day.email neq "">
	
	<cfsavecontent variable="ps90day" >
		<cfoutput>
							<br>
				<h3>P&S 90 DAY = 0 , DAYS = 90+ , FIXED 3+ and Exclude account 12190 items</h3> <!----1 or higher -2 --->
				<cfloop query="sqlTempAmz">
					
							<cftry>
								<cfset report_oldDateCount = #datediff("d",sqlTempAmz.oldDateCount,now())# >                    	                    
		                    <cfcatch type="Any" >
		                    	<cfset report_oldDateCount = 0 >
		                    </cfcatch>
		                    </cftry>
		                    
					<!---P&S 90 DAY = 0 , DAYS = 90+ , FIXED 3+ and Exclude account 12190 items..--->
					<cfif sqlTempAmz.amazonPS eq 0 and 
							sqlTempAmz.fixInventoryCount gte 3 and 
							report_oldDateCount gte 90 and
							not refindNocase(".12190.",sqlTempAmz.itemid ) >
						#sqlTempAmz.itemid# - #sqlTempAmz.title# <br>
					</cfif>
					
				</cfloop>
				
		</cfoutput>
	</cfsavecontent>
			<cfmail	
			from="#_vars.mails.from#"
			to="#_vars.Alert_ps90day.email#"
		
			subject="#_vars.Alert_ps90day.subject#" 
			type="html">
		
				#ps90day#
		
			</cfmail>
				
</cfif>	


<cfif _vars.Alert_startsWithB.email neq "">
	<cfsavecontent variable="startswithB" >
		<cfoutput>
							<br>
				<h3>LID = STARTS with a "B" and QTY +/-  = "0" </h3> <!----1 or higher -2 --->
				<cfloop query="sqlTempAmz">
					
					<cfif left(sqlTempAmz.lid,1) is "b" and  sqlTempAmz.skuFixDiff eq 0>
						#sqlTempAmz.itemid# - #sqlTempAmz.title# - #sqlTempAmz.lid# <br>
					</cfif>
					
				</cfloop>
				
		</cfoutput>
	</cfsavecontent>
			<cfmail	
			from="#_vars.mails.from#"
			to="#_vars.Alert_startsWithB.email#"
		
			subject="#_vars.Alert_startsWithB.subject#" 
			type="html">
		
				#startswithB#
		
			</cfmail>
</cfif>	
