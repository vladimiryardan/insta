<!---
Description:
- call every 8 or 12 hours interval to sync db to amazon
- gets all items and put it in the amazon items

ErrorResponse:#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
--->

<cfsetting requesttimeout="36000">
<cfscript>
_amazon = StructNew ();
</cfscript>


<cfoutput>

<h2>get Amazon items LastUpdatedAfter started at #DateFormat(Now())# #TimeFormat(Now())#</h2>

<cfquery datasource="#request.dsn#" name="get_amazonAccts" >
SELECT amazon_account_pkid
      ,[amazon_account_firstname]
      ,[amazon_account_lastname]
      ,[amazon_account_merchant_id]
      ,[amazon_account_marketplace_id]
      ,[amazon_account_aws_accesskeyid]
      ,[amazon_account_secret_key]
      ,[amazon_account_isactive]
  FROM [instant_main].[dbo].[amazon_accounts]
  where amazon_account_isactive = 1
</cfquery>



<cfloop query="get_amazonAccts">

<cfscript>
	_amazon = StructNew ();
	_amazon.callname = "ListOrders";
	_amazon.awsAccessId = amazon_account_aws_accesskeyid;
	_amazon.awsSecret = amazon_account_secret_key;
	_amazon.merchantId = amazon_account_merchant_id;
	_amazon.marketId = amazon_account_marketplace_id;
	signStr2 = "Action=" & #_amazon.callname# ;
	//daysback =  2;due to call being slow lets just use 1
	//daysback =  5; :vladedit: 20151203
	daysback =  100;

	m = createObject("component","amazon.com.amazon.mws.amazonorder");
	m.init(_amazon.awsAccessId,_amazon.awsSecret,_amazon.merchantId,_amazon.marketId);
	gn = m.GenerateSignedAmazonURL_listOrders('POST', 'mws.amazonservices.com', '/Orders/2011-01-01', signStr2, daysback);
</cfscript>



<cfset theDaysCount = #daysback# >
<cfset isstartDate = DateAdd( "d", -theDaysCount, now() ) />
<cfset iscreated_thenow = DateConvert("local2Utc", isstartDate)>
<cfset iscreated_time_stamp = "#DateFormat(iscreated_thenow,'yyyy-mm-dd')#T#TimeFormat(iscreated_thenow,'HH:mm:ss')#.00Z">
callname:#_amazon.callname#<br>
isstartDate:#isstartDate#<br>
iscreated_time_stamp:#iscreated_time_stamp#<br>
<br><br>

<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
		<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
		<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
		<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
		<cfhttpparam type="header" name="Accept-Encoding" Value="no-compression"> <!---:vladedit: 200151126 --->
		<cfhttpparam type="body" 	name="FeedContent" value="">
</cfhttp>



<cfset LastUpdatedAfter = now()>
<cfset callName = "ListOrders" >
<cfset _amazon.requestTimestamp = now()>
<cfset _amazon.response = cfhttp.FileContent>
<cfset _amazon.xmlResponse	= XMLParse (_amazon.response)>

<cfdump var="#trim(gn)#">

<cfif isdefined("vdebug")>
		<cfdump var="#_amazon.xmlResponse#">
</cfif>

