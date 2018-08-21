<cfif NOT isAllowed("Items_CheckCalculator")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.calc" default="">
<cfparam name="item1" default="0">
<cfparam name="item2" default="0">
<cfparam name="item3" default="0">
<cfparam name="item4" default="0">
<cfparam name="item5" default="0">

<cfif attributes.calc EQ 1>
<cfscript>
function RunCalc(itemsaleprice) {
	if (itemsaleprice GT 25){
		if (itemsaleprice GT 1000){
			ebayfees = 1.31 + 29.25 + 0.015 * (itemsaleprice - 1000) + 0.35 + 0.35;
		}else{
			ebayfees = 1.31 + (0.03 * (itemsaleprice - 25)) + 0.35 + 0.35;
		}
	}else{
		ebayfees = 0.0875 * itemsaleprice + 0.35 + 0.35;
	}
	ebayfees = Round(0.4 + (ebayfees * 100)) * .01;

	paypalfees = Round(30 + (2.9 * itemsaleprice)) * .01;

	if (itemsaleprice GT 28.54){
		if (itemsaleprice GT 499.99){
			if (itemsaleprice GT 999.99){
				ourfees = 0.18 * itemsaleprice;
			}else{
				ourfees = 0.23 * itemsaleprice;
			}
		}else{
			ourfees = 0.28 * itemsaleprice;
		}
	} else{
		ourfees = itemsaleprice - ebayfees - paypalfees;
		if (ourfees GT 7.99) {
			ourfees = 7.99;
		}
	}
	if ( ourfees LT 0 ) {
		ourfees = 0;
	}
	itemcheckamount = itemsaleprice - (Round(0.4 + (ourfees * 100)) * .01) - ebayfees - paypalfees;
	return itemcheckamount;
}

TotalCalc = RunCalc(item1) + RunCalc(item2) + RunCalc(item3) + RunCalc(item4) + RunCalc(item5);

</cfscript>
</cfif>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Item Calculator:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#

	<br><br><br>
	<table width="100%">

<cfif attributes.calc EQ 1>
	<tr>
		<td width="50%" align="left">
			<font size=4><strong>Check Amount: #DollarFormat(TotalCalc)#</strong></font><br><br>
		</td>
	</tr>
</cfif>
	<tr valign="middle">
		<td width="50%" align="left">
			Final Sale Price: $
			<form method="POST" action="index.cfm?dsp=management.calc&calc=1">
				<input type="text" size="10" maxlength="10" name="item1" value="#item1#">
		</td>
	</tr>
	<tr>
		<td width="50%" align="left">
			Final Sale Price: $
				<input type="text" size="10" maxlength="10" name="item2" value="#item2#">
		</td>
	</tr>
	<tr>
		<td width="50%" align="left">
			Final Sale Price: $
				<input type="text" size="10" maxlength="10" name="item3" value="#item3#">
		</td>
	</tr>
	<tr>
		<td width="50%" align="left">
			Final Sale Price: $
				<input type="text" size="10" maxlength="10" name="item4" value="#item4#">
		</td>
	</tr>
	<tr>
		<td width="50%" align="left">
			Final Sale Price: $
				<input type="text" size="10" maxlength="10" name="item5" value="#item5#"><br><br>
				<input type="submit" value="Calculate Check Amount"><br>
				(Inputs cannot be blank)
			</form>
		</td>
	</tr>
	</table>
</td></tr>
</table>
</cfoutput>
