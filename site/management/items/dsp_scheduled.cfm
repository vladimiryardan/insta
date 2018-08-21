<cfif NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="2">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.searchTerm" default="">


<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, q.listAt, u.title, a.id, u.GalleryImage, q.error, 
		CASE WHEN LEN(u.use_pictures) > 0
			THEN u.use_pictures
			ELSE i.item
		END AS use_pictures, status.status as istatus,
		i.internal_itemSKU
		
	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		INNER JOIN auctions u ON i.item = u.itemid
		LEFT JOIN queue q ON i.item = q.itemid
		inner join status on i.status=status.id
	WHERE q.itemid IS NOT NULL<!--- scheduled --->
		AND u.ready = '1'
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
		<cfif attributes.searchTerm neq "">
			and (
			i.item like '%#attributes.searchTerm#%' 
			or u.title like '%#attributes.searchTerm#%'
			or i.internal_itemSKU like '%#attributes.searchTerm#%' 
			)
		</cfif>
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Scheduled:</strong></font>
	<div style="float:right;"><form action="index.cfm?dsp=management.items.scheduled" method="post">
		<input type="text" name="searchTerm" id="searchTerm">
		<input type="button" name="SearchTitleOrId" id="SearchTitleOrId" value="Search ID or Title">
		</form>
	</div>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead" width="8%">Gallery</td>
			<td class="ColHead" width="20%"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead" width="15%">Edit Auction</td>
			<td class="ColHead" width="15%">Preview Auction</td>
			<td class="ColHead" width="25%"><a href="JavaScript: void fSort(2);">Scheduled Time</a></td>
			<td class="ColHead" width="17%">Launch Now</td>
		</tr>
		</cfoutput>
		<cfset maximumRow = 0>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td rowspan="2" align="center"><cfif sqlTemp.GalleryImage EQ 0><img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg"><cfelse><a href="#request.images_path##sqlTemp.use_pictures#/#sqlTemp.GalleryImage#.jpg" target="_blank"><img src="#request.images_path##sqlTemp.use_pictures#/#sqlTemp.GalleryImage#thumb.jpg" border=1></cfif></td>
			<td align="center">
				<a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a><br>
				#sqlTemp.istatus#<br>
				#sqlTemp.internal_itemSKU#
			</td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border=0></a></td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.preview&item=#sqlTemp.item#"><img src="#request.images_path#icon12.gif" border=0></a></td>
			<td align="center"<cfif sqlTemp.error NEQ ""> style="color:red;"</cfif>>#DateFormat(sqlTemp.listAt, "mmmm d, yyyy")# #TimeFormat(sqlTemp.listAt, "HH:mm:ss")#</td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.launch&item=#sqlTemp.item#"><img src="#request.images_path#icon3.gif" border=0></a></td>
			<cfset maximumRow = CurrentRow>
		</tr>
		<tr bgcolor="##FFFFFF">
			<form action="index.cfm?act=admin.auctions.update_title&dsp=#attributes.dsp#&item=#sqlTemp.item#" method="post">
			<td colspan="4" align="center"><input type="text" name="title" value="#HTMLEditFormat(sqlTemp.title)#" style="width:450px;" maxlength="80"> <input type="submit" style="width:80px;" value="Update"></td>
			</form>
			<form action="index.cfm?act=admin.auctions.cancel_schedule&dsp=#attributes.dsp#&item=#sqlTemp.item#" method="post">
			<td align="center"><input type="submit" style="width:120px;" value="Cancel Schedule"></td>
			</form>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="6"><cfif sqlTemp.error EQ "">&nbsp;<cfelse>#sqlTemp.error#</cfif></td></tr>
		</cfoutput>
		<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="6" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
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
//-->
</script>
<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>


<script language="javascript" type="text/javascript">
<!--//

	$(function(){
			$('##SearchTitleOrId').click(function(){
			var $searchTerm = $('##searchTerm').val();

			if($searchTerm == ""){
				alert('Please enter search Term');
			}else{
				window.location.href = "#_machine.self#&searchTerm="+$searchTerm;
			}

			});
	});
//-->
</script>

</cfoutput>
