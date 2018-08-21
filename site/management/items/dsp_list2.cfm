<cfif NOT isAllowed("Invoices_InvoiceItems")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.account" default="0">



<cfoutput>
	<cfif isdefined("attributes.SUBMITTED")>
		<cfloop list="#attributes.item_checked#" index="i">
			<cfquery datasource="#request.dsn#">
				delete from items
				where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
			</cfquery>
		</cfloop>
	</cfif>
</cfoutput>

<cfquery name="sqlAccount" datasource="#request.dsn#">
	SELECT id, first, last, store
	FROM accounts
	WHERE id = '#attributes.account#'
</cfquery>
<cfparam name="attributes.filter" default="all">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.orderby" default="9">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">

<cfset attributes.srch = trim(attributes.srch) >

<cfoutput>
	<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
	<script language="javascript" type="text/javascript">



		<!--//
		function confirmSubmit(){
			var count = 0;
			var count = $("[name='item_checked']:checked").length;
			var agree=confirm("you are getting ready to delete these items?" +count + " items to be deleted");
			if (agree)
				return true ;
			else
				return false ;
		}
		function fDNS2RTC(){
			if(confirm("Are you sure to mark EVERY item with status 'Need to Call' or 'Did Not Sell' or 'Need to Relot' as 'Returned to Client' for this user?")){
				window.location.href = "index.cfm?act=management.items.dns2rtc&account=#attributes.account#";
			}
		}
		function fDNS2NTD(){
			if(confirm("Are you sure to mark EVERY item with status 'Need to Call' or 'Did Not Sell' or 'Need to Relot' as 'Need to Donate' for this user?")){
				window.location.href = "index.cfm?act=management.items.dns2ntd&account=#attributes.account#";
			}
		}
		function fPage(Page){
			window.location.href = "#_machine.self#&srch=#attributes.srch#&filter=#attributes.filter#&account=#attributes.account#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
		}
		function fSort(OrderBy){
			if (#attributes.orderby# == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&srch=#attributes.srch#&filter=#attributes.filter#&account=#attributes.account#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
		}
		function fFilter(filter){
			window.location.href = "#_machine.self#&srch=#attributes.srch#&account=#attributes.account#&orderby=#attributes.orderby#&dir=#attributes.dir#&page=1&filter="+filter;
		}

		function toggleChecked(status) {
		$(".checkT").each( function() {
		$(this).attr("checked",status);
		})
		}

		//-->
	</script>
	<table width="90%" align="center">
		<tr>
			<td align="left">
				<strong>
					Account ID:
				</strong>
				<a href="index.cfm?dsp=account.edit&id=#sqlAccount.id#">
					#sqlAccount.id#
				</a>
			</td>
			<td align="center">
				<strong>
					Filter:
				</strong>
				<select name="filter" onchange="fFilter(this.value)">
					<option value="all"<cfif attributes.filter EQ "all"> selected</cfif>>All</option>
					<option value="itemscreated"<cfif attributes.filter EQ "itemscreated"> selected</cfif>>Items Created</option>
					<option value="itemsreceived"<cfif attributes.filter EQ "itemsreceived"> selected</cfif>>Items Received</option>
					<option value="active"<cfif attributes.filter EQ "active"> selected</cfif>>Auctions Listed</option>
					<option value="awaitingpayment"<cfif attributes.filter EQ "awaitingpayment"> selected</cfif>>Awaiting Payment</option>
					<option value="awaitingshipment"<cfif attributes.filter EQ "awaitingshipment"> selected</cfif>>Awaiting Shipment</option>
					<option value="paidandshipped"<cfif attributes.filter EQ "paidandshipped"> selected</cfif>>Paid and Shipped</option>
					<option value="didnotsell"<cfif attributes.filter EQ "didnotsell"> selected</cfif>>Did Not Sell / Need to Call</option>
					<option value="6"<cfif attributes.filter EQ "6"> selected</cfif>>Reserve Not Met</option>
					<option value="rtc"<cfif attributes.filter EQ "rtc"> selected</cfif>>Returned to Client</option>
					<option value="13"<cfif attributes.filter EQ "13"> selected</cfif>>Donated to Charity</option>
					<option value="16"<cfif attributes.filter EQ "16"> selected</cfif>>Fixed Inventory</option>
					<option value="14"<cfif attributes.filter EQ "14"> selected</cfif>>Item Relotted</option>
					<option value="invoiced"<cfif attributes.filter EQ "invoiced"> selected</cfif>>Invoiced</option>
					<option value="10days"<cfif attributes.filter EQ "10days"> selected</cfif>>Non-Invoiced (10 days wait)</option>
					<option value="noninvoiced30"<cfif attributes.filter EQ "noninvoiced30"> selected</cfif>>Non-Invoiced (up to 30)</option>
					<option value="noninvoiced"<cfif attributes.filter EQ "noninvoiced"> selected</cfif>>Non-Invoiced (all)</option>
				</select>
			</td>
			<form method="POST" action="#_machine.self#&account=#attributes.account#">
				<td align="right">
					<input type="text" size="20" maxlength="50" name="srch"
					       value="#HTMLEditFormat(attributes.srch)#">
					<input type="submit" value="Search">
				</td>
			</form>
		</tr>
	</table>

	<br>

	<font size="2">
		<strong>
			Items from
			#sqlAccount.first#
			#sqlAccount.last#
			:
		</strong>
	</font>

	<br>
	<br>

	<cfif isDefined("attributes.invoiced")>
		#attributes.invoiced#
	</cfif>
	<center>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0
	       width="100%">
	<tr>
	<td>
	<form method="POST" name="invoice" id="invoice" action="#_machine.self#&account=#attributes.account#">
	<input type="hidden" name="account" value="#attributes.account#">
	<table width="100%" cellspacing="1" cellpadding="4">
</cfoutput>
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT
	<cfif attributes.filter EQ "noninvoiced30">
		TOP 30
	</cfif>
	i.item, e.dtend,
	<cfif attributes.filter EQ "nobidsyet">
		'No Bids Yet'
	<cfelseif attributes.filter EQ "didnotsell">
		'Did Not Sell'
	<cfelse>
		'BUILD'
	</cfif>
	AS highbidder,
	e.hbuserid, e.ebayitem, e.hbfeedbackscore, e.galleryurl,
	e.price, i.id, i.title, i.invoicenum, i.startprice AS reserve, e.ebayitem AS record,
	i.offebay, i.listcount, i.ebayitem, s.status, i.status as statusid, r.finalprice, i.lid,
	i.shipnote,i.label_printed,
	<!--- OPTIMIZATION
	DATEADD(SECOND, h.timestamp + DATEDIFF(SECOND, GETUTCDATE(), GETDATE()), '01/01/1970') AS
	ShippedTime
	--->i.ShippedTime
	FROM items i
	LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
	LEFT JOIN status s ON i.status = s.id
	LEFT JOIN records r ON i.item = r.itemid
	<!--- OPTIMIZATION
	LEFT JOIN (SELECT iid, MAX(timestamp) AS timestamp FROM status_history WHERE new_status = 11 GROUP
	BY iid) h ON i.item = h.iid<!--- Paid and Shipped --->
	--->
	WHERE i.aid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.account#">
	and i.lid != 'dummy'
	<cfif attributes.srch NEQ "">
		AND
		(
		<cfif isNumeric(attributes.srch)>
			e.ebayitem LIKE
			<cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
			OR
		</cfif>
		e.title LIKE
		<cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
		OR
		i.item LIKE
		<cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
		OR
		i.title LIKE
		<cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.srch#%">
		
		or	i.internal_itemSKU = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.srch#">
		
		or i.internal_itemSKU2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.srch#">
		)
	</cfif>

	<cfswitch expression="#attributes.filter#">
		<cfcase value="itemscreated">
			AND i.status = '2'<!--- ITEMS CREATED --->
		</cfcase>
		<cfcase value="itemsreceived">
			AND i.status = '3'<!--- ITEMS RECEIVED --->
		</cfcase>
		<cfcase value="active">
			AND i.status = '4'<!--- AUCTIONS LISTED --->
		</cfcase>
		<cfcase value="awaitingpayment">
			AND i.status = '5'<!--- AWAITING PAYMENT --->
		</cfcase>
		<cfcase value="awaitingshipment">
			AND i.status = '10'<!--- AWAITING SHIPMENT --->
		</cfcase>
		<cfcase value="paidandshipped">
			AND i.status = '11'<!--- PAID AND SHIPPED --->
		</cfcase>
		<cfcase value="invoiced">
			AND i.status = '7'<!--- CHECK SENT --->
		</cfcase>
		<cfcase value="didnotsell">
			AND
			(
			i.status = '8'<!--- DID NOT SELL --->
			OR
			i.status = '12'<!--- NEED TO CALL --->
			)
		</cfcase>
		<cfcase value="rtc">
			AND
			(
			i.status = '9'<!--- RETURNED TO CLIENT --->
			OR
			i.status = '13'<!--- DONATED TO CHARITY --->
			)
		</cfcase>
		<cfcase value="noninvoiced30">
			AND i.status = '11'<!--- PAID AND SHIPPED --->
			AND i.invoicenum IS NULL
			AND
			(
			(
			i.offebay = '0'
			AND e.dtend <= DATEADD(DAY, -10, GETDATE())
			)
			OR
			(
			i.offebay = '1'
			AND r.dended <= DATEADD(DAY, -10, GETDATE())
			)
			)<!--- PAID AND SHIPPED --->
			<!--- ABLE TO INVOICE 10 DAYS SINCE PAID AND SHIPPED
			                AND ISNULL(i.ShippedTime, e.dtend) <= DATEADD(DAY, -10, GETDATE())
			/ ABLE TO INVOICE 10 DAYS SINCE PAID AND SHIPPED --->
		</cfcase>
		<cfcase value="noninvoiced">
			AND i.invoicenum IS NULL
			AND
			(
			i.status = '5'<!--- AWAITING PAYMENT --->
			OR
			i.status = '10'<!--- AWAITING SHIPMENT --->
			OR
			i.status = '11'<!--- PAID AND SHIPPED --->
			)
		</cfcase>
		<cfcase value="10days">
			AND i.status = '11'<!--- PAID AND SHIPPED --->
			AND e.dtend > DATEADD(DAY, -10, GETDATE())<!--- PAID AND SHIPPED --->
			<!--- ABLE TO INVOICE 10 DAYS SINCE PAID AND SHIPPED
			                AND ISNULL(i.ShippedTime, e.dtend) > DATEADD(DAY, -10, GETDATE())
			/ ABLE TO INVOICE 10 DAYS SINCE PAID AND SHIPPED --->
		</cfcase>
		<cfcase value="6,13,14,16"><!--- Reserve Not Met, Donated to Charity, Item Relotted, Need to Relot
                              --->
			AND i.status =
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.filter#">
		</cfcase>
	</cfswitch>
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page - 1) * _paging.RowsOnPage + 1>
<cfoutput>
	<tr bgcolor="##FFFFFF">
	<td colspan="7" align="center">
