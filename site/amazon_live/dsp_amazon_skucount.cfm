<!---
created: 20110805
author: vladimiryardan@gmail.com
description: this list items paid and shipped and item condition = amazon

--->
 <cfif NOT isGroupMemberAllowed("Listings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.xls" default="">


<cfoutput>
		<cfif isdefined("attributes.submitted")>
				<cfloop index="i" list="#attributes.FieldNames#" DELIMITERS="," >
					<cfif LEFT(i, 5) is "ITEM_" >
						<CFSET itmID = RemoveChars(i, 1, 5)>
						<cfquery datasource="#request.dsn#">
							update items
							set internal_itemCondition = <cfqueryparam cfsqltype="cf_sql_varchar" value="amazon">,
							status = <cfqueryparam cfsqltype="cf_sql_integer" value="3">
							where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#itmID#">
						</cfquery>
					</cfif>
				</cfloop>
		</cfif>
</cfoutput>



<cfparam name="attributes.orderby" default="5">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.sku" default="">
<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&sku=#URLEncodedFormat(attributes.sku)#&srch=#attributes.srch#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&sku=#URLEncodedFormat(attributes.sku)#&srch=#attributes.srch#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&sku=#URLEncodedFormat(attributes.sku)#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>SKU: #attributes.sku#</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
	</td></tr></table>
<br><br>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>Enter Search Term (title, number, buyer name):</td>
		<td width="300" rowspan="2"><!---<a href="index.cfm?dsp=management.paid_shipped&xls=emails">GATHER EMAILS</a>---></td>
		<td width="100">Store:</td>
	</tr>
	<tr>
		<td>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="18" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<input type="submit" value="Search Items">
			</form>
		</td>
		<td>
			<select name="store" onChange="fStore(this.value)">
				<option value="all"<cfif attributes.store EQ ""> selected</cfif>>All</option>
				<cfloop query="sqlStores">
				<option value="#sqlStores.store#"<cfif attributes.store EQ sqlStores.store> selected</cfif>>#sqlStores.store#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	</table>
	<br><br>
	<form id="myform" action="index.cfm?dsp=amazon_live.amazon_skucount&sku=#attributes.sku#" method="post">
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><input type="checkbox" name="chkAll" id="chkAll" value="All" onclick='checkedAll();'></td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
			<td class="ColHead">Track</td>
			<!---<td class="ColHead">Label</td>--->
			<td class="ColHead">LID</td>


			<td class="ColHead"><a href="JavaScript: void fSort(5);">SKU</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(9);">STATUS</a></td>
			<td class="ColHead">Condition</td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item, i.ebayitem, i.title, i.PaidTime, i.internal_itemSKU, i.shipper, i.tracking, i.byrName, 
			s.status as statusName,internal_itemCondition, 
			i.id, i.lid
			FROM items i
			left join status s ON i.status = s.id
			WHERE
			(i.item not like '%.11048.%' and i.item not like '%.11108.%') <!--- old account --->
			and (i.status = 8 or i.status = 3 or i.status = 16)
			and (i.internal_itemCondition != 'amazon')<!--- exclude amazon --->
			<cfif attributes.sku neq "">
				and i.internal_itemSKU = '#attributes.sku#'
			</cfif>
			<cfif attributes.store NEQ "all">
				AND i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.store#.%">
			</cfif>
			<cfif attributes.srch NEQ "">
				AND (
					i.title LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.ebayitem LIKE '%#attributes.srch#%'
					OR
					i.item LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.byrName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
					OR
					i.tracking LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
<!---					OR
					i.PaidTime LIKE #ParseDateTime("#attributes.srch#")#
					OR
					i.ShippedTime LIKE #ParseDateTime("#attributes.srch#")# --->
				)
			</cfif>
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>


		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('E7E6F2'))#">
			<td><input type="checkbox" name="item_#sqltemp.id#" value="#sqltemp.id#"</td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title#</td>
			<td>
				<cfif (sqlTemp.shipper EQ "UPS") AND (sqlTemp.tracking NEQ "")>
					<a href="http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#sqlTemp.tracking#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12" target="_blank">#sqlTemp.tracking#</a>
				<cfelseif (sqlTemp.shipper EQ "USPS") AND (sqlTemp.tracking NEQ "")>
					<a href="http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#sqlTemp.tracking#" target="_blank">#sqlTemp.tracking#</a>
				<cfelse>
					&nbsp;
				</cfif>
			</td>
			<!---<td align="center">
				<cfif (sqlTemp.shipper EQ "UPS") AND (sqlTemp.tracking NEQ "")>
					<a href="ups/label#sqlTemp.tracking#.html" target="_blank"><img src="#request.images_path#icon11.gif" border=0></a>
				<cfelseif (sqlTemp.shipper EQ "USPS") AND (sqlTemp.tracking NEQ "")>
					<a href="index.cfm?dsp=admin.ship.usps.print_label&itemid=#sqlTemp.item#" target="_blank"><img src="#request.images_path#icon11.gif" border=0></a>
				<cfelse>
					&nbsp;
				</cfif>
			</td>--->
			
			<td>#sqltemp.lid#</td>
			<td align="left">#sqlTemp.internal_itemSKU#</td>
			<td align="left">#sqlTemp.statusName#</td>
			<td align="left">#sqlTemp.internal_itemCondition#</td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr>
			<td colspan="9" align="center">
			<input type="submit" name="bthSubmit" value="Change All checked to Amazon Item condition & Status: Item Received">
			<input type="hidden" name="submitted"  value="submitted">
			</td>
		</tr>

		<tr bgcolor="##FFFFFF"><td colspan="9" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
	</form>
</td></tr>
</table>

<script language='JavaScript'>
checked = false;
function checkedAll () {
if (checked == false){checked = true}else{checked = false}
for (var i = 0; i < document.getElementById('myform').elements.length; i++) {
document.getElementById('myform').elements[i].checked = checked;
}
}
</script>

</cfoutput>
