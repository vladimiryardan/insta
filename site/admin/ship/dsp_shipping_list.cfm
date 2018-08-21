<cfparam name="attributes.local_buyers" default="0">
<cfif attributes.called_from EQ "admin.ship.combined">

<cfelse>
	
</cfif>	
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.title, i.PaidTime, i.weight, e.price,
		i.ebayitem, e.title AS etitle, e.hbuserid, e.galleryurl, i.shipnote,
		i.refundpr, i.drefund, i.lid, i.startprice AS reserve,  i.dlid, i.internal_itemSKU,
		i.byrCompanyName, amzn.amazon_item_amazonorderid, amzn.amazon_item_quantityordered, a.use_pictures,
		a.listingtype, i.internal_itemSKU2, i.byrStateOrProvince, i.byrCityName, i.byrCountry, i.usps_zone,i.byrPostalCode

	FROM items i
		LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
		LEFT JOIN auctions a ON i.item = a.itemid<!--- for DUPLICATE AUCTIONS that doesnt carry over the image--->
		
		<!--- 20140724 bug fix where the awaiting ship list have fixed item mixed in the display of items --->
		<!---20160810. commented out coz we need it the same with http://www.instantonlineconsignment.com/index.cfm?dsp=admin.ship.awaiting 
		<cfif attributes.called_from EQ "admin.ship.awaiting">
			and a.listingtype = 0
		</cfif>--->
		
		LEFT JOIN (SELECT DISTINCT itmItemID, byrCountry FROM ebtransactions) t ON i.ebayitem = t.itmItemID
		LEFT JOIN amazon_items amzn ON i.item  = amzn.items_itemid
	<cfif (attributes.called_from EQ "admin.ship.urgent") OR (attributes.called_from EQ "admin.ship.combined")>
		LEFT JOIN local_buyers lb ON e.hbuserid = lb.eBayUser
	WHERE lb.eBayUser IS<cfif attributes.local_buyers EQ 1> NOT</cfif> NULL
		AND
	<cfelse>
	WHERE
	</cfif>
	<cfif attributes.called_from EQ "admin.ship.ship_sold_off">
		i.offebay = '1'
		AND i.status = 10
	<cfelse>
		<cfif attributes.called_from NEQ "admin.ship.refund">
					(
						(
			e.hbuserid <cfif attributes.called_from NEQ "admin.ship.combined">NOT </cfif>IN
			(
				SELECT e2.hbuserid
				FROM items i2
					LEFT JOIN ebitems e2 ON i2.ebayitem = e2.ebayitem
				WHERE e2.hbuserid IS NOT NULL
					AND i2.paid = '1'
					AND i2.shipped = '0'
					AND i2.ShippedTime IS NULL
				GROUP BY e2.hbuserid
				HAVING COUNT(i2.item) > 1
			)
						)
					)
			AND
		</cfif>
		(
			(
			i.exception = 0
			AND i.paid = '1'
			AND i.shipped = '0'
			AND i.ShippedTime IS NULL
		<cfif attributes.called_from EQ "admin.ship.awaiting" >	
			and a.itemQty = 1 <!---20160810. don't include item If Quanity higher the "1"  --->
			and i.lid != 'dummy'
			and a.listingtype != 1
		</cfif>				
		<cfif attributes.called_from EQ "admin.ship.combined">
			AND i.drefund IS NULL
			AND i.PaidTime IS NOT NULL
			and 
			(
				(a.listingtype != 1 or a.listingtype is null) <!--- don't include fixed items. for the a.listingtype is null some items doesn't have auction --->			 
				and i.LID != 'Dummy'
			)

			<!---AND t.byrCountry = 'US'--->
			or i.dummy = 1 <!--- we need this coz create link item in ex. http://www.instantonlineconsignment.com/index.cfm?dsp=admin.ship.link_to_itemMultiV2&tid=1154672 sets dummy = 1--->			
		<!---		AND t.byrCountry = 'US'--->
		<cfelseif attributes.called_from EQ "admin.ship.international">
			AND i.drefund IS NULL
			AND i.PaidTime IS NOT NULL
			AND t.byrCountry != 'US'
		<cfelseif attributes.called_from EQ "admin.ship.urgent">
			AND i.drefund IS NULL
			AND
			(
				(i.PaidTime <= DATEADD(DAY, -7, GETDATE()) AND t.byrCountry = 'US')
				OR
				(i.drefund IS NOT NULL AND i.PaidTime IS NOT NULL AND t.byrCountry != 'US')
			)
		<cfelseif attributes.called_from EQ "admin.ship.refund">
			AND i.drefund IS NOT NULL
			AND t.byrCountry = 'US'
		<cfelse>
			AND i.drefund IS NULL
			AND t.byrCountry = 'US'
				<cfif attributes.srch NEQ ""><!--- search on Awaiting should search also Urgent --->
					AND i.PaidTime IS NOT NULL
				<cfelse>
					AND i.PaidTime > DATEADD(DAY, -7, GETDATE())
				</cfif>
		</cfif>
			)
		<cfif (attributes.called_from EQ "admin.ship.urgent") OR ((attributes.srch NEQ "") AND (attributes.called_from EQ "admin.ship.awaiting"))><!--- search on Awaiting should search also Urgent --->
			OR (i.exception = 1)
			
		</cfif>
		)
	</cfif>
	<cfif attributes.store NEQ "all">
		AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
	</cfif>
	<cfif attributes.srch NEQ "">
		AND (
			i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
			OR
			e.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
			OR
			i.ebayitem LIKE '%#attributes.srch#%'
			OR
			i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
		)
	</cfif>
	
	<!---ORDER BY a.listingtype asc, #attributes.orderby# #attributes.dir#--->
	ORDER BY #attributes.orderby#  #attributes.dir# <!--- 20160810 --->
