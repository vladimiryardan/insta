<cfif isDefined("attributes.GalleryImage")>
	<cfquery datasource="#request.dsn#">
		UPDATE auctions
		SET GalleryImage = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#attributes.GalleryImage#">,
			scheduledBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(session.user.first, 1)##Left(session.user.last, 1)#">
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>

<cfif isDefined("attributes.back")>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.step2&item=#attributes.item#">
<cfelseif isDefined("attributes.preview")>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.preview&item=#attributes.item#&back2lister=1">
<cfelseif isDefined("attributes.launch")>
	<cfset _machine.cflocation = "index.cfm?dsp=management.items.scheduled">
	<!--- mark item as ready to launch --->
	<cfquery datasource="#request.dsn#">
		UPDATE auctions
		SET ready = '1'
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<!--- if month less than current, then schedule to next year --->
	<cfset attributes.year = Year(Now())>
	<cfif attributes.month LT Month(Now())>
		<cfset attributes.year = attributes.year + 1>
	</cfif>
	<!--- if day is great than max then set it to max --->
	<cfset maxDays = DaysInMonth(CreateDate(attributes.year, attributes.month, 1))>
	<cfif attributes.day GT maxDays>
		<cfset attributes.day = maxDays>
	</cfif>
	<!--- Schedule auction --->
	<cfquery datasource="#request.dsn#">
		INSERT INTO queue
		(itemid, listAt)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateDateTime(attributes.year, attributes.month, attributes.day, attributes.hour, 45, 0)#"><!--- vlad made this 45. 20110610 requested Patrick --->
		)
	</cfquery>
	<!--- update scheduler --->
	<cfset attributes.ScheduleOnly = TRUE>
	<cfinclude template="st_scheduler.cfm">
<cfelseif isDefined("attributes.finish")>
	<cfset _machine.cflocation = "index.cfm?dsp=management.items">
	<cfquery datasource="#request.dsn#">
		UPDATE auctions
		SET ready = '1'
		WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>
<!--- Place watermark --->
<cfif isDefined("attributes.launch") OR isDefined("attributes.finish")>
	<cfinclude template="get_item.cfm">
	<cfscript>
		if(sqlAuction.use_pictures EQ sqlAuction.itemid){
			watermarkImage = CreateObject("Component","Image").setKey('HTMGB-MGPT0-0W9F0-JVGM5-543MM');
			
			/* :vladedit: 20180221 - after server port to CF 2016 this line is added to fix image path error "c:\inetpub\wwwroot\images/" */
			imagePathX = rereplaceNoCase("#request.basepath##_layout.images_path##sqlEBAccount.watermark#","\\","/","all" );

			
			/*			
			writeDump("request.basepath : #request.basepath#  <br>");
			writeDump("_layout.images_path : #_layout.images_path#  <br>");
			writeDump("sqlEBAccount.watermark: #sqlEBAccount.watermark# <br>");
			writeDump("#imagePathX#");
			*/
			watermarkImage.readImage("#imagePathX#");
			
			

			watermarkWidth = watermarkImage.getWidth();
			watermarkHeight = watermarkImage.getHeight();
			for(i=1; i LTE ListLast(sqlAuction.imagesLayout, '_'); i = i + 1){
				fileName = "#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#i#.jpg";
				if(FileExists(fileName)){
					// create the object
					myImage = CreateObject("Component","Image").setKey('HTMGB-MGPT0-0W9F0-JVGM5-543MM');
					// open a new image
					myImage.readImage(fileName);
					// set the transparency used when drawing into the image
					myImage.setTransparency(75);
					// draw an image into the image
					if(ListFindNoCase("instantsale4u,instantsales4u", sqlEBAccount.UserID)){
						myImage.drawImage("#imagePathX#", (myImage.getWidth()-watermarkWidth), myImage.getHeight()-watermarkHeight);
					}else{
						myImage.drawImage("#imagePathX#", (myImage.getWidth()-watermarkWidth)/2, myImage.getHeight()-watermarkHeight);
					}
					// output the new image
					myImage.writeImage(fileName, "jpg");
				}
			}
		}
	</cfscript>
</cfif>
