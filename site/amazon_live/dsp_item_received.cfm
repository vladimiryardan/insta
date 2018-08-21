<!---
created: 20110805
author: vladimiryardan@gmail.com
description: this list items paid and shipped and item condition = amazon

--->
 <cfif NOT isGroupMemberAllowed("Listings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.store" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.sku" default="">
<cfparam name="attributes.istatus" default="3"><!--- default to item received --->
<cfquery name="sqlStores" datasource="#request.dsn#">
	SELECT DISTINCT store FROM accounts
</cfquery>



<cfoutput>
		<cfif isdefined("attributes.submitNew")>
				<cfloop index="i" list="#attributes.itemsList#" DELIMITERS="," >
						<cfquery datasource="#request.dsn#">
							update items
							set internal_itemCondition = <cfqueryparam cfsqltype="cf_sql_varchar" value="New">
							where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
				</cfloop>
		</cfif>
		
		<cfif isdefined("attributes.submitNewOther")>
				<cfloop index="i" list="#attributes.itemsList#" DELIMITERS="," >
						<cfquery datasource="#request.dsn#">
							update items
							set internal_itemCondition = <cfqueryparam cfsqltype="cf_sql_varchar" value="New (Other) Opened">
							where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
				</cfloop>				
		</cfif>	
</cfoutput>


<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&srch=#attributes.srch#&istatus=#attributes.istatus#&store=#attributes.store#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&srch=#attributes.srch#&istatus=#attributes.istatus#&store=#attributes.store#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
}
function fStore(store){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&store="+store;
}
function fStatus(status){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&istatus="+status;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Amazon Item Received:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<!---<cfif isAllowed("EndOfDay_Shipments")>
	<b>Print Daily Report For:</b>
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.ship.daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>--->
	</td></tr></table>
<br><br>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>Enter Search Term (title, number, buyer name):</td>
		<td width="300" rowspan="2"><!---<a href="index.cfm?dsp=management.paid_shipped&xls=emails">GATHER EMAILS</a>---></td>
		<td width="100">Status:</td>
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
			<select name="newstatusid" onChange="fStatus(this.value)">
			<cfquery name="sqlStatus" datasource="#request.dsn#">
				SELECT id, status FROM status ORDER BY id ASC
			</cfquery>
			<cfloop query="sqlStatus">
				<cfif isAllowed("Items_ChangeStatus") OR ListFind("2,3,9,12", sqlStatus.id)>
					<option value="#sqlStatus.id#"<cfif sqlStatus.id EQ attributes.istatus> selected</cfif>>#sqlStatus.status#</option>
				</cfif>
			</cfloop>
			</select>
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
	<form id="myform" action="index.cfm?dsp=amazon_live.item_received&sku=#attributes.sku#" method="post">
			<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
			<tr><td>
				<form id="myform" action="index.cfm?dsp=amazon_live.amazon_skucount&sku=#attributes.sku#" method="post">
				<table width="100%" cellspacing="1" cellpadding="4">
				<tr bgcolor="##F0F1F3">
					<td class="ColHead"><input type="checkbox" name="chkAll" id="chkAll" value="All" onclick='checkedAll();'></td>
					<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
					<td class="ColHead"><a href="JavaScript: void fSort(2);">LID</a></td>
					<td class="ColHead"><a href="JavaScript: void fSort(3);">Date LID</a></td>
					<td class="ColHead"><a href="JavaScript: void fSort(4);">Title</a></td>
					<td class="ColHead"><a href="JavaScript: void fSort(5);">SKU</a></td>
					<td class="ColHead"><a href="JavaScript: void fSort(6);">Paid</a></td>
				</tr>
				</cfoutput>
				<cfquery name="sqlTemp" datasource="#request.dsn#">
					SELECT i.item, i.lid, i.dlid, i.title,  i.internal_itemSKU, i.PaidTime, i.ShippedTime, i.shipper, i.tracking, i.byrName, i.ebayitem
					,i.id
					FROM items i
					WHERE i.status = '#attributes.istatus#'<!--- item received --->
					and i.internal_itemCondition = 'amazon'
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
				<cfoutput query="sqlTemp" <!---maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#"--->>
				 <tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('eaeaea'))#">
				 	<td><input type="checkbox" name="itemsList" value="#sqltemp.item#"</td>
					<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
					<td>#sqlTemp.lid#</td>
					<td>#dateformat(sqlTemp.dlid,"yyyy-mmm-dd")#</td>
					<td>#sqlTemp.title#</td>
					<td>#sqlTemp.internal_itemSKU#</td>
					<td align="left">#DateFormat(sqlTemp.PaidTime)#</td>
		
				</tr>
				
	
				
		</cfoutput>
		
<cfoutput>
	
			<tr>
				<td colspan="9" align="center">
				<input type="submit" name="submitNew" value="Change Conditon to NEW">
				<input type="submit" name="submitNewOther" value="Change Condition to New (Other) Opened">
				</td>
			</tr>	
		</table>	
		</form>	
</cfoutput>	
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		
	</td></tr>
	</table>
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
