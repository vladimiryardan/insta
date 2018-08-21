<cfif isGroupMemberAllowed("Listings")>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		<cfif isDefined("attributes.refundpr")>
			SET drefund = GETDATE(),
				refundpr = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.refundpr#">,
				exception = 0
		<cfelse>
			SET drefund = NULL
		</cfif>
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfscript>
		if(isDefined("attributes.refundpr")){
			LogAction("added Refund Payment Reason #ListGetAt("Cannot Find,Double-Sold,Broken", attributes.refundpr)# for item #attributes.item#");
		}else{
			LogAction("deleted Refund Payment Reason for item #attributes.item#");
		}
	</cfscript>
	<cfif isDefined("attributes.refundpr") AND isEmail(_vars.emails.refund)>
		<cfquery name="sqlItem" datasource="#request.dsn#">
			SELECT item, title, PaidTime, refundpr
			FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfmail 
		from="#_vars.mails.from#" 
		to="#_vars.emails.refund#" 
		subject="Item #sqlItem.item# has been marked Refund">
The following item has been marked Refund because: #ListGetAt("Cannot Find,Double-Sold,Broken", sqlItem.refundpr)#

Item ID: #sqlItem.item#
Item Title: #sqlItem.title#
Date Paid: #DateFormat(sqlItem.PaidTime, "dd-mmm-yyyy")#
		</cfmail>
	</cfif>
</cfif>