</cfoutput>
<cfinclude template="../../../paging.cfm">
<cfoutput>

	</td>
	</tr>
	<tr bgcolor="##F0F1F3">
		<td class="ColHead">
			Gallery
		</td>
		<td class="ColHead">
			<a href="JavaScript: void fSort(9);">
				Number
			</a>
		</td>
		<td class="ColHead">
			<a href="JavaScript: void fSort(2);">
				Ended
			</a>
			<br>
			<a href="JavaScript: void fSort(21);">
				P&amp;S
			</a>
		</td>
		<td class="ColHead">
			<a href="JavaScript: void fSort(3);">
				Bidder
			</a>
		</td>
		<td class="ColHead">
			<a href="JavaScript: void fSort(8);">
				Price
			</a>
		</td>
		<td class="ColHead">
			Times Listed
		</td>
<!---		<td class="ColHead">
			Invoice
			<br>
			<font size=1>
				<i>
					(max 30)
				</i>
			</font>
		</td>--->
		<td class="ColHead">
				<input type="checkbox" name="checkp" id='checkp' >
		</td>
	</tr>
</cfoutput>
<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
	<tr bgcolor="##F0F1F3">
		<td rowspan=2 bgcolor="##FFFFFF">
			<cfif galleryurl EQ "">
				<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
			<cfelse>
				<a href="#galleryurl#" target="_blank">
				<img src="#galleryurl#" width=80 border=1>
			</cfif>
		</td>
		<td colspan="4" align="left">
			<b>
				#title#
			</b>
		</td>
		<td colspan=2>
			<cfif invoicenum NEQ "" AND attributes.filter EQ "paidandshipped">
				Check Sent
			<cfelse>
				#status#
			</cfif>
		</td>
	</tr>
	<tr bgcolor="##FFFFFF">
		<td>
			<a href="index.cfm?dsp=management.items.edit&item=#item#" <cfif label_printed eq 1> style="color:blue;"</cfif>>#item#</a>
			<cfif lid NEQ "">
				<br>
				LID:
				#lid#
			</cfif>
		</td>
		<td>
			END:
			#strDate(dtend)#
			<br>
			P&S:
			#strDate(ShippedTime)#
		</td>
		<td>
			<cfif dtend GT Now()>
				Active
			<cfelseif hbuserid EQ "">
				---
			<cfelseif highbidder EQ "BUILD">
				<a href="http://contact.ebay.com/ws/eBayISAPI.dll?ReturnUserEmail&requested=#hbuserid#&iid=#ebayitem#&frm=285">
					#hbuserid#
				</a>
				<img src="http://pics.ebaystatic.com/aw/pics/s.gif" width="4" border="0">
				(
				<a href="http://feedback.ebay.com/ws/eBayISAPI.dll?ViewFeedback&userid=#hbuserid#">
					#hbfeedbackscore#
				</a>
				)
				<br>
			<cfelse>
				#highbidder#
			</cfif>
		</td>
		<td>

			<cfif dtend LTE Now()>
				<cfif offebay EQ "1">
					#DollarFormat(finalprice)#
				<cfelse>
					#DollarFormat(price)#
				</cfif>
			</cfif>

			<cfif reserve GT 0>
				<br>
				<font color="blue">
					(
					#DollarFormat(reserve)#
					)
				</font>
			</cfif>
			<cfif offebay EQ "1">
				<br>
				<font color="blue">
					off eBay
				</font>
			</cfif>
		</td>
		<td>
			<cfif (ebayitem EQ "")>
				0
			<cfelse>
				#listcount#
			</cfif>
		</td>
		<cfif attributes.filter EQ "noninvoiced30">
			<cfset disabled = "CHECKED">
		<cfelse>
			<cfset disabled = "">
		</cfif>
		<cfif offebay NEQ "1">
			<cfif (reserve NEQ 0) AND (price LT reserve)>
				<cfset disabled = "DISABLED">
			</cfif>
			<cfif price LTE 0>
				<cfset disabled = "DISABLED">
			</cfif>
			<cfif statusid NEQ 11>
				<cfset disabled = "DISABLED">
			</cfif>
		</cfif>
		<cfif invoicenum NEQ "">
			<cfset disabled = 'DISABLED><BR><a href="index.cfm?act=management.items.delinvoice&account=#sqlAccount.id#&item=#item#"><img src="#request.images_path#void.png" border=0 onClick="return confirm(''Are you sure you want to delete the record of this invoice for this item?'');"></a><a href="invoices/Invoice #sqlAccount.store#.#sqlAccount.id#.#invoicenum#.htm" target="_blank"><img src="#request.images_path#look.png" border=0></a'>
		<cfelseif NOT isAllowed("Full_Access") AND (NOT isDate(ShippedTime) OR (DateDiff("D",
		                                                                                 ShippedTime,NOW())
		          LT 10))>
			<cfset disabled = "DISABLED">
		</cfif>
		<!---<td><cfif isGroupMemberAllowed("Invoices")><input type="checkbox" name="items"
		value="#sqlTemp.item#" #disabled#><cfelse>N/A</cfif></td>--->
		<td>
			<input type="checkbox" name="item_checked" id="item_checked"  value="#sqlTemp.item#" class="checkbox">		</td>
	</tr>
	<cfif shipnote NEQ "">
		<tr bgcolor="##FFFFCC">
			<td colspan="7" align="left">
				<b>
					Note:
				</b>
				#shipnote#
			</td>
		</tr>
	</cfif>
	<tr bgcolor="##FFFFFF">
		<td colspan="7" align="left">
			&nbsp;
		</td>
	</tr>
