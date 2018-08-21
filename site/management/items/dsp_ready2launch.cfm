

<cfif NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfset _paging.RowsOnPage = _vars.paging.RowsOnPageReady2Launch><!--- HARDCODE --->
<cfparam name="attributes.orderby" default="DATEPART(SECOND, i.dcreated)">
<cfparam name="attributes.dir" default="DESC">
<cfparam name="attributes.page" default="1">

<cfparam name="attributes.page" default="1">

<cfparam name="attributes.searchTerm" default="">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT i.item, u.title, a.id, u.GalleryImage, u.CategoryID, u.subtitle,
		CASE WHEN LEN(u.use_pictures) > 0
			THEN u.use_pictures
			ELSE i.item
		END AS use_pictures, u.StartingPrice, u.Duration,
		ea.UserID, i.internal_itemCondition, i.dlid, i.lid, u.BuyItNowPrice

	FROM accounts a
		INNER JOIN items i ON a.id = i.aid
		INNER JOIN auctions u ON i.item = u.itemid
		LEFT JOIN queue q ON i.item = q.itemid
		LEFT JOIN ebaccounts ea ON ea.eBayAccount = u.ebayaccount
	WHERE i.status = '3'<!--- ITEM RECEIVED --->
		AND q.itemid IS NULL<!--- not scheduled --->
		AND u.ready = '1'
		<cfif attributes.searchTerm neq "">
			and (i.item like '%#attributes.searchTerm#%' or u.title like '%#attributes.searchTerm#%')
		</cfif>
	ORDER BY #attributes.orderby# #attributes.dir#
</cfquery>
<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>
<cfset grandTotal = 0>
<cfquery name="sqlApiCall" datasource="#request.dsn#">
	SELECT callname, SUM(callcount) AS cnt
	FROM ebapilogcall
	WHERE dwhen = '#dateformat(now(),'yyyy-mm-dd')# 00:00:00' <!---and callname='GetCategoryFeatures'--->
	GROUP BY callname
</cfquery>


<!--- limit if 5k api calls per day --->
<table>
<cfoutput query="sqlApiCall" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
<tr bgcolor="##FFFFFF">
	<td><cfif sqlApiCall.cnt gte 3000>
	<h3 style="color:red">Warning! #sqlApiCall.callname# API Call - #sqlApiCall.cnt# </h3></cfif></td>
	<cfset grandTotal = grandTotal + sqlApiCall.cnt>
</tr>
</cfoutput>
<cfoutput>
<cfif grandTotal gte 3000>
		<tr><td>
			<h3 style="color:red">#grandTotal# Total API CALL </h3><em>(Limit of 5000 per day)</em>
		</td></tr>
	</cfif>
</cfoutput>
</table>

<cfoutput>
<table width="100%" style="text-align: justify;">

