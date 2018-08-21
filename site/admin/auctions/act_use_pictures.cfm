<cfparam name="attributes.items" default="">
<cfif attributes.items NEQ "">
	<!--- CREATE NON-EXISTING AUCTIONS, IF ANY --->
	<cfquery datasource="#request.dsn#" name="sqlDefault">
		SELECT i.item, i.title, i.description, i.weight, i.weight_oz, i.bold, i.border, i.highlight, i.startprice_real, i.startprice, i.buy_it_now
		FROM items i
			LEFT JOIN auctions a ON i.item = a.itemid
		WHERE i.item IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
			AND a.itemid IS NULL
	</cfquery>
	<cfloop query="sqlDefault">
		<cfset LogAction("created auction for item #sqlDefault.item# (use pictures of #attributes.use_pictures#)")>
		<cfquery datasource="#request.dsn#">
			INSERT INTO auctions
			(itemid, scheduledBy, Title, Description, PackedWeight, PackedWeight_oz, StartingPrice, ReservePrice, BuyItNowPrice, Bold, Border, Highlight, PackageSize)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlDefault.item#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(session.user.first, 1)##Left(session.user.last, 1)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#sqlDefault.title#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#_vars.lister.descriptionBegin##sqlDefault.description#">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#Val(sqlDefault.weight)#">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#sqlDefault.weight_oz#">,
				'#sqlDefault.startprice_real#',
				'#sqlDefault.startprice#',
				'#sqlDefault.buy_it_now#',
				'#sqlDefault.bold#',
				'#sqlDefault.border#',
				'#sqlDefault.highlight#',
				<cfif (sqlDefault.weight + sqlDefault.weight_oz/16) LT 30>
					0
				<cfelseif (sqlDefault.weight + sqlDefault.weight_oz/16) LT 70>
					2
				<cfelseif (sqlDefault.weight + sqlDefault.weight_oz/16) LT 90>
					3
				<cfelse>
					0
				</cfif>
			)
		</cfquery>
	</cfloop>
	<!--- UPDATE AUCTIONS, TO MAKE THEM USE PARTICULAR ITEM'S PICTURES --->
	<cfquery datasource="#request.dsn#">
		UPDATE auctions
		SET use_pictures = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.use_pictures#">
		WHERE itemid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.items#" list="yes">)
	</cfquery>
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=" & attributes.dsp>
