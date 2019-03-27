<cfif NOT isAllowed("Full_Access")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.edit" default="">
<cfset editTemplate = ListFindNoCase("Header,Description,SellWithUs,Payment,Shipping,AboutUs", attributes.edit)>
<cfif editTemplate>
	<cfquery name="sqlRecord" datasource="#request.dsn#">
		SELECT Template#attributes.edit# AS avalue, UserID
		FROM ebaccounts
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.eBayAccount#">
	</cfquery>
<cfelse>
	<cfquery name="sqlRecord" datasource="#request.dsn#">
		SELECT watermark, location, paypal,
			DeveloperName, ApplicationName, CertificateName,
			UserID, UserName, Password, RequestToken
		FROM ebaccounts
		WHERE eBayAccount = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.eBayAccount#">
	</cfquery>
	<cfoutput>
	<style type="text/css">
		input, textarea{font-size:11px; font-family:'Courier New', Courier, mono;}
		small{color:red;}
	</style>
	</cfoutput>
</cfif>
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Edit eBay Account:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table bgcolor="##AAAAAA" border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr><td>
		<table width="100%" cellspacing="1" cellpadding="4">
		<form action="index.cfm?act=admin.ebay.update&eBayAccount=#attributes.eBayAccount#&edit=#attributes.edit#" method="post">
</cfoutput>
		<cfif editTemplate>
			<cfoutput>
			<tr bgcolor="##F0F1F3"><td colspan="2"><b>#sqlRecord.UserID# / #attributes.edit#</b></td></tr>
			<tr bgcolor="##FFFFFF"><td colspan="2">
				Any of following will be replaced with dynamic values:<br>
				<div style="margin:2px 20px 2px 20px;">
					{ITEM_DESCRIPTION}<br>
					{ITEM_PAYMENT_METHODS}<br>
					{ITEM_ITEMID}<br>
					{ITEM_WHO_SCHEDULED}<br>
					{ITEM_VIDEO}<br>
				</div>
			</td></tr>
			<tr bgcolor="##F0F1F3"><td colspan="2">
					</cfoutput>
					<cfscript>
						basePath = Left(cgi.script_name, FindNoCase('index.cfm', cgi.script_name)-1) & "FCKeditor/";
						fckEditor = createObject("component", "#basePath#fckeditor");
						fckEditor.instanceName	= "avalue";
						fckEditor.value			= sqlRecord.avalue;
						fckEditor.basePath		= basePath;
						fckEditor.width			= "100%";
						fckEditor.height		= 270;
						fckEditor.toolbarSet	= "Auction";
						fckEditor.create();
					</cfscript>
					<cfoutput>
				</td>
			</tr>
			</cfoutput>
		<cfelse>
			<cfoutput>
			<tr bgcolor="##F0F1F3"><td align="right" valign="middle">Developer Name:</td><td><input name="DeveloperName" type="text" size="50" maxlength="50" value="#sqlRecord.DeveloperName#"></td></tr>
			<tr bgcolor="##FFFFFF"><td align="right" valign="middle">Application Name:</td><td><input name="ApplicationName" type="text" size="50" maxlength="50" value="#sqlRecord.ApplicationName#"></td></tr>
			<tr bgcolor="##F0F1F3"><td align="right" valign="middle">Certificate Name:</td><td><input name="CertificateName" type="text" size="50" maxlength="50" value="#sqlRecord.CertificateName#"></td></tr>
			<tr bgcolor="##FFFFFF"><td align="right" valign="middle">eBay UserID:</td><td><input name="UserID" type="text" size="50" maxlength="50" value="#sqlRecord.UserID#"> <small>DO NOT CHANGE THIS IF EXISTS AT LEAST ONE ACTIVE AUCTION</small></td></tr>
			<tr bgcolor="##F0F1F3"><td align="right" valign="middle">Dev ID:</td><td><input name="UserName" type="text" size="50" maxlength="50" value="#sqlRecord.UserName#"></td></tr>
			<tr bgcolor="##FFFFFF"><td align="right" valign="middle">Dev Password:</td><td><input name="Password" type="text" size="50" maxlength="50" value="#sqlRecord.Password#"></td></tr>
			<tr bgcolor="##F0F1F3"><td align="right" valign="middle">Request Token:</td><td><textarea name="RequestToken" cols="85" rows="12">#sqlRecord.RequestToken#</textarea></td></tr>
			<tr bgcolor="##FFFFFF"><td align="right" valign="middle">Watermark:</td><td><input name="watermark" type="text" size="50" maxlength="50" value="#sqlRecord.watermark#"><br><small>Must exist image (PNG) with specified name under IMAGES folder</small></td></tr>
			<tr bgcolor="##F0F1F3"><td align="right" valign="middle">Location:</td><td><input name="location" type="text" size="50" maxlength="50" value="#sqlRecord.location#"></td></tr>
			<tr bgcolor="##FFFFFF"><td align="right" valign="middle">PayPal:</td><td><input name="paypal" type="text" size="50" maxlength="50" value="#sqlRecord.paypal#"></td></tr>
			</cfoutput>
		</cfif>
<cfoutput>
		<tr bgcolor="##FFFFFF"><td colspan="2" class="ColHead">
			<button type="submit" style="width:100px;">Save</button>
		</td></tr>
		</form>
		</table>
	</td></tr>
	</table>

</td></tr>
</table>
</cfoutput>
