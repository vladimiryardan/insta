<!---
Description:  Submit Feed

- Use this operation to submit feed to amazon
- like _POST_ORDER_FULFILLMENT_DATA_ - Order Fulfillment Feed

ErrorResponse:#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
--->
<cfsetting requesttimeout="3600">

<cfoutput><h2>Submit Feed started at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>

<!--- GET THE AMAZON account --->
<cfquery datasource="#request.dsn#" name="get_amazonAccts" >
SELECT amazon_account_pkid
      ,amazon_account_firstname
      ,amazon_account_lastname
      ,amazon_account_merchant_id
      ,amazon_account_marketplace_id
      ,amazon_account_aws_accesskeyid
      ,amazon_account_secret_key
      ,amazon_account_isactive
      ,amazon_account_merchantidentifier
  FROM amazon_accounts
  where amazon_account_isactive = 1
</cfquery>

<cfloop query="get_amazonAccts">

<cfscript>
	_amazon = StructNew ();
	_amazon.callname = "SubmitFeed";
	_amazon.FeedType= "_POST_ORDER_FULFILLMENT_DATA_";
	_amazon.awsAccessId = amazon_account_aws_accesskeyid;
	_amazon.awsSecret = amazon_account_secret_key;
	_amazon.merchantId = amazon_account_merchant_id;
	_amazon.marketId = amazon_account_marketplace_id;
	_amazon.merchantidentifier = amazon_account_merchantidentifier;
	signStr2 = "Action=" & #_amazon.callname# ;

	m = createObject("component","amazon.com.amazon.mws.amazonorder");
	m.init(_amazon.awsAccessId,_amazon.awsSecret,_amazon.merchantId,_amazon.marketId);
	gn = m.GenerateSignedAmazonURL_SubmitFeed('POST', 'mws.amazonservices.com', '/', signStr2,_amazon.FeedType);
</cfscript>

<!---<cfdump var="#gn#">--->
<!--- get the amazon items that's ready for submit feed --->
<!---
Note: get amazon items that was last updated with a amazon_account_pkid eq amazon account holder and amazon_item_apiStatusFlag is 'newupdate'
NOTE: up to a maximum of 50 ORDER IDS
--->
<cfquery datasource="#request.dsn#" name="get_amazonOrderIds" >
SELECT amazon_items.*, items.*
FROM amazon_items INNER JOIN
items ON amazon_items.items_itemid = items.item
where (amazon_items.amazon_item_orderstatus = 'awaitingTrackingNum' or amazon_items.amazon_item_orderstatus= 'Unshipped')  <!--- ready for shipping --->
and  (amazon_items.local_status = 'tracking_generated' or amazon_items.local_status= 'error_feedsubmit')    <!--- insta generated the tracking number or there was an error in the submitfeed --->
and amazon_account_pkid = #get_amazonAccts.amazon_account_pkid# <!--- for this amazon account --->
</cfquery>
<cfoutput>


<cfloop query="get_amazonOrderIds" >

<cfset dshippedtime = dateconvert("local2Utc", now())>
<cfset Shiptime_stamp = "#DateFormat(now(),'yyyy-mm-dd')#T#TimeFormat(now(),'HH:mm:ss')#+00:00">
<br>
----------------------------<br>
callname:#_amazon.callname#<br>
FeedType:#_amazon.FeedType#<br>
AID: #amazon_item_amazonorderid#<br>
item: #items_itemid#<br>
----------------------------<br>


<!--- build the xml --->
<cfsavecontent variable="prodXML"><?xml version="1.0" encoding="iso-8859-1" ?>
<AmazonEnvelope xsi:noNamespaceSchemaLocation="amzn-envelope.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Header>
<DocumentVersion>1.01</DocumentVersion>
<MerchantIdentifier>#_amazon.merchantidentifier#</MerchantIdentifier>
</Header>
<MessageType>OrderFulfillment</MessageType>
<Message>
<MessageID>1</MessageID>
<OrderFulfillment>
<AmazonOrderID>#amazon_item_amazonorderid#</AmazonOrderID>
<MerchantFulfillmentID>#replacenocase(items_itemid,'.','','all')#</MerchantFulfillmentID>
<FulfillmentDate>#Shiptime_stamp#</FulfillmentDate>
<FulfillmentData>
<CarrierName>#shipper#</CarrierName>
<ShippingMethod>Standard</ShippingMethod>
<ShipperTrackingNumber>#tracking#</ShipperTrackingNumber>
</FulfillmentData>
</OrderFulfillment>
</Message>
</AmazonEnvelope>
</cfsavecontent>


