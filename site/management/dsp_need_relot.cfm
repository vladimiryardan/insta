<cfif NOT isAllowed("Lister_NeedToRelot")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="5">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.ebayitem, i.title, i.listcount, e.dtend, i.lid, a.first + ' ' + a.last AS owner
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
		INNER JOIN accounts a ON i.aid = a.id
	WHERE (i.status = 16)<!--- Need To Relot --->
		AND i.exception = 0
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>

<cfif isDefined("attributes.printable")>
	<cfset _paging.RowsOnPage = 250>
</cfif>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
	<cfoutput>
	<script language="javascript" type="text/javascript">
	<!--//
		function fPage(Page){
			window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page;
		}
		function fSort(OrderBy){
			if (#attributes.orderby# == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir;
		}
		function fREL(ID, CHECKED){
			fCheck(ID, CHECKED, "ap3ITEMS");
		}
		function fAP3(ID, CHECKED){
			fCheck(ID, CHECKED, "relITEMS");
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
		function fCheckAllAP3(){
			obj = document.getElementById("theForm").ap3ITEMS;
			obj2 = document.getElementById("theForm").relITEMS;
			if(isNaN(obj.length)){
				obj.checked = true;
				obj2.checked = false;
			}else{
				for(i=0; i<obj.length; i++){
					obj[i].checked = true;
					obj2[i].checked = false;
				}
			}
		}
	//-->
	</script>
	</cfoutput>
</cfif>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Need to Relot:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#
			<cfelse>
				<a href="#_machine.self#&page=#attributes.page#&orderby=#attributes.orderby#&dir=#attributes.dir#&printable" target="_blank">Printable version</a>
			</cfif>
		</td>
	</tr>
	</table>
	<cfif NOT isDefined("attributes.printable")>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<cfif isDefined("attributes.printable")>
			<td class="ColHead">Owner</td>
			<td class="ColHead">Item ID</td>
			<td class="ColHead">eBay Item</td>
			<td class="ColHead">Title</td>
			<td class="ColHead">Date Ended</td>
			<td class="ColHead" width="50">Times Listed</td>
		<cfelse>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Owner</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a> (<a href="JavaScript: void fSort(6);">LID</a>)</td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Date Ended</a></td>
			<td class="ColHead" width="50"><a href="JavaScript: void fSort(4);">Times Listed</a></td>
			<td class="ColHead" width="40">REL</td>
			<td class="ColHead" width="40">AP 25+</td>
		</cfif>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput><form action="index.cfm?act=management.ntc&dsp=#attributes.dsp#" method="post" id="theForm" name="theForm"></cfoutput>
		</cfif>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td>#sqlTemp.owner#</td>
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title# (#sqlTemp.lid#)</td>
			<td>#DateFormat(sqlTemp.dtend, "mmm d, yyyy")#</td>
			<td align="center">#sqlTemp.listcount#</td>
		<cfif NOT isDefined("attributes.printable")>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="relITEMS" onClick="fREL(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="ap3ITEMS" onClick="fAP3(this.value, this.checked)"></td>
		</cfif>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput>
			<tr bgcolor="##FFFFFF"><td colspan="8" align="right">
				<cfif sqlTemp.RecordCount GT 0>
					<input type="button" onClick="fCheckAllAP3()" value="Check All AP 25+">
				</cfif>
				<input type="submit" value="Mark as Relotted/AP 25+" style="width:200px;">
			</td></tr>
			</form>
			<tr bgcolor="##FFFFFF"><td colspan="8" align="center">
				</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
			</td></tr>
			</cfoutput>
		</cfif>
		<cfoutput>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
