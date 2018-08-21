


<cfif NOT isAllowed("Items_ChangeStatus") AND NOT isAllowed("Items_NormalChangeStatus")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>


<cfif isAllowed("Items_ChangeStatus") OR ListFind("2,3,9,12", attributes.newstatusid)>
	<cfset oldItem = fChangeStatus(attributes.item, attributes.newstatusid)>



	<cfset callEBAY = false>
	<cfif attributes.newstatusid NEQ oldItem.status><!--- if status changed --->
		<cfquery name="sqllid" datasource="#request.dsn#">
			SELECT lid FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfswitch expression="#attributes.newstatusid#">
			<cfcase value="5"><!--- AWAITING PAYMENT --->
				<cfquery datasource="#request.dsn#">
					UPDATE items
					SET paid = '0',
						paidtime = NULL,
						shipped = '0',
						shippedtime = NULL
					WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
				</cfquery>
				<cfset callEBAY = true>
				<cfset paidValue = "false">
				<cfset shippedValue = "false">
			</cfcase>
			<cfcase value="9"><!--- RETURNED TO CLIENT --->
				<cfset fChangeLocation(attributes.item, "RTC")>
			</cfcase>
			<cfcase value="10"><!--- AWAITING SHIPMENT --->
				<cfquery datasource="#request.dsn#">
					UPDATE items
					SET paid = '1',
						paidtime = GETDATE(),
						shipped = '0',
						shippedtime = NULL
					WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
				</cfquery>
				<cfset callEBAY = true>
				<cfset paidValue = "true">
				<cfset shippedValue = "false">
			</cfcase>
			<cfcase value="11"><!--- PAID AND SHIPPED --->
				<cfset fChangeLocation(attributes.item, "P&S")>
				<cfquery datasource="#request.dsn#">
					UPDATE items
					SET paid = '1',
						paidtime = GETDATE(),
						shipped = '1',
						shippedtime = GETDATE()
					WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
				</cfquery>
				<cfset callEBAY = true>
				<cfset paidValue = "true">
				<cfset shippedValue = "true">
			</cfcase>
			<cfcase value="13"><!--- DONATED TO CHARITY --->
				<cfset fChangeLocation(attributes.item, "DTC")>
			</cfcase>
			<cfcase value="14"><!--- ITEM RELOTTED --->
				<cfset fChangeLocation(attributes.item, "RELOT")>
			</cfcase>
		</cfswitch>
		<cfif callEBAY AND (oldItem.ebayitem NEQ "")>
			<cfquery name="sqlEBAccount" datasource="#request.dsn#">
				SELECT a.eBayAccount, a.UserID, a.UserName, a.Password,
					a.DeveloperName, a.ApplicationName, a.CertificateName, a.RequestToken
				FROM auctions u
					INNER JOIN ebaccounts a ON u.ebayaccount = a.eBayAccount
				WHERE u.itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
			</cfquery>
			<cfscript>
				_ebay.UserID			= sqlEBAccount.UserID;
				_ebay.UserName			= sqlEBAccount.UserName;
				_ebay.Password			= sqlEBAccount.Password;
				_ebay.DeveloperName		= sqlEBAccount.DeveloperName;
				_ebay.ApplicationName	= sqlEBAccount.ApplicationName;
				_ebay.CertificateName	= sqlEBAccount.CertificateName;
				_ebay.RequestToken		= sqlEBAccount.RequestToken;
			</cfscript>
			<cfset _ebay.CallName ="CompleteSale">
			<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
			<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
				<RequesterCredentials>
					<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
				</RequesterCredentials>
				<ItemID>#oldItem.ebayitem#</ItemID>
				<TransactionID>0</TransactionID>
				<Paid>#paidValue#</Paid>
				<Shipped>#shippedValue#</Shipped>
			</#_ebay.CallName#Request>'>
			<cfset _ebay.ThrowOnError = false>
			<cfinclude template="../../api/act_call.cfm">
			<cfif NOT isDefined("_ebay.xmlResponse")>
				<cfoutput><h1 style="color:red;">ERROR OCCURED: #_ebay.response#</h1></cfoutput>
				<cfset _machine.error_in_action = true>
			<cfelseif _ebay.Ack EQ "failure">
				<cfoutput><h1 style="color:red;">API call failed! Anyhow, item updated in local database.</h1></cfoutput>
				<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.xmlRoot.Errors)#">
					<cfoutput>
					<h2 style="color:red;">#_ebay.xmlResponse.xmlRoot.Errors[i].SeverityCode.xmlText#: #_ebay.xmlResponse.xmlRoot.Errors[i].ShortMessage.xmlText#</h2>
					#_ebay.xmlResponse.xmlRoot.Errors[i].LongMessage.xmlText#
					</cfoutput>
				</cfloop>
				<cfset _machine.error_in_action = true>
			</cfif>
		</cfif>
	</cfif>
</cfif>
