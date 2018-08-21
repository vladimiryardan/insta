<!---
Created: Dec 2010
Author: Vlad vladimiryardan@gmail.com
--->
<cfsetting RequestTimeout = "3600">
<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfset _paging.RowsOnPage = getVar('Paging.RowsOnPage4Multiple', 200, "NUMBER")>
<!---<cfparam name="attributes.orderby" default="6 DESC, 3">--->





<cfparam name="attributes.orderby" default="3 DESC, 4">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.searchTerm" default="">
<cfparam name="purchasePriceAll" default="0">

<cfif attributes.searchTerm neq "">
	<cfset attributes.searchTerm = trim(attributes.searchTerm)>
</cfif>
 <!---
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.title, i.internal_itemSKU, i.internal_itemCondition, u.ready,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		a.id, u.ready, i.lid,
		i.dpictured, i.status
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE 
	i.item IN
		(
			SELECT DISTINCT a.multiple
			FROM items a
				LEFT JOIN auctions b ON a.item = b.itemid
			WHERE b.itemid IS NULL or a.multiple = 'MULTIPLE' 
		) 
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
	ORDER BY  5 desc, #attributes.orderby# #attributes.dir#
</cfquery>                  
--->

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.title, i.internal_itemSKU, i.internal_itemCondition, u.ready,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		a.id, u.ready, i.lid,
		i.dpictured, i.status,i.purchase_price
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE 
		<cfif attributes.searchTerm neq "">
		i.item IN
		(				
					SELECT item
					FROM items 
					WHERE item like '%#attributes.searchTerm#%'	or
					internal_itemSKU like '%#attributes.searchTerm#%' or
					aid like '%#attributes.searchTerm#%' or
					title like '%#attributes.searchTerm#%' or 
					description like '%#attributes.searchTerm#%'or 
					internal_itemCondition like '%#attributes.searchTerm#%'						

					
		)
		<cfelse>	
		i.item IN
		(
			SELECT DISTINCT a.multiple
			FROM items a
				LEFT JOIN auctions b ON a.item = b.itemid
			WHERE b.itemid IS NULL 
		) 
		or i.item IN		
				(
			SELECT a.item
			FROM items a
				LEFT JOIN auctions b ON a.item = b.itemid
			WHERE a.internal_itemSKU is not null and a.internal_itemSKU != ''  and a.multiple = 'MULTIPLE'
		)
		</cfif>

		<!--- or i.item IN
		(
			SELECT TOP 50 a.item
			FROM items a
				LEFT JOIN auctions b ON a.item = b.itemid
			WHERE a.multiple = '' and a.internal_itemSKU is not null and a.internal_itemSKU != ''
		)--->
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
	ORDER BY  5 desc, #attributes.orderby# #attributes.dir#
