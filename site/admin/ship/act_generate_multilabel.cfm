<cfset _machine.cflocation = "">
<cfparam name="attributes.maximize" default="false">
<cfif isDefined("attributes.ship_list")>
	<cfquery name="sqlCheck" datasource="#request.dsn#">
		SELECT i.item
		FROM items i
			LEFT JOIN ebitems e ON i.ebayitem = e.ebayitem
			LEFT JOIN (SELECT DISTINCT itmItemID, byrCountry FROM ebtransactions) t ON i.ebayitem = t.itmItemID
		WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		<cfif attributes.ship_list EQ "admin.ship.ship_sold_off">
			AND i.offebay = '1'
			AND i.status = 10<!--- Awaiting Shipment --->
		<cfelseif attributes.ship_list NEQ "all">
			AND
			<cfif attributes.ship_list NEQ "admin.ship.refund">
				(
					(
						e.hbuserid <cfif attributes.ship_list NEQ "admin.ship.combined">NOT </cfif>IN
						(
							SELECT e2.hbuserid
							FROM items i2
								LEFT JOIN ebitems e2 ON i2.ebayitem = e2.ebayitem
							WHERE e2.hbuserid IS NOT NULL
								AND i2.paid = '1'
								AND i2.shipped = '0'
								AND i2.ShippedTime IS NULL
							GROUP BY e2.hbuserid
							HAVING COUNT(i2.item) > 1
						)
					)
				)
				AND
			</cfif>
			(
				(
					i.exception = 0
					AND i.paid = '1'
					AND i.shipped = '0'
					AND i.ShippedTime IS NULL
				<cfif attributes.ship_list EQ "admin.ship.combined">
					AND i.drefund IS NULL
					AND i.PaidTime IS NOT NULL
	<!---				AND t.byrCountry = 'US'--->
				<cfelseif attributes.ship_list EQ "admin.ship.international">
					AND i.drefund IS NULL
					AND i.PaidTime IS NOT NULL
					AND t.byrCountry != 'US'
				<cfelseif attributes.ship_list EQ "admin.ship.urgent">
					AND i.drefund IS NULL
					AND
					(
						(i.PaidTime <= DATEADD(DAY, -7, GETDATE()) AND t.byrCountry = 'US')
						OR
						(i.drefund IS NOT NULL AND i.PaidTime IS NOT NULL AND t.byrCountry != 'US')
					)
				<cfelseif attributes.ship_list EQ "admin.ship.refund">
					AND i.drefund IS NOT NULL
					AND t.byrCountry = 'US'
				<cfelse>
					AND i.drefund IS NULL
					AND t.byrCountry = 'US'
					AND i.PaidTime > DATEADD(DAY, -7, GETDATE())
				</cfif>
				)
				<cfif (attributes.ship_list EQ "admin.ship.urgent")>
					OR (i.exception = 1)
				</cfif>
			)
		</cfif>
	</cfquery>
	<cfif sqlCheck.RecordCount EQ 0>
		<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.gl&item=#attributes.item#&ship_list=#attributes.ship_list#&nil_error=1">
	</cfif>
</cfif>

<cfif _machine.cflocation EQ "">
	<cfquery name="sqlItem" datasource="#request.dsn#">
		SELECT weight
		FROM items
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	
	<cfif sqlItem.weight gT 3> 
		<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.fedex.FedexMulti&item=#attributes.item#&maximize=#attributes.maximize#">
	<cfelseif sqlItem.weight LTE 3 >
		<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.usps.request_multilabel&item=#attributes.item#&maximize=#attributes.maximize#">
	<cfelse>
		<cfset _machine.cflocation = "index.cfm?dsp=admin.ship.confirm_multilabel&item=#attributes.item#&maximize=#attributes.maximize#">
	</cfif>
</cfif>
