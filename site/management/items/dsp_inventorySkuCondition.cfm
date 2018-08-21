<cfparam name="attributes.repday" default="#Now()#">
<cfparam name="attributes.internal_itemSKU" default="">
<cfparam name="attributes.internal_itemCondition" default="">
<cfparam name="attributes.itemStatus" default="">
<cfparam name="attributes.FixedPrice" default="">
<cfparam name="attributes.itemIDof" default="">

<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="dtstart">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
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
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Active Listings:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
<cfif isAllowed("EndOfDay_Listings")>
	<b>Print Daily Report For: </b>
	<a href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.listing_daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>
	</td></tr></table>
	<br><br>

	<center>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(4);">Start Time</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(5);">End Time</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(6);">Times Launched</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(7);">Price</a></td>
		</cfoutput>
	
	
		<cfif attributes.FixedPrice neq "">
		
			<!--- lets get the fixed price item--->
			<cfquery name="sqlTemp" datasource="#request.dsn#">		
				SELECT     i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice, i.internal_itemSKU, i.internal_itemCondition, i.status
				FROM         dbo.items AS i INNER JOIN
	      ebitems AS e ON i.ebayitem = e.ebayitem 
	      WHERE 
	      <!--- i.status = 4 
       	and i.internal_itemSKU = '#attributes.internal_itemSKU#' 
       	and i.internal_itemCondition = '#attributes.internal_itemCondition#'
       	and  ---> 
       	 i.item in (#PreserveSingleQuotes(attributes.itemIDof)#)                     
			</cfquery>			
			<!---<cfoutput><tr><td>#attributes.itemIDof#</td></tr></cfoutput>--->
		<cfelse>			
			<cfquery name="sqlTemp" datasource="#request.dsn#">			
				SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice
				FROM items i
					INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
				WHERE i.status = '#attributes.itemStatus#'
	       	and i.internal_itemSKU = '#attributes.internal_itemSKU#' 
	       	and i.internal_itemCondition = '#attributes.internal_itemCondition#'  
			</cfquery>
			
		</cfif>
		

			
	<!---	
		<cfif attributes.itemStatus eq 4>		
				<cfquery name="sqlTemp" datasource="#request.dsn#">			
					SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice
					FROM items i
						INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
					WHERE <cfif attributes.itemStatus neq"">i.status = 4<cfelse>i.status = #attributes.itemStatus#</cfif>
		       	and i.internal_itemSKU = '#attributes.internal_itemSKU#' 
		       	and i.internal_itemCondition = '#attributes.internal_itemCondition#'  
				</cfquery>
		<cfelseif attributes.itemStatus neq 4>
					<cfquery name="sqlTemp" datasource="#request.dsn#">			
						SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice
						FROM items i
							INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
						WHERE <cfif attributes.itemStatus neq"">i.status = 4<cfelse>i.status = #attributes.itemStatus#</cfif>
			       	and i.internal_itemSKU = '#attributes.internal_itemSKU#' 
			       	and i.internal_itemCondition = '#attributes.internal_itemCondition#'  
					</cfquery>
		<cfelse>
					<cfquery name="sqlTemp" datasource="#request.dsn#">			
						SELECT i.item AS itemid, i.ebayitem, e.title, e.dtstart, e.dtend, i.listcount, e.price AS finalprice
						FROM items i
							INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
						WHERE <cfif attributes.itemStatus neq"">i.status = 4<cfelse>i.status = #attributes.itemStatus#</cfif>
			       	and i.internal_itemSKU = '#attributes.internal_itemSKU#' 
			       	and i.internal_itemCondition = '#attributes.internal_itemCondition#'  
					</cfquery>
		</cfif>
	--->	
		
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.records&item=#sqlTemp.itemid#">#sqlTemp.itemid#</a>  </td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title#</td>
			<td>#strDate(sqlTemp.dtstart)#</td>
			<td>#strDate(sqlTemp.dtend)#</td>
			<td>#sqlTemp.listcount#</td>
			<td>$#sqlTemp.finalprice#</td>
		</tr>
		</cfoutput>
		<cfoutput>

		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
