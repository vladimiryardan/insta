<cfif NOT isAllowed("Lister_ClaimsList")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="7">
<cfparam name="attributes.dir" default="ASC">
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&orderby="+OrderBy+"&dir="+dir;
}
function fRTC(ID, CHECKED){
	fCheck(ID, CHECKED, "dtcACCOUNTS");
	fCheck(ID, CHECKED, "ntrACCOUNTS");
}
function fDTC(ID, CHECKED){
	fCheck(ID, CHECKED, "rtcACCOUNTS");
	fCheck(ID, CHECKED, "ntrACCOUNTS");
}
function fNTR(ID, CHECKED){
	fCheck(ID, CHECKED, "dtcACCOUNTS");
	fCheck(ID, CHECKED, "rtcACCOUNTS");
}
function fCheck(ID, CHECKED, OBJ){
	if(CHECKED){
		var obj = document.all[OBJ];
		if(isNaN(obj.length) || (obj.length < 2)){
			obj.checked = false;
		}else{
			for(var i=0; i<obj.length; i++){
				if(obj[i].value == ID){
					obj[i].checked = false;
				}
			}
		}
	}
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Claims List:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Name</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Store</a></td>
			<td class="ColHead">NTC Items (<a href="JavaScript: void fSort(8);">LID</a>)</td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Phone</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Zip</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Called On</a></td>
			<td class="ColHead" width="40">RTC</td>
			<td class="ColHead" width="40">DTC</td>
			<td class="ColHead" width="40">NTR</td>
		</tr>
		<form action="index.cfm?act=management.rtc" method="post">
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT first + ' ' + last AS name, a.store, i.item, a.phone, a.zip, a.id, i.dcalled, i.lid, i.title
			FROM accounts a
				INNER JOIN items i ON a.id = i.aid
			WHERE i.status = 12<!--- NEED TO CALL --->
				AND i.dcalled <= DATEADD(DAY, -10, GETDATE())
			ORDER BY #attributes.orderby# #attributes.dir#, i.item
		</cfquery>
		<cfoutput query="sqlTemp" group="id">
		<tr bgcolor="##FFFFFF">
			<td align="left" nowrap><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.name#</a></td>
			<td align="center">#sqlTemp.store#</td>
			<td align="left"><cfoutput><table><tr valign="top"><td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a>:</td><td>#sqlTemp.title# (#sqlTemp.lid#)</td></tr></table></cfoutput></td>
			<td align="center">#sqlTemp.phone#</td>
			<td align="center">#sqlTemp.zip#</td>
			<td align="center" nowrap>#DateFormat(sqlTemp.dcalled, "mmm d, yyyy")#</td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="rtcACCOUNTS" onClick="fRTC(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="dtcACCOUNTS" onClick="fDTC(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="ntrACCOUNTS" onClick="fNTR(this.value, this.checked)"></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="9" align="right">
			<button type="submit">Mark as RTC/DTC/NTR</button>
		</td></tr>
		</form>
		</table>
	</td></tr>
	</table>

<br>

	<font size="4"><strong>Called List:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Name</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Store</a></td>
			<td class="ColHead">NTC Items - <a href="JavaScript: void fSort(8);">LID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Phone</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Zip</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Called On</a></td>
		</tr>
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT first + ' ' + last AS name, a.store, i.item, a.phone, a.zip, a.id, i.dcalled, i.lid
			FROM accounts a
				INNER JOIN items i ON a.id = i.aid
			WHERE i.status = 12<!--- NEED TO CALL --->
				AND i.dcalled > DATEADD(DAY, -10, GETDATE())
			ORDER BY #attributes.orderby# #attributes.dir#, i.item
		</cfquery>
		<cfoutput query="sqlTemp" group="id">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.name#</a></td>
			<td align="center">#sqlTemp.store#</td>
			<td align="left" style="padding-left:20px;"><cfoutput><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a> - #sqlTemp.lid#<br></cfoutput></td>
			<td align="center">#sqlTemp.phone#</td>
			<td align="center">#sqlTemp.zip#</td>
			<td align="center">#DateFormat(sqlTemp.dcalled, "mmm d, yyyy")#</td>
		</tr>
		</cfoutput>
		<cfoutput>
		</table>
	</td></tr>
	</table>

</td></tr>
</table>
</cfoutput>
