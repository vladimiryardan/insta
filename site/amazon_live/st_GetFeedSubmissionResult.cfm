<!---
Description:  GetFeedSubmissionResult
- call every 8 or 12 hours interval to sync db to amazon
- Use this operation to determine the status of a feed submission by passing in the FeedProcessingId that was returned by the SubmitFeed operation
author: vladimiryardan@gmail.com
ErrorResponse:#_amazon.xmlResponse.xmlRoot.Error.Message.XmlText#<br>
--->

<cfsetting requesttimeout="36000">
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

<!--- get the submissionids which are done and local status of error_feedsubmit or tracking_generated  --->
<cfquery datasource="#request.dsn#" name="get_amazonDoneSubmittedFeed" >
<!--- there seems to be a problem with sorting if we get more than 10 items. quick fix is to call it 9 --->
SELECT Top 9 amazon_submitfeeds.*, amazon_items.*
FROM amazon_submitfeeds INNER JOIN
amazon_items ON amazon_submitfeeds.amazon_item_amazonorderid = amazon_items.amazon_item_amazonorderid INNER JOIN
amazon_accounts ON amazon_items.amazon_account_pkid = amazon_accounts.amazon_account_pkid
where  amazon_accounts.amazon_account_pkid = #get_amazonAccts.amazon_account_pkid#
and amazon_submitfeeds.amazon_submitfeed_feedprocessingstatus ='_DONE_'
and (amazon_items.local_status = 'tracking_generated' or amazon_items.local_status= 'feedsubmit_inprogress' <!---or amazon_items.local_status= 'error_feedsubmit'--->)
</cfquery>



GetFeedSubmissionResult:#get_amazonDoneSubmittedFeed.recordcount#<br>
<cfif get_amazonDoneSubmittedFeed.RecordCount gte 1>

<cfloop query="get_amazonDoneSubmittedFeed">
<!--- define the amazon constant vars --->
<cfscript>
	_amazon = StructNew ();
	_amazon.callname = "GetFeedSubmissionResult";
	_amazon.awsAccessId = get_amazonAccts.amazon_account_aws_accesskeyid;
	_amazon.awsSecret = get_amazonAccts.amazon_account_secret_key;
	_amazon.merchantId = get_amazonAccts.amazon_account_merchant_id;
	_amazon.marketId = get_amazonAccts.amazon_account_marketplace_id;
	signStr2 = "Action=" & #_amazon.callname# ;

	m = createObject("component","amazon.com.amazon.mws.amazonorder");
	m.init(_amazon.awsAccessId,_amazon.awsSecret,_amazon.merchantId,_amazon.marketId);
</cfscript>

<cfset gn = m.GenerateSignedAmazonURL_GetFeedSubmissionResult('POST', 'mws.amazonservices.com', '/', signStr2, get_amazonDoneSubmittedFeed.amazon_submitfeed_feedsubmissionid)>
----------------------------<br>
callname:#_amazon.callname# <br>
----------------------------<br>

<!---#gn#<br>--->

	<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
			<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
			<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
			<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
			<cfhttpparam type="body" 	name="FeedContent" value="">
	</cfhttp>

<cfset _amazon.requestTimestamp = now()>
<cfset _amazon.response = cfhttp.FileContent>
<cfset _amazon.xmlResponse	= XMLParse (_amazon.response)>

<cfdump var="#_amazon.xmlResponse#">

<!---<cfdump var="#_amazon.xmlResponse#" >--->




<!--- SUCCESS STARTS --->
<!--- the push to the amazon was successfull then we need to update: items, amazon_submitfeeds, amazon_submitfeeds --->
<cfif isdefined("_amazon.xmlResponse.xmlRoot.Message.ProcessingReport.StatusCode")>

<!--- we did a good push of tracking then lets update the items --->
<cfif #_amazon.xmlResponse.xmlRoot.Message.ProcessingReport.StatusCode.XmlText# is "Complete">

	<!--- update the amazon_items local_status to tracking generated --->
	<cfquery datasource="#request.dsn#">
		update amazon_items
		set local_status = 'COMPLETED'
		where amazon_item_amazonorderid = '#get_amazonDoneSubmittedFeed.amazon_item_amazonorderid#'
	</cfquery>

	<!--- update the results --->
	<cfquery datasource="#request.dsn#">
	 update amazon_submitfeeds
	 set amazon_submitfeed_resultcode = 'COMPLETED',
	 amazon_submitfeed_resultmessagecode = 'COMPLETED',
	 amazon_submitfeed_resultdescription = 'COMPLETED'
	 where amazon_submitfeed_feedsubmissionid = '#get_amazonDoneSubmittedFeed.amazon_submitfeed_feedsubmissionid#'
	</cfquery>
COMPLETED SUBMISSION_ID: #get_amazonDoneSubmittedFeed.amazon_submitfeed_feedsubmissionid#<BR>
</cfif>

</cfif>
<!--- SUCCESS ENDS --->


<!--- THERE WAS AN ERROR START --->
<cfif isdefined("_amazon.xmlResponse.xmlRoot.Message.ProcessingReport.Result.ResultCode")>
<cfset objResult = _amazon.xmlResponse.xmlRoot.Message.ProcessingReport.Result >
<cfset ResultCode = objResult.ResultCode.XmlText>
<cfset ResultMessageCode = objResult.ResultMessageCode.XmlText>
<cfset ResultDescription = objResult.ResultDescription.XmlText>
resultcode: #resultcode#<br>
resultmessagecode: #resultmessagecode#<br>
resultdescription: #resultdescription#<br>

<!--- update the results --->
<cfquery datasource="#request.dsn#">
 update amazon_submitfeeds
 set amazon_submitfeed_resultcode = '#resultcode#',
 amazon_submitfeed_resultmessagecode = '#resultmessagecode#',
 amazon_submitfeed_resultdescription = '#resultdescription#'
 where amazon_submitfeed_feedsubmissionid = '#get_amazonDoneSubmittedFeed.amazon_submitfeed_feedsubmissionid#'
</cfquery>

<cfif resultcode eq "Error">
	<!--- update the amazon_items local_status to tracking generated --->
	<cfquery datasource="#request.dsn#">
		update amazon_items
		set local_status = 'error_feedsubmit'
		where amazon_item_amazonorderid = '#get_amazonDoneSubmittedFeed.amazon_item_amazonorderid#'
	</cfquery>
	<!--- update the results --->
	<cfquery datasource="#request.dsn#">
	 update amazon_submitfeeds
	 set amazon_submitfeed_resultcode = 'ERROR',
	 amazon_submitfeed_resultmessagecode = 'ERROR',
	 amazon_submitfeed_resultdescription = 'ERROR'
	 where amazon_submitfeed_feedsubmissionid = '#get_amazonDoneSubmittedFeed.amazon_submitfeed_feedsubmissionid#'
	</cfquery>

</cfif>

</cfif><!---_amazon.xmlResponse.xmlRoot.Message.ProcessingReport.Result.ResultCode--->
<!--- THERE WAS AN ERROR ENDS --->

</cfloop>


</cfif>




</cfloop>
















<h2>GetFeedSubmissionList ENDED at #DateFormat(Now())# #TimeFormat(Now())#</h2>
</cfoutput>