<cfif isdefined("_amazon.xmlResponse.xmlRoot.ListOrdersResult")>
	
	<cfset _amazon.requestid = #_amazon.xmlResponse.xmlRoot.ResponseMetadata.RequestId.XmlText#>
	<!--- API LOG CALL --->
	<cfquery datasource="#request.dsn#">
		INSERT INTO amazon_apicall_logs (callname, request_timestamp,  requestid, callresponse,date_added,request_details)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.callname#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#_amazon.requestTimestamp#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.requestid#">,
			'#xmlformat(_amazon.xmlResponse)#',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#">,
			'#urlencodedformat(gn)#'
		)
	</cfquery>



	<!--- API LOG CALL ENDS--->
	
	<!---
	url: #trim(gn)#<br><br>
	Call: #callName#<br><br>
	LastUpdatedAfter: #LastUpdatedAfter#<br>
	requestTimestamp: #_amazon.requestTimestamp#<BR>
	RequestId:#_amazon.xmlResponse.xmlRoot.ResponseMetadata.RequestId.XmlText#<BR>
	requestTimestamp:#_amazon.requestTimestamp#<BR>
	--->
	
	<!--- we have the timestamp we have the request id lets log it to the db --->





	<cfloop index="i" from="1" to="#ArrayLen(_amazon.xmlResponse.xmlRoot.ListOrdersResult.Orders.xmlChildren)#">
		<cfset orderObj = _amazon.xmlResponse.xmlRoot.ListOrdersResult.Orders.xmlChildren[i]>
		<cfset AmazonOrderId = orderObj.AmazonOrderId.XmlText >
	
			<!---
			Order:#orderObj#<br><br>
			AmazonOrderId:#AmazonOrderId#<br><br>
			--->			
			
			<!--- DEFINE THE VARS TO INSERT TO DB --->
			<!---
			NOTE:shipping address is returned when
			• The order status is Shipped or PartiallyShipped.
			• The order status is Unshipped, and the order is fulfilled the seller.
			--->
			
			<!---AmazonOrderId--->
			<cfset AmazonOrderId = orderObj.AmazonOrderId.XmlText >
			
			<!---SellerOrderId--->
			<cfif isdefined("orderObj.SellerOrderId.XmlText")>
				<cfset var_amazon_item_SellerOrderId = "#orderObj.SellerOrderId.XmlText#" >
			<cfelse>
				<cfset var_amazon_item_SellerOrderId = "" >
			</cfif>
			
			<!---PurchaseDate--->
			<cfset var_amazon_item_PurchaseDate = "#orderObj.PurchaseDate.XmlText#" >
			<!---LastUpdateDate--->
			<cfset var_amazon_item_LastUpdateDate = "#orderObj.LastUpdateDate.XmlText#" >
			<!---OrderStatus--->
			<cfset var_amazon_item_OrderStatus = "#orderObj.OrderStatus.XmlText#" >
			
			
			<!---FulfillmentChannel--->
			<cfif isdefined("orderObj.FulfillmentChannel.XmlText")>
				<cfset var_amazon_item_FulfillmentChannel = orderObj.FulfillmentChannel.XmlText >
			<cfelse>
				<cfset var_amazon_item_FulfillmentChannel = "" >
			</cfif>
			
			<!---SalesChannel--->
			<cfif isdefined("orderObj.SalesChannel.XmlText")>
				<cfset var_amazon_item_SalesChannel = orderObj.SalesChannel.XmlText >
			<cfelse>
				<cfset var_amazon_item_SalesChannel = "" >
			</cfif>
			
			<!---OrderChannel--->
			<cfif isdefined("orderObj.OrderChannel.XmlText")>
				<cfset var_amazon_item_OrderChannel = orderObj.OrderChannel.XmlText >
			<cfelse>
				<cfset var_amazon_item_OrderChannel = "" >
			</cfif>
			
			<!---ShipServiceLevel--->
			<cfif isdefined("orderObj.ShipServiceLevel.XmlText")>
				<cfset var_amazon_item_ShipServiceLevel = orderObj.ShipServiceLevel.XmlText >
			<cfelse>
				<cfset var_amazon_item_ShipServiceLevel = "" >
			</cfif>
			
			
			<!--- SHIPPINGADDRESS --->
			<!---Name--->
			<cfif isdefined("orderObj.ShippingAddress.Name.XmlText")>
				<cfset var_amazon_item_shippingaddress_name = orderObj.ShippingAddress.Name.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_name = "" >
			</cfif>
			
			<!---AddressLine1--->
			<cfif isdefined("orderObj.ShippingAddress.AddressLine1.XmlText")>
				<cfset var_amazon_item_shippingaddress_AddressLine1 = orderObj.ShippingAddress.AddressLine1.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_AddressLine1 = "" >
			</cfif>
			<!---AddressLine2--->
			<cfif isdefined("orderObj.ShippingAddress.AddressLine2.XmlText")>
				<cfset var_amazon_item_shippingaddress_AddressLine2 = orderObj.ShippingAddress.AddressLine2.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_AddressLine2 = "" >
			</cfif>
			<!---AddressLine3--->
			<cfif isdefined("orderObj.ShippingAddress.AddressLine3.XmlText")>
				<cfset var_amazon_item_shippingaddress_AddressLine3 = orderObj.ShippingAddress.AddressLine3.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_AddressLine3 = "" >
			</cfif>
			<!---City--->
			<cfif isdefined("orderObj.ShippingAddress.City.XmlText")>
				<cfset var_amazon_item_shippingaddress_City = orderObj.ShippingAddress.City.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_City = "" >
			</cfif>
			<!---County--->
			<cfif isdefined("orderObj.ShippingAddress.County.XmlText")>
			<cfset var_amazon_item_shippingaddress_County = orderObj.ShippingAddress.County.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_County = "" >
			</cfif>
			<!---District--->
			<cfif isdefined("orderObj.ShippingAddress.District.XmlText")>
			<cfset var_amazon_item_shippingaddress_District = orderObj.ShippingAddress.District.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_District = "" >
			</cfif>
			<!---StateOrRegion--->
			<cfif isdefined("orderObj.ShippingAddress.StateOrRegion.XmlText")>
			<cfset var_amazon_item_shippingaddress_StateOrRegion = orderObj.ShippingAddress.StateOrRegion.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_StateOrRegion = "" >
			</cfif>
			<!---PostalCode--->
			<cfif isdefined("orderObj.ShippingAddress.PostalCode.XmlText")>
			<cfset var_amazon_item_shippingaddress_PostalCode = orderObj.ShippingAddress.PostalCode.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_PostalCode = "" >
			</cfif>
			<!---CountryCode--->
			<cfif isdefined("orderObj.ShippingAddress.CountryCode.XmlText")>
			<cfset var_amazon_item_shippingaddress_CountryCode = orderObj.ShippingAddress.CountryCode.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_CountryCode = "" >
			</cfif>
			<!---Phone--->
			<cfif isdefined("orderObj.ShippingAddress.Phone.XmlText")>
			<cfset var_amazon_item_shippingaddress_Phone = orderObj.ShippingAddress.Phone.XmlText >
			<cfelse>
				<cfset var_amazon_item_shippingaddress_Phone = "" >
			</cfif>
			
			
			
			<!---OrderTotal_CurrencyCode--->
			<cfif isdefined("orderObj.OrderTotal.CurrencyCode.XmlText")>
				<cfset var_amazon_item_OrderTotal_CurrencyCode = orderObj.OrderTotal.CurrencyCode.XmlText >
			<cfelse>
				<cfset var_amazon_item_OrderTotal_CurrencyCode = "" >
			</cfif>
			
			<!---OrderTotal_Amount--->
			<cfif isdefined("orderObj.OrderTotal.Amount.XmlText")>
				<cfset var_amazon_item_OrderTotal_Amount = orderObj.OrderTotal.Amount.XmlText >
			<cfelse>
				<cfset var_amazon_item_OrderTotal_Amount = "" >
			</cfif>
			
			<!---NumberOfItemsShipped--->
			<cfif isdefined("orderObj.NumberOfItemsShipped.XmlText")>
				<cfset var_amazon_item_NumberOfItemsShipped = orderObj.NumberOfItemsShipped.XmlText >
			<cfelse>
				<cfset var_amazon_item_NumberOfItemsShipped = "" >
			</cfif>
			
			<!---NumberOfItemsUnshipped--->
			<cfif isdefined("orderObj.NumberOfItemsShipped.XmlText")>
				<cfset var_amazon_item_NumberOfItemsShipped = orderObj.NumberOfItemsShipped.XmlText >
			<cfelse>
				<cfset var_amazon_item_NumberOfItemsShipped = "" >
			</cfif>
			
			
			<!--- check if AmazonOrderId exist in the db --->
			<cfquery datasource="#request.dsn#" name="chk_amazonid">
				select amazon_item_amazonorderid from amazon_items
				where amazon_item_amazonorderid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#AmazonOrderId#">
			</cfquery>
			
			#AmazonOrderId# - status:#var_amazon_item_OrderStatus#<br>
			<cfflush interval="100">
			<cfif chk_amazonid.recordcount eq 0>
			
			<!--- INSERT ORDER --->
			<!--- record not existing yet then lets insert to db --->
				<!---<cfquery datasource="#request.dsn#">
					INSERT INTO amazon_items
					(
					amazon_item_amazonorderid,
					amazon_item_sellerorderid,
					amazon_item_purchasedate,
					amazon_item_lastupdatedate,
					amazon_item_orderstatus,
					amazon_item_fulfillmentchannel,
					amazon_item_saleschannel,
					amazon_item_orderchannel,
					amazon_item_shipservicelevel,
					amazon_item_shippingaddress_name,
					amazon_item_shippingaddress_addressline1,
					amazon_item_shippingaddress_addressline2,
					amazon_item_shippingaddress_addressline3,
					amazon_item_shippingaddress_city,
					amazon_item_shippingaddress_county,
					amazon_item_shippingaddress_district,
					amazon_item_shippingaddress_stateorregion,
					amazon_item_shippingaddress_postalcode,
					amazon_item_shippingaddress_countrycode,
					amazon_item_shippingaddress_phone,
					amazon_item_ordertotal_currencycode,
					amazon_item_ordertotal_amount,
					amazon_item_numberofitemsshipped,
					amazon_item_numberofitemsunshipped,
					amazon_account_pkid,
					amazon_item_apiStatusFlag
					)
					VALUES
					(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#AmazonOrderId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_SellerOrderId#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromAmazon(var_amazon_item_PurchaseDate)#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromAmazon(var_amazon_item_LastUpdateDate)#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderStatus#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_FulfillmentChannel#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_SalesChannel#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderChannel#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_ShipServiceLevel#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_name#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine1#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine2#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine3#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_City#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_County#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_District#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_StateOrRegion#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_PostalCode#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_CountryCode#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_Phone#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderTotal_CurrencyCode#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderTotal_Amount#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#var_amazon_item_NumberOfItemsShipped#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#var_amazon_item_NumberOfItemsShipped#">,
					#get_amazonAccts.amazon_account_pkid#,
					'newupdate'
					)
				</cfquery>
				--->
			<cfelse>
			
			
				<!--- DO AN UPDATE IF EXISTS --->
				<!---<cfquery datasource="#request.dsn#">
					update amazon_items
					set	amazon_item_sellerorderid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_SellerOrderId#">,
					amazon_item_purchasedate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromAmazon(var_amazon_item_PurchaseDate)#">,
					amazon_item_lastupdatedate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateTimeFromAmazon(var_amazon_item_LastUpdateDate)#">,
					amazon_item_orderstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderStatus#">,
					amazon_item_fulfillmentchannel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_FulfillmentChannel#">,
					amazon_item_saleschannel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_SalesChannel#">,
					amazon_item_orderchannel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderChannel#">,
					amazon_item_shipservicelevel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_ShipServiceLevel#">,
					amazon_item_shippingaddress_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_name#">,
					amazon_item_shippingaddress_addressline1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine1#">,
					amazon_item_shippingaddress_addressline2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine2#">,
					amazon_item_shippingaddress_addressline3 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_AddressLine3#">,
					amazon_item_shippingaddress_city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_City#">,
					amazon_item_shippingaddress_county = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_County#">,
					amazon_item_shippingaddress_district = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_District#">,
					amazon_item_shippingaddress_stateorregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_StateOrRegion#">,
					amazon_item_shippingaddress_postalcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_PostalCode#">,
					amazon_item_shippingaddress_countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_CountryCode#">,
					amazon_item_shippingaddress_phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_shippingaddress_Phone#">,
					amazon_item_ordertotal_currencycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderTotal_CurrencyCode#">,
					amazon_item_ordertotal_amount = <cfqueryparam cfsqltype="cf_sql_varchar" value="#var_amazon_item_OrderTotal_Amount#">,
					amazon_item_numberofitemsshipped = <cfqueryparam cfsqltype="cf_sql_integer" value="#var_amazon_item_NumberOfItemsShipped#">,
					amazon_item_numberofitemsunshipped = <cfqueryparam cfsqltype="cf_sql_integer" value="#var_amazon_item_NumberOfItemsShipped#">,
					amazon_item_apiStatusFlag = 'newupdate'
					where amazon_item_amazonorderid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#AmazonOrderId#">
					<!---and (local_status != 'tracking_generated' or local_status is null)--->
				</cfquery>--->
				
			</cfif><!---chk_amazonid.recordcount--->
			
	
	
	
	
		
		
	</cfloop>
	
	

	
	<!--- check if there is next token --->
	<cfif structkeyExists(_amazon.xmlResponse.xmlRoot.ListOrdersResult,"NextToken")>		
		<cfset NextToken =  1 >
		<cfset valNextToken = _amazon.xmlResponse.xmlRoot.ListOrdersResult.NextToken.xmlText >
		
		<!--- we have a token loop until there is token --->
		<cfloop  condition = "NextToken eq 1">
			
			<cfdump var="#valNextToken#"><br><br><br>
			<cfscript>
				_amazon = StructNew ();
				_amazon.callname = "ListOrdersByNextToken";
				_amazon.awsAccessId = amazon_account_aws_accesskeyid;
				_amazon.awsSecret = amazon_account_secret_key;
				_amazon.merchantId = amazon_account_merchant_id;
				_amazon.marketId = amazon_account_marketplace_id;
				signStr2 = "Action=" & #_amazon.callname# ;
			
				m = createObject("component","amazon.com.amazon.mws.amazonorder");
				m.init(_amazon.awsAccessId,_amazon.awsSecret,_amazon.merchantId,_amazon.marketId);
				gn = m.GenerateSignedAmazonURL_ListOrdersByNextToken('POST', 'mws.amazonservices.com', '/Orders/2011-01-01', signStr2, valNextToken );
			</cfscript>

			<cfdump var="#gn#"><br><br><br>
			
			<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
					<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
					<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
					<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
					<cfhttpparam type="header" name="Accept-Encoding" Value="no-compression"> <!---:vladedit: 200151126 --->
					<cfhttpparam type="body" 	name="FeedContent" value="">
			</cfhttp>
			
			
			<cfset _amazon.response = cfhttp.FileContent>
			<cfset _amazon.xmlResponse	= XMLParse (_amazon.response)>		
				
			<!--- we need to pause a bit to get ahead of throttling  --->
			<cfset sleep(15000)>			
			
			<!--- check if there are errors --->
			<cfif structkeyExists(_amazon.xmlResponse.xmlRoot,"Error")>				
				<cfdump var="#_amazon.xmlResponse#">
				<cfset NextToken = 0>
			</cfif>
			

			<cfif structkeyExists(_amazon.xmlResponse.xmlRoot,"ListOrdersByNextTokenResult") and not structkeyExists(_amazon.xmlResponse.xmlRoot.ListOrdersByNextTokenResult,"NextToken") >
				<cfset NextToken = 0>
			<cfelseif structkeyExists(_amazon.xmlResponse.xmlRoot,"ListOrdersByNextTokenResult") 
				and structkeyExists(_amazon.xmlResponse.xmlRoot.ListOrdersByNextTokenResult,"NextToken")><!---next token exist then lets set valNextToken to new value --->				
				<cfset valNextToken = _amazon.xmlResponse.xmlRoot.ListOrdersByNextTokenResult.NextToken.xmlText >							
			</cfif>
			
		</cfloop>
			
	</cfif>	



	<cfif isdefined("vdebug")>
		<cfdump var="#_amazon.xmlResponse#">
	</cfif>

