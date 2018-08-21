<cfif NOT isAllowed("POS_ShipPackage")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="4">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.srch" default="">
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
function fLabel(uid){
	LabelWin = window.open("index.cfm?dsp=admin.pos.ups_print&uid="+uid, "LabelWin", "height=400,width=700,location=yes,scrollbars=yes,menubar=yes,toolbar=yes,resizable=yes");
	LabelWin.opener = self;
	LabelWin.focus();
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>UPS Labels:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Ship To</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Address</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Created By</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Created On</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Weight</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">Declared Value</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Ship Charges</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(8);">Tracking Number</a></td>
			<td class="ColHead">Print</td>
			<td class="ColHead">Invoice</td>
		</tr>
</cfoutput>
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT
		u.TO_CompanyName,
		u.TO_CountryCode + ', ' + u.TO_City + ', ' + u.TO_StateProvinceCode AS address,
		a.first + ' ' + a.last AS who_created,
		u.dcreated, u.Weight, u.DeclaredValue, u.TotalCharges, u.TrackingNumber,
		u.uid, u.aid
	FROM ups u
		LEFT JOIN accounts a ON a.id = u.aid
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td>#sqlTemp.TO_CompanyName#</td>
			<td nowrap>#sqlTemp.address#</td>
			<td><a href="index.cfm?dsp=account.edit&id=#sqlTemp.aid#">#sqlTemp.who_created#</a></td>
			<td align="center">#DateFormat(sqlTemp.dcreated)#</td>
			<td align="center">#sqlTemp.Weight#</td>
			<td align="right">#DollarFormat(sqlTemp.DeclaredValue)#</td>
			<td align="right">#DollarFormat(sqlTemp.TotalCharges)#</td>
			<td><a href="http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#sqlTemp.TrackingNumber#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12" target="_blank">#sqlTemp.TrackingNumber#</a></td>
			<td align="center"><a href="JavaScript:fLabel(#sqlTemp.uid#)"><img src="#request.images_path#icon11.gif" border=0 alt="Print Label"></a></td>
			<td align="center"><a href="index.cfm?dsp=admin.pos.ups_invoice&uid=#sqlTemp.uid#" target="_blank"><img src="#request.images_path#payment.gif" border=0 alt="Print Invoice"></a></td>
		</tr>
</cfoutput>
<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="10" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		<tr bgcolor="##F0F1F3"><td colspan="10" class="ColHead">
			<a href="index.cfm?dsp=admin.pos.ship_package">Create New Label</a>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
