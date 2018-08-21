<!---
EXAMPLE CALL
https://mws.amazonservices.com/Orders/2011-01-01
          ?AWSAccessKeyId=0PB842EXAMPLE7N4ZTR2
          &Action=GetOrder
          &AmazonOrderId.Id.1=058-1233752-8214740
          &SellerId=A2986ZQ066CH2F
          &Signature=ZQLpf8vEXAMPLE0iC265pf18n0%3D
          &SignatureVersion=2
          &SignatureMethod=HmacSHA256
          &LastUpdatedAfter=2010-10-04T18%3A12%3A21
          &Timestamp=2010-10-05T18%3A12%3A21.687Z
          &Version=2011-01-01

NOTE: up to a maximum of 50 ORDER IDS
--->


<!--- build the orderIDs to be processed --->
<cfset arrOrderids =  ArrayNew(1) >
<cfset #ArrayAppend(arrOrderids, "103-6238235-0830610")#>
<cfset #ArrayAppend(arrOrderids, "104-6111299-4634625")#>
<cfset orderId_list = ArrayToList(arrOrderids, "?")>

<cfscript>
	//sellerId='A1QQKETFEK5INH'; //same as merchantid
	awsAccessId='AKIAJ7MTFQV6KNJAYN5Q'; //AWS Access Key ID
	awsSecret="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";//Secret Key
	merchantId='A1QQKETFEK5INH';//Merchant ID
	marketId='ATVPDKIKX0DER';//Marketplace ID
	signStr2 = "Action=GetOrder";


	//Create Marketplace Object
	m = createObject("component","amazon.com.amazon.mws.amazonorder");
	m.init(awsAccessId,awsSecret,merchantId,marketId);
	gn = m.GenerateSignedAmazonURL_GetOrder('POST', 'mws.amazonservices.com', '/Orders/2011-01-01', signStr2, orderId_list);
</cfscript>

<cfdump var="#gn#"/>
<br><br>

<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
		<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
		<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
		<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
		<cfhttpparam type="body" 	name="FeedContent" value="">
</cfhttp>


<cfdump var="#cfhttp.FileContent#">