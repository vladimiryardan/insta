<cfif NOT isAllowed("Items_UploadPictures")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.itemid" default="">
<cfparam name="attributes.doNotResize" default="0">

<cfquery name="sqlValidItems" datasource="#request.dsn#">
	SELECT i.item, i.title, a.use_pictures
	FROM items i
		LEFT JOIN auctions a ON i.item = a.itemid
	WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
</cfquery>

<cfoutput>
<table style="text-align: justify;" width="100%">
<tr>
	<td align="left"><font size="4"><strong>Manage Images - Item #attributes.itemid#</strong></font></td>
</tr>
<tr><td>
	<hr size="1" style="color: Black;" noshade>
	<table width="100%"><tr><td align="left" width="50%"><strong>Administrator:</strong> #session.user.first# #session.user.last#</td><td align="right" width="50%">
		<b>Print Daily Report For: </b>
		<a href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
		&nbsp;|&nbsp;
		<a href="index.cfm?dsp=admin.picturing_daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
	</td></tr></table>
	<br><br>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1" style="padding-bottom:0px;">
		<form action="index.cfm?dsp=admin.auctions.manage_images" method="post" style="margin:0px 0px 0px 0px;">
		<tr bgcolor="##F0F1F3">
			<td width="45%" align="right"><b>Item Number:</b></td>
			<td width="10%" align="center"><input type="text" name="itemid" value="#attributes.itemid#" size="20" style="font-size:10px; font-family:Arial, Helvetica, sans-serif;"></td>
			<td width="45%" align="left"><input type="submit" name="submit" value="Manage Images"></td>
		</tr>
		<cfif (attributes.itemid NEQ "") AND (sqlValidItems.RecordCount EQ 0)>
			<tr><td colspan="3" bgcolor="##FFFFFF"><h6 style="color:red;">Item "#attributes.itemid#" does not exist in database.</h6></td></tr>
		</cfif>
		</form>
		</table>

	<cfif attributes.doNotResize>
		<div style="color:red; text-align:center; background-color:white; padding:10px 0px 10px 0px;">WARNING! Images droped below won't be resized.</div>
	</cfif>
	<cfif (sqlValidItems.RecordCount NEQ 0) AND (sqlValidItems.use_pictures NEQ "")>
		<h3 align="center">This item use photos of item #sqlValidItems.use_pictures#</h3>
	<cfelseif (attributes.itemid NEQ "") AND (sqlValidItems.RecordCount NEQ 0)>
		<table width="100%" border="0" cellpadding="4" cellspacing="1" style="padding-top:0px;">
		<form action="index.cfm?act=admin.auctions.delete_image&item=#attributes.itemid#&multiple=1" method="post">
		<cfloop index="row" from="1" to="10" step="5">
		<tr bgcolor="##F0F1F3">
			<cfloop index="i" from="#row#" to="#(row+4)#">
			<td width="20%">
			<cfif FileExists("#request.basepath##_layout.images_path##attributes.itemid#/#i#.jpg")>
				<input type="checkbox" id="cb#i#" name="images2delete" value="#i#"><label for="cb#i#"><b>Photo ###i#</b></label>
			<cfelse>
				<b>Photo ###i#</b>
			</cfif>
			</td>
			</cfloop>
		</tr>
		<tr bgcolor="##FFFFFF">
			<cfset appletPath = "radupload/">
			<cfloop index="i" from="#row#" to="#(row+4)#">
			<td align="center" valign="middle" style="padding:4px 2px 4px 2px;">
				<cfif FileExists("#request.basepath##_layout.images_path##attributes.itemid#/#i#.jpg")>
					<img src="#_layout.ia_images##attributes.itemid#/#i#thumb.jpg?rnd=#Rand()#" border="0">
				<cfelse>
					<applet
						align		= "middle"
						codebase	= "#appletPath#"
						archive		= "dndplus.jar"
						code		= "com.radinks.dnd.DNDAppletPlus"
						name		= "APPLET_#i#"
						hspace		= "0"
						vspace		= "0"
						width		= "100"
						height		= "100"
						mayscript	= "yes"
					>
						<param name="url" value="http://#CGI.SERVER_NAME##CGI.PATH_INFO#?dsp=admin.auctions.save_pictures&item=#sqlValidItems.item#&oneImage=#i#&doNotResize=#attributes.doNotResize#">
						<param name="message" value='<br><br><div style="font-size:11px; font-weight:bold;">&nbsp;#attributes.itemid#<br>&nbsp;&nbsp;&nbsp;&nbsp;photo ###i#</div>'>
					<!--- settings for PLUS --->
						<param name="bachelor" value="1">
						<param name="angry_bachelor" value="Please upload <b>single</b> file.">
						<param name="max_upload" value="128000"><!--- size in kilobytes --->
						<param name="allow_types" value="jpg,jpeg,jpe">
						<param name="reject_message" value="please JPG only">
						<param name="show_thumb" value="1">
						<param name="browse" value="1">
						<param name="scale_images" value="yes">
						<param name="img_max_width" value="1600">
						<param name="img_max_height" value="1280">
					</applet>
				</cfif>
			</td>
			</cfloop>
		</tr>
		</cfloop>
		<tr bgcolor="##F0F1F3"><td colspan="5" align="center"><input type="submit" value="Delete Selected"></td></tr>
		</form>
		<tr bgcolor="##FFFFFF"><td colspan="5" align="center">&nbsp;</td></tr>
		<cfset variables.focusElement = "UNIQUE_NAME">
		<form action="" method="post" onSubmit="return addITEM()">
		<tr bgcolor="##F0F1F3"><td colspan="5" align="center"><b>Add sole item (<i>usally, scanned</i>) to items list:</b></td></tr>
		<tr bgcolor="##FFFFFF"><td colspan="5" align="center"><input type="text" id="#variables.focusElement#" name="#variables.focusElement#" value=""></td></tr>
		</form>
		<form action="index.cfm?act=admin.auctions.use_pictures&dsp=#attributes.dsp#&use_pictures=#attributes.itemid#" method="post">
		<tr bgcolor="##F0F1F3"><td colspan="5" align="center"><b>OR, type in Item Numbers separated by comma (,)</b></td></tr>
		<tr bgcolor="##FFFFFF"><td colspan="5" align="center"><textarea name="items" cols="100" rows="5"></textarea></td></tr>
		<tr bgcolor="##F0F1F3"><td colspan="5" align="center"><input type="submit" value="Use the Same Photos For Items Above"></td></tr>
		</form>
		</table>
	</cfif>

	</td></tr>
	</table>
</td></tr>
</table>
<br>
<cfif isDefined("variables.focusElement")>
	<script language="javascript" type="text/javascript">
	<!--//
		function addITEM(){
			document.getElementById("items").value += document.getElementById("#variables.focusElement#").value + ",";
			document.getElementById("#variables.focusElement#").value = "";
			document.getElementById("#variables.focusElement#").focus();
			return false;
		}
		document.getElementById("#variables.focusElement#").focus();
	//-->
	</script>
</cfif>
</cfoutput>
