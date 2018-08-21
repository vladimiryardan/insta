<cfsetting requesttimeout="3600" ><!--- ensure that we don't get timeouts on our call --->
<cfscript>
	merchantId='A1QQKETFEK5INH';
	awsAccessId='AKIAJ7MTFQV6KNJAYN5Q'; //Initialize with AWS Access Key (Not CBA Access Key!)
	awsSecret="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";
	marketId='ATVPDKIKX0DER';
	ordersFlag='true';

	//Create Marketplace Object
	m = createObject("component","amazon.com.amazon.mws.marketplace");
	m.init(awsAccessId,awsSecret,merchantId,marketId,ordersFlag);
</cfscript>
