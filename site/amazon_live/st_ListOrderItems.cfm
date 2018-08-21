<!---
Note:
- if the record count is greater than 15 the script pause for 6 seconds

ErrorResponse:
#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#
--->
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
<cfoutput>

	<cfloop query="get_amazonAccts" >
	
		<!---
		Note: get amazon items that was last updated with a amazon_account_pkid eq amazon 
		account holder and amazon_item_apiStatusFlag is 'newupdate'
		NOTE: up to a maximum of 50 ORDER IDS
		- revision: 20111129 - we dont want 'shipped' and 'canceled' items to be included in 
		ListOrderItems call coz those amazon items are done
		--->
		<cfquery datasource="#request.dsn#" name="get_amazonOrderIds" >
			select amazon_items.* from amazon_items
			where amazon_item_apiStatusFlag = 'newupdate'
			and amazon_account_pkid = #get_amazonAccts.amazon_account_pkid#and 
			(amazon_item_orderstatus != 'Shipped' and amazon_item_orderstatus != 'Canceled')
		</cfquery>
	
		<!--- loop over orderids --->
		<cfif get_amazonOrderIds.recordcount gte 1 >
		
			Amazon Order Id Count(max 15 - throttle): 
			#get_amazonOrderIds.recordcount#
			<br>
			<cfset row = 0 >
			<cfloop query="get_amazonOrderIds" >
				<cfset row = row + 1 >
			
				[
				#row#
				]
				<br>
				id:
				#amazon_item_amazonorderid#
				<br>
				status: 
				#amazon_item_orderstatus#
				<br>
				<cfflush interval="100" >
				
				<cfscript>
					_amazon = StructNew();
					_amazon.requestTimestamp = now();
					_amazon.callname = "ListOrderItems";
					_amazon.awsAccessId = get_amazonAccts.amazon_account_aws_accesskeyid;
					_amazon.awsSecret = get_amazonAccts.amazon_account_secret_key;
					_amazon.merchantId = get_amazonAccts.amazon_account_merchant_id;
					_amazon.marketId = get_amazonAccts.amazon_account_marketplace_id;
					signStr2 = "Action=" & #_amazon.callname#;
				
					//Create Marketplace Object
					m = createObject( "component", "amazon.com.amazon.mws.amazonorder" );
					m.init( _amazon.awsAccessId, _amazon.awsSecret, _amazon.merchantId, _amazon.marketId );
				</cfscript>
				
				<cfset gn = m.GenerateSignedAmazonURL_ListOrderItems( 'POST', 
				                                                      'mws.amazonservices.com',
				                                                      '/Orders/2011-01-01',signStr2, 
				                                                      get_amazonOrderIds.amazon_item_amazonorderid ) >
				<cfhttp url="#trim(gn)#" method="POST" 
				        useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)" >
					<cfhttpparam type="Header" name="Accept-Encoding" value="*" />
					<cfhttpparam type="Header" name="TE" value="deflate;q=0" />
					<cfhttpparam type="header" name="Content-Type" value="text/xml; charset=iso-8859-1" >
					<cfhttpparam type="body" name="FeedContent" value="" >
				</cfhttp>
				<cfset LastUpdatedAfter = now() >
				<cfset callName = _amazon.callname >
				<cfset _amazon.requestTimestamp = now() >
				<cfset _amazon.response = cfhttp.FileContent >
				<cfset _amazon.xmlResponse = XMLParse( _amazon.response ) >
				callname:
				#_amazon.callname#
				<br>
				<br>
				<br>
				<!--- if the record count is greater than 15 we need to pause for 6 seconds --->
				<cfif get_amazonOrderIds.RecordCount gte 15 >
					
					<cfscript>
						go_to = createObject( "java", "java.lang.Thread" );
						go_to.sleep( 30000 );
					</cfscript>
					
				</cfif>
			
				<cfif isdefined( "_amazon.xmlResponse.xmlRoot.ListOrderItemsResult" ) >
					<cfset _amazon.requestid = #_amazon.xmlResponse.xmlRoot.ResponseMetadata.RequestId.XmlText# >
					<!--- API LOG CALL --->
					<cfquery datasource="#request.dsn#" >
						INSERT INTO amazon_apicall_logs (callname, request_timestamp, requestid, 
						callresponse,date_added,request_details)
						VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.callname#" >
						,<cfqueryparam cfsqltype="cf_sql_date" value="#_amazon.requestTimestamp#" >
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.requestid#" >
						,
						'#xmlformat( _amazon.xmlResponse )#',<cfqueryparam cfsqltype="cf_sql_timestamp" 
					              value="#createodbcdatetime(now())#" >
						,
						'#urlencodedformat( gn )#'
						)
					</cfquery>
					<!--- API LOG CALL ENDS--->
					<cfset OrderItemObj = #_amazon.xmlResponse.xmlRoot.ListOrderItemsResult.OrderItems.OrderItem# >
					<cfset AmazonOrderId = #_amazon.xmlResponse.xmlRoot.ListOrderItemsResult.AmazonOrderId.XmlText# >
					<cfset ASIN = #OrderItemObj.ASIN.XmlText# >
				
					<!---SellerSKU--->
					<cfif isdefined( "OrderItemObj.SellerSKU.XmlText" ) >
						<cfset var_amazon_item_SellerSKU = OrderItemObj.SellerSKU.XmlText >
					<cfelse>
						<cfset var_amazon_item_SellerSKU = "" >
					</cfif>
					<!---Title--->
					<cfif isdefined( "OrderItemObj.Title.XmlText" ) >
						<cfset var_amazon_item_Title = OrderItemObj.Title.XmlText >
					<cfelse>
						<cfset var_amazon_item_Title = "" >
					</cfif>
					<!---QuantityOrdered--->
					<cfif isdefined( "OrderItemObj.QuantityOrdered.XmlText" ) >
						<cfset var_amazon_item_QuantityOrdered = OrderItemObj.QuantityOrdered.XmlText >
					<cfelse>
						<cfset var_amazon_item_QuantityOrdered = "0" >
					</cfif>
					<!---QuantityShipped--->
					<cfif isdefined( "OrderItemObj.QuantityShipped.XmlText" ) >
						<cfset var_amazon_item_QuantityShipped = OrderItemObj.QuantityShipped.XmlText >
					<cfelse>
						<cfset var_amazon_item_QuantityShipped = "0" >
					</cfif>
					<!---GiftMessageText--->
					<cfif isdefined( "OrderItemObj.GiftMessageText.XmlText" ) >
						<cfset var_amazon_item_GiftMessageText = OrderItemObj.GiftMessageText.XmlText >
					<cfelse>
						<cfset var_amazon_item_GiftMessageText = "" >
					</cfif>
					<!---ItemPrice.Amount--->
					<cfif isdefined( "OrderItemObj.ItemPrice.Amount.XmlText" ) >
						<cfset var_amazon_item_ItemPrice = OrderItemObj.ItemPrice.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ItemPrice = "" >
					</cfif>
					<!---ShippingPrice.Amount--->
					<cfif isdefined( "OrderItemObj.ShippingPrice.Amount.XmlText" ) >
						<cfset var_amazon_item_ShippingPrice = OrderItemObj.ShippingPrice.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ShippingPrice = "" >
					</cfif>
					<!---GiftWrapPrice.Amount--->
					<cfif isdefined( "OrderItemObj.GiftWrapPrice.Amount.XmlText" ) >
						<cfset var_amazon_item_GiftWrapPrice = OrderItemObj.GiftWrapPrice.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_GiftWrapPrice = "" >
					</cfif>
					<!---ItemTax.Amount--->
					<cfif isdefined( "OrderItemObj.ItemTax.Amount.XmlText" ) >
						<cfset var_amazon_item_ItemTax = OrderItemObj.ItemTax.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ItemTax = "" >
					</cfif>
					<!---ShippingTax.Amount--->
					<cfif isdefined( "OrderItemObj.ShippingTax.Amount.XmlText" ) >
						<cfset var_amazon_item_ShippingTax = OrderItemObj.ShippingTax.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ShippingTax = "" >
					</cfif>
					<!---ShippingTax.Amount--->
					<cfif isdefined( "OrderItemObj.ShippingTax.Amount.XmlText" ) >
						<cfset var_amazon_item_ShippingTax = OrderItemObj.ShippingTax.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ShippingTax = "" >
					</cfif>
					<!---GiftWrapTax.Amount--->
					<cfif isdefined( "OrderItemObj.GiftWrapTax.Amount.XmlText" ) >
						<cfset var_amazon_item_GiftWrapTax = OrderItemObj.GiftWrapTax.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_GiftWrapTax = "" >
					</cfif>
					<!---ShippingDiscount.Amount--->
					<cfif isdefined( "OrderItemObj.ShippingDiscount.Amount.XmlText" ) >
						<cfset var_amazon_item_ShippingDiscount = OrderItemObj.ShippingDiscount.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_ShippingDiscount = "" >
					</cfif>
					<!---PromotionDiscount.Amount--->
					<cfif isdefined( "OrderItemObj.PromotionDiscount.Amount.XmlText" ) >
						<cfset var_amazon_item_PromotionDiscount = OrderItemObj.PromotionDiscount.Amount.XmlText >
					<cfelse>
						<cfset var_amazon_item_PromotionDiscount = "" >
					</cfif>
				
					<!--- lets update the database --->
					<!--- check if AmazonOrderId exist in the db for surety and error --->
					<cfquery datasource="#request.dsn#" name="chk_amazonid" >
						select amazon_item_amazonorderid from amazon_items
						where amazon_item_amazonorderid = <cfqueryparam cfsqltype="cf_sql_varchar" 
					              value="#AmazonOrderId#" >
					</cfquery>
				
					<cfif chk_amazonid.recordCount gte 1 >
						<!--- DO AN UPDATE IF EXISTS --->
						<cfoutput>
							#ASIN#
							<br>
						</cfoutput>
						<cfquery datasource="#request.dsn#" >
							update amazon_items set
							amazon_item_asin = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ASIN#" >
							,amazon_item_sellersku = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_SellerSKU#" >
							,amazon_item_title = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_Title#" >
							,amazon_item_quantityordered = <cfqueryparam cfsqltype="cf_sql_integer" 
						              value="#var_amazon_item_QuantityOrdered#" >
							,amazon_item_quantityshipped = <cfqueryparam cfsqltype="cf_sql_integer" 
						              value="#var_amazon_item_QuantityShipped#" >
							,amazon_item_giftmessagetext = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_GiftMessageText#" >
							,amazon_item_itemprice = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_ItemPrice#" >
							,amazon_item_shippingprice = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_ShippingPrice#" >
							,amazon_item_giftwrapprice = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_GiftWrapPrice#" >
							,amazon_item_itemtax = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_ItemTax#" >
							,amazon_item_shippingtax = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_ShippingTax#" >
							,amazon_item_giftwraptax = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_GiftWrapTax#" >
							,amazon_item_shippingdiscount = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_ShippingDiscount#" >
							,amazon_item_promotiondiscount= <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#var_amazon_item_PromotionDiscount#" >
							,amazon_item_apiStatusFlag = 'updated'
							where amazon_item_amazonorderid = <cfqueryparam cfsqltype="cf_sql_varchar" 
						              value="#AmazonOrderId#" >
						</cfquery>
					</cfif>
				
				<cfelse><!---isdefined("_amazon.xmlResponse.xmlRoot.ListOrderItemsResult")--->
					Error: 
					#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#
					<br>
				</cfif>
			
				<cfif isdefined( "vdebug" ) >
					<cfdump var="#_amazon.xmlResponse#" >
				</cfif>
			</cfloop>
		</cfif><!---get_amazonOrderIds.recordcount--->
	</cfloop><!---get_amazonAccts--->
	<br>Script Ended successfully: #dateformat( now() )#
	<br>
</cfoutput>