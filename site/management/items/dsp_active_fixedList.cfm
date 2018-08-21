<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.item" default="0">


<cfoutput>
		<cfif isdefined("attributes.submitted")>
			<cfquery name="getFixedInventory" datasource="#request.dsn#">
				SELECT id,status
				  FROM status
				    where id = 16
			</cfquery>

				<cfloop index="i" list="#attributes.FieldNames#" DELIMITERS="," >

					<cfif LEFT(i, 5) is "ITEM_" >
						<CFSET itmID = RemoveChars(i, 1, 5)>
						<!---#itmID#<br>--->
						<cfquery name="getFixedInventory" datasource="#request.dsn#">
							update items
							set status = <cfqueryparam cfsqltype="cf_sql_integer" value="16">
							where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itmID#">
						</cfquery>
						
						<cfset LogAction("Changed to Fixed Inventoryitem #itmID#")>
					</cfif>
				</cfloop>
		</cfif>
</cfoutput>


<cfoutput>
<h3>Matched SKU</h3>


	<!--- items count base on sku and item condition--->
		<cfquery name="getInternalSKu" datasource="#request.dsn#">
			SELECT      i.internal_itemSKU, i.internal_itemCondition, i.status
			FROM         dbo.items i
			INNER JOIN auctions a ON i.item = a.itemid
			WHERE  i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">

			<!--- filters removed --->
			<!---i.status = 4 <!--- Auction Listed --->--->
				<!---and (i.lid != 'P&S' or i.lid is null) <!--- don't display paid and shipped --->--->
				<!--- a.listingtype =  '1' <!---only fixed price items --->--->

		</cfquery>


	<cfif getInternalSKu.RecordCount gte 1>
			<cfquery name="get_InstaItemCount" datasource="#request.dsn#">
						SELECT items.item
								,items.aid
								,items.cid
						      ,items.title
						      ,items.description
						      ,items.make
						      ,items.model
						      ,items.value
						      ,items.age
						      ,items.ebaytitle
						      ,items.ebaydesc
						      ,items.status
						      ,items.ebayitem
						      ,items.shipper
						      ,items.tracking
						      ,items.invoicenum
						      ,items.weight
						      ,items.commission
						      ,items.dcreated
						      ,items.dreceived
						      ,items.listcount
						      ,items.dinvoiced
						      ,items.offebay
						      ,items.shipped
						      ,items.paid
						      ,items.PaidTime
						      ,items.ShippedTime
						      ,items.shipnote
						      ,items.ShipCharge
						      ,items.byrName
						      ,items.byrStreet1
						      ,items.byrStreet2
						      ,items.byrCityName
						      ,items.byrStateOrProvince
						      ,items.byrCountry
						      ,items.byrPhone
						      ,items.byrPostalCode
						      ,items.byrCompanyName
						      ,items.byrOrderQtyToShip
						      ,items.startprice
						      ,items.dcalled
						      ,items.bold
						      ,items.border
						      ,items.highlight
						      ,items.vehicle
						      ,items.drefund
						      ,items.refundpr
						      ,items.lid
						      ,items.lid2
						      ,items.dlid
						      ,items.startprice_real
						      ,items.buy_it_now
						      ,items.dpacked
						      ,items.dpictured
						      ,items.who_created
						      ,items.exception
						      ,items.purchase_price
						      ,items.multiple
						      ,items.pos
						      ,items.aid_checkout_complete
						      ,items.combined
						      ,items.width
						      ,items.height
						      ,items.depth
						      ,items.weight_oz
						      ,items.label_printed
						      ,items.internal_itemSKU
						      ,items.internal_itemCondition
						      ,items.itemManual
						      ,items.itemComplete
						      ,items.itemTested
						      ,items.retailPackingIncluded
						      ,items.specialNotes
						      ,items.internalShipToLocations
						      ,status.status as istatus
						  FROM items
						  left JOIN status ON status.id = items.status
						  where
						  (
						  	items.internal_itemSKU = '#getInternalSKu.internal_itemSKU#'
						  )
						   and (items.internal_itemCondition != 'amazon' and items.internal_itemCondition != 'AS-IS'and items.internal_itemCondition != 'New with Defect')

<!---						  and (items.status = '3' or items.status='8')<!--- 3 = item received --->
						  AND items.paid != '1'--->
						  and items.offebay = '0'
						   and (items.status != 11 and items.status != 4 and items.status != 5 and items.status != 10 and items.status != 16 and items.status != 14)
						   and (items.item not like '%.11048.%' and items.item not like '%.11108.%') <!--- old account --->
						order by items.status desc, items.dcreated asc
						</cfquery>

			<cfif get_InstaItemCount.RecordCount gte 1>
				<form action="index.cfm?dsp=management.items.active_fixedList&item=#attributes.item#" method="post">
					<table bgcolor="##aaaaaa" border=0 width="100%" cellpadding="5" cellspacing="5">
						<tr>
							<td>Item</td>
							<td>Title</td>
							<td>SKU</td>
							<td>Condition</td>
							<td>Status</td>
							<td>LID</td>
							<td><input type="button" id="Togglebutton" value="All"></td>
						</tr>
					<cfloop query="get_InstaItemCount" >
						<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('E7E6F2'))#">
							<td><a href="index.cfm?dsp=management.items.edit&item=#get_InstaItemCount.item#">#get_InstaItemCount.item#</a></td>
							<td>#get_InstaItemCount.title#</td>
							<td>#get_InstaItemCount.internal_itemSKU#</td>
							<td>#get_InstaItemCount.internal_itemCondition#</td>
							<td>#get_InstaItemCount.istatus#</td>
							<td>#get_InstaItemCount.lid#</td>
							<td>  <INPUT Type="Checkbox" name="item_#get_InstaItemCount.item#" class="checkBoxes" Value="#get_InstaItemCount.item#"></td>
						</tr>
					</cfloop>
					<tr><td>
						<strong>#get_InstaItemCount.RecordCount# Records</strong>
					</td></tr>
					</table>

					<div style="text-align:center">
						<input type="hidden" name="submitted"  value="submitted">
						<input type="hidden" name="d_item" value="#attributes.item#">
						<input type="submit" name="btnsubmit" value="Change All to Fixed Inventory">
					</div>
				</form>

			<cfelse>
				<h3>Nothing found.</h3>
			</cfif>

	<cfelse>
		<h3>no match found.</h3>
	</cfif>


<br><br>

<A HREF="javascript:history.go(-1)">Go Back</a>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script type="text/javascript">



		//checkall
		$(function () {

            $('##Togglebutton').click(function() {
                    $('.checkBoxes').each(function() {
                        $(this).attr('checked',!$(this).attr('checked'));
                    });
            });

		});



</script>


</cfoutput>