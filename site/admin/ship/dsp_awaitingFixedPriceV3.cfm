<cfsetting requesttimeout="360">

<cfoutput>
	<style>
	tr.rowOdd {background-color: ##FFFFFF;}
	tr.rowEven {background-color: ##E7E7E7;}
	tr.rowHighlight {background-color: ##FFFF99;}
	.itemHide{display:none;}
	</style>
</cfoutput>

<cfif ((attributes.dsp EQ "") AND NOT isGroupMemberAllowed("Listings")) OR NOT isAllowed("Lister_MarkRefundItems")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>




<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.local_buyers" default="0">
<cfparam name="attributes.filter_lid" default="notshipped">
<cfparam name="attributes.filter_date" default="7">
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="desc">

<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&filter_date=#attributes.filter_date#&filter_lid=#attributes.filter_lid#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&filter_date=#attributes.filter_date#&filter_lid=#attributes.filter_lid#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&page=1&store="+store;
}

//-->
</script>
<style type="text/css">
##comlist{background-color:##AAAAAA;}
##comlist th{background-color:##F0F1F3; font-weight:bold; text-align:center;}
##comlist td{background-color:white;}
##comlist th a, ##comlist th a:visited{color:red;}
##comlist th a:hover{color:green;}
</style>


<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>#attributes.pageTitle#</strong></font><br>
	<strong>Note:</strong> Items listed are fixed price items.
	<br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<a href="##" id="showHidden">show hidden</a>

<div style="float:right">
<strong>Filter:</strong>
<select id="filter_date">
    <option value="7" <cfif attributes.filter_date is "7">selected</cfif> >7 days</option>
	<option value="30" <cfif attributes.filter_date is "30">selected</cfif> >30 days</option>
	<option value="60" <cfif attributes.filter_date is "60">selected</cfif> >60 days</option>
	<option value="365" <cfif attributes.filter_date is "365">selected</cfif> >365 days</option>
</select>
<select id="filter_lid">
    <option value="paidshipped" <cfif attributes.filter_lid is "paidshipped">selected</cfif> >P&S</option>
	<option value="notshipped" <cfif attributes.filter_lid is "notshipped">selected</cfif> >not shipped</option>
</select>

</div>
<br><br>
<!---<a href="index.cfm?dsp=admin.ship.shipping_listFixedPrice&lid_filter=#attributes.lid_filter#" target="_blank">Print Shipping List</a><br><br>--->
</cfoutput>









<!--- get the items which are fixed price --->
		<cfquery name="sqlTemp" datasource="#request.dsn#" >
				SET ANSI_WARNINGS OFF<!--- 20120202: we must include this coz if there are no records returned it will err and says that the sqlTemp is undefined --->
				SELECT
				e1.itmItemID,
				ebitems.title AS etitle,

				e1.byrName as hbuserid,
				e1.paidtime,
				e1.amountpaid as price,
				e1.itmQuantitySold,
				e1.ShippedTime,
				e1.*,
				ebitems.galleryurl,



				e1.BYRCOUNTRY,
				e1.itmitemid as ebayitem,
				e1.byrEmail,
				auctions.itemqty,
				eb2.galleryurl as galleryurl2,
				u.use_pictures
				from ebtransactions e1 inner join
				(
					SELECT itmItemID, MAX(ShippedTime) AS ShippedTime, MAX(PaidTime) AS PaidTime, MAX(transactionid) AS transactionid, max(tid) as tid2, max(salesrecord) as salesrecord2
					FROM ebtransactions
					WHERE (ListingType = 'FixedPriceItem' or  ListingType = 'StoresFixedPrice')
					and  stsCheckoutStatus  = 'CheckoutComplete'
					and PaidTime IS NOT NULL
					<!---and itmitemid = '150716001270'--->
					GROUP BY itmItemID, paidtime, salesrecord<!--- grouping by itemid, paidtime and salesrecord. 20120424 has an issue that some sales don't appear in the awaiting linking of fixed price items. this is the fix --->
					<!---order by itmItemID,tid desc--->

				) e2 on e2.tid2 = e1.tid
				inner JOIN ebitems ON e2.itmItemID = ebitems.ebayitem
				left join auctions on e1.itmSKU = auctions.itemid
				left join ebitems eb2 on eb2.ebayitem = e2.itmItemID
				LEFT JOIN auctions u ON e1.itmsku = u.itemid

				where 1=1
				and e1.paidtime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd("d","-#attributes.filter_date#",now())#">

				<cfswitch expression="#attributes.filter_lid#" >
					<cfcase value="paidshipped" >
						and e1.ShippedTime is not null
					</cfcase>
					<cfcase value="notshipped" >
						and e1.ShippedTime is null
						<!--- check to see if item is linked itmItemID and TransactionID--->
						and not exists ( select item,status	from items where parentEbayItemFixed = e1.itmItemID and ebayTxnid = e1.TransactionID )
					</cfcase>
					<cfdefaultcase>
						and 1=1
					</cfdefaultcase>
				</cfswitch>



				<!---order by e1.PaidTime desc--->
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>

<cfdump var="#sqlTemp#">

<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<!---<cfset _paging.RecordCount = 0>--->


<cfoutput>
	<table bgcolor="##aaaaaa" border=1 cellspacing="0" cellpadding="4" width="100%" >

		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Image</td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">eBay Number</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Title</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">High Bidder</a> / <a href="JavaScript: void fSort(4);">Paid Time</a></td>
			<td class="ColHead" ><a href="JavaScript: void fSort(5);">Price</a></td>
			<td class="ColHead" ><a href="JavaScript: void fSort(6);">Qty</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Shipped Time</a></td>
			<td class="ColHead">Link</td>

		</tr>
</cfoutput>
	<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">

		<!---#sqlTemp.itmItemID# - #sqlTemp.salesrecord# <br>---><!--- uncomment this to show items that doesn't show up in the list --->


		<!--- do a query here to check if the item is linked already and the count is equal --->
		<cfquery datasource="#request.dsn#" name="get_linkeditems" >
			select item,status
			from items
			where parentEbayItemFixed = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlTemp.itmItemID#">
			and ebayTxnid = <cfqueryparam cfsqltype="varchar" value="#sqltemp.TransactionID#">
		</cfquery>

		<!--- we don't want to display fixed price items that are being sold with a qty of 1 --->
		<cfset varDontDisplay = false>
		<cfif attributes.filter_lid is "paidshipped">
			<cfset varDontDisplay = false >
			<!---<cfset _paging.RecordCount-->---><!--- subtract display count --->
		<cfelse>

			<cfif get_linkeditems.RecordCount gte sqlTemp.itmQuantitySold and attributes.filter_lid is "notshipped" or #sqlTemp.itemqty# eq 1 >
				<cfset varDontDisplay = true>
				<!---<cfset _paging.RecordCount-->---><!--- subtract display count --->
			<cfelse>
				<cfset varDontDisplay = false>
			</cfif>
		</cfif>

<!---
	get_linkeditems.RecordCount: #get_linkeditems.RecordCount#<br>
#sqlTemp.itmQuantitySold#<br>
<cfset varDontDisplay = false>
--->


			<tr  class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))# <cfif varDontDisplay>itemHide rowHidden</cfif>" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif> >
			<td align=center>

				<!---<cfif sqlTemp.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
					<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" width=80 border=1>
				</cfif>--->

				<!--- image --->
					<!---[#sqlTemp.galleryurl2#][#sqlTemp.use_pictures#]--->
				<cfif sqlTemp.galleryurl2 EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
				<cftry>
						<cfhttp method="head" url="#sqlTemp.galleryurl2#" result="sc">
						<cfif sc.statuscode is "200 OK">
							<a href="#sqlTemp.galleryurl2#" target="_blank"><img src="#sqlTemp.galleryurl2#" border="1" width="80"></a>
						<cfelse>
							<!--- use_pictures --->
							<cfset sqlTemp.galleryurl2 = replace(sqlTemp.galleryurl2,sqlTemp.itmsku,sqlTemp.use_pictures)>
							<a href="#sqlTemp.galleryurl2#" target="_blank"><img src="#sqlTemp.galleryurl2#" border="1" width="80"></a>
						</cfif>

				<cfcatch>
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				</cfcatch>
				</cftry>
				</cfif>
			</td>

			<!--- lid --->
			<td width="150">
				<strong>SKU:</strong> #sqlTemp.itmSKU#<br>
				<strong>SR:</strong> #sqlTemp.salesRecord#<br>
				<strong>TID:</strong> #sqlTemp.TransactionID#<br>
				<a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a>&nbsp;
			</td>

			<!--- ebay title --->
			<td align=left>
			#sqlTemp.etitle#<br><br>
			Buyer: <strong style="color:##3064CA">#sqltemp.byrEmail#</strong><br>
			</td>
			<td align="center">
				#DateFormat(sqlTemp.PaidTime,"medium" )#<br>
				#sqlTemp.hbuserid#<br>


				<cfif Trim(sqlTemp.byrCountry) NEQ ""> (#sqlTemp.byrCountry#)<br></cfif>
				<td align=center>$#sqlTemp.price#</td>
			</td>
			<td align="center" <cfif sqlTemp.itmQuantitySold gt 1>style="background-color:##3165CB"</cfif> >#sqlTemp.itmQuantitySold#</td>
			<td align="center">#sqlTemp.ShippedTime#</td>
			<td align="center">

					<button type="button" value="Link" onclick="location.href='index.cfm?dsp=admin.ship.link_to_itemMultiV2&tid=#sqlTemp.tid#'" <cfif sqlTemp.itmQuantitySold gt 1>style="background-color:##3165CB"</cfif>>
						Link & Details
					</button>

			</td>




		</tr>

		<!---
		<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'"<cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif>>
			<td colspan="8">
				<cfif sqlTemp.shipnote NEQ "">
					<b>Note: </b>#sqlTemp.shipnote#
				<cfelse>
					&nbsp;
				</cfif>
			</td>
		</tr>--->
	</cfoutput><!--- this cfoutput loops. closing table is in another loop --->

<cfoutput>
<tr>
	<td colspan="8">
		<cfinclude template="../../../paging.cfm">
	</td>
</tr>
</table>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script>
    $(function(){
      // bind change event to select
      $('##filter_date').change(function () {
          var filter_date = $(this).val(); // get selected value
          var filter_lid = $('##filter_lid').val(); // get selected value

          if (filter_date) { // require a URL
              window.location.href = "#request.base#index.cfm?dsp=admin.ship.awaitingFixedPriceV2&filter_date=" + filter_date + "&filter_lid="+filter_lid;
          }
          return false;
      });
	  // bind change event to select
      $('##filter_lid').change(function () {
          var filter_date = $('##filter_date').val(); // get selected value
          var filter_lid = $(this).val(); // get selected value
          if (filter_date) { // require a URL
              window.location.href = "#request.base#index.cfm?dsp=admin.ship.awaitingFixedPriceV2&filter_date=" + filter_date + "&filter_lid="+filter_lid;
          }
          return false;
      });

		$('##showHidden').toggle(
			function(){
				$('.rowHidden').show();
			},function(){
				$('.rowHidden').hide();
			}
		);
    });//doc ready
</script>
</cfoutput>
