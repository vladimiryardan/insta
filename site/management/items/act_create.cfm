<cfif NOT isAllowed("Items_CreateNew")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.bold" default="0">
<cfparam name="attributes.upc" default="">
<cfparam name="attributes.border" default="0">
<cfparam name="attributes.highlight" default="0">
<cfparam name="attributes.vehicle" default="0">
<cfparam name="attributes.width_is" default="1">
<cfparam name="attributes.height_is" default="1">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.itemSKU" default="00001"><!--- we will set an sku item 00001 if ever they don't want or forgot to set it --->
<cfparam name="attributes.itemCondition" default="">
<cfparam name="attributes.itemManual" default="">
<cfparam name="attributes.itemComplete" default="">
<cfparam name="attributes.itemTested" default="">
<cfparam name="attributes.retailPackingIncluded" default="">
<cfparam name="attributes.specialNotes" default="">
<cfparam name="attributes.internalShipToLocations" default="Worldwide">
<cfparam name="attributes.sub_description" default="">
<cfparam name="attributes.ship_dimension_name" default="">


<cfparam name="attributes.shipNotes" default=""  >
<cfparam name="attributes.redirectLocation" default="" >
<cfparam name="attributes.orig_item" default="" >
<cfparam name="attributes.dummy" default="0" >
<cfparam name="attributes.item" default="" >

<cfparam name="attributes.model2" default="" >


<cfif attributes.accountid EQ "">
	<cfset attributes.accountid = session.user.accountid>
<cfelse>
	<cfset attributes.accountid = REReplace(attributes.accountid, "[^0-9]*", "", "ALL")>
</cfif>
<cfparam name="attributes.purchase_price" default="0">
<cfset attributes.purchase_price = REReplace(attributes.purchase_price, "[^0-9\.]*", "", "ALL")>
<cfif NOT isNumeric(attributes.purchase_price)>
	<cfset attributes.purchase_price = 0>
</cfif>
<cfif attributes.age EQ "">
	<cfset attributes.age = "N/A">
</cfif>
<cfset attributes.startprice_real = REReplace(attributes.startprice_real, "[^0-9\.]*", "", "ALL")>
<cfif NOT isNumeric(attributes.startprice_real)>
	<cfset attributes.startprice_real = 0>
</cfif>
<cfset attributes.startprice = REReplace(attributes.startprice, "[^0-9\.]*", "", "ALL")>
<cfif NOT isNumeric(attributes.startprice)>
	<cfset attributes.startprice = 0>
</cfif>
<cfset attributes.buy_it_now = REReplace(attributes.buy_it_now, "[^0-9\.]*", "", "ALL")>
<cfif NOT isNumeric(attributes.buy_it_now)>
	<cfset attributes.buy_it_now = 0>
</cfif>
<cfset attributes.qty_multiple = REReplace(attributes.qty_multiple, "[^0-9]*", "", "ALL")>
<cfif NOT isNumeric(attributes.qty_multiple) OR (attributes.qty_multiple LT 2)>
	<cfset attributes.qty_multiple = 1>
