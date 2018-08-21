

<!--- build the orderIDs to be processed --->
<cfset Orderid =  "105-9851185-4673025" >
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
	gn = m.GenerateSignedAmazonURL_ListOrderItems('POST', 'mws.amazonservices.com', '/Orders/2011-01-01', signStr2, Orderid);
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