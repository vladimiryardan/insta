<cfif isAllowed("Listings_EditShippingNote")>
	<cfquery name="sqlNote" datasource="#request.dsn#">
		UPDATE items
		SET shipnote = <cfif Trim(attributes.shipnote) EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.shipnote#"></cfif>
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
	<cfset LogAction("edited shipment note for item #attributes.itemid#")>
</cfif>
