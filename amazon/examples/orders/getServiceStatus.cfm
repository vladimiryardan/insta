

<cfscript>

	//sellerId='A1QQKETFEK5INH'; //same as merchantid
	awsAccessId='AKIAJ7MTFQV6KNJAYN5Q'; //Initialize with AWS Access Key (Not CBA Access Key!)
	awsSecret="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";
	merchantId='A1QQKETFEK5INH';
	marketId='ATVPDKIKX0DER';
	signStr2 = "Action=GetServiceStatus";

	//Create Marketplace Object
	m = createObject("component","amazon.com.amazon.mws.amazonorder");
	m.init(awsAccessId,awsSecret,merchantId,marketId);
	gn = m.GenerateSignedAmazonURL('POST', 'mws.amazonservices.com', '/Orders/2011-01-01', signStr2);
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




