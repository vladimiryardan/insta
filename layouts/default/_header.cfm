
<cfparam name="attributes.srchState" default="XX">
<cfparam name="attributes.srchfield" default="internal_itemSKU2">
<cfparam name="attributes.srch" default="">
<cfparam name="attributes.orderby" default="i.id">


<cfset statesList = "XX,Any;AL,AL;AK,AK;AZ,AZ;AR,AR;CA,CA;CO,CO;CT,CT;DE,DE;DC,DC;FL,FL;GA,GA;HI,HI;ID,ID;IL,IL;IN,IN;IA,IA;KS,KS;KY,KY;LA,LA;ME,ME;MD,MD;MA,MA;MI,MI;MN,MN;MS,MS;MO,MO;MT,MT;NE,NE;NV,NV;NH,NH;NJ,NJ;NM,NM;NY,NY;NC,NC;ND,ND;OH,OH;OK,OK;OR,OR;PA,PA;RI,RI;SC,SC;SD,SD;TN,TN;TX,TX;UT,UT;VT,VT;VA,VA;WA,WA;WV,WV;WI,WI;WY,WY">
<cfoutput>
<!---<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">--->
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<title>#request.title#</title>
<meta name="DESCRIPTION" content="Instant Auctions is one of the largest eBay trading assistants in the world! We offer professional services which will significantly increase your final sale amount and get you top dollar for your valuable items. Call us at 1-866-390-4060 or check us out online at http://www.instantauctions.net!">
<meta name="KEYWORDS" content="ebay,auction,auctions,dropoff,trading,assistant,auctiondrop,isoldit,quikdrop,consignment,sell,pawn">

<!--- bootstrap goes first and over ridden by default.css--->
<!---<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">--->

<link href="layouts/#_machine.layout#/#_machine.css#.css" rel="stylesheet" type="text/css">
<script src="layouts/#_machine.layout#/menu.js" language="javascript" type="text/javascript"></script>

<!--- added font awesome --->
<!---<link rel="stylesheet" href="layouts/#_machine.layout#/css/font-awesome.min.css">--->



<script language="javascript" type="text/javascript">
<!--//
function fAddress(itemid){
	AddressWin = window.open("index.cfm?dsp=admin.buyer&itemid="+itemid, "AddressWin", "height=520,width=460,location=no,scrollbars=no,menubars=no,toolbars=no,resizable=yes");
	AddressWin.opener = self;
	AddressWin.focus();
}
//-->
</script>
</head>
<body style="text-align: justify;" link="##708090" alink="##778899">

<br>
<table bgcolor="white" width="755" border="0" align="center" cellpadding="0" cellspacing="0" class="vbmenu_popup">
<tr><td align="left" valign="top">

<table cellpadding="7" width="100%" id="noprint">
<tr>
	<td valign="top" align="left"><a href="./"><img alt="" src="ialogoebay.jpg" border="0" <!---width="320"---> height="90"></a></td>
	<td align="center" valign="top">
		<font style="text-align: right; vertical-align: top;">
			<a href="index.cfm">Home</a>
			<cfif isDefined("session.user.both_req") AND (session.user.both_req EQ 1)>
				<a href="index.cfm?dsp=store.member.overview&redirect_system=1">Wholesale</a>
			</cfif>
			| <a href="index.cfm?dsp=contact">Contact</a>
			| <a href="index.cfm?dsp=about">About</a>
		</font>
		<cfif isDefined("session.user")>
			|
			<a href="index.cfm?logout=1">Logout</a> |
			<cfif session.user.usertype GTE 10>
				<a href="index.cfm?dsp=management.overview">Management Overview</a> |
			</cfif>
			<a href="index.cfm?dsp=account.overview">My Account</a><br>
		</cfif>
		<br>
		<cfif isGuest()>
			<!---<img src="#request.images_path#powerseller.jpg">--->
		<cfelse>
			<table cellpadding="0" cellspacing="0" border="0">
			<form action="index.cfm?dsp=management.items" method="post" id="srchFORM">
				<tr>
					<td rowspan="3">
						<!---<img src="#request.images_path#powerseller.jpg">--->
						<!---<img src="Sharks new tattoo.jpg">---><!---
						<p style="text-align:center">
						<img src="Sharks new tattoo.jpg" <!---height="90"--->><br>
						"sharks new Tattoo"
						</p>--->
						</td>
					<td colspan="3" align="right">Enter Search: <input type="text" name="srch" size="12"></td>
				</tr>

			<cfif isAllowed("Accounts_EditAccounts")>
				<!---<tr>
					<td><input type="radio" name="radiosearch" id="x1" onClick="document.forms.srchFORM.action='index.cfm?dsp=management.items';" checked></td>
					<td colspan="2" align="left"><label for="x1">search item</label></td>
				</tr>
				<tr>
					<td><input type="radio" name="radiosearch" id="x2" onClick="document.forms.srchFORM.action='index.cfm?dsp=management.accounts';"></td>
					<td align="left"><label for="x2">search account&nbsp;</label></td>
					<td><select name="srchState">#SelectOptions(attributes.srchState, statesList)#</select></td>
				</tr>--->
				<tr>
					<td align="right">
						<select name="srchfield" style="font-size: 13px;">
							#SelectOptions(attributes.srchfield, "all,All Fields;item,Item Number;title,Item Title;description,Description;Owner,Owner;ebayitem,eBay Number;ebaytitle,eBay Title;HighBidder,High Bidder ID;HighBidderEmail,High Bidder Email;tracking,Tracking Number;ebayhistory,eBay History;extExternalTransactionID,PayPal Transaction ID;internal_itemSKU,SKU;internal_itemSKU2,SKU2;LID,LID;UPC,UPC;itemExact,Item Exact Number;salesRecord,Sales Record")#
						</select>
						<br>
						<input type="submit" name="frmsubmit" value="go">
					</td>
				</tr>
			</cfif>
			
			

			</form>
			</table>
		</cfif>
	</td>
	<td align="right">
		<cfif NOT isDefined("session.user")>
			<font size="-2">
				
				<form action="index.cfm?dsp=management.items" method="POST">	
					<strong>Email:</strong>&nbsp;<input class="button" maxlength="40" type="text" size="12" style="font-size: 12px;" name="login"><br>
					<strong>Password:</strong>&nbsp;<input class="button" maxlength="40" type="password" size="12" style="font-size: 12px;" name="pass"><br>
					<input type="submit" value="   Log In   "  class="button">
				</form>
				<br>
				<!---
				Forgot your <a href="index.cfm?dsp=account.forgot_password">password</a>?<br>
				Create a <a href="index.cfm?dsp=account.create">new account</a>!
				--->
				<!---<a href="index.cfm?dsp=account.create"><img src="#request.images_path#newaccount.jpg" border=0></a>--->
			</font>
		<cfelse>
			<br>
		</cfif>
	</td>
