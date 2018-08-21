<cfif NOT isAllowed("POS_ClientPickup")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="i.id">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.stype" default="1">

<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
function fLabel(itemid){
	nw=window.open('index.cfm?dsp=management.items.itemslip&item='+itemid,'NewWin','height=250,width=355,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');
	nw.opener=self;
	nw.focus();
}
function fSSheet(itemid){
	nw=window.open('index.cfm?dsp=management.items.customerslip&item='+itemid,'NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');
	nw.opener=self;
	nw.focus();
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Client Pickup:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
	Search by UserID:<br>
	<form method="POST" action="#_machine.self#">
		<input type="text" size="20" maxlength="50" name="srch" value="#HTMLEditFormat(attributes.srch)#">
		<input type="submit" value="Search In">
		<select name="stype">
			#SelectOptions(attributes.stype, "1,Awaiting Payment or Shipment;2,Did Not Sell or Need to Call")#
		</select>
	</form>
	<br><br>
	</cfoutput>
	<cfquery name="sqlTemp" datasource="#request.dsn#">
		SELECT i.title, e.price, a.first + ' ' + a.last AS owner, a.first, a.last, i.item, a.id, e.galleryurl, i.dcreated, a.email, i.ebayitem, a.store, i.lid, i.ebayitem, i.startprice
		FROM accounts a
			INNER JOIN items i ON a.id = i.aid
			INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
	<cfif attributes.stype EQ 1>
		WHERE (i.status = 5<!--- Awaiting Payment --->
			OR i.status = 10)<!--- Awaiting Shipment --->
			AND YEAR(i.dcreated) > 2005
		<cfif attributes.srch NEQ "">
			AND e.hbuserid LIKE '%#attributes.srch#%'
		<cfelse>
			AND 1 = 2
		</cfif>
	<cfelse>
		WHERE (i.status = 8<!--- Did Not Sell --->
			OR i.status = 12)<!--- Need to Call --->
		<cfif attributes.srch NEQ "">
			AND
			(
				a.first LIKE '%#attributes.srch#%'
				OR
				a.last LIKE '%#attributes.srch#%'
				OR
				a.id LIKE '%#attributes.srch#%'
			)
		<cfelse>
			AND 1 = 2
		</cfif>
	</cfif>
		ORDER BY #attributes.orderby# #attributes.dir#
	</cfquery>
	<cfoutput>
	<cfif sqlTemp.RecordCount GT 0><b style="color:green;">#sqlTemp.RecordCount# records found</b><br><br></cfif>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<form id="frm" method="POST" action="index.cfm?dsp=admin.pos.checkout&stype=#attributes.stype#" target="_self">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Gallery</td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Owner</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">Item Number</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Final Price</a></td>
			<td class="ColHead" width="50">Label</td>
			<td class="ColHead" width="50">Form</td>
			<td class="ColHead" width="100">CheckOut</td>
		</tr>
		<!-- RecordCount: #sqlTemp.RecordCount# -->
		</cfoutput>
		<cfoutput query="sqlTemp">
		<tr bgcolor="##F0F1F3"><td rowspan="2" bgcolor="##FFFFFF" align="center">
			<cfif sqlTemp.galleryurl EQ ""><img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg"><cfelse><a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" width=80 border=1></cfif></td>
			<td colspan="6" align="left"><cfif DateDiff("d", sqlTemp.dcreated, Now()) EQ 0><img src="#request.images_path#newsun.gif"></cfif><b>#sqlTemp.title#</b> <i>(#DateFormat(sqlTemp.dcreated)#)</i></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="center"><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.owner#</a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a><cfif sqlTemp.lid NEQ ""><br>LID: #sqlTemp.lid#</cfif><cfif sqlTemp.ebayitem NEQ ""><br>(<a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_new">#sqlTemp.ebayitem#</a>)</cfif></td>
			<td align="center"><cfif sqlTemp.price NEQ "">#DollarFormat(sqlTemp.price)#<cfelse>$0</cfif><cfif sqlTemp.startprice GT 0><br><font color="blue">(#DollarFormat(sqlTemp.startprice)#)</font></cfif></td>
			<td align="center"><a href="JavaScript: fLabel('#sqlTemp.item#');"><img border="0" src="#request.images_path#icon11.gif" alt="Print Label"></a></td>
			<td align="center"><a href="JavaScript: fSSheet('#sqlTemp.item#');"><img border="0" src="#request.images_path#icon11.gif" alt="Print Signing Sheet"></a></td>
			<td align="center"><input type="checkbox" name="items" value="#sqlTemp.item#" checked></td>
		</tr>
		<tr bgcolor="##FFFFFF"><td colspan="7">&nbsp;</td></tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td colspan="4" align="right">&nbsp;</td>
			<td colspan="2" align="center"><input type="submit" style="font-size: 10px; width:100px;" name="printable" value="Print" onClick="document.forms.frm.target='_blank';"></td>
			<td align="center"><input type="submit" style="font-size: 10px; width:100px;" value="Check Out" onClick="document.forms.frm.target='_self';"></td>
		</tr>
		</form>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
