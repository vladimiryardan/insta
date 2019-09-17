

<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>



<cfparam name="attributes.orderby" default="i.id">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.srchfield" default="internal_itemSKU2">
<cfparam name="attributes.start" default="0">
<cfset startTime = getTickCount() />
<cfoutput>


<cfparam name="attributes.repday" default="#Now()#">
<cfset currMonth = Month(attributes.repday)>
<!--- getting total --->
<cfquery name="sqlTempTotal" datasource="#request.dsn#">
		SELECT SUM(case when i.buy_it_now > 0 then i.buy_it_now else i.startprice_real end) as iTotal
		FROM items i				
			INNER JOIN accounts a ON i.who_created = a.id
			
		WHERE YEAR(i.dcreated) = <cfqueryparam cfsqltype="cf_sql_integer" value="#year(attributes.repday)#">
			AND MONTH(i.dcreated) = <cfqueryparam cfsqltype="cf_sql_integer" value="#currMonth#">
			AND DAY(i.dcreated) = <cfqueryparam cfsqltype="cf_sql_integer" value="#day(attributes.repday)#">
			AND i.status != 2
			AND a.rid != 10
			AND a.id in (#session.user.ACCOUNTID#)
			and dummy != 1
</cfquery>
	

		
					
<cfif isdefined("attributes.srch")>
	<cfset attributes.srch = trim(attributes.srch)>	
</cfif>
<script language="javascript" type="text/javascript">
<!--//


function flagPrint(itemid){
/*	alert('Please save/update item and set PRINTED LABEL value to YES if the printing of LABEL is successful!');
	nw=window.open('index.cfm?dsp=management.items.edit&item='+itemid,'NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');
	nw.opener=self;
	nw.focus();
	*/
	window.location.href = "index.cfm?act=management.update_printlabel&item="+itemid;
}
function fPage(Page){
	window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#&srchfield=#attributes.srchfield#"</cfif>;
}
function fSort(OrderBy){
	if ('#attributes.orderby#' == OrderBy){
		dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
	}else{
		dir = "ASC";
	}
	window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir<cfif attributes.srch NEQ "">+"&srch=#URLEncodedFormat(attributes.srch)#&srchfield=#attributes.srchfield#"</cfif>;
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
function fOnChange(num){
	var formObj = document.all?document.all.frm:document.getElementById("frm");
	var cs = eval("formObj.cs"+num);
	cs.checked = true;
}
function fChange(num){
	var formObj = document.all?document.all.frm:document.getElementById("frm");
	var itemValue = eval("formObj.item"+num+".value");
	var ebayitemValue = eval("formObj.ebayitem"+num+".value");
	var newstatusidValue = eval("formObj.newstatusid"+num+".value");
	window.location.href = "index.cfm?act=management.items.change_status&item="+itemValue+"&ebayitem="+ebayitemValue+"&newstatusid="+newstatusidValue;
}
function fShipNote(itemid){
	ShipNoteWin = window.open("index.cfm?dsp=admin.ship.note&itemid="+itemid, "ShipNoteWin", "height=300,width=600,location=no,scrollbar=yes,menubar=yes,toolbars=yes,resizable=yes");
	ShipNoteWin.opener = self;
	ShipNoteWin.focus();
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Item Management:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last# | 
	<strong <cfif sqlTempTotal.iTotal gt 1000>style="color:green"</cfif>> #numberFormat(sqlTempTotal.iTotal,"9,999.99")# </strong>
	</td><td align="right" width="50%">
<cfif isAllowed("EndOfDay_Processing")>
	<b>Print Daily Report For:</b>
	<a href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
	&nbsp;|&nbsp;
	<a href="index.cfm?dsp=admin.processing_daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
</cfif>
	</td></tr></table>
	<br>
	</cfoutput>
	<cfif isDefined("attributes.msg")>
		<cfswitch expression="#attributes.msg#">
			<cfcase value="1"><cfoutput><font color=red><br><b>Item deleted sucessfully!</b><br></font></cfoutput></cfcase>
			<cfcase value="2">
				<cfoutput>
				<font color=red><br><b>Item created successfully!</b><br></font>
				<script language="JavaScript" type="text/javascript">
				<!--//
					//patrick wanted to get rid of the pop up 20101204 - vlad
					//nw=window.open('index.cfm?dsp=management.items.customerslip&item=#attributes.itemid#','NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');
					nu=window.open('index.cfm?dsp=management.items.itemslip&item=#attributes.itemid#','NewWin2','height=200,width=400,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');
				//-->
				</script>
				</cfoutput>
			</cfcase>
			<cfcase value="10"><cfoutput><font color=red><br><b>Could not find account. Item NOT created sucessfully!</b><br></font></cfoutput></cfcase>
			<cfcase value="20"><cfoutput><font color=red><br><b>Item NOT created sucessfully!</b><br></font></cfoutput></cfcase>
		</cfswitch>
	</cfif>
	<cfoutput>
	<br>
	<table width="100%">
	<tr>
		<td width="50%" align="left">
			Enter Item Number:<br>
			<form method="POST" action="index.cfm?dsp=management.items.edit">
				<input type="text" size="20" maxlength="18" name="item" id="item">
				<input type="submit" value="Manage Item">
			</form>
		</td>
		<td width="50%" align="left">
			Enter Search Term:<br>
			<form method="POST" action="#_machine.self#">
				<input type="text" size="20" maxlength="50" name="srch" value="#HTMLEditFormat(attributes.srch)#">
				<select name="srchfield" style="font-size: 13px;">
					#SelectOptions(attributes.srchfield, "all,All Fields;item,Item Number;title,Item Title;description,Description;Owner,Owner;ebayitem,eBay Number;ebaytitle,eBay Title;HighBidder,High Bidder ID;HighBidderEmail,High Bidder Email;tracking,Tracking Number;ebayhistory,eBay History;extExternalTransactionID,PayPal Transaction ID;internal_itemSKU,SKU;internal_itemSKU2,SKU2;LID,LID;UPC,UPC;itemExact,Item Exact Number;Bonanza,Bonanza Bidder;salesRecord, sales Record")#
				</select>
				<input type="submit" value="Search">
			</form>
		</td>
		<tr>
			<td>&nbsp;</td>
			<td><small>
				<b>foot%met</b> - will find "<b>foot</b>ball hel<b>met</b>"<br>
				<b>b.d</b> - will find "b<b>a</b>d", "b<b>e</b>d" but NOT "b<b>re</b>d"
			</small></td>
		</tr>
	</tr>
	</table><br><br>
		</cfoutput>
		


		
		<cfset attributes.start = (attributes.page-1)*_paging.RowsOnPage>
		<cfquery name="sqlTemp" datasource="#request.dsn#" >
			SELECT top 500 i.title, e.price, a.first + ' ' + a.last AS owner, a.first, a.last, i.item,i.internal_itemCondition, a.id,
				s.status, s.id as statusid, e.galleryurl, i.dcreated, a.email, i.ebayitem, a.store,
				i.lid, i.ebayitem, i.startprice, i.shipnote, u.ready, i.label_printed, i.internal_itemSKU,a.is_archived, u.use_pictures, i.paid, 
				i.ShippedTime, i.customer_returned, i.dpictured, i.itemis_template,i.itemis_template_setdate, i.ebayTxnid

			FROM accounts a
				INNER JOIN items i ON a.id = i.aid
				LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
				LEFT JOIN status s ON i.status = s.id
				LEFT JOIN auctions u ON i.item = u.itemid
			<cfif attributes.srch NEQ "">
				<cfswitch expression="#attributes.srchfield#">
					<cfcase value="extExternalTransactionID">
						INNER JOIN ebtransactions t ON t.itmItemID = i.ebayitem
						WHERE t.extExternalTransactionID = '#attributes.srch#'
					</cfcase>
					<cfcase value="all">
					<!--- vlad added filter of archived users --->
						WHERE
						(a.is_archived != 1 or a.is_archived is null) and

						(
							 i.item LIKE '#attributes.srch#%'
							OR i.description LIKE '#attributes.srch#%'
							OR a.email LIKE '#attributes.srch#%'
							OR a.first LIKE '#attributes.srch#%'
							OR a.last LIKE '#attributes.srch#%'
							OR a.id LIKE '#attributes.srch#%'
							OR i.ebayitem LIKE '#attributes.srch#%'
							OR i.byrName LIKE '#attributes.srch#%'
							OR i.byrCompanyName LIKE '#attributes.srch#%'
							OR e.hbuserid LIKE '#attributes.srch#%'
							OR i.item IN (SELECT itemid FROM ebitems WHERE ebayitem LIKE '#attributes.srch#%')
							OR i.internal_itemSKU LIKE '#attributes.srch#%'
							OR i.internal_itemSKU2 LIKE '#attributes.srch#%'
							OR e.title LIKE '#attributes.srch#%'
							OR i.title LIKE '#attributes.srch#%'
							OR i.lid LIKE '#attributes.srch#%'
							OR i.internal_itemSKU LIKE '#attributes.srch#%'
							OR i.internal_itemSKU2 LIKE '#attributes.srch#%'							
							OR i.ebayTxnid LIKE '#attributes.srch#%'
						)

					</cfcase>
					<cfcase value="Owner">
						WHERE a.email LIKE '%#attributes.srch#%'
							OR a.first LIKE '%#attributes.srch#%'
							OR a.last LIKE '%#attributes.srch#%'
							OR a.id LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="HighBidder">
						WHERE e.hbuserid = '#attributes.srch#'
							<!---AND (i.status = 5 OR i.status = 10)--->
					</cfcase>
					<cfcase value="HighBidderEmail">
						WHERE e.hbemail LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="ebaytitle">
						WHERE e.title LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="ebayhistory">
						WHERE i.item IN (SELECT itemid FROM ebitems WHERE ebayitem LIKE '%#attributes.srch#%')
					</cfcase>
					<cfcase value="internal_itemSKU">
						WHERE i.internal_itemSKU LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="internal_itemSKU2">
						WHERE i.internal_itemSKU2 LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="LID">
						WHERE i.lid LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="upc">
						WHERE i.upc LIKE '%#attributes.srch#%'
					</cfcase>
					<cfcase value="item">
						WHERE i.item like '%#attributes.srch#%'
					</cfcase>
					<cfcase value="itemExact">
						WHERE i.item = '#attributes.srch#'
					</cfcase>	
					<cfcase value="Bonanza">
						WHERE i.bonanza_bidder = '#attributes.srch#'
					</cfcase>	
					<cfcase value="salesRecord">
						WHERE i.ebayTxnid = '#attributes.srch#'
					</cfcase>								
					<cfdefaultcase>
						WHERE i.#attributes.srchfield# LIKE '%#attributes.srch#%'
					</cfdefaultcase>
				</cfswitch>
			</cfif>
			<cfif #session.user.store# NEQ "201" AND #session.user.store# NEQ "101">
				<cfif attributes.srch NEQ "">
					AND a.store = #session.user.store# and	(a.is_archived != 1 or a.is_archived is null)

				<cfelse>
					WHERE a.store = #session.user.store# and (a.is_archived != 1 or is_archived is null)
				</cfif>
			</cfif>
			
			<cfif attributes.srch NEQ "">
				ORDER BY  i.itemis_template desc, #attributes.orderby# #attributes.dir#
			<cfelse>
				ORDER BY  #attributes.orderby# #attributes.dir#	
			</cfif>	
			
		</cfquery>
		
		

<!---
<cfdump var = "#sqlTemp#">
	--->


		<cfset _paging.RecordCount = sqlTemp.recordcount>
		<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

		


		<cfoutput>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##FFFFFF"><td colspan="10" align="center">
		</cfoutput><cfinclude template="../../paging.cfm">
		<cfoutput>
		</td></tr>
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">Gallery</td>
			<td class="ColHead">Note</td>
			<td class="ColHead"><a href="JavaScript: void fSort(3);">Owner</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(6);">Item Number</a></td>
			<td class="ColHead"><a href="JavaScript: void fSort(2);">Final Price</a></td>
			<td class="ColHead">Label</td>
			<td class="ColHead" width="90">Upload<br>Images</td>
			<td class="ColHead" width="90">Mobile <br>Auction Images </td>
			<td class="ColHead" width="100">Copy, Relist</td>
			<td class="ColHead" width="50">
				<a href="JavaScript: void fSort(7);">Internal Item</a>
				<input type="button" id="Togglebutton" value="All">
			</td>
			<!---<td class="ColHead" width="50">Send Invoice</td>--->
		</tr>
		<cfif isAllowed("Items_ChangeStatus") OR isAllowed("Items_NormalChangeStatus")>
		<form id="frm" method="POST" action="index.cfm?act=management.items.mass_change_status&backdsp=management.items&srch=#attributes.srch#">
		</cfif>
		</cfoutput>
		<cfset num = 0>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<cfset num = num + 1>
		<tr bgcolor="##F0F1F3">
			
			<td rowspan="2" bgcolor="##FFFFFF" align="center" id="tThumb#sqlTemp.item#">
			<!---	20120216 thumb fix
				<cfif sqlTemp.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
					<a href="#sqlTemp.galleryurl#" target="_blank"><img src="#sqlTemp.galleryurl#" width=80 border=1>
				</cfif>--->

				<cfif sqlTemp.galleryurl EQ "">
					<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
				<cfelse>
					
					
							
							<cfhttp method="head" url="#replaceNoCase(sqlTemp.galleryurl,"https","http")#" result="sc">
							<cfif sc.statuscode is "200 OK">
								<a href="#sqlTemp.galleryurl#" target="_blank">
									<img src="#sqlTemp.galleryurl#" border="1" width="80">
								</a>							
							<cfelse>
								<!--- use_pictures --->
								<cfset sqlTemp.galleryurl = replace(sqlTemp.galleryurl,sqlTemp.item,sqlTemp.use_pictures)>
								<img src="#sqlTemp.galleryurl#" border="1" width="80">
							</cfif>
							
							<!--- patrick wants smaller than 500 to display red background --->
							<!---<cfimage source="#sqlTemp.galleryurl#" name="myImage">
							<cfif myImage.width lt 500 and myImage.height lt 500>
								<script type="text/javascript">									
									var element = document.getElementById('tThumb#sqlTemp.item#');
									element.style.background = '##ff0000';
								</script>
							</cfif>--->
					<cftry>		
					<cfcatch>
						<img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg">
					</cfcatch>
					</cftry>
					
				</cfif>
			</td>
			<td rowspan="2" align=center><cfif isAllowed("Listings_EditShippingNote")><a href="javascript: fShipNote('#sqlTemp.item#')"><cfif sqlTemp.shipnote EQ ""><img src="#request.images_path#icon14.gif" border=0><cfelse>Edit</cfif></a><cfelse><cfif sqlTemp.shipnote EQ "">N/A<cfelse><a href="javascript: fShipNote('#sqlTemp.item#')">View</a></cfif></cfif></td>
			<td colspan="4" align="left">
				<cfif DateDiff("d", sqlTemp.dcreated, Now()) EQ 0><img src="#request.images_path#newsun.gif"></cfif>
				<cfset titleColor = "##26353F">
				<cfif sqlTemp.lid is "p&s" and paid eq 0>
					<cfset titleColor = "##aa0000">
				</cfif>
				<!--- 20140114 - turn red if item is returned  --->
				<cfif sqlTemp.customer_returned is "1">
					<cfset titleColor = "##aa0000">
				</cfif>
				<b style="color:#titleColor#">#sqlTemp.title#</b>
				<i>(#DateFormat(sqlTemp.dcreated)#)</i>
			</td>
			
			<td colspan="4" align="right">
			<cfif isAllowed("Items_ChangeStatus") OR (isAllowed("Items_NormalChangeStatus") AND ListFind("2,3,9,12", sqlTemp.statusid))>
				<input type="hidden" name="item#num#" value="#sqlTemp.item#">
				<input type="hidden" name="ebayitem#num#" value="#sqlTemp.ebayitem#">
				<select name="newstatusid#num#" onChange="fOnChange(#num#)">
				<cfif isAllowed("Items_ChangeStatus")>
					#SelectOptions(sqlTemp.statusid, "2,Item Created;3,Item Received;4,Auction Listed;5,Awaiting Payment;10,Awaiting Shipment;11,Paid and Shipped;8,Did Not Sell;12,Need to Call;13,Donated to Charity;14, Item Relotted;9,Returned to Client;7,Check Sent;16,Fixed Inventory;6,Reserve Not Met")#
				<cfelse>
					#SelectOptions(sqlTemp.statusid, "2,Item Created;3,Item Received;12,Need to Call;9,Returned to Client")#
				</cfif>
				</select>
				<input type="button" style="font-size: 10px;" value="Save" onClick="fChange(#num#)">
				<input type="checkbox" name="cs#num#" value="1" class="checkBoxes">
			<cfelse>
				#sqlTemp.status#
			</cfif>
			
			</td>
		</tr>
		

		<tr bgcolor="##FFFFFF">
			<td align="center"><a href="index.cfm?dsp=account.edit&id=#sqlTemp.id#">#sqlTemp.owner#</a></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#"
			<cfif sqlTemp.label_printed eq 1> style="color:blue"</cfif> >#sqlTemp.item#</a>
			<cfif sqlTemp.lid NEQ ""><br>LID: #sqlTemp.lid#<BR></cfif>
			<cfif sqlTemp.internal_itemSKU NEQ ""><span style="font-size:10px">SKU: #sqlTemp.internal_itemSKU#</span></cfif>
			<cfif sqlTemp.ebayitem NEQ ""><br>(<a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlTemp.ebayitem#" target="_new">#sqlTemp.ebayitem#</a>)</cfif></td>
			<td align="center"><cfif sqlTemp.price NEQ "">#DollarFormat(sqlTemp.price)#<cfelse>$0</cfif><cfif sqlTemp.startprice GT 0><br><font color="blue">(#DollarFormat(sqlTemp.startprice)#)</font></cfif></td>
			<td align="center"><a href="JavaScript: fLabel('#sqlTemp.item#');flagPrint('#sqlTemp.item#');"><img border="0" src="#request.images_path#icon11.gif" alt="Print Label"></a></td>
			<td align="center">
				<!---<a href="JavaScript: fSSheet('#sqlTemp.item#');">
					<img border="0" src="#request.images_path#icon11.gif" alt="Print Signing Sheet">
				</a>--->
				<a href="index.cfm?dsp=admin.auctions.upload_pictures&items=#sqlTemp.item#">
					<img border="0" src="/imagesnotes/instagram500.png" alt="Print Signing Sheet">
				</a>				
			</td>
			
			<!--- if pictured at change --->
			<cfset bgColor = "white" >	
			<cfif isdate(sqlTemp.dpictured)>
				<cfset bgColor = "green" >
			</cfif>	
			<!--- step 4 --->
			<td align="center" style="background-color:#bgColor#">

				
				<a href="index.cfm?dsp=admin.auctions.step3&from=upload_pictures&item=#sqlTemp.item#">
					<img border="0" src="/imagesnotes/mobile-05-48.png" alt="Print Signing Sheet" >
				</a>				
			</td>		
				
			<td align="center">
				<a href="index.cfm?dsp=management.items.copy&item=#sqlTemp.item#"><img border="0" src="#request.images_path#icon3.gif" alt="Create Similar Item"></a>
				<cfif (sqlTemp.statusid NEQ "4") AND (sqlTemp.ready EQ 1) AND isAllowed("Lister_ListAuction")><!--- Auction Listed --->
					, <a href="index.cfm?dsp=admin.auctions.relist_item&item=#sqlTemp.item#"><img alt="Relist Item" src="#request.images_path#icon8.gif" border="0"></a>
				</cfif>
			</td>
			<td>#sqlTemp.internal_itemCondition#</td>
	<!---		<td align="center">
				<cfif sqlTemp.ebayitem NEQ "">
					<a href="index.cfm?dsp=api.mymessages.send_invoice&item=#sqlTemp.ebayitem#"><img border="0" src="#request.images_path#icon5.gif" alt="Send Invoice"></a>
				<cfelse>
					N/A
				</cfif>
			</td>--->
		</tr>
		<tr bgcolor="##F0F1F3">
		<cfif sqlTemp.ebayTxnid gte 1>
			<tr bgcolor="##FFFFFF">
				<td valign="middle" align="right"><b>Sales Record:</b></td>
				<td colspan="10" align="left">#sqlTemp.ebayTxnid#</td>
			</tr>
		</cfif>
		</tr>
		<cfif sqlTemp.shipnote NEQ "">
			<tr bgcolor="##F0F1F3"><td colspan="10"><b>Note: </b>#sqlTemp.shipnote#<br><br></td></tr>
		<cfelse>
			<!---<tr bgcolor="##F0F1F3"><td colspan="10">&nbsp;</td></tr>--->
		</cfif>
		<cfif sqlTemp.itemis_template is 1>
			<tr bgcolor="##F0F1F3">
				<td colspan="10" style="background-color:##E49BB4">
							This is an auction template	#dateformat(sqlTemp.itemis_template_setdate,"medium")#
				</td>
			</tr>
		</cfif>
		
		<td colspan="10">&nbsp;</td>
		<tr bgcolor="##FFFFFF"><td colspan="10">&nbsp;</td></tr>
		</cfoutput>
		<cfoutput>
		<cfif isAllowed("Items_ChangeStatus") OR isAllowed("Items_NormalChangeStatus")>
		<tr bgcolor="##F0F1F3">
			<td>
				<input type="submit" name="changelid" value="Update LID Selected" style="font-size: 10px;">
				<input type="text" name="newlidName" value="">
			</td>
			<td colspan="8" align="right">
			<input type="submit" style="font-size: 10px;" value="Change Selected">
			<input type="hidden" name="num" value="#num#">
			</form>
			</td>
		</tr>
		</cfif>
		<tr bgcolor="##FFFFFF"><td colspan="9" align="center">
			</cfoutput><cfinclude template="../../paging.cfm"><cfoutput>
		</td></tr>
		</table>
	</td></tr>
	</table>
</td></tr>




<tr>
	<td>
<cfset eTime = getTickCount() />
<cfset intRunTimeInSeconds = DateDiff(
"s",
GetPageContext().GetFusionContext().GetStartTime(),
Now()
) />
<h3>Page load #intRunTimeInSeconds# Seconds! (#(eTime-startTime)/1000#)
</h3>
	</td>
</tr>
</table>



<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
<!--
document.getElementById("item").focus();
//checkall
$(function () {

    $('##Togglebutton').click(function() {
            $('.checkBoxes').each(function() {
                $(this).attr('checked',!$(this).attr('checked'));
            });
    });

});
//-->

</script>

<!---<cfquery name="sqlAuction" datasource="#request.dsn#">
	SELECT *
	FROM auctions
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>--->

<!---
	function fShowImage(num){
	if(FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#arguments.num#.jpg")){
		WriteOutput('<a href="##" onClick="return false;" onMouseOver="document.clicPicBig.src=preloadedImage#arguments.num#.src; return false;"><img src="#_layout.ia_images##sqlAuction.use_pictures#/#arguments.num#thumb.jpg" border="1"></a>');
		variables.jsPreload = variables.jsPreload & "var preloadedImage#arguments.num#=new Image(); preloadedImage#arguments.num#.src='#_layout.ia_images##sqlAuction.use_pictures#/#arguments.num#.jpg';";
	}else{
		WriteOutput('&nbsp;');
	}
}--->

<!---<cffunction name="getImageDimension" access="public" output="false" description="given an imagepath return image dimensions">
	<cfargument name="urlPath">
	<cfimage source="#urlPath#" name="myImage">
	<cfreturn myImage>
</cffunction>--->

</cfoutput>