</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="noprint">
<tr><td width="100%" style="background-image:url(#request.images_path#bar.gif)" valign="middle" height="22" align="center"></cfoutput>
	<cfoutput><a href="index.cfm?dsp=howitworks"><img alt="How It Works" src="#request.images_path#howitworks_button.gif" border="0"></a></cfoutput>
	<cfoutput><a href="index.cfm?dsp=account.sell_item"><img alt="Sell an Item" src="#request.images_path#sell_button.gif" border="0"></a></cfoutput>
<!---
	<cfoutput><a href="index.cfm?dsp=store"><img alt="Store Locations" src="#request.images_path#bar-storelocations.jpg" border="0"></a></cfoutput>
--->
	<cfoutput><a href="index.cfm?dsp=policies"><img alt="Policies" src="#request.images_path#policies_button.gif" border="0"></a></cfoutput>
	<cfoutput><a href="http://www.ebay.com" target="_blank"><img alt="Live Auctions" src="#request.images_path#auctions_button.gif" border="0"></a></cfoutput>
<!---
	<cfoutput><a href="index.cfm?dsp=franchiseinfo"><img alt="Franchise Info" src="#request.images_path#bar-franchiseinfo.jpg" border="0"></a></cfoutput>
--->
	<cfoutput><a href="store.cfm"><img alt="Buy with Us" src="#request.images_path#wholesale_button.gif" border="0"></a></cfoutput>
	<cfoutput><a href="http://www.ebay.com"><img alt="Best Buys" src="#request.images_path#bestbuys_button.gif" border="0"></a></cfoutput>
	<cfoutput><a href="index.cfm?dsp=contact"><img alt="Contact Us" src="#request.images_path#contact_button.gif" border="0"></a></cfoutput>
<cfoutput></td></tr>
</table>
</cfoutput>

<cfinclude template="../dsp_menu.cfm">

<cfif isDefined("_machine.menu")>
	<cfset divID = 1>
	<cfoutput>
	<table width="95%" cellpadding="4" align="center">
	<tr>
		<td width="20%" valign="top">
			<table bgcolor="##aaaaaa" border=0 cellspacing=0 cellpadding=0 width="100%">
			<tr><td>
				<table width="100%" cellspacing="1" cellpadding="4" style="text-align: justify;">
				<tr bgcolor="##F0F1F3"><td><strong>#_machine.menuTitle#</strong></td></tr>
					<cfloop index="i" from="1" to="#ArrayLen(_machine.menu)#">
						<cfif NOT StructKeyExists(_machine.menu[i], "type")>
							<cfset StructInsert(_machine.menu[i], "type", "link")>
						</cfif>
						<cfswitch expression="#_machine.menu[i].type#">
							<cfcase value="link"><tr bgcolor="##FFFFFF"><td><a href="#_machine.menu[i].href#">#_machine.menu[i].text#</a></td></cfcase>
							<cfcase value="header"><tr bgcolor="##F0F1F3"><td><strong>#_machine.menu[i].text#</strong></td></tr></cfcase>
						</cfswitch>
					</cfloop>
				</td></tr>
				</table>
			</td></tr>
			</table>
		</td>
		<td width="80%" valign="top">
	</cfoutput>
<cfelse>
	<cfoutput>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr><td valign="top" style=" padding:0px 0px 0px 0px;">
	</cfoutput>
</cfif>
