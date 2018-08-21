<!---
Description:  GetFeedSubmissionList
- call every 8 or 12 hours interval to sync db to amazon
- Use this operation to determine the status of a feed submission by passing in the FeedProcessingId that was returned by the SubmitFeed operation

ErrorResponse:#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
--->


<cfsetting requesttimeout="36000">
<cfoutput>
	<h2>GetFeedSubmissionList started at #DateFormat(Now())# #TimeFormat(Now())#</h2>
</cfoutput>

<cfoutput>
<!--- GET THE AMAZON account --->
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
#amazon_account_secret_key#
<!--- get the submissionids --->
<cfquery datasource="#request.dsn#" name="get_amazonSubmitted" >
<!--- there seems to be a problem with sorting if we get more than 10 items. quick fix is to call it 9 --->
SELECT Top 9 amazon_submitfeeds.*, amazon_items.items_itemid
FROM amazon_submitfeeds INNER JOIN
amazon_items ON amazon_submitfeeds.amazon_item_amazonorderid = amazon_items.amazon_item_amazonorderid INNER JOIN
amazon_accounts ON amazon_items.amazon_account_pkid = amazon_accounts.amazon_account_pkid
where amazon_submitfeeds.amazon_submitfeed_feedprocessingstatus ='_SUBMITTED_' or amazon_submitfeeds.amazon_submitfeed_feedprocessingstatus ='_IN_PROGRESS_'
and amazon_accounts.amazon_account_pkid = #get_amazonAccts.amazon_account_pkid#
</cfquery>
GetFeedSubmissionList:#get_amazonSubmitted.recordcount#<br>
<cfif get_amazonSubmitted.recordcount gte 1 >
	<!--- define the amazon constant vars --->
	<cfscript>
		_amazon = StructNew ();
		_amazon.callname = "GetFeedSubmissionList";
		_amazon.awsAccessId = amazon_account_aws_accesskeyid;
		_amazon.awsSecret = amazon_account_secret_key;
		_amazon.merchantId = amazon_account_merchant_id;
		_amazon.marketId = amazon_account_marketplace_id;
		signStr2 = "Action=" & #_amazon.callname# ;


		m = createObject("component","amazon.com.amazon.mws.amazonorder");
		m.init(_amazon.awsAccessId,_amazon.awsSecret,_amazon.merchantId,_amazon.marketId);

	</cfscript>

<!--- build the submissionids --->
<cfset SubmissionIDS = ValueList(get_amazonSubmitted.amazon_submitfeed_feedsubmissionid)   >
<cfset gn = m.GenerateSignedAmazonURL_GetFeedSubmissionList('POST', 'mws.amazonservices.com', '/', signStr2, SubmissionIDS)>

----------------------------<br>
callname:#_amazon.callname# <br>
<cfif isdefined("url.debugv")>
#SubmissionIDS#<br>
#gn#<br>
</cfif>
----------------------------<br>


	<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
			<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
			<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
			<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
			<cfhttpparam type="body" 	name="FeedContent" value="">
	</cfhttp>


<cfset _amazon.requestTimestamp = now()>
<cfset _amazon.response = cfhttp.FileContent>
<cfset _amazon.xmlResponse	= XMLParse (_amazon.response)>



<!---<cfdump var="#_amazon.xmlResponse#" >--->




<!--- process the response --->
<cfif isdefined("_amazon.xmlResponse.xmlRoot.GetFeedSubmissionListResult")>
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


<cfloop index="i" from="1" to="#ArrayLen(_amazon.xmlResponse.xmlRoot.GetFeedSubmissionListResult.FeedSubmissionInfo)#">
	<cfset response_Submission_id 	= _amazon.xmlResponse.xmlRoot.GetFeedSubmissionListResult.FeedSubmissionInfo[i].FeedSubmissionId.XmlText>
	<cfset response_FeedProcessingStatus = _amazon.xmlResponse.xmlRoot.GetFeedSubmissionListResult.FeedSubmissionInfo[i].FeedProcessingStatus.XmlText>
#response_Submission_id# - #response_FeedProcessingStatus#<br>
<cfquery datasource="#request.dsn#">
 update amazon_submitfeeds
 set amazon_submitfeed_feedprocessingstatus = '#response_FeedProcessingStatus#'
 where amazon_submitfeed_feedsubmissionid = '#response_Submission_id#'
</cfquery>



</cfloop>

<cfelse><!--- isdefined("_amazon.xmlResponse.xmlRoot.GetFeedSubmissionListResult") --->
	Error: #_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
	<h2>get Amazon ABORTED FOR amazon_account_pkid:#get_amazonAccts.amazon_account_pkid# at #DateFormat(Now())# #TimeFormat(Now())#</h2><br>
	<cfabort>
</cfif>


</cfif>



</cfloop>

<h2>GetFeedSubmissionList ENDED at #DateFormat(Now())# #TimeFormat(Now())#</h2>
</cfoutput>

