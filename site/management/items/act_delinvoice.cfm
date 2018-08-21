<cfif NOT isAllowed("Invoices_InvoiceItems")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfif isDefined("attributes.byinvoice")>
	<cftransaction>
		<cfquery datasource="#request.dsn#">
			DELETE FROM invoices
			WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.byinvoice#">
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE expenses
			SET invoicenum = 0
			WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#attributes.byinvoice#">
		</cfquery>
		<cfquery datasource="#request.dsn#" name="sqlList">
			SELECT item FROM items
			WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.byinvoice#">
		</cfquery>
		<cfif sqlList.RecordCount GT 0>
			<cfset lsItems = ValueList(sqlList.item)>
			<cfquery datasource="#request.dsn#">
				UPDATE items
				SET invoicenum = NULL
				WHERE item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#lsItems#" list="yes">)
			</cfquery>
			<cfquery datasource="#request.dsn#">
				UPDATE records
				SET checksent = 0
				WHERE itemid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#lsItems#" list="yes">)
			</cfquery>
			<cfloop index="i" list="#lsItems#">
				<cfset fChangeStatus(i, 11)><!--- Paid and Shipped --->
			</cfloop>
		</cfif>
	</cftransaction>
	<cfset _machine.cflocation = "index.cfm?dsp=management.invoices">
	<cfset LogAction("deleted invoice #attributes.byinvoice#")>
<cfelse>
	<cfparam name="attributes.item">
	<cfparam name="attributes.account">
	<cftransaction>
		<cfquery datasource="#request.dsn#" name="sqlInvoice">
			SELECT invoicenum
			FROM items
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET invoicenum = NULL
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfquery datasource="#request.dsn#">
			UPDATE records
			SET checksent = 0
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
		<cfset fChangeStatus(attributes.item, 11)><!--- Paid and Shipped --->
		<cfquery datasource="#request.dsn#" name="sqlItemsLeft">
			SELECT COUNT(*) AS cnt
			FROM items
			WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlInvoice.invoicenum#">
		</cfquery>
		<cfif sqlItemsLeft.cnt EQ 0>
			<cfquery datasource="#request.dsn#">
				DELETE FROM invoices
				WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlInvoice.invoicenum#">
			</cfquery>
			<cfquery datasource="#request.dsn#">
				UPDATE expenses
				SET invoicenum = 0
				WHERE invoicenum = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlInvoice.invoicenum#">
			</cfquery>
		</cfif>
	</cftransaction>
	<cfset _machine.cflocation = "index.cfm?dsp=management.items.list&account=#attributes.account#">
	<cfset LogAction("deleted invoice for item #attributes.item#")>
</cfif>
