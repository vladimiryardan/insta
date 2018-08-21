<cfhttp url="#trim(gn)#" method="POST" useragent="insta MWS Component/1.0 (Language=ColdFusion; Platform=Windows/2003)">
		<cfhttpparam type="Header" 	name= "Accept-Encoding" value= "*" />
		<cfhttpparam type="Header" 	name= "TE" value= "deflate;q=0" />
		<cfhttpparam type="header" 	name="Content-Type" value="text/xml; charset=iso-8859-1">
		<cfhttpparam type="body" 	name="FeedContent" value="">
</cfhttp>