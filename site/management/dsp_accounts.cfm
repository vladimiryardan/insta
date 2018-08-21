<cfif NOT isAllowed("Accounts_EditAccounts")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfparam name="attributes.orderby" default="1">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.srchState" default="XX">
<cfset statesList = "XX,Any;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming">
<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function fPage(Page){
	window.location.href = "#_machine.self#&srchState=#attributes.srchState#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
function fSort(OrderBy){
	if (#attributes.orderby# == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&srchState=#attributes.srchState#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#"</cfif>;
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Account Management:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br>
	<cfparam name="attributes.msg" default="0">
	<cfswitch expression="#attributes.msg#">
		<cfcase value="1"><font color="red"><br><b>Account created successfully!</b><br></font></cfcase>
		<cfcase value="2"><font color="red"><br><b>Account NOT created successfully!</b><br></font></cfcase>
		<cfcase value="3"><font color="red"><br><b>Account deleted successfully!</b><br></font></cfcase>
	</cfswitch>
	<br>
	<table width="99%" align="center">
	<tr>
		<td align="left">
			Enter Account Number:<br>
			<form method="POST" action="index.cfm?dsp=account.edit" onSubmit="if(isNaN(this.id.value)||(this.id.value=='')){alert('Please enter Account Number!');return false;};">
				<input type="text" size="17" maxlength="18" name="id">
				<input type="submit" value="Manage">
			</form>
		</td>
		<td align="left">
			Enter Search Term:<br>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="14" maxlength="60" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<select name="srchState">#SelectOptions(attributes.srchState, statesList)#</select>
				<input type="submit" value="Search">
			</form>
		</td>
		<form name="PrxInputAdv" method="post" action="http://go.mappoint.net/ups/PrxInputAdv.aspx" id="PrxInputAdv" target="_blank">
		<td align="left" valign="middle">
			UPS Store Search:<br>
<!---
			<input type="hidden" name="__VIEWSTATE" value="dDwtMTU4NjAwMTQzO3Q8O2w8aTwzPjs+O2w8dDw7bDxpPDM+O2k8Nz47aTwxOT47PjtsPHQ8cDxwPGw8VGV4dDs+O2w8XGU7Pj47Pjs7Pjt0PDtsPGk8MT47PjtsPHQ8dDxwPHA8bDxEYXRhVmFsdWVGaWVsZDtEYXRhVGV4dEZpZWxkOz47bDxJc28zO0ZyaWVuZGx5TmFtZTs+Pjs+O3Q8aTw0PjtAPFVuaXRlZCBTdGF0ZXM7UHVlcnRvIFJpY287Q2FuYWRhO0luZGlhOz47QDxVU0E7UFJJO0NBTjtJTkQ7Pj47Pjs7Pjs+Pjt0PHA8cDxsPFRleHQ7PjtsPEZpbmQgeW91ciBuZWFyZXN0IFRoZSBVUFMgU3RvcmUgbG9jYXRpb24gYnkgZW50ZXJpbmcgdGhlIGxvY2F0aW9uIG51bWJlci47Pj47Pjs7Pjs+Pjs+PjtsPHdpZmlDa0JveDtmaW5kSW1hZ2VCdXR0b247YmlkRmluZEltYWdlQnV0dG9uOz4+ciFA+fjU0w4fg8pO7co8kcSgedk=" />
--->
			<input name="controlAddress:txtStreet" type="hidden" id="controlAddress_txtStreet" class="modTxtMedium" style="width:180px;" />
			<input name="controlAddress:txtCity" type="hidden" id="controlAddress_txtCity" class="modTxtMedium" style="width:180px;" />
			<input name="controlAddress:txtState" type="hidden" id="controlAddress_txtState" class="modTxtMedium" style="width:180px;" />
			<input name="controlAddress:txtZip" type="text" id="controlAddress_txtZip" class="modTxtMedium"  style="width:55px;FONT-SIZE: 11px"/>
			<input id="wifiCkBox" type="hidden" name="wifiCkBox" />
			<input type="image" name="findImageButton" id="findImageButton" src="#request.images_path#UPS_FindBtn.gif" alt="" border="0" />
		</td>
		</form>
	</tr>
	</table>
	<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		</cfoutput>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT id, first + ' ' + last AS name, email, store, phone, zip, dcreated, notes
			FROM accounts
			WHERE 1 = 1 and (is_archived != 1 or is_archived is null)
			<cfif attributes.srch NEQ "">
				AND
				(
					first LIKE '%#attributes.srch#%'
					OR last LIKE '%#attributes.srch#%'
					OR email LIKE '%#attributes.srch#%'
					OR address1 LIKE '%#attributes.srch#%'
					OR address2 LIKE '%#attributes.srch#%'
					OR city LIKE '%#attributes.srch#%'
					OR state LIKE '%#attributes.srch#%'
					OR zip LIKE '%#attributes.srch#%'
					OR phone LIKE '%#attributes.srch#%'
					OR company LIKE '%#attributes.srch#%'
					OR howfound LIKE '%#attributes.srch#%'
					OR store LIKE '%#attributes.srch#%'
					OR id LIKE '%#attributes.srch#%'
					OR notes LIKE '%#attributes.srch#%'
				)
			</cfif>
			<cfif attributes.srchState NEQ "XX">
				AND state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.srchState#">
			</cfif>
			<cfif #session.user.store# NEQ "201" AND #session.user.store# NEQ "101">
				AND store = #session.user.store#
			</cfif>
			ORDER BY #attributes.orderby# #attributes.dir#
		</cfquery>
		<cfset _paging.RecordCount = sqlTemp.RecordCount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="10" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		<tr bgcolor="##F0F1F3">
			<td class="ColHead"><a href="JavaScript: void fSort(4);">Store</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(1);">Account</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Name</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Email</a></td>
			<td class="ColHead">Phone</td>
			<td class="ColHead">Zip</td>
			<td class="ColHead"><a href="JavaScript: void fSort(7);">Created</a></td>
			<td class="ColHead">Expense</td>
			<td class="ColHead">TA Email</td>
			<td class="ColHead">New Item</td>
		</tr>
		</cfoutput>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td align="center">#sqlTemp.store#</td>
			<td align="center"><cfif isAllowed("Full_Access")><a title="Overview" href="index.cfm?dsp=account.overview&accountid=#sqlTemp.id#">#sqlTemp.id#</a><cfelse>#sqlTemp.id#</cfif></td>
			<td align="left"><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.name#</a></td>
			<td><a href="mailto:#sqlTemp.email#">#sqlTemp.email#</a></td>
			<td align="center">#sqlTemp.phone#</td>
			<td align="center">#sqlTemp.zip#</td>
			<td align="center">#DateFormat(sqlTemp.dcreated, "mmm d,yyyy")#</td>
			<td align="center"><a href="index.cfm?dsp=admin.finance.add&aid=#sqlTemp.id#">Add</a></td>
			<td align="center"><a href="index.cfm?dsp=management.taemail&aid=#sqlTemp.id#"><img border="0" src="#request.images_path#icon5.gif"></a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.create&accountid=#sqlTemp.id#"><img border="0" src="#request.images_path#icon12.gif" alt="Create New Item"></a></td>
		</tr>
		<cfif Trim(notes) NEQ "">
		<tr bgcolor="##FFFFFF"><td colspan="10">#notes#</td>
		</cfif>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="10" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
