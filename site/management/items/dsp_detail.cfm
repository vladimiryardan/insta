<cfif NOT isDefined("session.user")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT i.item, i.title, i.ebayitem, i.age, i.description, e.galleryurl, s.status AS statusname, a.first, a.last, a.company, a.address1, a.address2,
		a.city, a.state, a.zip, c.name, i.status
	FROM accounts a
		LEFT JOIN items i ON a.id = i.aid
		LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
		LEFT JOIN status s ON i.status = s.id
		LEFT JOIN categories c ON i.cid = c.id
	WHERE a.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.accountid#">
		AND i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfset editable = (sqlItem.status EQ 2)>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Item Details:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
</td></tr>
<tr><td align="left">
	<table width="100%">
	<tr>
		<td valign="top" align="left">
			<strong>Item ID:</strong> #sqlItem.item#<br><br>
			<strong>Current Status:</strong> #sqlItem.statusname#<br>
			<cfif sqlItem.ebayitem NEQ ""><strong>eBay Auction:</strong> <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#" target="_blank">#sqlItem.ebayitem#</a><BR><BR></cfif>
		</td>
		<td align="center"><cfif sqlItem.galleryurl NEQ ""><a href="#sqlItem.galleryurl#" target="_blank"><img src="#sqlItem.galleryurl#" width=250 border="1"></a></cfif></td>
	</tr>
	<tr><td colspan="2">
		<br><b>General Information:</b><br><br>
	</td></tr>
	</table>
</td></tr>
<tr><td>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<cfif editable>
		<form action="index.cfm?act=management.items.edit" method="post">
		<input type="hidden" name="item" value="#sqlItem.item#">
	</cfif>
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3"><td valign="top" align="right"><b>Category:</b></td><td width="70%" align="left">#sqlItem.name#</td></tr>
		<tr bgcolor="##FFFFFF"><td valign="top" align="right"><b>Title:</b></td><td width="70%" align="left"><cfif editable><input type="text" size="20" maxlength="80" name="title" value="#sqlItem.title#" style="font-size: 11px;"><cfelse>#sqlItem.title#</cfif></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="top" align="right"><b>Age:</b></td><td width="70%" align="left">#sqlItem.age#</td></tr>
		<tr bgcolor="##FFFFFF"><td valign="top" align="right"><b>Description:</b></td><td width="70%" align="left"><cfif editable><textarea name="description" rows="5" cols="40" style="font-size: 11px;">#sqlItem.description#</textarea><cfelse>#sqlItem.description#</cfif></td></tr>
	<cfif editable>
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center"><input type="submit" value="Update Item"></td></tr>
		</form>
	</cfif>
		</table>
	</td></tr>
	</table>
	<br>
</td></tr>
	<tr><td valign="top"><strong>Payment Information:</strong>
	<br><br>
	#sqlItem.first# #sqlItem.last#<br>
	<cfif sqlItem.company NEQ "">#sqlItem.company#<br></cfif>
	#sqlItem.address1#<br>
	<cfif sqlItem.address2 NEQ "">#sqlItem.address2#<br></cfif>
	#sqlItem.city#, #sqlItem.state# #sqlItem.zip#<br>
</td></tr>
<tr><td valign="top">
	<br><br>
	<center>
	<table border="0" style="text-align: left">
	<tr>
		<td valign=middle><a target="NewWin" href="index.cfm?dsp=management.items.packinglist&item=#sqlItem.item#" onClick="javascript:nw=window.open(document.getElementById('popup').href,'NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');nw.opener=self;return false;"><img border=0 src="#request.images_path#upsshield.jpg"></td>
		<td valign=middle><font size=4><a id="popup" target="NewWin" href="index.cfm?dsp=management.items.packinglist&item=#sqlItem.item#" onClick="javascript:nw=window.open(document.getElementById('popup').href,'NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');nw.opener=self;return false;"><strong>Print Your Packing Slip</strong></a></font><br><br>Drop your item off at the nearest The UPS Store for free shipping to us!  Find a location near you by clicking <a href="index.cfm?dsp=ups_store">here</a>.<br>
	</tr>
	</table>
</td></tr>
</table>
</cfoutput>
