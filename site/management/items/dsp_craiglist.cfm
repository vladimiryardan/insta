<cfif NOT isAllowed("Lister_ActiveListings")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="s.status">
<cfparam name="attributes.dir" default="asc">
<cfparam name="attributes.page" default="1">

<cfparam name="attributes.srch" default="">
<cfif isdefined("attributes.srch")>
	<cfset attributes.srch = trim(attributes.srch)>	
</cfif>

<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Craiglist:</strong></font><br>
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

		
        	<table width="100%">
			<tr>
				<td width="50%" align="left">
					Enter Search Term:<br>
					<form method="POST" action="#_machine.self#">
						<input type="text" size="20" maxlength="50" name="srch" value="#HTMLEditFormat(attributes.srch)#">
						<input type="submit" value="Search">
					</form>
				</td>
			</tr>
			</table><br><br>
        

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="1">
		<tr bgcolor="##F0F1F3">
		<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>

		<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(4);">Status</a></td>

		<td class="ColHead"><a href="JavaScript: void fSort(6);">Ebay<br>Times Launched</a></td>
		<td class="ColHead"><a href="JavaScript: void fSort(7);">Price</a></td>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.item AS itemid, i.ebayitem, i.title, s.status, e.dtend, i.listcount, e.price AS finalprice
			FROM items i
				left JOIN ebitems e ON i.ebayitem = e.ebayitem
				left JOIN status s ON i.status = s.id
			WHERE i.internal_itemCondition = 'craiglist'<!--- Auction Listed --->

			<cfif attributes.srch neq "">
				and
				(
					 i.item LIKE '#attributes.srch#%'
					OR i.description LIKE '#attributes.srch#%'
					OR i.ebayitem LIKE '#attributes.srch#%'
					OR i.byrName LIKE '#attributes.srch#%'
					OR i.byrCompanyName LIKE '#attributes.srch#%'
					OR i.internal_itemSKU LIKE '#attributes.srch#%'
					OR i.internal_itemSKU2 LIKE '#attributes.srch#%'
					OR i.title LIKE '#attributes.srch#%'
					OR i.lid LIKE '#attributes.srch#%'
					OR i.internal_itemSKU LIKE '#attributes.srch#%'
					OR i.internal_itemSKU2 LIKE '#attributes.srch#%'							

				)				
			</cfif>
						
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>

		
	

		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
		<cfset totalFinalPricePage = 0>

		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
			<cfquery datasource="#request.dsn#" name="sqlRecord">
				SELECT finalprice, dended
				FROM records
				WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.itemid#">
			</cfquery>
			<cftry>
            	<cfset totalFinalPricePage += sqlRecord.finalprice>
            <cfcatch type="Any" >
            </cfcatch>
            </cftry>


		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.records&item=#sqlTemp.itemid#">#sqlTemp.itemid#</a></td>
			<td>#sqlTemp.title#</td>
			<td>#sqlTemp.status#</td>
			<td>#sqlTemp.listcount#</td>
			<td>#dollarformat(sqlRecord.finalprice)#</td>
		</tr>

		</cfoutput>
		<cfoutput>
		<tr>
			<td colspan="4" align="right">Page Sum</td>
			<td>#dollarformat(totalFinalPricePage)#</td>
		</tr>
		<tr>
			<td colspan="4" align="right">Total Price</td>
			<td>


				<cfset theTotal = 0>
				<cfloop query="sqlTemp">
					<cfquery datasource="#request.dsn#" name="sqlRecord">
						SELECT finalprice, dended
						FROM records
						WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.itemid#">
					</cfquery>
					<cftry>
                    	<cfset theTotal += sqlRecord.finalprice>
                    <cfcatch type="Any" >
                    </cfcatch>
                    </cftry>
				</cfloop>
				#dollarformat(theTotal)#
			</td>
		</tr>

		<tr bgcolor="##FFFFFF"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