<cfelse><!---isdefined("_amazon.xmlResponse.xmlRoot.ListOrderItemsResult")--->
	Error: #_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
	<h2>get Amazon ABORTED FOR amazon_account_pkid:#get_amazonAccts.amazon_account_pkid# at #DateFormat(Now())# #TimeFormat(Now())#</h2><br>
	<cfabort>
</cfif>

</cfloop><!--- get_amazonAccts --->


<!--- include  --->
<cfinclude template="st_ListOrderItems.cfm" >

</cfoutput>



<cffunction output="false" returntype="date" name="DateTimeFromAmazon">
	<cfargument name="sArg" type="string" required="yes">
	<!--- sample return: 2011-07-15T03:46:16.000Z --->
	<cftry>
		<cfscript>
			sYear = Mid(sArg, 1, 4);
			sMonth = Mid(sArg, 6, 2);
			sDay = Mid(sArg, 9, 2);
			sHour = Mid(sArg, 12, 2);
			sMinute = Mid(sArg, 15, 2);
			sSecond = Mid(sArg, 18, 2);
			return DateConvert('utc2Local', CreateDateTime(sYear, sMonth, sDay, sHour, sMinute, sSecond));
		</cfscript>
		<cfcatch type="any">
			<cfif request.emails.error NEQ "">
				<cfmail
					from="#_vars.mails.from#"
					to="#request.emails.error#" 
					subject="DateTimeFromAmazon(#sArg#)"
				>
					#sArg#:CreateDateTime(#sYear#, #sMonth#, #sDay#, #sHour#, #sMinute#, #sSecond#)
				</cfmail>
			</cfif>
			<cfreturn DateConvert('utc2Local', CreateDateTime(sYear, sMonth, sDay, 0, 0, 0))>
		</cfcatch>
	</cftry>
</cffunction>