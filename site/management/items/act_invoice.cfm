<cfif NOT isAllowed("Invoices_InvoiceItems")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.items" default="">
<cfif attributes.items EQ "">
	<cfset _machine.cflocation = "index.cfm?dsp=management.items.list&account=#attributes.account#&invoiced=#URLEncodedFormat('<br><br><font style="color:red">Please select at least one item!</font><br><br>')#">
<cfelse>
	<cfparam name="attributes.extra_amount" default="0">
	<cfparam name="attributes.extra_description" default="">
	<cfif attributes.extra_amount EQ 0>
		<cfset attributes.extra_description = "">
	</cfif>
	<cfset invoicenum = DateDiff("s", "1/1/1", Now())>
	<cfquery name="sqlRecords" datasource="#request.dsn#" maxrows="30">
		SELECT r.ebayitem, r.itemid, CASE WHEN e.title IS NOT NULL THEN e.title ELSE i.title END AS [desc], r.finalprice, r.ebayfees, r.ourfees, r.paypalfees, r.ExtraFees, r.aid
		FROM records r
			LEFT JOIN ebitems e ON r.ebayitem = e.ebayitem
			LEFT JOIN items i ON r.itemid = i.item
		WHERE r.itemid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
	</cfquery>
<!--- 2 October 2006
	<cfif isDefined("attributes.account")>
		<cfset aid_invoiced = attributes.account>
	<cfelse>
		<cfset aid_invoiced = ListGetAt(sqlRecords.itemid, 2, ".")>
	</cfif>
--->
	<cfset aid_invoiced = ListGetAt(sqlRecords.itemid, 2, ".")>
	<cfquery name="sqlAccount" datasource="#request.dsn#">
		SELECT first, last, address1, address2, city, state, zip, store, email, id AS aid
		FROM accounts
		WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#aid_invoiced#">
	</cfquery>
	<cfif NOT isDefined("attributes.createreceipt")>
		<cfquery datasource="#request.dsn#">
			UPDATE items SET paid = '1' 
			WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
		</cfquery>
		<cfloop index="i" list="#attributes.items#">
			<cfset fChangeStatus(i, 10)><!--- AWAITING SHIPMENT --->
		</cfloop>
	</cfif>
	<cfquery datasource="#request.dsn#">
		UPDATE records SET checksent = '1' 
		WHERE itemid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
	</cfquery>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET invoicenum = <cfqueryparam cfsqltype="cf_sql_integer" value="#invoicenum#">,
			dinvoiced = <cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">
		WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
	</cfquery>
	
	<cfsavecontent variable="somecontent">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.instantauctions.net/loose.dtd">
<html>
<head>
<title>InstantAuctions.net - The Easy Way to eBay - 1-866-390-4060</title>

