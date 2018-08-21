<cfif NOT isAllowed("Listings_BuyPostage")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Buy Postage:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
	<div style="border:1px solid ##AAAAAA; margin:10px 10px 10px 10px; padding:10px 10px 10px 10px;">
		<p><b>Postage Balance: #DollarFormat(_vars.endicia.PostageBalance)#</b>. <i>Remaining postage balance after recredit in dollars and cents</i></p>
		<cfif isDefined("attributes.AscendingBalance")>
			<p><b>Postage Balance: #DollarFormat(attributes.AscendingBalance)#</b>. <i>Total amount of postage printed (after recredit) in dollars and cents</i></p>
		</cfif>
		<cfif isDefined("attributes.AccountStatus")>
			<p><b>Account Status:</b> <i>
				<cfswitch expression="#attributes.AccountStatus#">
					<cfcase value="A">Active</cfcase>
					<cfcase value="S">Suspended due to bad login attempts</cfcase>
					<cfcase value="C">Closed</cfcase>
					<cfcase value="P">Close requested, pending</cfcase>
					<cfcase value="X">Suspended for cause</cfcase>
					<cfdefaultcase>UNKNOWN (#attributes.AccountStatus#)</cfdefaultcase>
				</cfswitch>
			</i></p>
		</cfif>
		<form method="POST" action="index.cfm?act=admin.ship.usps.buy_postage">
			<b>Amount:</b>
			<select name="amount">#SelectOptions(250, "10,10;25,25;50,50;100,100;200,200;250,250;500,500;1000,1000;2500,2500;5000,5000")#</select>
			<input type="submit" name="submit" value="Buy Postage">
		</form>
	</div>
	</td></tr>
	</table>
</td></tr>
</table>
</cfoutput>
