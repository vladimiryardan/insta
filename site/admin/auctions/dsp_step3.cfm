<cfif NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction") AND NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">
<cfinclude template="get_item.cfm">
<cfparam name="attributes.from" default="N/A">
<cfparam name="attributes.doNotResize" default="0">

<!--- KILL HORIZONTAL SCROLLBAR --->
<cfhtmlhead text='<style type="text/css">body{width:96%;}</style>'>

<cfoutput>
<script language="javascript" type="text/javascript">
<!--//
function setGallery(n){
	if(n>0){
		document.getElementById("imgGallery").src = "#request.images_path##sqlAuction.use_pictures#/" + n + ".jpg";
	}else{
		document.getElementById("imgGallery").src = "#_layout.images_path#blank.gif";
	}
}
//-->
</script>

<table width="95%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Auction Management - Step 4 of 4:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3">
			<td align="left">
				<div style="font-size:13px;">
					<strong>Item Number:
					#sqlAuction.itemid#</strong> 
				</div>	
				<div style="font-size:13px;padding-top:5px">					
					<strong>Title:</strong>
					
					#sqlAuction.title#</div>
				
			</td>
		</tr>
 	<cfif isDefined("attributes.use_pictures")>
 		<tr bgcolor="##FFFFFF"><td style="color:red;">
			<b>ATTENTION!</b> This item use the pictures of <b>#attributes.use_pictures#</b> item.
		</td></tr>
 		<tr bgcolor="##FFFFFF"><td>
			<table cellpadding="0" cellspacing="3" border="0" width="100%">
			<cfset imgList = "">
			<cfloop index="i" from="1" to="#ListLast(sqlAuction.imagesLayout, '_')#">
			<tr>
				<td width="70">Photo ###i#</td>
			<cfif FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#i#.jpg")>
				<cfset imgList = ListAppend(imgList, i)>
				<td><img src="#_layout.ia_images##sqlAuction.use_pictures#/#i#thumb.jpg?rnd=#Rand()#" border="0"></td>
			<cfelse>
				<td colspan="2">NO PICTURE AVAILABLE</td>
			</cfif>
			</tr>
			<tr><td colspan="2"><hr noshade></td></tr>
			</cfloop>
			</table>
		</td></tr>
	<cfelse>
 		<tr bgcolor="##FFFFFF"><td>
			<table cellpadding="0" cellspacing="3" border="0" width="100%">
			<form action="index.cfm?act=admin.auctions.upload_images" method="post" enctype="multipart/form-data" style="margin:0px 0px 0px 0px;" target="_top">
			<cfset imgList = "">
			<cfloop index="i" from="1" to="#ListLast(sqlAuction.imagesLayout, '_')#">
			<tr>
				<td width="70">Photo ###i#</td>
			<cfif FileExists("#request.basepath##_layout.images_path##sqlAuction.itemid#/#i#.jpg")>
				<cfset imgList = ListAppend(imgList, i)>
				<td width="180">
					<img src="#_layout.ia_images##sqlAuction.itemid#/#i#thumb.jpg?rnd=#Rand()#" border="0">
				</td>
				<td width="70">
					<a href="index.cfm?act=admin.auctions.delete_image&item=#sqlAuction.itemid#&from=#attributes.from#&imgnum=#i#" 
					target="_self">Delete</a>
				</td>
				<td>
					<a href="index.cfm?dsp=admin.auctions.edit_image&item=#sqlAuction.itemid#&from=#attributes.from#&imgnum=#i#" >Edit</a>
				</td>
			<cfelse>
				<td width="180"><input type="file" accept="image/jpeg" name="img#i#" size="30" class="btn"
				<!---style="font-size:10px; font-family:Arial, Helvetica, sans-serif;"--->></td>
				<!---<td colspan="2"><a href="index.cfm?dsp=admin.auctions.new_image&item=#sqlAuction.itemid#&from=#attributes.from#&imgnum=#i#" target="leftFrame">New</a></td>--->
				<td colspan="2">
					<a href="index.cfm?dsp=admin.auctions.upload_pictures&item=#sqlAuction.itemid#&from=#attributes.from#&imgnum=#i#" class="btn">New</a>
				</td>
			</cfif>
			</tr>
			<tr><td colspan="4"><hr noshade></td></tr>
			</cfloop>
			<tr><td colspan="4" align="center">
				<input type="hidden" name="item" value="#sqlAuction.itemid#">
				<input type="hidden" name="maxImages" value="#ListLast(sqlAuction.imagesLayout, '_')#">
				<input type="hidden" name="from" value="#attributes.from#">
				<input type="hidden" name="doNotResize" value="#attributes.doNotResize#" checked>
				<!---<input type="submit" name="submit" value="Upload Photos" class="btn btn-primary">--->
	           <button type="submit" name="submit" class="btn btn-success">
	                 Upload Photos
	            </button>					
			</td></tr>
			</form>
			</table>
		</td></tr>
	</cfif>
	<cfif attributes.from NEQ "upload_pictures">
		<tr bgcolor="##F0F1F3">
			<td>
				<table cellpadding="0" cellspacing="0" border="0">
				<form method="POST" action="index.cfm?act=admin.auctions.step3" target="_parent">
				<input type="hidden" name="item" value="#sqlAuction.itemid#">
				<tr>
					<td><b>eBay Gallery:</b></td>
					<td valign="middle" width="200" align="center">
						<select name="GalleryImage" style="width:150px;" onChange="setGallery(this.value)">
							<option value="0"<cfif sqlAuction.GalleryImage EQ 0> selected</cfif>>None</option>
							<cfloop index="i" list="#imgList#">
								<option value="#i#"<cfif sqlAuction.GalleryImage EQ i> selected</cfif>>Image #i#</option>
							</cfloop>
						</select>
					</td>
					<td valign="middle">
						<cfif sqlAuction.GalleryImage EQ 0>
						<img id="imgGallery" src="#_layout.images_path#blank.gif" width="40" height="40" border="1" alt="Layout Preview">
						<cfelse>
						<img id="imgGallery" src="#_layout.images_path##sqlAuction.use_pictures#\#sqlAuction.GalleryImage#.jpg?rnd=#Rand()#" width="40" height="40" border="1" alt="Layout Preview">
						</cfif>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		</cfif>
		</table>
	</td></tr>
	</table>