</cfif>




	<cfloop index="multi" from="1" to="#attributes.qty_multiple#">
		<cfquery name="sqlNextID" datasource="#request.dsn#">
			SELECT nextitemnum, store, commission, invested
			FROM accounts
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.accountid#">
		</cfquery>
		<cfquery name="sqlInvestmentSpent" datasource="#request.dsn#">
			SELECT SUM(purchase_price) AS total_purchased
			FROM items
			WHERE aid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.accountid#">
		</cfquery>
		<cfset investment_balance = sqlNextID.invested>
		<cfif (sqlInvestmentSpent.RecordCount GT 0) AND isNumeric(sqlInvestmentSpent.total_purchased)>
			<cfset investment_balance = investment_balance - sqlInvestmentSpent.total_purchased>
		</cfif>
		<cfif sqlNextID.RecordCount NEQ 1>
			<cfset _machine.cflocation = "index.cfm?dsp=management.items&msg=10">
		<cfelseif (sqlNextID.invested GT 0) AND (attributes.purchase_price EQ 0)>
			<cfset _machine.cflocation = "index.cfm?dsp=management.items.create&msg=1">
			<cfloop index="a" list="accountid,title,cat,age,description,startprice_real,startprice,buy_it_now,weight,commission,purchase_price,bold,border,highlight,vehicle">
				<cfparam name="attributes.#a#" default="">
				<cfset _machine.cflocation = _machine.cflocation & "&#a#=#URLEncodedFormat(attributes[a])#">
			</cfloop>
		<cfelseif (sqlNextID.invested GT 0) AND (investment_balance LT attributes.purchase_price)>
			<cfset _machine.cflocation = "index.cfm?dsp=management.items.create&msg=2&investment_balance=#URLEncodedFormat(investment_balance)#">
			<cfloop index="a" list="accountid,title,cat,age,description,startprice_real,startprice,buy_it_now,weight,commission,purchase_price,bold,border,highlight,vehicle">
				<cfparam name="attributes.#a#" default="">
				<cfset _machine.cflocation = _machine.cflocation & "&#a#=#URLEncodedFormat(attributes[a])#">
			</cfloop>
		<cfelse>
			<cfset itemid = "#sqlNextID.store#.#attributes.accountid#.#sqlNextID.nextitemnum#">
			<cfif multi EQ 1>
				<cfset multi_itemid = itemid>
			</cfif>
			<cfset itemnumber = sqlNextID.nextitemnum + 1>
			<cfquery datasource="#request.dsn#">
				UPDATE accounts
				SET nextitemnum = <cfqueryparam cfsqltype="cf_sql_integer" value="#itemnumber#">
				WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.accountid#">
			</cfquery>
			<cfif NOT isDefined("attributes.commission") OR (attributes.commission EQ "")>
				<cfset attributes.commission = sqlNextID.commission>
			</cfif>



			<cfquery datasource="#request.dsn#" result="insertRes">
				INSERT INTO items
				(
					ebaytitle,
					ebaydesc,
					item,
					aid,
					dcreated,
					who_created,
					listcount,
					<cfif attributes.cat NEQ "">cid, </cfif>
					title,
					description,
					make,
					model,
					value,
					age,
					startprice_real,
					startprice, buy_it_now, status, dreceived, weight<cfif isAllowed("Items_EditCommission") AND (attributes.commission NEQ "")>, commission</cfif>,
					bold, border, highlight, vehicle, purchase_price, width, height, depth, multiple, weight_oz,internal_itemSKU,internal_itemCondition,itemManual,
					itemComplete,itemTested,retailPackingIncluded,specialNotes,internalShipToLocations,internal_itemSKU2,
					lid, dpacked, 
					upc,
					mpnBrand,
					mpnNum,
					sub_description,
					ship_dimension_name,
					dummy,
					isbn,
					model2
					

				)
				VALUES (
					'',
					'',
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">,<!---'#itemid#',--->
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.accountid#">,<!---#attributes.accountid#,--->
					GETDATE(),
					<cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.accountid#">,<!---#session.user.accountid#,--->
					1,
				<cfif attributes.cat NEQ "">
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cat#">,
				</cfif>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.title#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.description#">,
					'DEPRECATED',
					'DEPRECATED',
					'DEPRECATED',
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#listfirst(attributes.age)#">,<!--- NOTE VLAD: listfirst is used coz there is err where multi comma delimited values are being passed ex. http://www.instantonlineconsignment.com/index.cfm?dsp=management.items.copy&item=201.11153.1036 --->
					<cfqueryparam cfsqltype="cf_sql_float" value="#attributes.startprice_real#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#attributes.startprice#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#attributes.buy_it_now#">,
					3,<!--- ITEM RECEIVED --->
					GETDATE(),
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.weight#" null="#IIF(attributes.weight EQ '', DE('YES'), DE('NO'))#">,
				<cfif isAllowed("Items_EditCommission") AND (attributes.commission NEQ "")>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.commission#">,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.bold#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.border#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.highlight#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.vehicle#">,
				<cfqueryparam cfsqltype="cf_sql_money" value="#attributes.purchase_price#">,
				<!---dimensions --->
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.width_dimension#">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.height_dimension#">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.depth_dimension#">,
				<cfif attributes.qty_multiple EQ 1>
					''
				<cfelseif multi EQ 1>
					'MULTIPLE'
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#multi_itemid#">
				</cfif>,
				<cfif Len(attributes.weight_oz)>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.weight_oz#">
				<cfelse>
					0
				</cfif>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemSKU#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemCondition#">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemManual#">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemComplete#">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.itemTested#">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.retailPackingIncluded#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.specialNotes#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.internalShipToLocations#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemSKU#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.lid#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.upc#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.mpnBrand#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.mpnNum#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.sub_description#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#HTMLEditFormat(attributes.ship_dimension_name)#" list="true" separator="," >,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.dummy#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.isbn#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.model2#">
				)
			</cfquery>



			<!--- chk auction_itemspecifics for this item--->
			<cfquery name="chkItemspecifics" datasource="#request.dsn#">
				select * from auction_itemspecifics
				where itemid  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">
			</cfquery>

			<!---clear existing most probably none but to be safe and not mess up--->
			<cfif chkItemspecifics.recordcount gte 1 >
				<cfquery name="clrItemspecifics" datasource="#request.dsn#">
					DELETE FROM auction_itemspecifics
					WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">
				</cfquery>
			</cfif>


			<CFLOOP COLLECTION="#Form#" ITEM="VarName">
					<!--- is there item specifics?--->
					<cfif LEFT(VarName, 14) IS "itemspecifics_" >
						<CFSET spcfcsName = RemoveChars(VarName, 1, 14)>
						<CFSET spcfcsValue = #Form[VarName]#>
						<!--- get selection mode --->
						<CFSET selmode = #Form["mode_"&rereplace(spcfcsName,"[^A-Za-z0-9]","","all")]# >

						<!---
						this is a complex form. if user enters something in the input box it will overwrite what's selected
						user specified a custom value and freetext.
						--->
						<CFSET userTextSpcfcs = #Form[rereplace(spcfcsName,"[^A-Za-z0-9]","","all")]# >
						<cfif userTextSpcfcs neq "">
							<!--- we will set only if there is a custom value and freetext --->
							<CFSET spcfcsValue = userTextSpcfcs >
						</cfif>



						<!--- lets insert to db:auction_itemspecifics --->
						<cfquery datasource="#request.dsn#">
							 insert into auction_itemspecifics
							(itemid,iname,ivalue,selection_mode)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#spcfcsName#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#spcfcsValue#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#selmode#">
							)
						</cfquery>

					</cfif>
			</CFLOOP>





			<cfquery name="sqlRecord" datasource="#request.dsn#">
				INSERT INTO records
				(tracking, itemid, [desc], aid, dstarted, dended, checksent, highbidder)
				VALUES (
					'',
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.description#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.accountid#">,
					NULL, NULL, '0', ''

				)
			</cfquery>
			
			<cftransaction>
				<!--- update shipnote when supplied --->
				<cfif attributes.shipNotes neq "" >
					<cfquery datasource="#request.dsn#">
						UPDATE items
						SET shipnote = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#attributes.shipNotes#">
						WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#itemid#">
					</cfquery>
				</cfif>
				
				<cfif attributes.orig_item neq "">
					<!--- we need this to set lid to dummy 20160816 Patricks request --->
					<cfquery datasource="#request.dsn#">
						UPDATE items
						SET lid = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="DUMMY">
						,itemis_template = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
						WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.orig_item#">
					</cfquery>
				</cfif>
			</cftransaction>
			
			<cfset LogAction("created item #itemid#")>
			<cfif attributes.redirectLocation neq "">
				
				<cfset _machine.cflocation = "#attributes.redirectLocation#&msg=4&msgDetail=#itemid# Created">
			<cfelse>	
				<cfset _machine.cflocation = "index.cfm?dsp=management.items&msg=2&itemid=#itemid#">
			</cfif>
		</cfif>
	</cfloop>
	<cftry>
	<cfcatch type="any">
		<cfset _machine.cflocation = "index.cfm?dsp=management.items&msg=20">
	</cfcatch>
</cftry>
