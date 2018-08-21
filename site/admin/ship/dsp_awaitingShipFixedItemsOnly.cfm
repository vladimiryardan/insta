<cfif ((attributes.dsp EQ "") AND NOT isGroupMemberAllowed("Listings")) OR NOT isAllowed("Lister_MarkRefundItems")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="13">

<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.local_buyers" default="0">
<cfparam name="attributes.lid_filter" default="notshipped">

<cfparam name="attributes.searchTerm" default="">
<cfparam name="session.combined" default="">


<cfif isdefined("attributes.btnSave")>
	<cfoutput>
	<cfloop item="fname" collection="#attributes#">
	<cfif left(fname,5) is "SKU2_">
		<!---<cfoutput>name:#fname# - val:#attributes[fname]#<br></cfoutput>--->
			<CFSET dItemid = RemoveChars(fname, 1, 5)>
			<CFSET dSkuVal = #attributes[fname]#>
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET
				internal_itemSKU2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dSkuVal#">
				where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dItemid#">
			</cfquery>
	</cfif>
	</cfloop>
	</cfoutput>

</cfif>


<cfif isDefined("attributes.combined_del")>
	<cfif ListFind(session.combined, attributes.combined_del)>
		<cfset session.combined = ListDeleteAt(session.combined, ListFind(session.combined, attributes.combined_del))>
	</cfif>
</cfif>
	

<cfif isdefined("attributes.btnCombined")>
	<cfif isDefined("attributes.combined_add")>
		<cfloop index="i" list="#attributes.combined_add#">
			<cfif NOT ListFind(session.combined, i)>
				<cfset session.combined = ListAppend(session.combined, i)>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<!--- get the fixed price items that are ready for tracking generation --->
<cfquery name="get_History" datasource="#request.dsn#" >
	SELECT distinct
	ebtransactions.itmItemID,
	ebtransactions.PaidTime,
	ebtransactions.byrName,
	ebtransactions.salesRecord,
	ebtransactions.itmQuantitySold,
	ebtransactions.itmSKU,
	ebtransactions.TransactionID,
	ebtransactions.TransactionID,
	ebtransactions.byrCountryName,
	items.item,
	items.internal_itemSKU2,
	items.lid,
	items.ebayitem,
	items.PaidTime,
	items.ShippedTime,	
	items.byrStateOrProvince,
	items.byrCityName,
	
	
	ebitems.title,
	ebitems.galleryurl
	FROM   ebtransactions
	INNER JOIN items ON ebtransactions.itmItemID = items.parentEbayItemFixed AND ebtransactions.TransactionID = items.ebayTxnid
		INNER JOIN ebitems ON ebitems.ebayitem = ebtransactions.itmItemID
	where ebtransactions.paidtime > <cfqueryparam cfsqltype="cf_sql_date" value="#dateadd('d',-30,now())#"> <!--- lets do a filter of 1 week for faster query result --->
	and (items.shippedtime is null or shipped = 0)
	and ebtransactions.itmQuantitySold = 1
	<!---and (items.lid != 'p&s' or items.lid is null)--->
	<cfif attributes.searchTerm neq "">
		and (
		items.item like '%#trim(attributes.searchTerm)#%'
		or items.title like '%#trim(attributes.searchTerm)#%'
		or items.ebayitem like '%#trim(attributes.searchTerm)#%'
		or items.internal_itemSKU like '%#trim(attributes.searchTerm)#%'
		or items.internal_itemSKU2 like '%#trim(attributes.searchTerm)#%'
		)
	</cfif>
	order by items.lid,ebtransactions.PaidTime desc
</cfquery>




<cfoutput>