<!---#gn#<br>--->

<cfhttp url="#gn#" method="post" useragent="1SmartSolution MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
       <cfhttpparam name="Content-Type" type="header" value="text/xml; charset=iso-8859-1">
       <cfhttpparam name="FeedContent" type="body" value="#prodXML#">
       <cfhttpparam type="header" name="Content-MD5" value="#ToBase64(BinaryDecode(Hash(prodXML), 'hex'))#">
</cfhttp>


<cfset _amazon.requestTimestamp = now()>
<cfset _amazon.response = cfhttp.FileContent>
<cfset _amazon.xmlResponse	= XMLParse (_amazon.response)>

<!---<cfdump var="#_amazon.xmlResponse#">--->



<cfif isdefined("_amazon.xmlResponse.xmlRoot.SubmitFeedResult")>
<cfset _amazon.requestid = #_amazon.xmlResponse.xmlRoot.ResponseMetadata.RequestId.XmlText#>
<!--- API LOG CALL --->
<cfquery datasource="#request.dsn#">
	INSERT INTO amazon_apicall_logs (callname, request_timestamp,  requestid, callresponse,date_added,request_details,feed_body)
	VALUES (
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.callname#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#_amazon.requestTimestamp#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#_amazon.requestid#">,
		'#xmlformat(_amazon.xmlResponse)#',
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#">,
		'#urlencodedformat(gn)#',
		'#prodXML#'
	)
</cfquery>
<!--- API LOG CALL ENDS--->


<cfloop index="i" from="1" to="#ArrayLen(_amazon.xmlResponse.xmlRoot.SubmitFeedResult.xmlChildren)#">
	<cfset objFeedSubmissionInfo = _amazon.xmlResponse.xmlRoot.SubmitFeedResult.xmlChildren[i]>
	<cfset feedsubmissionid = objFeedSubmissionInfo.FeedSubmissionId.XmlText>
	<cfset FeedType = objFeedSubmissionInfo.FeedType.XmlText>
	<cfset SubmittedDate = objFeedSubmissionInfo.SubmittedDate.XmlText>
	<cfset FeedProcessingStatus = objFeedSubmissionInfo.FeedProcessingStatus.XmlText>

<cfquery name="chkAmazonId" datasource="#request.dsn#">
	select * from amazon_submitfeeds
	where amazon_item_amazonorderid = '#amazon_item_amazonorderid#'
</cfquery>

<cfif chkAmazonId.RecordCount gte 1>
	<!--- update the feedid if existing --->
	<cfquery datasource="#request.dsn#">
		update amazon_submitfeeds
		set	amazon_submitfeed_feedsubmissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#feedsubmissionid#">,
		amazon_submitfeed_feedtype=<cfqueryparam cfsqltype="cf_sql_varchar" value="#FeedType#">,
		amazon_submitfeed_feedprocessingstatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="#FeedProcessingStatus#">,
		amazon_submitfeed_submitteddate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#">
		where amazon_item_amazonorderid = '#amazon_item_amazonorderid#'
	</cfquery>

	<!--- update the amazon_items local_status --->
	<cfquery datasource="#request.dsn#">
		update amazon_items
		set local_status = 'feedsubmit_inprogress'
		where amazon_item_amazonorderid = '#amazon_item_amazonorderid#'
	</cfquery>
<cfelse>
	<!--- insert new submit feed --->
	<cfquery datasource="#request.dsn#">
		INSERT INTO amazon_submitfeeds
		(
		amazon_submitfeed_feedsubmissionid,
	    amazon_submitfeed_feedtype,
	    amazon_submitfeed_submitteddate,
	    amazon_submitfeed_feedprocessingstatus,
	    amazon_item_amazonorderid
	    )
		values
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#feedsubmissionid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FeedType#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FeedProcessingStatus#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#amazon_item_amazonorderid#">
		)
	</cfquery>
</cfif>


</cfloop>

<cfelse><!---isdefined("_amazon.xmlResponse.xmlRoot.SubmitFeedResult")--->
	Error: #_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
	<h2>get Amazon ABORTED FOR amazon_account_pkid:#get_amazonAccts.amazon_account_pkid# at #DateFormat(Now())# #TimeFormat(Now())#</h2><br>
	<cfabort>
</cfif>
</cfloop>



</cfoutput>



</cfloop>









<cfoutput><h2>Submit Feed ENDED at #DateFormat(Now())# #TimeFormat(Now())#</h2></cfoutput>


