<cfif NOT isAllowed("POS_RunCreditCard")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<cfif isDefined("attributes.x_type")>
	<cfset processData = TRUE>
	<cfif attributes.x_type EQ "AUTH_CAPTURE">
		<cfif attributes.x_fp_sequence NEQ "">
			<cfquery datasource="#request.dsn#" name="sqlValidate">
				SELECT DISTINCT ebayitem, item
				FROM items
				WHERE status = '5'<!---  Awaiting Payment --->
					AND ebayitem IN (<cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.x_fp_sequence#" list="yes">)
			</cfquery>
			<cfset goodItems = ValueList(sqlValidate.ebayitem)>
			<cfset badItems = "">
			<cfloop index="i" list="#attributes.x_fp_sequence#">
				<cfif NOT ListFind(goodItems, i)>
					<cfset badItems = ListAppend(badItems, i)>
				</cfif>
			</cfloop>
			<cfif badItems NEQ "">
				<cfset processData = FALSE>
				<cfoutput><h3 style="color:red;">#badItems# - either incorrect, or illegal (should be Awaiting Payment) number(s)</h3></cfoutput>
			</cfif>
			<cfset goodItems = ValueList(sqlValidate.item)>
		</cfif>
	</cfif>
<cfelse>
	<cfset processData = FALSE>
</cfif>

<cfif processData>
	<cfif NOT ListFindNoCase("AUTH_ONLY,AUTH_CAPTURE,CAPTURE_ONLY,CREDIT", attributes.x_type)>
		<cfthrow message="UNSUPPORTED OPERATION (#attributes.x_type#)">
	</cfif>
	<cfset TransactionKey = _vars.authorizeNet.TransactionKey>
	<cfset x_login = _vars.authorizeNet.login>
	<cfhttp url="https://secure.authorize.net/gateway/transact.dll" method="post">
		<cfif isDefined("attributes.x_test_request")>
			<cfhttpparam name="x_test_request" type="formfield" value="#attributes.x_test_request#">
		</cfif>

		<cfhttpparam name="x_type" type="formfield" value="#attributes.x_type#">
		<cfhttpparam name="x_login" type="formfield" value="#x_login#">
		<cfhttpparam name="x_fp_sequence" type="formfield" value="#attributes.x_fp_sequence#">

		<cfparam name="attributes.description" default="">

		<cfswitch expression="#attributes.x_type#">
			<cfcase value="AUTH_ONLY,AUTH_CAPTURE,CREDIT" delimiters=",">
				<cfhttpparam name="x_card_num" type="formfield" value="#attributes.x_card_num#">
				<cfhttpparam name="x_exp_date" type="formfield" value="#attributes.x_exp_date#">
				<cfhttpparam name="x_amount" type="formfield" value="#attributes.x_amount#">
				<cfhttpparam name="x_description" type="formfield" value="#attributes.description#">
				<cfif attributes.x_type EQ "CREDIT">
					<cfhttpparam name="x_trans_id" type="formfield" value="#attributes.x_trans_id#">
				</cfif>
			</cfcase>
			<cfcase value="CAPTURE_ONLY">
				<cfhttpparam name="x_auth_code" type="formfield" value="#attributes.x_auth_code#">
			</cfcase>
		</cfswitch>
		<cfset x_fp_timestamp = _vars.authorizeNet.shiftSeconds + DateDiff("s", "1/1/1970", DateConvert("local2UTC", Now()))><!--- UNIX_TIMESTAMP() --->
		<cf_hmac data="#x_login#^#attributes.x_fp_sequence#^#x_fp_timestamp#^#attributes.x_amount#^" key="#TransactionKey#">
		<cfhttpparam name="x_fp_hash" type="formfield" value="#digest#">
		<cfhttpparam name="x_fp_timestamp" type="formfield" value="#x_fp_timestamp#">
		<cfhttpparam name="x_first_name" type="formfield" value="#attributes.x_first_name#">
		<cfhttpparam name="x_last_name" type="formfield" value="#attributes.x_last_name#">
	</cfhttp>
	<cfset authorizeNetResponse = CFHTTP.fileContent>
	<cfif isDefined("goodItems") AND (goodItems NEQ "")>
		<!--- index.cfm?act=admin.api.checkout&stype=1&StatusIs=2&PaymentMethodUsed=VisaMC&items=#goodItems#&dsp=admin.pos.run_credit_card --->
		<cfset attributes.stype = 1>
		<cfset attributes.StatusIs = 2>
		<cfset attributes.PaymentMethodUsed = "VisaMC">
		<cfset attributes.items = goodItems>
		<cfinclude template="../api/act_checkout.cfm">
		<cfparam name="attributes.email" default="">
		<cfmail from="#_vars.mails.from#" 
		to="#_vars.mails.from#" 
		subject="Instant Auctions: CC Transaction Details" type="html">
<b>Card Number:</b>#attributes.x_card_num#<br>
<b>Expiration Date:</b>#attributes.x_exp_date#<br>
<b>Amount:</b>#attributes.x_amount#<br>
<b>eBay Number(s):</b>#goodItems#<br>
<b>Description:</b>#attributes.description#<br>
<b>Email:</b>#attributes.email#<br>
<h3 align="center">Authorize.Net response</h3><table style="border:1px dotted black;" cellpadding="5" cellspacing="0" align="center"><tr><td>#authorizeNetResponse#</td></tr></table>
		</cfmail>
	</cfif>
	<cfoutput><h3 align="center">Authorize.Net response</h3><table style="border:1px dotted black;" cellpadding="5" cellspacing="0" align="center"><tr><td>#authorizeNetResponse#</td></tr></table></cfoutput>
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Run Credit Card:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
	<form action="" method="post">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4" border="0">
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td width="50%" align="right"><input type="radio" name="x_type" id="x1" disabled></td>
			<td width="50%"><label for="x1">Charge a Credit Card</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="x_type" id="x2" value="CREDIT"></td>
			<td><label for="x2">Refund a Credit Card</label></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="x_type" id="x3" value="AUTH_CAPTURE" checked></td>
			<td><label for="x3">Authorize and Capture</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="x_type" id="x4" value="AUTH_ONLY"></td>
			<td><label for="x4">Authorize Only</label></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="radio" name="x_type" id="x5" value="CAPTURE_ONLY"></td>
			<td><label for="x5">Capture Only</label></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>First Name</b></td>
			<td><input type="text" name="x_first_name" value="" maxlength="50"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Last Name</b></td>
			<td><input type="text" name="x_last_name" value="" maxlength="50"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Card Number</b></td>
			<td><input type="text" name="x_card_num" value=""></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Expiration Date</b></td>
			<td><input type="text" name="x_exp_date" value=""></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Amount</b></td>
			<td><input type="text" name="x_amount" value=""></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>eBay Number(s)</b><br><small>(separated by comma)</small></td>
			<td><input type="text" name="x_fp_sequence" value="" size="50"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Description</b></td>
			<td><input type="text" name="description"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Email</b></td>
			<td><input type="text" name="email"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2">&nbsp;</td></tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Approval Code</b></td>
			<td><input type="text" name="x_auth_code" value=""></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><b>Transaction ID</b></td>
			<td><input type="text" name="x_trans_id" value=""></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td align="right"><input type="checkbox" name="x_test_request" id="x_test_request" value="TRUE"></td>
			<td><label for="x_test_request">Test Request</label></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center"><input type="submit" value="Submit" style="width:250px;"></td></tr>
		</table>
	</td></tr>
	</form>
	</table>
</td></tr>
</table>
</cfoutput>