</cfoutput>
<cfoutput>
	<tr bgcolor="##FFFFFF">
	<td colspan="7" align="center">
</cfoutput>
<cfinclude template="../../../paging.cfm">
<cfoutput>
	</td>
	</tr>
	</table>
	</td>
	</tr>
	</table>
	<br>
	<table cellpadding="2" cellspacing="0" border="0">
		<!---<cfif isGroupMemberAllowed("Invoices")>
		<tr><td align="left">
		    <input type="text" name="extra_amount" value="0" size="7" maxlength="10"> - extra amount
		<small>(negative numbers substructed from invoice, positive added)</small><br>
		</td></tr>
		<tr><td align="left">
		    <input type="text" name="extra_description" value="" size="70" maxlength="50"> - description
		of extra amount<br>
		</td></tr>
		<tr><td align="left">
		    <input type="submit" value="Invoice Selected">
		<cfelse>
		<tr><td align="left">
		</cfif>--->
		<!---    &nbsp;&nbsp;&nbsp;
		    <input type="button" value="Mark All DNS/NTC as RTC" onClick="fDNS2RTC();">
		    &nbsp;&nbsp;&nbsp;
		    <input type="button" value="Mark All DNS/NTC as NTD" onClick="fDNS2NTD();">--->
		<input type="submit" name="frmSubmit" value="Delete checked items" onclick="return confirmSubmit()">
		<input type="hidden" name="submitted" value="1">
	</table>
	</form>
	<br>
	<br>
	</center>

<script type="text/javascript">
		$(function(){
			$('##checkp').click(function(){
		        if(this.checked){
		            $('.checkbox').attr('checked','checked');
		        } else {
		            $('.checkbox').removeAttr('checked');
		        }
			});
		});//doc ready
	</script>
</cfoutput>