</td></tr>
<cfif attributes.from EQ "upload_pictures">
<form action="index.cfm?dsp=admin.auctions.upload_pictures&items=#attributes.item#" method="post" target="_top">
<tr>
	<td align="center">
		<br>
		<input type="submit" name="back" value="Back to Upload Images page">
		
	</td></tr>
</form>
<cfelse>
<tr><td>
<br>
<center>
<input type="submit" name="back" value="Back" width="100" style="width:100px;">
&nbsp;
<input type="submit" name="preview" value="Preview" width="100" style="width:100px;">
&nbsp;
<input type="submit" name="finish" value="Finish" width="100" style="width:100px;">
<br><br>
<table cellpadding="5" cellspacing="0" align="center">
<tr>
	<td>Schedule for:</td>
	<td>
		<select name="month" onChange="setMaxDay(this.value)">
		<cfset maxDays = "">
		<cfloop index="i" from="1" to="12">
			<cfset maxDays = ListAppend(maxDays, DaysInMonth(CreateDate(Year(Now()), i, 1)))>
			<option value="#i#"<cfif i EQ Month(Now())> selected</cfif>>#Left(MonthAsString(i),3)#</option>
		</cfloop>
		</select>
	</td>
	<td>
		<select name="day">
		<cfloop index="i" from="1" to="#DaysInMonth(Now())#">
		<option value="#i#"<cfif i EQ Day(Now())> selected</cfif>>#i#</option>
		</cfloop>
		</select>
	</td>
	<td>
		
		<cfset minuteInterval = 15>
		<!---<cfset defHour = TimeFormat( createDateTime( year(now() ) , month( now() ), day( now() ), hour( now() ), round(minute(now())/minuteInterval) * minuteInterval, second( now() ) ),"h:mm TT")>--->
		<cfset defHour = TimeFormat( createDateTime( year(now() ) , month( now() ), day( now() ), hour( now() ), 45, second( now() ) ),"h:mm TT")>
		<!---
		:vladedit: 20161208 - step by 15 minutes
		--->
		<cfset defHour = Hour(Now()) + 1>
		<cfif defHour GT 23>
			<cfset defHour = 0>
		</cfif>
		<select name="hour">
			<cfloop index="i" from="0" to="11" >
				<option value="#i#"<cfif defHour EQ i> selected</cfif>>#TimeFormat(CreateTime(i, 45, 0))#</option>
			</cfloop>
			<cfloop index="i" from="12" to="23">
			<option value="#i#"<cfif defHour EQ i> selected</cfif>>#TimeFormat(CreateTime(i, 45, 0))#</option>
			</cfloop>
		</select>
		

		<!--- 
		:vladedit: 20161208 - step by 15 minutes
		--->
		<!---<select name="hour">
			<!---<cfoutput> <li>#TimeFormat( tm, "h:mm TT" )#</li></cfoutput>--->
			<cfloop index="tm" from="00:00" to="23:59" step="#createTimespan(0,0,minuteInterval,0)#">
			    <option value="#TimeFormat( tm, "H" )#"<cfif defHour EQ TimeFormat( tm, "h:mm TT" )> selected</cfif> >#TimeFormat( tm, "h:mm TT" )#</option>
			</cfloop>
		</select>--->
		<br>
	</td>
	<td><input type="submit" name="launch" value="Schedule"></td>
	<!---<td>
		<input type="button" name="launch2minutesAhead" value="Schedule 2 minutes">
	</td>--->	
	<td>
		Server Time: #TimeFormat(now(),'short')#
	</td>	
</tr>

</table>
</form>
</center>
<br>
</td></tr>
</cfif>
</table>
<cfif attributes.from NEQ "upload_pictures">
<script language="javascript" type="text/javascript">
<!--//
var maxDays = String("#maxDays#").split(",");
function setMaxDay(n){
	obj = document.getElementById("day");
	obj.length = 0;
	for(i=1;i<=maxDays[n-1];i++){
		obj.options[obj.length] = new Option(i, i);
	}
}
//-->

$(function(){
	alert('h');
		
})
</script>
</cfif>


</cfoutput>
