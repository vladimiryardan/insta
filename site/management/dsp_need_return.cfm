<cfif NOT isAllowed("Lister_NeedToReturn")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="5">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.srchfield" default="all">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, i.ebayitem, i.title, i.listcount, e.dtend, i.lid, i.dlid
	FROM items i
		INNER JOIN ebitems e ON i.ebayitem = e.ebayitem
	WHERE
		(i.status = 8)<!--- Did Not Sell --->
			AND
		(
			e.hbuserid = ''
				OR
			e.hbuserid IS NULL
				OR
			i.dcalled IS NOT NULL
		)
		AND i.exception = 0
		AND e.dtend >= '2005-12-20'
	<cfif attributes.srch NEQ "">
		<cfswitch expression="#attributes.srchfield#">
			<cfcase value="all">
				AND (i.title LIKE '%#attributes.srch#%' OR i.item LIKE '%#attributes.srch#%')
			</cfcase>
			<cfdefaultcase>
				AND i.#attributes.srchfield# LIKE '%#attributes.srch#%'
			</cfdefaultcase>
		</cfswitch>
	</cfif>
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>

<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
	<cfoutput>
	<script language="javascript" type="text/javascript">
	<!--//
		function fPage(Page){
			window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#&srchfield=#attributes.srchfield#"</cfif>;
		}
		function fSort(OrderBy){
			if (#attributes.orderby# == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#&srchfield=#attributes.srchfield#"</cfif>;
		}
		function fNTC(ID, CHECKED){
			fCheck(ID, CHECKED, "ntrITEMS");
			fCheck(ID, CHECKED, "ap3ITEMS");
			fCheck(ID, CHECKED, "ntdITEMS");
		}
		function fNTR(ID, CHECKED){
			fCheck(ID, CHECKED, "ntcITEMS");
			fCheck(ID, CHECKED, "ap3ITEMS");
			fCheck(ID, CHECKED, "ntdITEMS");
		}
		function fAP3(ID, CHECKED){
			fCheck(ID, CHECKED, "ntcITEMS");
			fCheck(ID, CHECKED, "ntrITEMS");
			fCheck(ID, CHECKED, "ntdITEMS");
		}
		function fNTD(ID, CHECKED){
			fCheck(ID, CHECKED, "ntcITEMS");
			fCheck(ID, CHECKED, "ntrITEMS");
			fCheck(ID, CHECKED, "ap3ITEMS");
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
	</cfoutput>
</cfif>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Return to Client:</strong></font><br></td>
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
		<table width="100%">
		<tr>
			<td width="50%" align="left" valign="top">
				<strong>Administrator:</strong> #session.user.first# #session.user.last#
			</td>
			<td width="50%" align="left">
				Enter Search Term:<br>
				<form method="POST" action="#_machine.self#">
					<input type="text" size="20" maxlength="50" name="srch" value="#HTMLEditFormat(attributes.srch)#">
					<select name="srchfield" style="font-size: 13px;">
						#SelectOptions(attributes.srchfield, "all,All Fields;item,Item Number;title,Item Title")#
					</select>
					<input type="submit" value="Search">
				</form>
			</td>
		</tr>
		</table>
	</cfif>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
		<cfif isDefined("attributes.printable")>
			<td class="ColHead">Item ID</td>
			<td class="ColHead">eBay Item</td>
			<td class="ColHead">Title</td>
			<td class="ColHead">Date Ended</td>
			<td class="ColHead" width="50">Times Listed</td>
		<cfelse>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">eBay Item</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Title</a><br>(<i><a href="JavaScript: void fSort(6);">LID</a> - <a href="JavaScript: void fSort(7);">DLID</a></i>)</td>
			<td class="ColHead"><a href="JavaScript: void fSort(5);">Date Ended</a></td>
			<td class="ColHead" width="50"><a href="JavaScript: void fSort(4);">Times Listed</a></td>
			<td class="ColHead" width="40">NTC</td>
			<td class="ColHead" width="40">NTR</td>
			<td class="ColHead" width="40">AP 25+</td>
			<td class="ColHead" width="40" title="Move to 'Need to Donate' list">NTD</td>
		</cfif>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput><form action="index.cfm?act=management.ntc&dsp=#attributes.dsp#" method="post"></cfoutput>
		</cfif>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_blank">#sqlTemp.ebayitem#</a></td>
			<td>#sqlTemp.title#<cfif Len(sqlTemp.lid) GT 0><br>(<i>#sqlTemp.lid# - #DateFormat(sqlTemp.dlid, "mmm d, yyyy")#</i>)</cfif></td>
			<td nowrap>#DateFormat(sqlTemp.dtend, "mmm d, yyyy")#</td>
			<td align="center">#sqlTemp.listcount#</td>
		<cfif NOT isDefined("attributes.printable")>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="ntcITEMS" onClick="fNTC(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="ntrITEMS" onClick="fNTR(this.value, this.checked)"></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="ap3ITEMS" onClick="fAP3(this.value, this.checked)" checked></td>
			<td align="center"><input type="checkbox" value="#sqlTemp.item#" name="ntdITEMS" onClick="fNTD(this.value, this.checked)"></td>
		</cfif>
		</tr>
		</cfoutput>
		<cfif NOT isDefined("attributes.printable")>
			<cfoutput>
			<tr bgcolor="##FFFFFF"><td colspan="9" align="right">
				<input type="submit" value="Mark as NTC/NTR/AP 25+/NTD" style="width:200px;">
			</td></tr>
			</form>
			<tr bgcolor="##FFFFFF"><td colspan="9" align="center">
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