<!--- get items which are linked --->
<table border="1" cellspacing="0" cellpadding="4" align="center" width="100%">
	<tr>

	<td colspan="13">
		<div style="float:right;clear:both">
			<form action="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly" id="srchFrm" method="post">

				<input type="text" name="searchTerm" id="searchTerm" value="#attributes.searchTerm#">
				<input type="button" name="SearchTitleOrId" id="SearchTitleOrId" value="Search">
				<a href="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly" >Refresh</a>
			</form>
		</div>

		</td>
	</tr>


	
		
	<cfif session.combined NEQ "" >
		<cfquery name="sqlCombinedList" datasource="#request.dsn#">
			SELECT item, title
			FROM items
			WHERE item IN(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.combined#" list="yes">)
		</cfquery>
		<cfoutput>
		<tr>
			<td colspan="13">
            	
            	<table cellpadding="3" cellspacing="1" border="0"
            	       width="100%" id="comlist" >
            		<tr>
            			<th colspan="3" >
            				Items selected for combined shipment
            			</th>
            		</tr>
            		<cfloop query="sqlCombinedList" >
            			<tr>
            				<td>
            					<a href="index.cfm?dsp=management.items.edit&item=#item#" >
            						#item#
            					</a>
            				</td>
            				<td>
            					#title#
            				</td>
            				<td>
            					<a href="#_machine.self#&combined_del=#item#" >
            						Remove from list
            					</a>
            				</td>
            			</tr>
            		</cfloop>
            		<tr>
            			<th colspan="3" >
            				<a href="index.cfm?dsp=admin.ship.confirm_multilabel" >
            					Click to create combined label
            				</a>
            			</th>
            		</tr>
            	</table>	
	
			</td>
		</tr>
		</cfoutput>
	</cfif>
		
	<tr>
		<td colspan="13" align="center">
		<h3>Fixed Price Items Ready to be shipped </h3>
		<em style="color:red;">Note: Same row colors have the same buyer!</em>
		</td>
	</tr>
	<cfif get_History.RecordCount gte 1>


		<tr>
			<td>&nbsp;</td>
			<td>Item</td>
			<td>LID</td>
			<td>Ebay item</td>
			<td>SKU</td>
			<td>SKU2</td>
			<td>High Bidder</td>
			<td>Qty</td>
			<td>PaidTime</td>
			<td width="20px">Shipped<br>Time</td>
			<td>Create<br>label</td>
			<td>Note</td>
			<td>Combine</td>
		</tr>


		<form method="post" action="index.cfm?dsp=admin.ship.awaitingShipFixedItemsOnly">
		<cfloop query="get_History">
			<cfset className = "#get_History.byrName#">
			<cfset className = replace(className, " ","")>
			<cfset className = #left(stringToHex((className)),6)# >
			
			<cfquery name="getShipNote" datasource="#request.dsn#" >
				select shipnote
				from items
				where item = '#get_History.item#'
			</cfquery>
			<!--- check byrname is more than 1 --->
			<cfquery name="chkByrname" dbtype="query">
				select * from get_History
				where byrname = '#get_History.byrName#'
			</cfquery>

			<tr class="className" <cfif chkByrname.RecordCount gt 1>style="background-color:###className#"</cfif>>
				<td>
				<!---<cfif get_History.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
					<a href="#get_History.galleryurl#" target="_blank"><img src="#get_History.galleryurl#" width=80 border=1>
				</cfif>--->

					<!--- image --->
				<cfif get_History.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
				<cftry>
						
						<cfhttp method="head" url="#replaceNoCase(get_History.galleryurl,"https","http")#" result="sc">
						<cfif sc.statuscode is "200 OK">
							<a href="#get_History.galleryurl#" target="_blank"><img src="#get_History.galleryurl#" border="1" width="80"></a>
						<cfelse>
							<!--- use_pictures --->
							<cfset get_History.galleryurl = replace(get_History.galleryurl,get_History.item,get_History.use_pictures)>
							<a href="#get_History.galleryurl#" target="_blank"><img src="#get_History.galleryurl#" border="1" width="80"></a>
						</cfif>
				<cfcatch>
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				</cfcatch>
				</cftry>
				</cfif>


				</td>
				
				<td><a href="index.cfm?dsp=management.items.edit&item=#get_History.item#" target="_blank">#get_History.item#</a>
					<br>
					#get_History.ebayitem#
					<br>
					SR: <a target="_blank" href="http://k2b-bulk.ebay.com/ws/eBayISAPI.dll?EditSalesRecord&transid=#get_History.TransactionID#&itemid=#get_History.itmItemID#">#get_History.salesrecord#</a>

				</td>
				<!---lid --->
				<td>
					&nbsp;#get_History.lid#
				</td>
				<!---title --->
				<td>
				#get_History.title#
				</td>
				
				<!---sku --->
				<td>#get_History.itmSKU#</td>
				
				<!---sku2 --->
				<td>
					<input type="text" name="sku2_#get_History.item#" value="#get_History.internal_itemSKU2#" maxlength="70">
					<cfif #get_History.internal_itemSKU2# neq "">
						<br>#get_History.internal_itemSKU2#
					</cfif>
				</td>
				<!---byr --->
				<td class="byrname">
					#get_History.byrName#<br> 	
						----------<br>									
						#get_History.byrCityName#<br>
						#get_History.byrStateOrProvince#<br>
						#get_History.byrCountryName#
				</td>
				<td>#get_History.itmQuantitySold#</td>
				<td>#dateformat(get_History.PaidTime,"medium" )#</td>
				<td>&nbsp;#dateformat(get_History.ShippedTime,"medium")#</td>
				<td><a href="index.cfm?act=admin.ship.generate_label&item=#get_History.item#"><img src="#request.images_path#icon13.gif" border="0" alt="Generate Tracking" title="Generate Tracking"></a></td>
				<td width="70%" align="left"><cfif isAllowed("Listings_EditShippingNote")>
					<a href="javascript: fShipNote('#get_History.item#')"><cfif getShipNote.shipnote EQ "">
					<img src="#request.images_path#icon14.gif" border=0><cfelse>Edit</cfif></a><cfelse><cfif getShipNote.shipnote EQ "">N/A<cfelse>
						<a href="javascript: fShipNote('#get_History.item#')">View</a></cfif></cfif> #getShipNote.shipnote#
				</td>
				<td>
					 <input type="checkbox" name="combined_add" value="#get_History.item#">
				</td>
			</tr>
		</cfloop>
			<tr>
				<td colspan="12" align="center">
					#get_History.recordcount# Records found.
				</td>
			</tr>

			<tr>
				<td colspan="12" align="center">
					<input type="submit" name="btnSave" value="Save">
					<input type="submit" name="btnCombined" value="Move checked to Combined Shipment List" >	
					<input type="hidden" name="isSubmitted" value="1">
				</td>
			</tr>
		</form>



	<cfelse>
		<tr>
			<td  colspan="4" align="left">
				No Records Found
			</td>
		</tr>
	</cfif>
</table>
<br><br>


<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
<!--//

	$(function(){
			$('##SearchTitleOrId').click(function(){

			var $searchTerm = $('##searchTerm').val();

			if($searchTerm == ""){
				alert('Please enter search Term');
			}else{
				window.location.href = "#_machine.self#&searchTerm="+$searchTerm;
			}
			});

			$('##searchTerm').keypress(function(e){
				if(e.which == 13){
					$('##srchFrm').submit();
				}
			});




		$('##searchTerm').focus();
	});//doc ready
//-->

function fShipNote(itemid){
	ShipNoteWin = window.open("index.cfm?dsp=admin.ship.note&itemid="+itemid, "ShipNoteWin", "height=300,width=600,location=no,scrollbar=yes,menubar=yes,toolbars=yes,resizable=yes");
	ShipNoteWin.opener = self;
	ShipNoteWin.focus();
}

</script>

<cfscript>
/**
* Counterpart to HexToString - converts an ASCII string to hexadecimal.
*
* @param str      String to convert to hex. (Required)
* @return Returns a string.
* @author Chris Dary (umbrae@gmail.com)
* @version 1, May 8, 2006
*/
function stringToHex(str) {
    var hex = "";
    var i = 0;
    for(i=1;i lte len(str);i=i+1) {
        hex = hex & right("0" & formatBaseN(asc(mid(str,i,1)),16),2);
    }
    return hex;
}
</cfscript>

</cfoutput>