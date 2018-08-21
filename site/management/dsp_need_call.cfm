<cfif NOT isAllowed("Lister_NeedToCall")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="1">
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
	<font size="4"><strong>Need to Call:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Name</a></td>
			<td class="ColHead">NTC Items</td>
			<td class="ColHead">Owed</td>
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Phone</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Zip</a></td>
			<td class="ColHead" width="40">Called</td>
			<td class="ColHead" width="40">DTC</td>
			<td class="ColHead" width="40">NTR</td>
		</tr>
		<form action="index.cfm?act=management.called" method="post">
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT z.name, x.owed, z.item, z.phone, z.zip, z.id, z.title, z.lid FROM
			(
				SELECT first + ' ' + last AS name, i.item, a.phone, a.zip, a.id, i.title, i.lid
				FROM accounts a
					INNER JOIN items i ON i.aid = a.id
				WHERE i.status = 12
					AND i.dcalled IS NULL
			) z
			LEFT JOIN
			(
				SELECT a.id, SUM(r.checkamount) AS owed
				FROM accounts a
					INNER JOIN items i ON i.aid = a.id AND i.invoicenum IS NULL AND i.status = 11
					LEFT JOIN records r ON i.item = r.itemid
				GROUP BY a.id
			) x ON z.id = x.id
			ORDER BY #attributes.orderby# #attributes.dir#, z.item
		</cfquery>
		<cfoutput query="sqlTemp" group="id">
		<tr bgcolor="##FFFFFF">
			<td align="left"><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.name#</a></td>
			<td align="left"><cfoutput><table><tr valign="top"><td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a>:</td><td>#sqlTemp.title# (#sqlTemp.lid#)</td></tr></table></cfoutput></td>
			<td align="center"><cfif sqlTemp.owed EQ "">$0.00<cfelse>#DollarFormat(sqlTemp.owed)#</cfif></td>
			<td align="center">#sqlTemp.phone#</td>
			<td align="center">#sqlTemp.zip#</td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="rtcACCOUNTS" onClick="fRTC(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="dtcACCOUNTS" onClick="fDTC(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.id#" name="ntrACCOUNTS" onClick="fNTR(this.value, this.checked)"></td>
		</tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="8" align="right">
			<input type="submit" value="Mark as Called/DTC/NTR">
		</td></tr>
		</form>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
