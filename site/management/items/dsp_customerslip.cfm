<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT i.item, i.title, i.startprice AS reserve, i.description, i.make, i.model, i.age,
		a.first, a.last, a.company, a.address1, a.address2, a.city, a.state, a.zip,
		a.email, a.phone, c.name 
	FROM accounts a
		LEFT JOIN items i ON a.id = i.aid
		LEFT JOIN categories c ON i.cid = c.id 
		WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfoutput query="sqlItem">
<br>
<table cellpadding="7" border="0" width="100%" cellspacing="0">
<tr>
	<td align="left"><img src="#request.images_path#ia-packing.jpg" border="0"></td>
	<td align="left" width="100%">
		<strong>Instant Auctions</strong><br>
		441 Southland Drive<br>
		Lexington, KY 40503
	</td>
	<td width="100%">
		Phone: 1-866-390-4060<br>
		Email: ia201@instantauctions.net<br>
		eBay ID: instantauctions
	</td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="4" border="0" width="100%">
<tr><td><strong>Item Information:</strong></td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr>
	<td width="35%"><strong>Item ID</strong></td>
	<td width="65%"><strong>Category</strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr>
		<td width="35%" bgcolor="##F0F1F3">#item#</td>
		<td width="65%" bgcolor="##F0F1F3">#name#</td>
	</tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr>
	<td width="70%"><strong>Title</strong></td>
	<td width="15%"><strong>Age</strong></td>
	<td width="15%"><strong>Reserve</strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr>
		<td width="70%" bgcolor="##F0F1F3">#title#</td>
		<td width="15%" bgcolor="##F0F1F3">#age#</td>
		<td width="15%" bgcolor="##F0F1F3">#DollarFormat(reserve)#</td>
	</tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr><td><strong>Description</strong></td></tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr><td bgcolor="##F0F1F3"><cfif Len(description) LT 1>...<cfelse><cfif Len(description) GT 50>#Left(description, 367)#...<cfelse>#description#</cfif></cfif></td></tr>
	</table>
</td></tr>
</table>

<br><br>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding=4 border="0" width="100%">
<tr><td><strong>Customer Information:</strong></td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr>
	<td width="34%"><strong>First Name</strong></td>
	<td width="33%"><strong>Last Name</strong></td>
	<td width="33%"><strong>Company <em>(if applicable)</em></strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr>
		<td width="34%" bgcolor="##F0F1F3">#first#</td>
		<td width="33%" bgcolor="##F0F1F3">#last#</td>
		<td width="33%" bgcolor="##F0F1F3">#company#</td>
	</tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr><td><strong>Street Address</strong></td></tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr><td width="100%" bgcolor="##F0F1F3">
		#address1#
		<cfif address2 NEQ "">, #address2#</cfif>
	</td></tr>
	</table>
</td></tr>
</table>

<table cellspacing="1" cellpadding="4" border="0" width="100%" bgcolor="##FFFFFF">
<tr>
	<td width="30%"><strong>City</strong></td>
	<td width="5%"><strong>State</strong></td>
	<td width="10%"><strong>ZIP</strong></td>
	<td width="35%"><strong>E-Mail</strong></td>
	<td width="20%"><strong>Phone</strong></td>
</tr>
</table>

<table bgcolor="##aaaaaa" cellspacing="0" cellpadding="0" border="0" width="100%">
<tr><td>
	<table cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr>
		<td width="30%" bgcolor="##F0F1F3">#city#</td>
		<td width=5% bgcolor="##F0F1F3">#state#</td>
		<td width=10% bgcolor="##F0F1F3">#zip#</td>
		<td width="35%" bgcolor="##F0F1F3">#email#</td>
		<td width=20% bgcolor="##F0F1F3">#phone#</td>
	</tr>
	</table>
</td></tr>
</table>

<br><br>

<table cellpadding="7" border="0" width="100%" cellspacing="0">
<tr>
	<td align="left">
		Your signature below constitutes your agreement to be bound by the Terms and Conditions listed on the reverse side of this agreement:<br><br><br>
		Signature: ____________________________________________________
	</td>
	<td align="right"><font size=4><strong>Today's Date: #DateFormat(Now(), "m/d/yyyy")#</strong></font></td>
</tr>
</table>

</td></tr></table><br><br><br>

<font size=3><center><strong>Thank you for listing with Instant Auctions - The Easy Way to eBay!</strong></center></font><br><br>

<strong>What will happen next?</strong><br><br>
<table>
<tr valign="top"><td>1.</td><td>Our experienced staff will photograph your item and write up a detailed auction listing for eBay. Your item will be listed within 5 business days of being dropped off.</td></tr>
<tr valign="top"><td>2.</td><td>As soon as your item has been listed on eBay, you will receive an automated email with a link to your auction.  If you have a spam filter, please add our email address (info@instantauctions.net).  You can also check the status of your item by logging into our website at www.InstantAuctions.net using your email as a login and the password you supplied at sign-up.</td></tr>
<tr valign="top"><td>3.</td><td>If you find a serious error in your listing, please notify us immediately.  Per eBay's policy, we are unable to change an auction once it has received its first bid.</td></tr>
<tr valign="top"><td>4.</td><td>Once your item has sold and payment is received, your item will be shipped to the winning bidder.</td></tr>
<tr valign="top"><td>5.</td><td>Your check will be ready 10 days after your item has shipped (eBay has a 10-day mandatory return policy) and will be mailed to you.</td></tr>
</table>
<br><br>

<center><strong>Visit our website for more information or to check the status of your item at www.InstantAuctions.net!</strong></center>

</cfoutput>
