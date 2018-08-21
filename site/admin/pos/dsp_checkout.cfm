<cfparam name="attributes.items" default="">
<cfif isDefined("attributes.printable")>
	<cfset _machine.layout = "slip">
</cfif>
<cfif ListLen(attributes.items) EQ 0>
	<cfoutput><h3 style="color:red;">Please select at least one item.</h3></cfoutput>
<cfelse>
	<cfif attributes.stype EQ 1>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.title, e.price, i.item, i.id, s.tax, i.ebayitem, i.lid
			FROM items i
				INNER JOIN accounts a ON a.id = i.aid
				INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
				INNER JOIN stores s ON s.store = a.store
			WHERE i.item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
		</cfquery>
	<cfelse>
		<cfquery name="sqlTemp" datasource="#request.dsn#">
			SELECT i.title, e.price, i.item, i.id, i.ebayitem, i.lid
			FROM items i
				INNER JOIN accounts a ON a.id = i.aid
				INNER JOIN ebitems e ON e.ebayitem = i.ebayitem
			WHERE i.item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
		</cfquery>
	</cfif>
	<cfset sum = 0>
	<cfset sum_tax = 0>
	<cfset handling = 0>
	<cfoutput>
	<cfif isDefined("attributes.printable")>
	<table>
	<tr>
		<td valign="top" align="left"><table><tr><td><center><img width=150 src="http://www.instantauctions.net/images/ialogoebayhigh.jpg" border=0><br><font size=1>441 Southland Drive<br>Lexington, KY 40503<br>http://www.instantauctions.net</center></font></td></tr></table></td>
		<td align="right"><br><font size=5 color=gray><b>Invoice</b></font><br><br><font size=1><b>DATE:</b><br>#DateFormat(Now(), "m/d/yyyy")#<br></font></td>
	</tr>
	<tr><td colspan="2">
	<cfelse>
	<table width="100%" style="text-align: justify;">
	<tr><td>
		<font size="4"><strong>Check Out:</strong></font><br>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last#
		<br><br>
	</cfif>
		<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding="0" width="100%">
		<tr><td>
			<table cellspacing="1" cellpadding="4" width="100%">
			<tr bgcolor="##F0F1F3" align="center">
				<td width="80"><b>Item</b></td>
				<td width="70"><b>Auction</b></td>
				<td width="320"><b>Title</b></td>
				<td width="50"><b>LID</b></td>
				<td width="80"><b>Price</b></td>
			</tr>
			<cfloop query="sqlTemp">
				<cfif attributes.stype EQ 1>
					<cfset handling = handling + 2>
					<cfset sum_tax = sum_tax + sqlTemp.price*sqlTemp.tax/100>
					<cfset sum = sum + price>
				<cfelse>
					<cfset handling = handling + 1>
				</cfif>
				<tr bgcolor="##FFFFFF">
					<td>#sqlTemp.item#</td>
					<td>#sqlTemp.ebayitem#</td>
					<td>#sqlTemp.title#</td>
					<td>#sqlTemp.lid#</td>
					<td align="right">#DollarFormat(sqlTemp.price)#</td>
				</tr>
			</cfloop>
			<tr bgcolor="##F0F1F3"><td colspan="5">&nbsp;</td></tr>
			<tr align="right" bgcolor="##FFFFFF">
				<td colspan="4"><b>Sum</b></td>
				<td><b>#DollarFormat(sum)#</b></td>
			</tr>
			<tr align="right" bgcolor="##FFFFFF">
				<td colspan="4"><b>Tax</b></td>
				<td><b>#DollarFormat(sum_tax)#</b></td>
			</tr>
			<tr align="right" bgcolor="##FFFFFF">
				<td colspan="4"><b>Handling</b></td>
				<td><b>#DollarFormat(handling)#</b></td>
			</tr>
			<tr align="right" bgcolor="##F0F1F3">
				<td colspan="4"><b>Total</b></td>
				<td><b>#DollarFormat(handling+sum+sum_tax)#</b></td>
			</tr>
<cfif NOT isDefined("attributes.printable")>
			<form action="index.cfm?act=admin.api.checkout&stype=#attributes.stype#" method="post">
			<tr bgcolor="##FFFFFF"><td colspan="5" align="center" style="padding:10px 10px 10px 10px;">
				<input type="hidden" name="items" value="#attributes.items#">
	<cfif attributes.stype EQ 1>
				<b>Payment Methods</b>
				<select name="PaymentMethodUsed">
				#SelectOptions("PayPal","PayPal,PayPal;MOCC,Money Order / Cashiers Check;CashInPerson,Cash-in-person;VisaMC,Visa/Mastercard;PersonalCheck,Personal Check")#
				</select>
				<input type="hidden" name="pos" value="1"><!--- POS ITEM --->
				<input type="hidden" name="StatusIs" value="2"><!--- COMPLETE --->
				<input type="hidden" name="shipped" id="pors" value="1"><!--- YES --->
				<input type="hidden" name="items" value="#attributes.items#">
				<input type="submit" value="Mark as Paid & Shipped" onClick="document.getElementById('pors').name = 'shipped';">
				<input type="submit" value="Mark as Paid" onClick="document.getElementById('pors').name = 'paid';">
	<cfelse>
				<input type="submit" value="Mark as Returned To Client">
	</cfif>
			</td></tr>
			</form>
</cfif>
			</table>
		</td></tr>
		</table>
	</td></tr>
	</table>
	</cfoutput>
</cfif>
