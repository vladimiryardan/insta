<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<title>#request.title#</title>
<meta name="DESCRIPTION" content="Instant Auctions is one of the largest eBay trading assistants in the world! We offer professional services which will significantly increase your final sale amount and get you top dollar for your valuable items. Call us at 1-866-390-4060 or check us out online at http://www.instantauctions.net!">
<meta name="KEYWORDS" content="ebay,auction,auctions,dropoff,trading,assistant,auctiondrop,isoldit,quikdrop,consignment,sell,pawn">
<base href="#request.base#">
<link href="layouts/#_machine.layout#/#_machine.css#.css" rel="stylesheet" type="text/css">
<script src="layouts/store/menu.js" language="javascript" type="text/javascript"></script>
</head>
<body style="text-align: justify;" link="##708090" alink="##778899">

<br>
<table bgcolor="white" width="755" border="0" align="center" cellpadding="0" cellspacing="0" class="vbmenu_popup">
<tr><td align="left" valign="top">

<table cellpadding="7" width="100%" id="noprint">
<tr>
	<td valign="top" align="left"><a href="./"><img alt="" src="ialogoebay.jpg" border="0" <!---width="320"---> height="90"></a></td>
	<cfif isDefined("session.basket") AND ArrayLen(session.basket)>
		<td align="center" valign="top">
			<a href="index.cfm?dsp=store.basket.view">View Shopping cart</a>
		</td>
	</cfif>
	<cfif isDefined("session.user")>
		<td align="center" valign="top">
			<a href="index.cfm?dsp=store.member.overview">My Account</a> | <a href="index.cfm?logout=1">Logout</a>
		</td>
	<cfelse>
		<td align="right">
			<font size="-2">
				<form action="index.cfm?dsp=store.member.overview" method="POST">
					<strong>Email:</strong>&nbsp;<input class="button" maxlength="40" type="text" size="12" style="font-size: 12px;" name="login"><br>
					<strong>Password:</strong>&nbsp;<input class="button" maxlength="40" type="password" size="12" style="font-size: 12px;" name="pass"><br>
					<input type="submit" value="   Log In   "  class="button">
				</form>
				<br>
				<a href="index.cfm?dsp=store.member.create"><img src="#request.images_path#newaccount.jpg" border=0></a>
			</font>

		</td>
	</cfif>
</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="noprint">
<tr><td width="100%" style="background-image:url(#request.images_path#bar.gif)" valign="middle" height="22" align="center"></cfoutput>
	<cfoutput><a href="index.cfm?dsp=howitworks"><img alt="How It Works" src="#request.images_path#bar-howitworks.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="index.cfm?dsp=account.sell_item"><img alt="Sell an Item" src="#request.images_path#bar-sellanitem.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="index.cfm?dsp=store"><img alt="Store Locations" src="#request.images_path#bar-storelocations.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="http://stores.ebay.com/Instant-Auctions" target="_blank"><img alt="Our Auctions" src="#request.images_path#bar-ourauctions.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="store.cfm"><img alt="Buy with Us" src="#request.images_path#bar-buywithus.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="http://www.instant-auctions.com"><img alt="Best Buys" src="#request.images_path#bar-bestbuys.jpg" border="0"></a></cfoutput>
	<cfoutput><a href="index.cfm?dsp=contact"><img alt="Contact Us" src="#request.images_path#bar-contactus.jpg" border="0"></a></cfoutput>
<cfoutput></td></tr>
</table>
</cfoutput>

<cfinclude template="dsp_menu.cfm">

<cfoutput>
<table width="95%" cellpadding="4" align="center">
<tr>
	<td valign="top">
</cfoutput>
