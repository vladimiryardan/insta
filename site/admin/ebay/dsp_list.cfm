<cfif NOT isAllowed("Full_Access")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Manage eBay Accounts:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding=0 width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr bgcolor="##F0F1F3">
			<td class="ColHead">eBay UserID</td>
			<td class="ColHead">Development ID</td>
			<td class="ColHead">Diplicate</td>
			<td class="ColHead">Edit Template</td>
		</tr>
</cfoutput>
<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT eBayAccount, UserID, UserName
	FROM ebaccounts
</cfquery>
<cfoutput query="sqlTemp">
		<tr bgcolor="##FFFFFF">
			<td><a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#">#UserID#</a></td>
			<td>#UserName#</td>
			<td align="center"><a href="index.cfm?act=admin.ebay.duplicate&eBayAccount=#eBayAccount#">Duplicate</a></td>
			<td align="center">
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=Header">Header</a>
				|
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=Description">Description</a>
				|
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=SellWithUs">Sell With Us</a>
				|
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=Payment">Payment</a>
				|
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=Shipping">Shipping</a>
				|
				<a href="index.cfm?dsp=admin.ebay.edit&eBayAccount=#eBayAccount#&edit=AboutUs">About Us</a>
			</td>
		</tr>
</cfoutput>
<cfoutput>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
