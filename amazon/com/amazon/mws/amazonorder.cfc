<cfcomponent displayname="AmazonOrderComponent" hint="Amazon Order Component" output="false">

	<!--- Basic object properties --->
	<cfproperty name="baseurl" hint="The base URL used to construct requests." type="string" />
	<cfproperty name="signaturemethod" hint="Which HMAC hash algorithm is being used to calculate your signature, either SHA256 or SHA1." type="string" default="SHA256" />
	<cfproperty name="merchantid" hint="Merchant ID" type="string" />
	<cfproperty name="sellerid" hint="Same as merchant id" type="string" />
	<cfproperty name="marketplaceid" hint="Marketplace ID" type="string" />
	<cfproperty name="useragent" type="string" default="My Company/1.0 (Language=ColdFusion; Library=CFAmazon)" />
	<cfproperty name="enum" type="struct" hint="Enumeration of different types."/>

    <!--- Initialize the object --->
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="accessKeyID" type="string" required="true" hint="Your Checkout by Amazon Access Key ID"/>
		<cfargument name="secretKeyID" type="string" required="true" hint="Your Checkout by Amazon Secret Access Key"/>
		<cfargument name="merchantID" type="string" required="true" hint="Your Merchant ID"/>
		<cfargument name="marketplaceID" type="string" required="true" hint="Your Marketplace ID"/>

		<cfargument name="location" type="string" required="false" default="US" hint="US,UK,Germany,France,Japan,China,Canada"/>
		<cfscript>
			setAccessKeyID(arguments.accessKeyID);
			setSecretKeyID(arguments.secretKeyID);
			setMerchantID(arguments.merchantID);
			setMarketplaceId(arguments.marketplaceID);


			this.baseurl 			= "https://mws.amazonservices.com";
			this.useragent 			= "instantonlineconsignment/1.0 (Language=ColdFusion; Library=CFAmazon; Host="&CGI.SERVER_NAME&")";
			this.signaturemethod	="HmacSHA256";
			this.signatureversion	=2;
			//this.version			="2009-01-01";
			//this.version			="2011-01-01";
			this.version			="2013-09-01"; //:vladedit:20180803 - amazon stopped working and we change to this version
			//this.showXmlResponse 	= false;
			//this.debug 				= false;


			//Enumerations
			this.enum = StructNew();
			this.enum.FeedType = StructNew();
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_DATA_','Product Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_RELATIONSHIP_DATA_','Relationships Feed');
			StructInsert(this.enum.FeedType,'_POST_ITEM_DATA_','Single Format Item Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_OVERRIDES_DATA_','Shipping Override Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_IMAGE_DATA_','Product Images Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_PRICING_DATA_','Pricing Feed');
			StructInsert(this.enum.FeedType,'_POST_INVENTORY_AVAILABILITY_DATA_','Inventory Feed');
			StructInsert(this.enum.FeedType,'_POST_ORDER_ACKNOWLEDGEMENT_DATA_','Order Acknowledgement Feed');
			StructInsert(this.enum.FeedType,'_POST_ORDER_FULFILLMENT_DATA_','Order Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FULFILLMENT_ORDER_REQUEST_DATA_','FBA Shipment Injection Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FULFILLMENT_ORDER_CANCELLATION_REQUEST_DATA_','FBA Shipment Injection Cancellation Feed');
			StructInsert(this.enum.FeedType,'_POST_PAYMENT_ADJUSTMENT_DATA_','Order Adjustment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_LISTINGS_DATA_','Flat File Listings Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_ORDER_ACKNOWLEDGEMENT_DATA_','Flat File Order Acknowledgement Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_FULFILLMENT_DATA_','Flat File Order Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_PAYMENT_ADJUSTMENT_DATA_','Flat File Order Adjustment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_INVLOADER_DATA_','Flat File Inventory Loader Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_CONVERGENCE_LISTINGS_DATA_','Flat File Music Loader File');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_BOOKLOADER_DATA_','Flat File Book Loader File');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_PRICEANDQUANTITYONLY_UPDATE_DATA_','Flat File Price and Quantity Update File');
			StructInsert(this.enum.FeedType,'_POST_UIEE_BOOKLOADER_DATA_','UIEE Inventory File');

			this.enum.Schedule = StructNew();
			StructInsert(this.enum.Schedule,'_15_MINUTES_','Every 15 minutes');
			StructInsert(this.enum.Schedule,'_30_MINUTES_','Every 30 minutes');
			StructInsert(this.enum.Schedule,'_1_HOUR_','Every hour');
			StructInsert(this.enum.Schedule,'_2_HOURS_','Every 2 hours');
			StructInsert(this.enum.Schedule,'_4_HOURS_','Every 4 hours');
			StructInsert(this.enum.Schedule,'_8_HOURS_','Every 8 hours');
			StructInsert(this.enum.Schedule,'_12_HOURS_','Every 12 hours');
			StructInsert(this.enum.Schedule,'_1_DAY_','Every day');
			StructInsert(this.enum.Schedule,'_2_DAYS_','Every 2 days');
			StructInsert(this.enum.Schedule,'_72_HOURS_','Every 3 days');
			StructInsert(this.enum.Schedule,'_7_DAYS_','Every 7 days');
			StructInsert(this.enum.Schedule,'_14_DAYS_','Every 14 days');
			StructInsert(this.enum.Schedule,'_15_DAYS_','Every 15 days');
			StructInsert(this.enum.Schedule,'_30_DAYS_','Every 30 days');
			StructInsert(this.enum.Schedule,'_NEVER_','Delete a previously created report schedule');

			this.enum.Error = StructNew();
			StructInsert(this.enum.Error,'AccessDenied','Client tried connecting to MWS through HTTP rather than HTTPS.');
			StructInsert(this.enum.Error,'AccessToFeedProcessingResultDenied','Insufficient privileges to access the feed processing result.');
			StructInsert(this.enum.Error,'AccessToReportDenied','Insufficient privileges to access the requested report.');
			StructInsert(this.enum.Error,'ContentMD5Missing','The Content-MD5 header value was missing.');
			StructInsert(this.enum.Error,'ContentMD5DoesNotMatch','The calculated MD5 hash value doesn�t match the provided Content-MD5 value.');
			StructInsert(this.enum.Error,'FeedCanceled','Returned for a request for a processing report of a canceled feed.');
			StructInsert(this.enum.Error,'FeedProcessingResultNoLongerAvailable','The feed processing result is no longer available for download.');
			StructInsert(this.enum.Error,'FeedProcessingResultNotReady','Processing report not yet generated.');
			StructInsert(this.enum.Error,'InputDataError','Feed content contained errors.');
			StructInsert(this.enum.Error,'InternalError','Unspecified server error occurred.');
			StructInsert(this.enum.Error,'InvalidFeedSubmissionId','Provided Feed Submission Id was invalid.');
			StructInsert(this.enum.Error,'InvalidAction','The action was invalid.');
			StructInsert(this.enum.Error,'InvalidFeedType','Submitted Feed Type was invalid.');
			StructInsert(this.enum.Error,'InvalidParameterValue','Provided query parameter was invalid. For example, the format of the Timestamp parameter was malformed.');
			StructInsert(this.enum.Error,'InvalidQueryParameter','Superfluous parameter submitted.');
			StructInsert(this.enum.Error,'InvalidReportId','Provided Report Id was invalid.');
			StructInsert(this.enum.Error,'InvalidReportType','Submitted Report Type was invalid.');
			StructInsert(this.enum.Error,'InvalidRequest','The request was invalid.');
			StructInsert(this.enum.Error,'InvalidScheduleFrequency','Submitted schedule frequency was invalid.');
			StructInsert(this.enum.Error,'MissingClientTokenId','Either the Merchant Id or Marketplace Id parameter was empty or missing.');
			StructInsert(this.enum.Error,'MissingParameter','Required parameter was missing from the query.');
			StructInsert(this.enum.Error,'ReportNoLongerAvailable','The specified report is no longer available for download.');
			StructInsert(this.enum.Error,'ReportNotReady','Report not yet generated.');
			StructInsert(this.enum.Error,'SignatureDoesNotMatch','The provided request signature does not match the server''s calculated signature value.');
			StructInsert(this.enum.Error,'UserAgentHeaderLanguageAttributeMissing','The User-Agent header Language attribute was missing.');
			StructInsert(this.enum.Error,'UserAgentHeaderMalformed','The User-Agent value did not comply with the expected format. See the topic, User-Agent Header.');
			StructInsert(this.enum.Error,'UserAgentHeaderMaximumLengthExceeded','The User-Agent value exceeded 500 characters.');
			StructInsert(this.enum.Error,'UserAgentHeaderMissing','The User-Agent header value was missing.');

			this.enum.ReportType = StructNew();
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_OPEN_LISTINGS_DATA_','Open Listings Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_','Merchant Listings Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_LITE_','Merchant Listings Lite Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_LITER_','Merchant Listings Liter Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_CANCELLED_LISTINGS_DATA_','Canceled Listings Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_','Unshipped Orders Report');
			StructInsert(this.enum.ReportType,'_GET_ORDERS_DATA_','Scheduled XML Order Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ORDER_REPORT_DATA_','Scheduled Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ORDERS_DATA_','Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_CONVERGED_FLAT_FILE_ORDER_REPORT_DATA_','Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_PAYMENT_SETTLEMENT_DATA_','Flat File Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_PAYMENT_SETTLEMENT_DATA_','XML Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_ALT_FLAT_FILE_PAYMENT_SETTLEMENT_DATA_','Flat File V2 Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ALL_ORDERS _DATA_BY_LAST_UPDATE_','Flat File All Orders Report by Last Update');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ALL_ORDERS _DATA_BY_ORDER_DATE_','Flat File All Orders Report by Order Date');
			StructInsert(this.enum.ReportType,'_GET _XML_ALL_ORDERS _DATA_BY_LAST_UPDATE_','XML All Orders Report by Last Update');
			StructInsert(this.enum.ReportType,'_GET _XML_ALL_ORDERS _DATA_BY_ORDER_DATE_','XML All Orders Report by Order Date');
			StructInsert(this.enum.ReportType,'_GET_AFN_INVENTORY_DATA_','FBA Inventory Report');
			StructInsert(this.enum.ReportType,'_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_','FBA Fulfilled Shipments Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_','FBA Returns Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_SALES_DATA_','FBA Customer Shipment Sales Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_PROMOTION_DATA_','FBA Promotions Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CURRENT_INVENTORY_DATA_','FBA Daily Inventory History Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_MONTHLY_INVENTORY_DATA_','FBA Monthly Inventory History Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_','FBA Received Inventory Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_SUMMARY_DATA_','FBA Inventory Event Detail Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_ADJUSTMENTS_DATA_','FBA Inventory Adjustments Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_AGE_DATA_','FBA Inventory Age Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_REPLACEMENT_DATA_','FBA Replacements Report');
			StructInsert(this.enum.ReportType,'_GET_NEMO_MERCHANT_LISTINGS_DATA_','Product Ads Listings Report');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_DAILY_DATA_TSV_','Product Ads Daily Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_DAILY_DATA_XML_','Product Ads Daily Performance by SKU Report, XML');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_WEEKLY_DATA_TSV_','Product Ads Weekly Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_WEEKLY_DATA_XML_','Product Ads Weekly Performance by SKU Report, XML');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_MONTHLY_DATA_TSV_','Product Ads Monthly Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_MONTHLY_DATA_XML_','Product Ads Monthly Performance by SKU Report, XML');

			this.enum.OrderStatus = StructNew();
			StructInsert(this.enum.OrderStatus,"Pending","Order has been placed but payment has not been authorized. Not ready for shipment.");
			StructInsert(this.enum.OrderStatus,"Unshipped","Payment has been authorized and order is ready for shipment, but no items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"PartiallyShipped","One or more (but not all) items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"Shipped","All items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"Canceled","The order was canceled.");
			StructInsert(this.enum.OrderStatus,"Unfillable","The order cannot be fulfilled. This state applies only to Amazon-fulfilled orders that were not placed on Amazon's retail website.");

			this.enum.FulfillmentChannel = StructNew();
			StructInsert(this.enum.FulfillmentChannel,"AFN","Fulfilled by Amazon");
			StructInsert(this.enum.FulfillmentChannel,"MFN","Fulfilled by Seller");





		</cfscript>
	</cffunction>


<!--- function helpers --->
	<cffunction name="getMarketplaceid" access="public" output="false" returntype="string">
		<cfreturn this.marketplaceid />
	</cffunction>

	<cffunction name="setMarketplaceid" access="public" output="false" returntype="void">
		<cfargument name="marketplaceid" type="string" required="true" />
		<cfset this.marketplaceid = arguments.marketplaceid />
		<cfreturn />
	</cffunction>

	<cffunction name="getAccessKeyID" access="public" output="false" returntype="string">
		<cfreturn this.accessKeyID />
	</cffunction>

	<cffunction name="setAccessKeyID" access="public" output="false" returntype="void">
		<cfargument name="accessKeyID" type="string" required="true" />
		<cfset this.accessKeyID = arguments.accessKeyID />
		<cfreturn />
	</cffunction>

	<cffunction name="getSecretKeyID" access="public" output="false" returntype="string">
		<cfreturn this.secretKeyID />
	</cffunction>

	<cffunction name="setSecretKeyID" access="public" output="false" returntype="void">
		<cfargument name="secretKeyID" type="string" required="true" />
		<cfset this.secretKeyID = arguments.secretKeyID />
		<cfreturn />
	</cffunction>

	<cffunction name="getMerchantID" access="public" output="false" returntype="string">
		<cfreturn this.merchantID />
	</cffunction>

	<cffunction name="setMerchantID" access="public" output="false" returntype="void">
		<cfargument name="merchantID" type="string" required="true" />
		<cfset this.merchantID = arguments.merchantID />
		<cfreturn />
	</cffunction>

	<cffunction name="getSellerID" access="public" output="false" returntype="string">
		<cfreturn this.sellerID />
	</cffunction>

	<cffunction name="setSellerID" access="public" output="false" returntype="void">
		<cfargument name="sellerID" type="string" required="true" />
		<cfset this.sellerID = arguments.sellerID />
		<cfreturn />
	</cffunction>

	<cffunction name="md5" hint="Compute an MD5 hash." access="public" output="false" returnType="string">
		<cfargument name="content" type="any" hint="The content to hash."/>
		<cfreturn toBase64(BinaryDecode(Hash(arguments.content),'hex'))/>
	</cffunction>

<!--- blog.1smartsolution.com --->
	<cffunction name="HMAC_SHA256" returntype="binary" access="public" output="false">
		<cfargument name="signMessage" type="string" required="true"/>

		<cfset var jMsg = JavaCast("string", arguments.signMessage).getBytes("UTF-8")>
		<cfset var jKey = JavaCast("string", this.secretKeyID).getBytes("UTF-8")>
		<cfset var key = createObject("java", "javax.crypto.spec.SecretKeySpec")>
		<cfset var mac = createObject("java", "javax.crypto.Mac")/>
		<cfset key = key.init(jKey, "HmacSHA256")>
		<cfset mac = mac.getInstance(key.getAlgorithm())>
		<cfset mac.init(key)>
		<cfset mac.update(jMsg)>
		<cfreturn mac.doFinal()>
	</cffunction>

	<cffunction name="GenerateSignedAmazonURL" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">

		<!--- append timestamp to query string --->
		<!---<cfset arguments.RawQueryString = arguments.RawQueryString & "&Marketplace=#this.marketplaceID#">--->
		<!---<cfset arguments.RawQueryString = arguments.RawQueryString & "&Merchant=#this.merchantID#">--->
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=#this.version#">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>




		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">

	</cffunction>

	<cffunction name="GenerateSignedAmazonURL_listOrders" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="varDaysBack" type="string" required="no" default="2"  />
		<cfargument name="verbAfter" type="string" required="no" default="LastUpdatedAfter"  />
		

		<!---
		NOTE:
		 the default date call is now less 1 day to go back
		--->

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">

		<!--- createdafter --->
		<cfset theDaysCount = varDaysBack >
		<cfset startDate = DateAdd( "d", -theDaysCount, now() ) />
		<cfset var created_thenow = DateConvert("local2Utc", startDate)>
		<cfset var created_time_stamp = "#DateFormat(created_thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">
		
		<cfdump var="#created_time_stamp#">
		
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&LastUpdatedAfter=#created_time_stamp#">
		<!---<cfset arguments.RawQueryString = arguments.RawQueryString & "&CreatedAfter=#created_time_stamp#">--->
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&MarketplaceId.Id.1=#this.marketplaceid#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=#this.version#">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>


		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">

	</cffunction>


	<cffunction name="GenerateSignedAmazonURL_GetOrder" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="orderIDs" type="string" required="yes"/>



		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">


		<cfset loopCount = 1>
		<cfloop index="a_oid" list="#arguments.orderIDs#" delimiters="?">
			<cfset arguments.RawQueryString = arguments.RawQueryString & "&AmazonOrderId.Id." & #loopCount# & "=#a_oid#" >
			<cfset loopCount++>
		</cfloop>

		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=#this.version#">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>


		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">

	</cffunction>



<cffunction name="GenerateSignedAmazonURL_ListOrderItems" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="orderID" type="string" required="yes"/>



		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">



		<cfset arguments.RawQueryString = arguments.RawQueryString & "&AmazonOrderId" &  "=#arguments.orderID#" >
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=#this.version#">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>


		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">

	</cffunction>


<cffunction name="GenerateSignedAmazonURL_SubmitFeed" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="dFeedType" type="string" required="yes"/>

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Merchant=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&FeedType=#arguments.dFeedType#" >
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=2009-01-01">


		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>

		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">
</cffunction>

<cffunction name="GenerateSignedAmazonURL_GetFeedSubmissionList" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="commaDelimSubmissionIDs" type="string" required="yes"/>

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- build the submissionids --->
		<cfset sid_count = 1>
		<cfloop index = "this_submissionid" list = "#arguments.commaDelimSubmissionIDs#">
			<cfset arguments.RawQueryString = arguments.RawQueryString & "&FeedSubmissionIdList.Id." & sid_count &"=#this_submissionid#">
			<cfset sid_count += 1>
		</cfloop>



		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Merchant=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=2009-01-01">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>

		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">
</cffunction>

<cffunction name="GenerateSignedAmazonURL_GetFeedSubmissionResult" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="SubmissionID" type="string" required="yes"/>

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Merchant=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&FeedSubmissionId=#SubmissionID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=2009-01-01">


		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>


		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">
</cffunction>


	<cffunction name="GenerateSignedAmazonURL_ListOrdersByNextToken" returntype="string" output="yes">
		<cfargument name="HTTPVerb" required="yes"/>
		<cfargument name="HostHeader" type="string" required="yes"/>
		<cfargument name="HTTPRequestURI" type="string" required="yes"/>
		<cfargument name="RawQueryString" type="string" required="yes"/>
		<cfargument name="nextToken" required="true">

		<cfset var signature = "">
		<cfset var encodedQueryString = "">
		<cfset var sortedQueryString = "">
		<cfset var encodedSignature = "">
		<cfset var name = "">
		<cfset var value = "">
		<cfset var i = "">

		<!--- get your timestamp--->
		<cfset var thenow = DateConvert("local2Utc", Now())>
		<cfset var time_stamp = "#DateFormat(thenow,'yyyy-mm-dd')#T#TimeFormat(thenow,'HH:mm:ss')#.00Z">
		
		<br><cfdump var="#thenow#"><br>

		<cfset arguments.RawQueryString = arguments.RawQueryString & "&NextToken=#arguments.nextToken#">

		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SellerId=#this.merchantID#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureMethod=#this.signaturemethod#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&SignatureVersion=#this.signatureversion#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Timestamp=#time_stamp#">
		<cfset arguments.RawQueryString = arguments.RawQueryString & "&Version=#this.version#">

		<!--- start building signature --->
		<cfset signature = arguments.HTTPVerb & Chr(10)>
		<cfset signature = signature & LCase(arguments.HostHeader) & Chr(10)>
		<cfset signature = signature & arguments.HTTPRequestURI & Chr(10)>
		<!--- loop over the list and urlEncode each value --->
		<cfloop list="#arguments.RawQuerySTring#" delimiters="&" index="i">
			<cfset name = ListGetAt(i, 1, "=")>
			<cfset value = "">

			<!--- if this item has a value encode it --->
			<cfif ListLen(i, "=") gt 1>
				<cfset value = Replace(Replace(Replace(ListGetAt(i, 2, "="), ",", "%2C", "ALL"), ":", "%3A", "ALL")," ","%20", "ALL")>
			</cfif>
			<!--- build the new query string with encoded values --->
			<cfset encodedQueryString = ListAppend(encodedQueryString, "#name#=#value#", "&")>
		</cfloop>

		<!--- next we need to canonically order the queryString params --->
		<cfset sortedQueryString = ListSort(encodedQueryString, "textnocase", "asc", "&")>

		<!--- append to the signature --->
		<cfset signature = signature & "AWSAccessKeyId=#this.accessKeyId#&" & sortedQueryString>

		<!--- encode the signature --->
		<cfset encodedSignature = URLEncodedFormat(ToBase64(HMAC_SHA256(signature)))/>


		<cfreturn "https://#arguments.HostHeader##arguments.HTTPRequestURI#?AWSAccessKeyId=#this.accessKeyId#&#sortedQueryString#&Signature=#encodedSignature#">

	</cffunction>
	
</cfcomponent>
