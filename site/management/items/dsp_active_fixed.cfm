<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.secondsort" default="internal_itemSKU">
<cfparam name="attributes.searchTerm" default="">

<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page+"&searchTerm="+"#attributes.searchTerm#";
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir+"&searchTerm="+"#attributes.searchTerm#";
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Fixed Item Active Listings:</strong></font>

	<div style="float:right;clear:both">
		<form action="index.cfm?dsp=management.items.active_fixed" method="post">

			<input type="text name="TitleOrId" id="TitleOrId" value="#attributes.searchTerm#">
			<input type="button" name="SearchTitleOrId" id="SearchTitleOrId" value="Search">
			<a href="index.cfm?dsp=management.items.active_fixed" >Refresh</a>
		</form>
	</div>
	<br><br>

	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<!---
<cfif isAllowed("EndOfDay_Listings")>
	<b>Print Daily Report For: </b>
	<a href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>
--->
	</td></tr></table>
	<br><br>


	<center>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>	
		
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">LID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(17);">QTY</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(12);" title="Fixed Inventory Count">Fixed</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(21);">SKU</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(18);" title="Amazon">AMZ</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(22);" title="Amazon">QTY +/-</a></td>		
			<td class="ColHead" width="200px"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Start Time</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">End Time</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">Times Run</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Price</a></td>			
						
			<td class="ColHead">SKU ##</td>
			
			<!---<td class="ColHead"><a href="JavaScript: void fSort(13);">SKU<br>Count</a></td>--->
					
			<td class="ColHead">Dups</td>
			<td class="ColHead"><a href="JavaScript: void fSort(11);">Dup Match</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(10);">Status</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(14);">Days</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(15);">P&S<br>90 days</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(16);">P&S<br>7 days</a></td>		
			
			
		</cfoutput>
		
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice,
			i.internal_itemSKU, a.listingtype, status.status as istatus,
			
			(
			SELECT count(*)
			FROM dbo.items x
				INNER JOIN auctions y ON x.item = y.itemid
				WHERE  x.status = 4
				and (x.lid != 'P&S' or x.lid is null)
				and y.listingtype =  '1'
				and x.internal_itemSKU = i.internal_itemSKU
			) as dupcount,

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
			) as fixInventoryCount, <!--- sort 12 --->

			(
				SELECT count(*)
				FROM items
				left JOIN status ON status.id = items.status
				where
				(
				items.internal_itemSKU = i.internal_itemSKU
				)
				and (items.internal_itemCondition != 'amazon' and items.internal_itemCondition != 'AS-IS' and items.internal_itemCondition != 'New with Defect')
				and (items.status != 11 and items.status != 4 and items.status != 5 and items.status != 10 and items.status != 16 )

				and items.offebay = '0'
				<!---and (items.status = '3' or items.status='8')<!--- 3 = item received --->--->
				and (items.item not like '%.11048.%' and items.item not like '%.11108.%') <!--- old account --->

			) as skuCount,


			(

				SELECT top 1 e2.dtstart
				FROM  items IT		
				LEFT JOIN ebitems e2 ON e2.ebayitem = it.ebayitem					
				WHERE 
					IT.item = i.item
				
			) as oldDateCount,
			
			(
				SELECT count(x.item) as amazonPS
				FROM items x
				WHERE x.shipped = '1' 
				AND x.paid = '1' 				
				and x.internal_itemSKU2 = i.internal_itemSKU2
				and x.ShippedTime >= DATEADD(Day, -90, GETDATE())
			) as amazonPS,
			
			(
				SELECT count(x.item) as amazonPS
				FROM items x
				WHERE x.shipped = '1' 
				AND x.paid = '1' 				
				and x.internal_itemSKU2 = i.internal_itemSKU2
				and x.ShippedTime >= DATEADD(Day, -7, GETDATE())
			) as amazonPS7
			,e.ebay_quantity
			
			,(
				SELECT count(ii.item)
				FROM items ii
					WHERE ii.status = '3' and 
						ii.internal_itemCondition = 'amazon' and 
						ii.internal_itemSKU = i.internal_itemSKU
			) as itemreceived_count

				
			,i.lid
			,i.paidtime
			,
			(
				SELECT  count(item)
				  FROM items
				  left JOIN status ON status.id = items.status
				  where
				  (
				  	items.internal_itemSKU = i.internal_itemSKU
				  )
				  and (items.internal_itemCondition != 'amazon' and 
				  items.internal_itemCondition != 'AS-IS' and 
				  items.internal_itemCondition != 'New with Defect')
				 and (
				 	items.status != 11 and 
				 	items.status != 4 and 
				 	items.status != 5 and 
				 	items.status != 10 and 
				 	items.status != 16) and
				 	 items.status != 14
				  and items.offebay = '0'
				   <!---and (items.status = '3' or items.status='8')<!--- 3 = item received --->--->
				  and (items.item not like '%.11048.%' and items.item not like '%.11108.%')
			) as skuCounter
			
			 <!--- sort 22 --->
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
					(	i.status = 11  and i.paidtime > (GetDate()-360) ) or 
					i.paidtime is null 
				)<!--- Auction Listed. :vladedit: 20161020 - change from 90 to 360 days --->
				

			<cfif attributes.searchTerm neq "">
				and (i.item like '%#attributes.searchTerm#%'
				or i.title like '%#attributes.searchTerm#%'
				or i.ebayitem like '%#attributes.searchTerm#%'
				or i.internal_itemSKU like '%#attributes.searchTerm#%'
				
				)
			</cfif>

				   	<!---and  (i.paidtime > (GetDate()-30))--->
			ORDER BY #attributes.orderby# #attributes.dir#
			<cfif attributes.orderby neq 8>
			, #attributes.secondsort# #attributes.dir#
			</cfif>
		</cfquery>





		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">


			<!--- items count base on sku and item condition--->
			<cfquery name="rs_skuCondFixedPriceItem" datasource="#request.dsn#">
				SELECT     i.item AS itemid, i.ebayitem,  
				i.listcount,  i.internal_itemSKU, i.internal_itemCondition, i.status
				FROM         dbo.items i
				INNER JOIN auctions a ON i.item = a.itemid
				WHERE  i.status = 4 <!--- Auction Listed --->
					and (i.lid != 'P&S' or i.lid is null) <!--- don't display paid and shipped --->
					and a.listingtype =  '1' <!---only fixed price items --->
					and i.offebay = '0'
				and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#'
			</cfquery>
			
		
		<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('E7E6F2'))#">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.itemid#" target="_blank">#sqlTemp.itemid#</a></td>
			<td >#sqlTemp.lid#</td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			
			
			<td>
				<!--- ebay quantity. the value here is being updated by a scheduled task \site\admin\api\st_getEbayQuantity.cfm --->
				#sqlTemp.ebay_quantity#
			</td>	
			
			<!--- FIXED INVENTORY COUNT COLUMN --->
			<td>
				<a href="index.cfm?dsp=management.items.active_fixedInventoryList&item=#sqlTemp.itemid#">#sqltemp.fixInventoryCount#</a>
			</td>
			
			<td>
				<!--- SKU COUNT --->
				<a href="index.cfm?dsp=management.items.active_fixedList&item=#sqlTemp.itemid#">#sqlTemp.skuCounter#</a>
			</td>
			<!--- amazon column --->
			<td>
				<a href="index.cfm?dsp=amazon_live.item_received&sku=#URLEncodedFormat(sqlTemp.internal_itemSKU)#">#sqlTemp.itemreceived_count#</a>
			</td>
			<td>#sqlTemp.skuFixDiff#</td>									
			<td >#sqlTemp.title#</td>
			
			<td>#strDate(sqlTemp.dtstart)#</td>
			
			<td>#strDate(sqlTemp.dtend)#</td>
			
			<td>#sqlTemp.listcount#</td>
			
			<td>$#sqlTemp.finalprice#</td>
			
			<td>#sqlTemp.internal_itemSKU#</td>


			<!--- DUP COUNT COLUMN --->
			<td>#sqlTemp.dupcount#</td>
			
			<td>
				<cfif rs_skuCondFixedPriceItem.recordcount gt 1>
					<cfloop query="rs_skuCondFixedPriceItem">
						<cfif rs_skuCondFixedPriceItem.itemid neq sqlTemp.itemid>
						#rs_skuCondFixedPriceItem.itemid#<br>
						</cfif>
					</cfloop>
				<cfelse>
					None
				</cfif>
			</td>	
						
				<!--- status --->
				<td>#sqlTemp.istatus#</td>
				
				
				<!--- days old --->
				<td>

					<cftry>
						#datediff("d",sqlTemp.oldDateCount,now())#                    	                    
                    <cfcatch type="Any" >
                    	VOID - [#sqlTemp.oldDateCount#]
                    </cfcatch>
                    </cftry>

				</td>
				
				<!--- amazon paid and shipped --->
				<td>
					<a href="index.cfm?dsp=management.items.itemsSku2&item=#sqlTemp.itemid#">#sqlTemp.amazonPS#</a>
					
				</td>
				
				<!--- amazon paid and shipped 7 Days--->
				<td>
					<a href="index.cfm?dsp=management.items.itemsSku2&item=#sqlTemp.itemid#&days=7">#sqlTemp.amazonPS7#</a>
					
				</td>	
								
			
	
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="19" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
<!--//

	$(function(){
			$('##SearchTitleOrId').click(function(){
			var $searchTerm = $('##TitleOrId').val();

			if($searchTerm == ""){
				alert('Please enter search Term');
			}else{
				window.location.href = "#_machine.self#&searchTerm="+$searchTerm;
			}

			});
	});
//-->
</script>
</cfoutput>