</cfquery>     	


                      
                      
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
	<cfoutput>
	<script language="javascript" type="text/javascript">
	<!--//
		function fPage(Page){
			window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
		}
		function fSort(OrderBy){
			if ('#attributes.orderby#' == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
		}
		function fCheckAll(){
			obj = document.getElementById("theForm").multidup;
			if(isNaN(obj.length)){
				obj.checked = true;
			}else{
				for(i=0; i<obj.length; i++){
					obj[i].checked = true;
				}
			}
		}
	//-->
	</script>
	</cfoutput>
</cfif>
<cfset attributes.show_check_all = FALSE>
<cfoutput>


<table width="100%" style="text-align: justify;">
<tr><td>
	<!---
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Inventory Management:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				#_paging.RecordCount# records<!-- Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#-->
			<cfelse>
				<a href="#_machine.self#&page=#attributes.page#&orderby=#attributes.orderby#&dir=#attributes.dir#&printable" target="_blank">Printable version</a>
			</cfif>
		</td>
	</tr>
	</table>
	--->


	<cfif NOT isDefined("attributes.printable")>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last# 
		<div style="float:right">
			<form mode="post" action="index.cfm?dsp=management.items.dsp_inventoryManagement" onSubmit="return isEnter()">
				<input type="text" name="TitleOrId" id="TitleOrId">
				<input type="button" name="submit" id="SearchTitleOrId" value="Search">
			</form>
		</div>
		<br><br>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	
	<tr><td>
		<table id="myTable" class="tablesorter" width="100%" cellspacing="1" cellpadding="4">
		<thead>
		<cfif isDefined("attributes.printable")>
		<tr bgcolor="##F0F1F3">
			<th class="ColHead header">SKU&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header">Item Cond</th>
			<th class="ColHead header">Item ID</th>
			<th class="ColHead header">Title (LID)</th>
			<th class="ColHead header">##&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" title="Active Auctions" alt="Active Auctions">AA&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" title="Items Did not Sell" alt="Items Did not Sell">DNS&nbsp;&nbsp;</th> 
			<th class="ColHead header" title="Sold Items" alt="Sold Items" style="background-color:##CFCFCF">Sold&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" title="Fixed Price" alt="Fixed Price">FP&nbsp;&nbsp;&nbsp;</th>
		</tr>
		<cfelse>
		<tr bgcolor="##F0F1F3">
			<th class="ColHead header">SKU&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header">Item Cond</th>
			<th class="ColHead header">Item ID</th>
			<th class="ColHead header">Title (LID)</th>
			<th class="ColHead header">Last Listed&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header">##&nbsp;&nbsp;&nbsp;</th>	
			<th class="ColHead header" title="Active Auctions" alt="Active Auctions" >AA&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" title="Items Did not Sell" alt="Items Did not Sell">DNS&nbsp;&nbsp;&nbsp;</th> 
			<th class="ColHead header" title="Sold Items" alt="Sold Items" >Sold&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" title="Fixed Price" alt="Fixed Price">FP&nbsp;&nbsp;&nbsp;</th>
			<th class="ColHead header" colspan="2">Duplcate Auction To</th>
		</tr>
		<form action="index.cfm?dsp=#attributes.dsp#&act=admin.auctions.duplicate" method="post" id="theForm" name="theForm">
		</cfif>
		</thead>
		</cfoutput>
		
		
		<cfif isDefined("attributes.printable")>
			<cfset _paging.RowsOnPage = _paging.RecordCount>
			<cfset _paging.StartRow = 1>
		</cfif>
	<tbody> 
		<cfoutput query="sqlTemp" > <!---maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#"--->
		<cfif sqlTemp.internal_itemSKU neq "" and sqlTemp.status neq "11" and IsNumeric(sqlTemp.purchase_price)>
			<cfset purchasePriceAll = purchasePriceAll + 	sqlTemp.purchase_price >
		</cfif>
		
		<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('BFCAFF'))#">
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#" target="_blank">#sqlTemp.internal_itemSKU#</a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#" target="_blank">#sqlTemp.internal_itemCondition#</a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#" target="_blank">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#<cfif sqlTemp.lid NEQ ""> (#sqlTemp.lid#)</cfif></td>
		<cfif isDefined("attributes.printable")>
			<cfquery name="sqlChilds" datasource="#request.dsn#">
				SELECT COUNT(i.item) AS cnt
				FROM items i
					LEFT JOIN auctions u ON i.item = u.itemid
				WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
					AND u.itemid IS NULL
			</cfquery>
			<td align="right">#sqlChilds.cnt#&nbsp;</td>
		<cfelse>
			
			

			
			
			<cfif sqlTemp.ready EQ "">
				<td align="center" title="##" alt="##" >0</td>
				<td align="center" title="Active Auctions" alt="Active Auctions">0</td>
				<td align="center" title="Items Did not Sell" alt="Items Did not Sell">0</td>
				<td align="center" title="Sold Items" alt="Sold Items">0</td>
				<td align="center" title="Fixed Price" alt="Fixed Price">0</td>
				<td colspan="3" align="center"><a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#" target="_blank">Create Auction</a></td>
			<cfelse>
			
								<cfquery name="sqlStatusHistory" datasource="#request.dsn#">
								SELECT MAX(DATEADD(SECOND, h.[timestamp] + DATEDIFF(SECOND, GETUTCDATE(), GETDATE()), '01/01/1970')) AS max_listed
								FROM items i
									INNER JOIN status_history h ON i.item = h.iid
								WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
									AND h.new_status = 4
							</cfquery>
								<td nowrap align="center"><cfif isDate(sqlStatusHistory.max_listed)>#DateFormat(sqlStatusHistory.max_listed)#<cfelse>Never</cfif></td>
				
							<!--- items count base on sku and item condition--->
							<cfquery name="rs_skuItemCondCount" datasource="#request.dsn#">		
								SELECT     i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice, 
								i.internal_itemSKU, i.internal_itemCondition, i.status
								FROM         dbo.items AS i left JOIN
					      ebitems AS e ON i.ebayitem = e.ebayitem INNER JOIN
					      auctions a ON e.itemid = a.itemid
					      WHERE i.status = 4<!--- Auction Listed ---> 
				       <!---	and (YEAR(e.dtend) = #Year(now())#)	 --->		
				       	and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#' 
				       	and i.internal_itemCondition = '#sqlTemp.internal_itemCondition#' 
				       	and i.internal_itemSKU != '' and i.internal_itemCondition != '' <!--- don't count nulls --->                      
							</cfquery>
				
							<!--- items count base on sku and item condition--->
							<cfquery name="rs_skuItemDidNotSell" datasource="#request.dsn#">		
								SELECT     i.item AS itemid, i.ebayitem, i.listcount,  i.internal_itemSKU, i.internal_itemCondition, i.status
								FROM  items AS i 
					      WHERE i.status = 8<!--- DID NOT SELL ---> 				       	
				       	and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#' 
				       	and i.internal_itemCondition = '#sqlTemp.internal_itemCondition#' 
				     		and i.internal_itemSKU != '' and i.internal_itemCondition != '' <!--- don't count nulls   ---> 
							</cfquery>
					
							<!--- items count base on sku and item condition--->
							<cfquery name="rs_skuItemSold" datasource="#request.dsn#">		
								SELECT     i.item AS itemid, i.ebayitem,  i.listcount,  i.internal_itemSKU, i.internal_itemCondition, i.status
								FROM         dbo.items AS i INNER JOIN					      
					      auctions a ON i.item = a.itemid
					      WHERE i.status = 11<!--- PAID AND SHIPPED ---> 
				       	<!--- 	and (YEAR(e.dtend) = #Year(now())#)active auctions by date year --->		
				       	and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#' 
				       	and i.internal_itemCondition = '#sqlTemp.internal_itemCondition#' 
				       	and i.internal_itemSKU != '' and i.internal_itemCondition != '' <!--- don't count nulls --->                      
							</cfquery>
							
							<!--- items count base on sku and item condition--->
							<cfquery name="rs_skuCondFixedPriceItem" datasource="#request.dsn#">		
								SELECT     i.item AS itemid, i.ebayitem,  i.listcount,  i.internal_itemSKU, i.internal_itemCondition, i.status
								FROM         dbo.items i							      
					      WHERE  i.status = 4 <!--- Auction Listed ---> 
				       	and i.internal_itemSKU = '#sqlTemp.internal_itemSKU#' 
				       	<!---and i.internal_itemCondition = '#sqlTemp.internal_itemCondition#' --->
				       	and i.internal_itemSKU != '' and i.internal_itemCondition != '' <!--- don't count nulls --->    
							</cfquery>
							
							<cfset fixed_price_count = 0>
							<cfset itemIDof = "">
							<cfloop query="rs_skuCondFixedPriceItem">
								<cfquery name="getListingType" datasource="#request.dsn#">
									select ListingType from auctions where itemid = '#itemid#' and ListingType = 1
								</cfquery>
								<cfif getListingType.recordcount gte 1>
									<cfset fixed_price_count = fixed_price_count + 1>
									<cfif itemIDof eq "">
										<cfset itemIDof = "'" & #itemid# & "'" >
									<cfelse>
										<cfset itemIDof = itemIDof & ',' & "'" & #itemid# & "'" >
									</cfif>
								</cfif>
							</cfloop>

			
				<cfquery name="sqlChilds" datasource="#request.dsn#">
					SELECT i.item AS child_itemid, i.multiple
					FROM items i
						LEFT JOIN auctions u ON i.item = u.itemid
					WHERE (i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#"> ) 
						AND u.itemid IS NULL
				</cfquery>

				<cfif sqlChilds.RecordCount GT 0>
					<cfset attributes.show_check_all = TRUE>
					<td align="right" title="##" alt="##" >#sqlChilds.RecordCount#</td>

					<!--- AA --->
					<td align="center" title="Active Auctions" alt="Active Auctions" ><cfif rs_skuItemCondCount.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemCondCount.status#" target="_blank">#rs_skuItemCondCount.recordcount#</a><cfelse>#rs_skuItemCondCount.recordcount#</cfif></td>	
					<!--- DNS --->
					<td align="center" title="Items Did not Sell" alt="Items Did not Sell"><cfif rs_skuItemDidNotSell.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemDidNotSell.status#" target="_blank">#rs_skuItemDidNotSell.recordcount#</a><cfelse>#rs_skuItemDidNotSell.recordcount#</cfif></td>	
					<!--- Sold --->
					<td align="center" title="Sold Items" alt="Sold Items" ><cfif rs_skuItemSold.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemSold.status#" target="_blank">#rs_skuItemSold.recordcount#</a><cfelse>#rs_skuItemSold.recordcount#</cfif></td>	
					<!--- FP --->
					<td align="center" title="Fixed Price" alt="Fixed Price"><cfif fixed_price_count gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=4&FixedPrice=1&itemIDof=#itemIDof#" target="_blank">#fixed_price_count#</a><cfelse>#fixed_price_count#</cfif></td>	
					
					
					<td align="center" width="30"><input type="checkbox" name="multidup" value="#CurrentRow#"></td>					
					<td align="left" width="100">
						<input type="hidden" name="item_#CurrentRow#" value="#sqlTemp.item#">
						<select name="newitem_#CurrentRow#">
							<cfloop query="sqlChilds" endrow="1">
								<option value="#child_itemid#">#child_itemid#</option>
							</cfloop>
						</select>
					</td>
				<cfelse>
						<cfquery name="sqlChilds" datasource="#request.dsn#">
							SELECT i.item AS child_itemid, i.multiple
							FROM items i
								LEFT JOIN auctions u ON i.item = u.itemid
							WHERE (i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#"> or i.multiple = 'MULTIPLE' ) 
								AND u.itemid IS NULL
						</cfquery>
				
						<!--- vlad didn't test this just replicated it here for the sqlchilds --->
							<td align="right" title="##" alt="##" ><cfif LCase(sqlChilds.multiple) is "multiple">+.1<cfelseif sqlChilds.multiple is ''>+.001<cfelse>#sqlChilds.RecordCount#&nbsp;</cfif></td>
		
							<!--- AA --->
							<td align="center" title="Active Auctions" alt="Active Auctions" ><cfif rs_skuItemCondCount.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemCondCount.status#" target="_blank">#rs_skuItemCondCount.recordcount#</a><cfelse>#rs_skuItemCondCount.recordcount#</cfif></td>	
							<!--- DNS --->
							<td align="center" title="Items Did not Sell" alt="Items Did not Sell"><cfif rs_skuItemDidNotSell.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemDidNotSell.status#" target="_blank">#rs_skuItemDidNotSell.recordcount#</a><cfelse>#rs_skuItemDidNotSell.recordcount#</cfif></td>	
							<!--- Sold --->
							<td align="center" title="Sold Items" alt="Sold Items" ><cfif rs_skuItemSold.recordcount gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=#rs_skuItemSold.status#" target="_blank">#rs_skuItemSold.recordcount#</a><cfelse>#rs_skuItemSold.recordcount#</cfif></td>	
							<!--- FP --->
							<td align="center" title="Fixed Price" alt="Fixed Price"><cfif fixed_price_count gte 1><a href="index.cfm?dsp=management.items.dsp_inventorySkuCondition&internal_itemSKU=#sqlTemp.internal_itemSKU#&internal_itemCondition=#sqlTemp.internal_itemCondition#&itemStatus=4&FixedPrice=1&itemIDof=#itemIDof#" target="_blank">#fixed_price_count#</a><cfelse>#fixed_price_count#</cfif></td>	
							
							
							<td align="center" width="30"><input type="checkbox" name="multidup" value="#CurrentRow#"></td>					
							<td align="left" width="100">
								<input type="hidden" name="item_#CurrentRow#" value="#sqlTemp.item#">
								<select name="newitem_#CurrentRow#">
									<cfloop query="sqlChilds" endrow="1">
										<option value="#child_itemid#">#child_itemid#</option>
									</cfloop>
								</select>
							</td>
				</cfif>
			</cfif>
		</cfif>
		</tr><!--- end of 1 row --->

		
		
		<cfif ListFindNoCase("2,3", status) AND (sqlTemp.ready NEQ "1")><!--- Item Created, Item Received --->
			<cfquery name="sqlListedChilds" datasource="#request.dsn#">
				SELECT '<a href="index.cfm?dsp=#attributes.dsp#&act=admin.auctions.duplicate&newitem=#sqlTemp.item#&item=' + i.item + '">' + i.item + '</a>' AS child_itemid
				FROM items i
					INNER JOIN auctions u ON i.item = u.itemid
				WHERE i.multiple = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
					AND u.ready = 1
					AND i.status IN (4,5,10,11)<!--- Auction Listed, Awaiting Payment, Awaiting Shipment, Paid and Shipped --->
			</cfquery>
			<cfif sqlListedChilds.RecordCount GT 0>
				<tr bgcolor="##FFFFFF"><td colspan="8" align="center" style="color:red;">
					LISTED AUCTION(S): #ValueList(sqlListedChilds.child_itemid)#.<br>
					Click at item to duplicate its auction to #sqlTemp.item#
				</td></tr>
			</cfif>
		</cfif>
	
		</cfoutput>
	</tbody> 
		</table>


		
		<cfif NOT isDefined("attributes.printable")>
			
			<cfoutput>
			<table>
			<tr bgcolor="##F0F1F3">
				<td colspan="5" align="right">
					<cfif attributes.show_check_all>
						<!---<input type="button" onClick="fCheckAll()" value="Check All">--->
					<cfelse>
						#sqlTemp.RecordCount#
					</cfif>
				</td>
				<td colspan="3" align="center">
					<input type="submit" value="Duplicate Selected" style="font-size:10px;">
				</td>
			</tr>
			</form>

<tr><td>&nbsp;</td><td>
<div id="pager" class="pager">
	<form>
		<img src="layouts/default/blue/first.png" class="first"/>
		<img src="layouts/default/blue/prev.png" class="prev"/>
		<input type="text" class="pagedisplay"/>
		<img src="layouts/default/blue/next.png" class="next"/>
		<img src="layouts/default/blue/last.png" class="last"/>
		<select class="pagesize">
			<option selected="selected"  value="60">60</option>
			<option value="120">120</option>
			<option value="180">180</option>
		</select>
		Total: #sqlTemp.RecordCount# Records
	</form>
</div>
</td>
</tr>

<tr>
<td>
Purchase price of all items:  $#purchasePriceAll#
</td>
</tr>
			
			<!---
			<tr bgcolor="##FFFFFF">
			<td colspan="8" align="center">
				</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
			</td>
			</tr>
			--->
			</table>
			</cfoutput>
			
		</cfif>
		<cfoutput>
		</table>
	</td></tr>

</td></tr>



</table>
</cfoutput>

<cfoutput>
<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script src="layouts/default/jquery.tablesorter.min.js" language="javascript" type="text/javascript"></script>
<script src="layouts/default/jquery.tablesorter.pager.js" language="javascript" type="text/javascript"></script>

<link rel="stylesheet" href="layouts/default/blue/style.css" type="text/css" id="" media="print, projection, screen" />

<script type="text/javascript">
	$(function() {
		$("##myTable")
			.tablesorter({widthFixed: true, widgets: ['zebra']})
			.tablesorterPager({container: $("##pager")});
	});

</script>

<script language="javascript" type="text/javascript">
	$(function(){
			$('##SearchTitleOrId').click(function(){	
			var $searchTerm = $('##TitleOrId').val();
			
			if($searchTerm == ""){
				alert('Please Enter Search Term');
			}else{
				//window.location.href = "#_machine.self#&searchTerm="+$searchTerm;
				window.open("#_machine.self#&searchTerm="+$searchTerm,'_blank');
			}
							
			});			

	});
	
		function isEnter(){
			var $searchTerm = $('##TitleOrId').val();
			if($searchTerm == ""){
				alert('Please Enter Search Term');
				return false;
			}else{
				//window.location.href = "#_machine.self#&searchTerm="+$searchTerm;
				window.open("#_machine.self#&searchTerm="+$searchTerm,'_blank');
				return false;
			}
		}	
//-->
</script>
	
</cfoutput>