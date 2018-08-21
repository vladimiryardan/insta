<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.rtcACCOUNTS" default="">
<cfif ListLen(attributes.rtcACCOUNTS) GT 0>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET dcalled = GETDATE()
		WHERE aid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.rtcACCOUNTS#" list="yes">)
			AND status = 12<!--- NEED TO CALL --->
			AND (
					(dcalled IS NULL)
						OR
					(dcalled <= DATEADD(DAY, -10, GETDATE()))
				)
	</cfquery>
</cfif>

<cfparam name="attributes.dtcACCOUNTS" default="">
<cfif ListLen(attributes.dtcACCOUNTS) GT 0>
	<cfquery name="sqlItems" datasource="#request.dsn#">
		SELECT item FROM items
		WHERE aid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dtcACCOUNTS#" list="yes">)
			AND status = 12<!--- NEED TO CALL --->
			AND (
					(dcalled IS NULL)
						OR
					(dcalled <= DATEADD(DAY, -10, GETDATE()))
				)
	</cfquery>
	<cfloop query="sqlItems">
		<cfset fChangeStatus (sqlItems.item, 13)><!--- DONATED TO CHARITY --->
	</cfloop>
</cfif>

<cfparam name="attributes.ntrACCOUNTS" default="">
<cfif ListLen(attributes.ntrACCOUNTS) GT 0>
	<cfquery name="sqlItems" datasource="#request.dsn#">
		SELECT item FROM items
		WHERE aid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ntrACCOUNTS#" list="yes">)
			AND status = 12<!--- NEED TO CALL --->
			AND (
					(dcalled IS NULL)
						OR
					(dcalled <= DATEADD(DAY, -10, GETDATE()))
				)
	</cfquery>
	<cfloop query="sqlItems">
		<cfset fChangeStatus (sqlItems.item, 16)><!--- NEED TO RELOT --->
	</cfloop>
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=management.need_call">
