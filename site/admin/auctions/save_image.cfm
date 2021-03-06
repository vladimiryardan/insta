<cfset path = "#ExpandPath("..\..\..\images")#\#attributes.item#">
<cfif NOT DirectoryExists(path)>
	<cfdirectory action="create" directory="#path#">
</cfif>

<cfset tmpFile = "#path#\tmp_#attributes.item#_#attributes.imgnum#.jpg">
<!---
	COPY *.TMP FILE GENERATED BY APPLET TO TEMPORARY FILE
	NOTE THAT *.TMP AUTODELETED BY SERVER
--->
<cffile action="copy"
	destination="#tmpFile#"
	source="#form.image#" nameconflict="overwrite">

<!--- RESIZE MAIN IMAGE AND GENERATE THUMBNAIL --->
<cfparam name="attributes.doNotResize" default="0">

<cfscript>
	myImage = CreateObject("Component", "Image").setKey('HTMGB-MGPT0-0W9F0-JVGM5-543MM');
	// proceed image
	
	myImage.readImage("#tmpFile#");

	// myImage.scalePixels(400, 370);
	if(attributes.doNotResize EQ "0"){
		if(myImage.getWidth() GT 400){
			myImage.scalePixels(myImage.getHeight()*500/myImage.getWidth(),500);
		}
		if(myImage.getHeight() GT 370){
			myImage.scalePixels(myImage.getWidth()*500/myImage.getHeight(), 500);
		}
	}
	myImage.writeImage("#path#\#attributes.imgnum#.jpg", "jpg");
	// generate thumbnail
	myImage.readImage("#tmpFile#");
	// myImage.scalePixels(96, 89);
	if(myImage.getWidth() GT 96){
		myImage.scalePixels(96, myImage.getHeight()*96/myImage.getWidth());
	}
	if(myImage.getHeight() GT 89){
		myImage.scalePixels(myImage.getWidth()*89/myImage.getHeight(), 89);
	}
	myImage.writeImage("#path#\#attributes.imgnum#thumb.jpg", "jpg");
</cfscript>



<!--- DELETE TEMPORARY FILE --->
<cffile action="delete" file="#tmpFile#">

<cfset attributes.imgnum = attributes.imgnum + 1>

<!--- UPDATE ITEM PICTURED TIME
<cfquery datasource="#request.dsn#">
	UPDATE items
	SET dpictured = NOW()
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
--->

<cfparam name="attributes.from" default="N/A">
<cfoutput>
##SHOWDOCUMENT=/index.cfm?dsp=admin.auctions.step3&item=#attributes.item#&imgnum=#attributes.imgnum#&from=#attributes.from#&doNotResize=#attributes.doNotResize#</cfoutput>
