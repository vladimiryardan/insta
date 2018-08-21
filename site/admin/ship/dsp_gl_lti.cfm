<cfif ((attributes.dsp EQ "") AND NOT isGroupMemberAllowed("Listings")) OR NOT isAllowed("Lister_MarkRefundItems")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>
<!---<cfparam name="attributes.ship_list" default="admin.ship.awaiting">--->
<cfparam name="attributes.item" default="">
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>#attributes.pageTitle#</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
<cfif isDefined("attributes.nil_error")>
	<h3 style="color:red;">Item [#attributes.item#] does not belong to selected Ship List!</h3>
<cfelse>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<form method="POST" action="index.cfm?act=admin.ship.generate_label&maximize=true"><!--- target="_blank" onSubmit="postSubmit()"--->
	<tr>
	<!---
		<td>
			<select name="ship_list">
				<option value="all"<cfif attributes.ship_list EQ "all"> selected</cfif>>All</option>
				<option value="admin.ship.awaiting"<cfif attributes.ship_list EQ "admin.ship.awaiting"> selected</cfif>>Awaiting Ship</option>
				<option value="admin.ship.ship_sold_off"<cfif attributes.ship_list EQ "admin.ship.ship_sold_off"> selected</cfif>>Off eBay</option>
				<option value="admin.ship.combined"<cfif attributes.ship_list EQ "admin.ship.combined"> selected</cfif>>Combined</option>
				<option value="admin.ship.international"<cfif attributes.ship_list EQ "admin.ship.international"> selected</cfif>>Inter</option>
				<option value="admin.ship.urgent"<cfif attributes.ship_list EQ "admin.ship.urgent"> selected</cfif>>Urgent</option>
			</select>
		</td>--->
		<td>Enter Item Number:<br>
			<input type="text" size="20" maxlength="18" name="item" id="item" value="#attributes.item#">
			<br>
			<input type="submit" value="Generate Label">
			<input type="button" name="btn_cancel" value="Cancel" onclick="history.go(-1)">
		</td>
	</tr>
	</form>
	</table>
</cfif>
</td></tr>
</table>
<br>
<cfif NOT isDefined("attributes.nil_error")>
<!---
	function postSubmit(){
		document.getElementById("item").focus();
		document.getElementById("item").select();
	}
--->
<!---	<script language="javascript" type="text/javascript">
	<!--
	document.getElementById("item").focus();
	document.getElementById("item").value = ".";
	document.getElementById("item").select();
	document.getElementById("item").value = "";
	//-->
	</script>--->
</cfif>
</cfoutput>