<tr><td>
	<font size="4"><strong>Ready to Launch:</strong></font>  			<div style="float:right;">
	<form action="index.cfm?dsp=management.items.ready2launch" method="post"><input type="text" name="searchTerm" id="searchTerm"><input type="button" name="SearchTitleOrId" id="SearchTitleOrId" value="Search ID or Title"></form></div>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead" width="8%">Gallery</td>
			<td class="ColHead" width="23%"><a href="JavaScript: void fSort(1);">Item ID</a></td>
			<td class="ColHead" width="15%">eBay Account</td>
			<td class="ColHead" width="18%">Edit Auction</td>
			<td class="ColHead" width="18%">Preview Auction</td>
			<td class="ColHead" width="18%">Launch Now</td>
			<td class="ColHead" width="23%"><a href="JavaScript:fCheckAll()">Schedule</a></td>
		</tr>
		<form action="index.cfm?act=admin.auctions.schedule" method="post">
		</cfoutput>
		<cfset maximumRow = 0>
		<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
		<tr bgcolor="##FFFFFF">
			<td rowspan="4" align="center"><cfif sqlTemp.GalleryImage EQ 0><img src="http://pics.ebaystatic.com/aw/pics/stockimage1.jpg"><cfelse><a href="#request.images_path##sqlTemp.use_pictures#/#sqlTemp.GalleryImage#.jpg" target="_blank"><img src="#request.images_path##sqlTemp.use_pictures#/#sqlTemp.GalleryImage#thumb.jpg" border=1></cfif></td>
			<td align="center"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
			<td>#sqlTemp.UserID#</td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border=0></a></td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.preview&item=#sqlTemp.item#" target="_blank"><img src="#request.images_path#icon12.gif" border=0></a></td>
			<td align="center"><a href="index.cfm?dsp=admin.auctions.launch&item=#sqlTemp.item#"><img src="#request.images_path#icon3.gif" border=0></a></td>
			<td align="center"><input type="checkbox" name="cb#CurrentRow#" id="cb#CurrentRow#" value="#sqlTemp.item#" onClick="updateEndTime()"></td>
			<cfset maximumRow = CurrentRow>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"<cfif (Len(sqlTemp.title) EQ 0) OR (sqlTemp.GalleryImage EQ 0) OR (sqlTemp.CategoryID EQ 0)> bgcolor="red"</cfif>>
				<small>Duration</small>
				<select size="1" name="duration_#CurrentRow#" style="width:60px;">
					#SelectOptions(sqlTemp.Duration, "1,1;3,3;5,5;7,7;10,10;30,30;60,60;90,90;120,120;0,every 30")#
				</select>
			</td>
			<td colspan="4" align="center"<cfif (Len(sqlTemp.title) EQ 0) OR (sqlTemp.GalleryImage EQ 0) OR (sqlTemp.CategoryID EQ 0)> bgcolor="red"</cfif>>
				<input type="hidden" name="item_#CurrentRow#" value="#sqlTemp.item#">
				<input style="width:350px;" type="text" name="title_#CurrentRow#" value="#HTMLEditFormat(sqlTemp.title)#" maxlength="80" onChange="fCharsLeft('dyna#CurrentRow#', this.value, 80)" onKeyUp="fCharsLeft('dyna#CurrentRow#', this.value, 80)">
			</td>
			<td align="center"><font id="dyna#CurrentRow#">(#80-Len(sqlTemp.title)# chars left)</font></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"<cfif (Len(sqlTemp.title) EQ 0) OR (sqlTemp.GalleryImage EQ 0) OR (sqlTemp.CategoryID EQ 0)> bgcolor="red"</cfif>>
				<small>Start Price:</small>
				<input style="width:50px;" type="text" name="startingprice_#CurrentRow#" value="#sqlTemp.StartingPrice#" maxlength="10">
				<br>
				<small>Buy Now:</small>
				<input style="width:50px;" type="text" name="buynowPrice_#CurrentRow#" value="#sqlTemp.BuyItNowPrice#">
			</td>
			<td colspan="4" align="center"<cfif (Len(sqlTemp.title) EQ 0) OR (sqlTemp.GalleryImage EQ 0) OR (sqlTemp.CategoryID EQ 0)> bgcolor="red"</cfif>>
				<input style="width:350px;" type="text" name="subtitle_#CurrentRow#" value="#HTMLEditFormat(sqlTemp.subtitle)#" maxlength="55" onChange="fCharsLeft('subdyna#CurrentRow#', this.value, 55)" onKeyUp="fCharsLeft('subdyna#CurrentRow#', this.value, 55)">
			</td>
			<td align="center"><font id="subdyna#CurrentRow#">(#55-Len(sqlTemp.subtitle)# chars left)</font></td>
		</tr>


		<!--- ebay item condition --->
		<cfquery name="sqlAuction" datasource="#request.dsn#">
			SELECT *
			FROM auctions
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlTemp.item#">
		</cfquery>
		<cfset _ebay.CallName ="GetCategoryFeatures">
		<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
		<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
			<RequesterCredentials>
				<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
			</RequesterCredentials>

		  <DetailLevel>ReturnAll</DetailLevel>
		  <ViewAllNodes>true</ViewAllNodes>
		  <CategoryID>#sqlAuction.CategoryID#</CategoryID>
		  <FeatureID>ConditionEnabled</FeatureID>
		  <FeatureID>ConditionValues</FeatureID>

		</#_ebay.CallName#Request>'>
				<cfset _ebay.ThrowOnError = false>
				<cfinclude template="../../api/act_call.cfm">


		<tr bgcolor="##FFFFFF">
			<td align="right"<cfif (Len(sqlTemp.title) EQ 0) OR (sqlTemp.GalleryImage EQ 0) OR (sqlTemp.CategoryID EQ 0)> bgcolor="red"</cfif>>
				<small>Item Condition:</small>
				<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
						<cftry>
						<a href="#_ebay.xmlResponse.GetCategoryFeaturesResponse.Category.ConditionValues.ConditionHelpURL.XmlText#" target="_blank">Condition</a><br>
						<select name="ItemCondition_#CurrentRow#">
								<!---<option value="">	- </option>--->
								<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.GetCategoryFeaturesResponse.Category.ConditionValues.Condition)#">
									<option value="#_ebay.xmlResponse.GetCategoryFeaturesResponse.Category.ConditionValues.Condition[i].XmlChildren['1'].XmlText#" <cfif "#sqlAuction.conditionID#" eq "#_ebay.xmlResponse.GetCategoryFeaturesResponse.Category.ConditionValues.Condition[i].XmlChildren['1'].XmlText#">selected</cfif>>#_ebay.xmlResponse.GetCategoryFeaturesResponse.Category.ConditionValues.Condition[i].XmlChildren['2'].XmlText#</option>
								</cfloop>
						</select>
						<cfcatch type="any">
							<cfoutput>
								Item Condition Error: #sqlAuction.itemid#
							</cfoutput>
						</cfcatch>
						</cftry>
				<cfelse>
						<cfif isDefined("_ebay.XMLResponse.xmlRoot.Errors.LongMessage.xmlText")>
							<cfoutput><h1 style="color:red;">#_ebay.XMLResponse.xmlRoot.Errors.LongMessage.xmlText#</h1></cfoutput>
						<cfelse>
							<cfdump var="#_ebay#">
						</cfif>
						<cfabort>
				</cfif>
			</td>
			<td colspan="4" align="left">
				#sqlTemp.internal_itemCondition#
			</td>
			<td align="center"><b>LID:</b><br> <cfif sqlTemp.lid NEQ ""><b>#sqlTemp.lid#</b> <i>(#DateFormat(sqlTemp.dlid)# #TimeFormat(sqlTemp.dlid)#)<cfelse>NONE</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="7">&nbsp;</td></tr>
		<!--- item condition --->

		</cfoutput>
		<cfoutput>
		<tr bgcolor="##F0F1F3"><td colspan="7" align="center"><input type="submit" name="update" value="Update Duration, Start Prices, Titles and SubTitles for all items above"></td></tr>
		<tr bgcolor="##FFFFFF">
			<td colspan="6" align="right" style="font-weight:bold;" id="totalChecked">&nbsp;</td>
			<td class="ColHead"><a href="JavaScript:fCheckAll()">Check All</a></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="7" align="center">
			</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
		</td></tr>
		<tr bgcolor="##FFFFFF">
			<td colspan="6">
				<table cellpadding="5" cellspacing="0" align="center">
				<tr>
					<td>Launch auctions every</td>
					<td><input name="interval" id="interval" type="text" maxlength="5" value="5" onChange="updateEndTime()" style="width:40px;"></td>
					<td><select name="period" id="period" onChange="updateEndTime()">#SelectOptions("n", "s,Seconds;n,Minutes;h,Hours")#</select></td>
					<td>starting at</td>
					<td>
						<select name="startDay"  id="startDay" onChange="updateEndTime()">
						<cfloop index="i" from="0" to="29">
						<cfset d = DateAdd("D", i, Now())>
						<option value="#i#"<cfif i EQ 0> selected</cfif>>#DateFormat(d, "mmm, d dddd")#</option>
						</cfloop>
						</select>
					</td>
					<td>
						<cfset defHour = Hour(Now()) + 1>
						<cfif defHour GT 23>
							<cfset defHour = 0>
						</cfif>
						<select name="startTime" id="startTime" onChange="updateEndTime()">
							<cfloop index="i" from="12" to="23">
								<option value="#i#"<cfif defHour EQ i> selected</cfif>>#TimeFormat(CreateTime(i, 0, 0))#</option>
								<option value="-#i#">#TimeFormat(CreateTime(i, 15, 0))#</option>
								<option value="+#i#">#TimeFormat(CreateTime(i, 30, 0))#</option>
							</cfloop>

							<cfloop index="i" from="0" to="11">
								<option value="#i#"<cfif defHour EQ i> selected</cfif>>#TimeFormat(CreateTime(i, 0, 0))#</option>
								<option value="-#i#">#TimeFormat(CreateTime(i, 15, 0))#</option>
								<option value="+#i#">#TimeFormat(CreateTime(i, 30, 0))#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr><td colspan="6" align="right"><b>Time when launch very last of checked auctions:</b></td><td id="endTime" align="center" colspan="3">&nbsp;</td></tr>
				</table>
			</td>
			<input type="hidden" name="iBegin" value="#_paging.StartRow#">
			<input type="hidden" name="iEnd" value="#maximumRow#">
			<td align="center"><input type="submit" value="Launch!" style="width:120px;"></td>
		</tr>
		</form>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
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
	function fCheckAll(){
		for(i=#_paging.StartRow#; i<= #maximumRow#; i++){
			document.getElementById("cb"+i).checked = true;
		}
		updateEndTime();
	}
	function updateEndTime(){
		var interval = document.getElementById("interval").value;
		if(isNaN(interval)){
			document.getElementById("interval").value = 5;
			interval = 5;
		}
		var period = document.getElementById("period").value;
		var startTime = String(document.getElementById("startTime").value);
		var startMinutes = 0;
		if(startTime.charAt(0)=="+"){
			startMinutes = 30;
		}
		if(startTime.charAt(0)=="-"){
			startMinutes = 15;
			startTime = startTime.replace("-","+");

		}

		startTime = eval(startTime);


		var start = new Date(#Year(Now())#, #Month(Now())-1#, #Day(Now())#, startTime, startMinutes, 0);
		if(document.getElementById("startDay").value > 0){
			start.setTime(start.getTime() + 86400000 * document.getElementById("startDay").value);
		}else{
			if(start < new Date()){
				start.setTime(start.getTime() + 86400000); // 1 day = 86400000 = 24*60*60*1000
			}
		}
		var itemsSelected = 0;
		for(i=#_paging.StartRow#; i<= #maximumRow#; i++){
			if(document.getElementById("cb"+i).checked){
				itemsSelected++;
			};
		}
		document.getElementById("totalChecked").innerHTML = ""+itemsSelected+" item(s) checked";
		if(itemsSelected==0){
			document.getElementById("endTime").innerHTML = "N/A";
		}else{
			switch(period){
				case "s" : interval *= 1000; break; // 1 sec = 1000 ms = 1000
				case "n" : interval *= 60000; break; // 1 min = 60000 ms = 60*1000
				case "h" : interval *= 3600000; break; // 1 hour = 3600000 ms = 60*60*1000
			};
			start.setTime(start.getTime() + (itemsSelected-1) * interval);
			document.getElementById("endTime").innerHTML = start.toString().substr(0, 18);
		}
	}
	updateEndTime();
	function fCharsLeft(objID, val, maxChars){
		document.getElementById(objID).innerHTML = "(" + (maxChars-val.length) + " chars left)";
	}

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
