<cfif NOT isAllowed("POS_ShipPackage")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#&uid=#attributes.uid#" addtoken="no">
</cfif>

<cfquery datasource="#request.dsn#" name="sqlUPS">
	SELECT *
	FROM ups
	WHERE uid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.uid#">
</cfquery>

<cfoutput query="sqlUPS">
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
		<td><br><font size=5 color=gray><b>Invoice</b></font><br><br><font size=1><b>DATE:</b><br>#DateFormat(dcreated, "m/d/yyyy")#<br><br><b>INVOICE ##:</b><br>#Right("00000#uid#", 5)#<br><br><b>Tracking Number ##:</b><br>#TrackingNumber#</font></td>
	</tr>
	<tr>
		<td valign=top align=left colspan="2"><br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#TO_CompanyName# #TO_AttentionName#<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#TO_AddressLine1# #TO_AddressLine2# #TO_AddressLine3#<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#TO_City#, #TO_StateProvinceCode# #TO_PostalCode#<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;phone:#TO_PhoneNumber#, fax: #TO_FaxNumber#<br>
		</td>
	</tr>
	<tr>
		<td>Shipping and Handling Cost</td>
		<td>#DollarFormat(TotalCharges+ship_handling_cost+ship_cost_per_pound*Weight)#</td>
	</tr>
	<tr>
		<td>Packing and Materials</td>
		<td>#DollarFormat(packing_and_materials)#</td>
	</tr>
	<tr>
		<td><b>Total</b></td>
		<td><b>#DollarFormat(TotalCharges+ship_handling_cost+ship_cost_per_pound*Weight+packing_and_materials)#</b></td>
	</tr>
	</table><br><br>
<center>Thank you for selling with Instant Auctions!  We appreciate your business and hope to see you back soon!  If you have any questions concerning this receipt, please contact us at 1-866-390-4060.<br>
<b>Each Instant Auctions store is independently owned and operated.<br>Franchises are available! Visit InstantAuctions.net!</b></center>
</td></tr>
</table>
</body>
</html>
</cfoutput>
