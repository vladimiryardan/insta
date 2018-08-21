<cfif NOT isDefined("session.user")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT i.item, i.title, i.value, i.description, i.make, i.model, i.age,
		a.first, a.last, a.company, a.address1, a.address2, a.city, a.state,
		a.zip, a.email, a.phone, c.name 
	FROM accounts a
		LEFT JOIN items i ON a.id = i.aid
		LEFT JOIN status s ON i.status = s.id
		LEFT JOIN categories c ON i.cid = c.id 
		WHERE a.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.accountid#">
			AND i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfoutput>
#getVar('Site_Content.Packing_Slip', '
<br>
<center>
	<a href="javascript:self.print()"><font size="4"><strong>Click Here To Print This Page</strong></font></a>
	<br><br>
        <strong>Drop your item off at the nearest The UPS Store for free shipping to us!<br>
	Tell them you want to ship the item to "Instant Auctions Corporate Account Work Order Process".</strong><BR>
	Please remember to sign the bottom and include this with your item when you package it!<br>
	Also, please recheck that your item is worth more than $25.<br>
	<br><br>
	Please ship your item to:<br>
	<font size="3" style="font-weight:bold;">
		Instant Auctions Corporate Account<br>
		441 Southland Drive<br>
		Lexington, KY 40503<BR>
		1-866-390-4060
	</font>
	<br><br>
</center>
', 'HTML')#
</cfoutput>
<cfoutput query="sqlItem">
<table cellpadding="7" border="0" width="100%" cellspacing="0">
<tr>
	<td align="left"><img src="#request.images_path#ia-packing.jpg" border="0"></td>
	<td align="right">
		<font size="4" style="font-weight:bold;">
			Item ID: #item#<br>
			Shipment Packing List
		</font>
	</td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="4" border="0" width="100%">
<tr><td></td></tr>
<tr width="100%"><td width="100%"><strong>Item Information:</strong></td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr width="100%">
	<td width="15%"><strong>Item ID</strong></td>
	<td width="70%"><strong>Title</strong></td>
	<td width="15%"><strong>Age</strong></td><!--- AUGUST 19 --->
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr width="100%">
		<td width="15%" bgcolor="##FFFFFF">#item#</td>
		<td width="70%" bgcolor="##FFFFFF">#title#</td>
		<td width="15%" bgcolor="##FFFFFF">#age#</td><!--- AUGUST 19 --->
	</tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr width="100%"><td width="100%"><strong>Description</strong></td></tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr width="100%"><td width="100%" bgcolor="##FFFFFF">#description#</td></tr>
	</table>
</td></tr>
</table>

<br><br>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding=4 border="0" width="100%">
<tr><td></td></tr>
<tr width="100%"><td width="100%"><strong>Customer Information:</strong></td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr width="100%">
	<td width="34%"><strong>First Name</strong></td>
	<td width="33%"><strong>Last Name</strong></td>
	<td width="33%"><strong>Company <em>(if applicable)</em></strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr width="100%">
		<td width="34%" bgcolor="##FFFFFF">#first#</td>
		<td width="33%" bgcolor="##FFFFFF">#last#</td>
		<td width="33%" bgcolor="##FFFFFF">#company#</td>
	</tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr width="100%"><td width="100%"><strong>Street Address</strong></td></tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr width="100%"><td width="100%" bgcolor="##FFFFFF">#address1#<cfif address2 NEQ "">, #address2#</cfif></td></tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr width="100%">
	<td width="30%"><strong>City</strong></td>
	<td width=5%><strong>State</strong></td>
	<td width=10%><strong>ZIP</strong></td>
	<td width="35%"><strong>E-Mail</strong></td>
	<td width="20%"><strong>Phone</strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr width="100%">
		<td width="30%" bgcolor="##FFFFFF">#city#</td>
		<td width="5%" bgcolor="##FFFFFF">#state#</td>
		<td width="10%" bgcolor="##FFFFFF">#zip#</td>
		<td width="35%" bgcolor="##FFFFFF">#email#</td>
		<td width="20%" bgcolor="##FFFFFF">#phone#</td>
	</tr>
	</table>
</td></tr>
</table>

<br><br>

<table cellpadding="7" border="0" width="100%" cellspacing="0">
<tr>
	<td align="left">
		Your signature below constitutes your agreement to be bound by the Terms and Conditions listed on our website:<br><br><br>
		Signature: ____________________________________________________
	</td>
	<td align="right"><font size="4" style="font-weight:bold;">Today's Date: #DateFormat(Now(), "m/d/Y")#</font></td>
</tr>
</table>
</cfoutput>
