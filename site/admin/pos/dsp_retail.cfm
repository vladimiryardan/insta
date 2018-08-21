<cfif NOT isAllowed("POS_Retail")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfoutput><h3 style="color:red;">UNDER CONSTRUCTION</h3></cfoutput>
<!---
<cfparam name="attributes.orderby" default="id">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.srch" default="">

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
	<font size="4"><strong>Retail:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
	</cfoutput>
	<cfquery name="sqlTemp" datasource="#request.dsn#">
		SELECT item, title, startprice
		FROM items
		WHERE status = 4<!--- Auction Listed --->
		ORDER BY #attributes.orderby# #attributes.dir#
	</cfquery>

	<cfoutput>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<form id="frm" method="POST" action="index.cfm?dsp=admin.pos.checkout" target="_blank" onSubmit="alert('under construction');return false;">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead" width="90"><a href="JavaScript: void fSort(1);">Item Number</a></td>
			<td class="ColHead">Description</td>
			<td class="ColHead" width="80"><a href="JavaScript: void fSort(3);">Price</a></td>
			<td class="ColHead" width="80">CheckOut</td>
		</tr>
		</cfoutput>
		<cfoutput query="sqlTemp">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.title#</td>
			<td align="right">#DollarFormat(sqlTemp.startprice)#</td>
			<td align="center"><input type="checkbox" name="items" value="#sqlTemp.item#" checked></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##F0F1F3"><td colspan="4" align="right">
			<input type="submit" style="font-size: 10px;" value="Check Out">
		</td></tr>
		</form>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
--->