</cfquery>

<cfoutput>
	


<style type="text/css">

.btmborder{
	border-bottom: 2px dashed ##9EB5C5;
}
</style>

<h3>SHIPPING LIST - #UCase(DateFormat(Now(), "mmmm d, yyyy"))# #TimeFormat(Now())#</h3>
<table>
</cfoutput>
<cfoutput query="sqlTemp" group="hbuserid">
	<cfoutput>
	<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('D1D2D3'))#" >
		<!---<cfif attributes.called_from EQ "admin.ship.combined">
			<td<cfif sqlTemp.shipnote NEQ ""> rowspan="2"</cfif>><input type="checkbox" class="btmborder"></td>
		</cfif>--->
		<td class="btmborder">
			<!--- 20120216 fix thumb display --->
<!---			<cfif sqlTemp.galleryurl EQ "">
				<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
			<cfelse>
				<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" width=80 border=1>
			</cfif>--->
				<cfif sqlTemp.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
				<cftry>
						<cfhttp method="head" url="#sqlTemp.galleryurl#" result="sc">
						<cfif sc.statuscode is "200 OK">
							<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" border="1" width="80"></a>
						<cfelse>
							<!--- use_pictures --->
							<cfset sqlTemp.galleryurl = replace(sqlTemp.galleryurl,sqlTemp.item,sqlTemp.use_pictures)>
							<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" border="1" width="80"></a>
						</cfif>
				<cfcatch>
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				</cfcatch>
				</cftry>
				</cfif>
		</td>
		<td class="btmborder">
			<b><font size=2>#item#<br>
			LID: #lid#<cfset varZip = sqlTemp.byrPostalCode><cfset varReturnedZone = 0><cfinclude template="zoneChart.cfm">[Zone: #varReturnedZone#]<cfif varReturnedZone neq 0></cfif><br>#DateFormat(dlid)# <br>
			#hbuserid# -			
			<cfif Trim(sqlTemp.byrCityName) NEQ "">#sqltemp.byrCityName#</cfif> 
			<cfif Trim(sqlTemp.byrStateOrProvince) NEQ "">
				#sqltemp.byrStateOrProvince#
			</cfif>
			<cfif Trim(sqlTemp.byrCountry) NEQ ""> (#sqlTemp.byrCountry#)</cfif>
			
			</font></b><br>
			<!--- added internal item sku --->
			<strong><font size=2>#item#</font></strong><br>
		</td>
		<td class="btmborder">
		<font size=2>#title#</font><br />
		<hr />
		<font size=2>#internal_itemSKU# | #sqltemp.internal_itemSKU2#</font> <cfif sqlTemp.listingtype eq 1>
			<span style="background-color:##E49BB4">FIXED PRICE ITEM</span></cfif>
			 
			<br />
		<hr />
		<font size=2>#etitle#</font>


		<!--- 20120205 display for amazon --->
		<cfif sqlTemp.amazon_item_amazonorderid neq "">
			<font size=2>
				Amzn: #sqlTemp.amazon_item_amazonorderid#<br>
				Byr: #sqlTemp.byrCompanyName#<br>
				qty: #sqlTemp.amazon_item_quantityordered#<br>
			</font>
			<hr />
		</cfif>
		</td>
		<td class="btmborder"><font size=2>#weight# lbs.</font></td>
		<td class="btmborder"><font size=2>#DollarFormat(price)#<cfif (reserve NEQ 0) AND (price GTE reserve)> -R</cfif></font></td>
	</tr>
	<cfif sqlTemp.shipnote NEQ ""><tr><td class="btmborder" align="right"><b>Note:</b></td><td colspan="4" class="btmborder"><b>#shipnote#</b></td></tr></cfif>
	</cfoutput>
	<cfif attributes.called_from EQ "admin.ship.combined">
		<tr><td colspan="6" class="btmborder"><hr style="page-break-after:always;"></td></tr>
	</cfif>
</cfoutput>
<cfoutput></table></cfoutput>