<style type="text/css">
<!--
body
{
    background-color: ##FFFFFF;
    color: ##26353F;
    font: 10pt verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
    MARGIN-TOP: -40px;
    MARGIN-BOTTOM: 0px;
    MARGIN-LEFT: 0px;
    MARGIN-RIGHT: 0px;  
    
    scrollbar-base-color: ##f2f2f2; 
    scrollbar-track-color: ##f9fafa;
    scrollbar-face-color: ##F1F1F1;
    scrollbar-highlight-color: ##ffffff;
    scrollbar-3dlight-color: ##ffffff;
    scrollbar-darkshadow-color: ##ffffff;
    scrollbar-shadow-color: ##C8C8CA;
    scrollbar-arrow-color: ##999999;
}
a:link
{
    color: ##26353F;
}
a:visited
{
    color: ##26353F;
}
a:hover, a:active
{
    color: ##4F5459;
}
.page
{
    background-color: ##EDEDED;
    color: ##B9B9B9;
}
td, th, p, li
{
    font: 10pt verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.tborder
{
    background-color: ##181B16;
    color: ##000000;
}
.tcat
{
    color: ##0B2943;
    font: bold 9pt verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.tcat a:link
{
    color: ##0B2943;
    text-decoration: none;
}
.tcat a:visited
{
    color: ##0B2943;
    text-decoration: none;
}
.tcat a:hover, .tcat a:active
{
    color: ##0B2943;
    text-decoration: underline;
}
.thead
{
    color: ##0B2943;
    font: bold 10px tahoma, verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.thead a:link
{
    color: ##0B2943;
}
.thead a:visited
{
    color: ##0B2943;
}
.thead a:hover, .thead a:active
{
    color: ##0B2943;
}
.tfoot
{
    background-color: ##F9F9F9;
    color: ##0B2943;
}
.tfoot a:link
{
    color: ##0B2943;
}
.tfoot a:visited
{
    color: ##0B2943;
}
.tfoot a:hover, .tfoot a:active
{
    color: ##0B2943;
}
.alt1, .alt1Active
{
    background-color: ##F7F7F7;
    color: ##000000;
}
.alt2, .alt2Active
{
    background-color: ##FDFDFD;
    color: ##000000;
}
.alt3
{
    background-color: ##D5D8E5;
    color: ##000000;
}
.wysiwyg
{
    background-color: ##FDFDFD;
    color: ##000000;
    font: 10pt verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
textarea, .bginput
{
    font: 10pt verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.button
{
    font: 11px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
select
{
    font: 11px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
option, optgroup
{
    font-size: 11px;
    font-family: verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.smallfont
{
    color: ##26353F;
    font: 10px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.time
{
    color: ##26353F;
}
.navbar
{
    color: ##26353F;
    font: 10px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.highlight
{
    color: ##FF0000;
    font-weight: bold;
}
.fjsel
{
    background-color: ##3E5C92;
    color: ##E0E0F6;
}
.fjdpth0
{
    background-color: ##F7F7F7;
    color: ##000000;
}
.panel
{
    background-color: ##F7F7F7;
    color: ##000000;
    padding: 10px;
    border: 2px outset;
}
.panelsurround
{
    background-color: ##F0F1F3;
    color: ##000000;
}
legend
{
    color: ##4F5459;
    font: 10px tahoma, verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
}
.vbmenu_control
{
    color: ##4F5459;
    font: bold 10px tahoma, verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
    padding: 3px 6px 3px 6px;
    white-space: nowrap;
}
.vbmenu_control a:link
{
    color: ##4F5459;
    text-decoration: none;
}
.vbmenu_control a:visited
{
    color: ##4F5459;
    text-decoration: none;
}
.vbmenu_control a:hover, .vbmenu_control a:active
{
    color: ##4F5459;
    text-decoration: underline;
}
.vbmenu_popup
{
    background-color: ##FFFFFF;
    color: ##000000;
    border: 1px solid ##181B16;
    text-align: left;
}
.vbmenu_option
{
    background-color: ##C3CBD0;
    color: ##26353F;
    font: 10px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
    white-space: nowrap;
    cursor: pointer;
    border: 1px solid ##181B16;
}
.vbmenu_option a:link
{
    color: ##26353F;
    text-decoration: none;
}
.vbmenu_option a:visited
{
    color: ##26353F;
    text-decoration: none;
}
.vbmenu_option a:hover, .vbmenu_option a:active
{
    color: ##26353F;
    text-decoration: none;
}
.vbmenu_hilite
{
    background-color: ##768F9F;
    color: ##101A21;
    font: 10px verdana, geneva, lucida, 'lucida grande', arial, helvetica, sans-serif;
    white-space: nowrap;
    cursor: pointer;
    border: 1px solid ##181B16;
}
.vbmenu_hilite a:link
{
    color: ##101A21;
    text-decoration: none;
}
.vbmenu_hilite a:visited
{
    color: ##101A21;
    text-decoration: none;
}
.vbmenu_hilite a:hover, .vbmenu_hilite a:active
{
    color: ##101A21;
    text-decoration: none;
}
.pagenav a { text-decoration: none; }
.pagenav td { padding: 2px 4px 2px 4px; }
.fieldset { margin-bottom: 6px; }
.fieldset, .fieldset td, .fieldset p, .fieldset li { font-size: 11px; }

form { display: inline; }
label { cursor: default; }
.normal { font-weight: normal; }
.inlineimg { vertical-align: middle; }

TABLE.border {
border-right: 1px solid ##181B16;
border-left: 1px solid ##181B16;
border-bottom: 1px solid ##B6B6B6;
}

.info {
padding-left: 3px;
padding-right: 0px;
padding-top: 3px;
padding-bottom: 3px;
background-color: ##F1F1F1;
border-top: 1px solid ##505050;
border-right: 2px solid ##505050;
border-left: 1px solid ##505050;
border-bottom: 2px solid ##505050;
margin-bottom: 3px;
}

TABLE.nav {
border-right: 1px solid ##181B16;
border-left: 1px solid ##181B16;
}
-->
</style>
</head>

<body style="text-align: justify;" link="##708090" alink="##778899">
<br>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td align=left valign=top>
	<table cellpadding=7 width=100%>
	<tr>
		<td valign=top align=left><table><tr><td><center><img width=150 src="http://www.instantauctions.net/images/ialogoebayhigh.jpg" border=0><br><font size=1>441 Southland Drive<br>Lexington, KY 40503<br>http://www.instantauctions.net</center></font></td></tr></table></td>
		<td colspan="4"><br><font size=5 color=gray><B>Invoice</B></font><br><br><font size=1><B>DATE:</B><br>#DateFormat(Now(), "m/d/yyyy")#<br><br><B>INVOICE ##:</B><br>#sqlAccount.store#.#sqlRecords.aid#.#invoicenum#</font></td>
	</tr>
	<tr>
		<td valign=top align=left colspan="5"><BR>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#sqlAccount.first# #sqlAccount.last#<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#sqlAccount.address1# #sqlAccount.address2#<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#sqlAccount.city#, #sqlAccount.state# #sqlAccount.zip#
		</td>
	</tr>
	<tr>
		<td valign=top align=left width="100%">
			<br><br><B>Item ## / eBay ## / eBay Title</B><br><font size=1>
</cfoutput>
			<cfset finalpricetotal = 0>
			<cfset paypalfeestotal = 0>
			<cfset ebayfeestotal = 0>
			<cfset ourfeestotal = 0>
			<cfset extrafeestotal = 0>
			<cfset checkamount = 0>
			<cfloop query="sqlRecords">
				<cfset finalpricetotal = finalpricetotal + finalprice>
				<cfset paypalfeestotal = paypalfeestotal - paypalfees>
				<cfset ebayfeestotal = ebayfeestotal - ebayfees>
				<cfset ourfeestotal = ourfeestotal - ourfees>
				<cfif isNumeric(extrafees)>
					<cfset extrafeestotal = extrafeestotal + extrafees>
				</cfif>
				<cfset checkamount = finalpricetotal + paypalfeestotal + ebayfeestotal + ourfeestotal>
				<cfif checkamount LT 0>
					<cfset checkamount = 0>
				</cfif>
				<cfoutput>#itemid#/#ebayitem# #desc#<br></cfoutput>
			</cfloop>
			<cfif sqlRecords.RecordCount LT 30><cfoutput>#RepeatString("<br>", 30-sqlRecords.RecordCount)#</cfoutput></cfif>
			<cfquery datasource="#request.dsn#" name="sqlExpenses">
				SELECT eid, amount, caption
				FROM expenses
				WHERE invoicenum = 0
					AND aid = <cfqueryparam cfsqltype="cf_sql_integer" value="#aid_invoiced#">
			</cfquery>
<cfoutput>
		</td>
		<td valign=top align=right style="color:##06151F;">
			<br><B>Sale<br>Price</B><br><font size=1>
			<cfloop query="sqlRecords">#DollarFormat(finalprice)#<br></cfloop>
			<cfif sqlRecords.RecordCount LT 30>#RepeatString("<br>", 30-sqlRecords.RecordCount)#</cfif>
		</td>
		<td valign=top align=right style="color:##06151F;">
			<br><B>eBay<br>Fees</B><br><font size=1>
			<cfloop query="sqlRecords">#DollarFormat(ebayfees)#<br></cfloop>
			<cfif sqlRecords.RecordCount LT 30>#RepeatString("<br>", 30-sqlRecords.RecordCount)#</cfif>
		</td>
		<td valign=top align=right style="color:##06151F;">
			<br><B>PayPal<br>Fees</B><br><font size=1>
			<cfloop query="sqlRecords">#DollarFormat(paypalfees)#<br></cfloop>
			<cfif sqlRecords.RecordCount LT 30>#RepeatString("<br>", 30-sqlRecords.RecordCount)#</cfif>
		</td>
		<td valign=top align=right style="color:##06151F;">
			<br><B>Our<br>Fees</B><br><font size=1>
			<cfloop query="sqlRecords">#DollarFormat(ourfees)#<br></cfloop>
			<cfif sqlRecords.RecordCount LT 30>#RepeatString("<br>", 30-sqlRecords.RecordCount)#</cfif>
		</td>
	</tr>
	<tr>
		<TD valign=top align=left><font size=1><b>
			Total eBay Fees:<br>
			Total Transaction Fees:<br>
			Total Instant Auction Fees:
			<cfif extrafeestotal GT 0><br>Total Extra Fees:</cfif>
			<cfif attributes.extra_amount NEQ 0><br>#attributes.extra_description#</cfif>
			<cfloop query="sqlExpenses"><br>#caption#</cfloop>
		</b></font></td>
		<TD valign=top align=right colspan="4"><font size=1>
			<B>#DollarFormat(ebayfeestotal)#<br>
			#DollarFormat(paypalfeestotal)#<br>
			#DollarFormat(ourfeestotal)#<br>
			<cfif extrafeestotal GT 0>#DollarFormat(extrafeestotal)#<br></cfif>
			<cfif attributes.extra_amount NEQ 0>#DollarFormat(attributes.extra_amount)#<br><cfset checkamount = checkamount + attributes.extra_amount></cfif>
			<cfloop query="sqlExpenses">#DollarFormat(-amount)#<br><cfset checkamount = checkamount - amount></cfloop>
			<br>
			<font size=3><B>Check Total: #DollarFormat(checkamount)#</B></font>
		</td>
	</tr>			
	</table><br><br>
<center>Thank you for selling with Instant Auctions!  We appreciate your business and hope to see you back soon!  If you have any questions concerning this receipt, please contact us at 1-866-390-4060.<br>
<B>Each Instant Auctions store is independently owned and operated.<BR>Franchises are available! Visit InstantAuctions.net!</B></center>
</td></tr>
</table>
</body>
</html>
</cfoutput>
	</cfsavecontent>

	<cfset sFile = "invoices/Invoice #sqlAccount.store#.#sqlAccount.aid#.#invoicenum#.htm">
	<cfset sFileName = "#ExpandPath('Invoices')#\Invoice #sqlAccount.store#.#sqlAccount.aid#.#invoicenum#.htm">
	<cffile action="write" output="#somecontent#" file="#sFileName#">
	<cfscript>
		LogAction("created invoice #invoicenum#");
		for(i=1; i LTE ListLen(attributes.items); i=i+1){
			fChangeStatus(ListGetAt(attributes.items, i), 7); // CHECK SENT
		}
	</cfscript>
	<cfif TRIM(sqlAccount.email) NEQ "">
<cfmail 
from="#_vars.mails.from#" 
to="#sqlAccount.email#" subject="#_vars.emails.invoiced_title#">
Dear #sqlAccount.first# #sqlAccount.last#,

#_vars.emails.invoiced_message#

--
Instant Auction Support Team
http://www.instantauctions.net
</cfmail>
	</cfif>
	<cfif isDefined("attributes.createreceipt")>
		<cfset _machine.cflocation = "index.cfm?dsp=management.records&item=#attributes.items#">
	<cfelse>
		<cfset _machine.cflocation = "index.cfm?dsp=management.items.list&account=#sqlAccount.aid#&invoiced=#URLEncodedFormat('<br><br>Success, wrote to file (<a href="#sFile#" target="_blank">#sFileName#</a>)!<br><br>')#">
	</cfif>
	<cfquery datasource="#request.dsn#">
		INSERT INTO invoices
		(invoicenum, aid, extra_amount, extra_description)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_bigint" value="#invoicenum#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#aid_invoiced#">,
			<cfqueryparam cfsqltype="cf_sql_money" value="#attributes.extra_amount#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.extra_description#">
		)
	</cfquery>
	<cfquery datasource="#request.dsn#">
		UPDATE expenses
		SET invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#invoicenum#">
		WHERE invoicenum = 0
			AND aid = <cfqueryparam cfsqltype="cf_sql_integer" value="#aid_invoiced#">
	</cfquery>
</cfif>
