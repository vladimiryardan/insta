<cfif isDefined("attributes.back_dsp")>
	<cfset _machine.cflocation = "index.cfm?dsp=#attributes.back_dsp#">
<cfelse>
	<cfset _machine.cflocation = "index.cfm?dsp=admin.auctions.step3&item=#attributes.item#">
</cfif>
<cfparam name="attributes.doNotResize" default="0">
<cfif isDefined("attributes.checkitem")>
	<cfquery datasource="#request.dsn#" name="sqlItem">
		SELECT COUNT(*) AS cnt FROM items
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
	<cfif sqlItem.cnt EQ 0>
		<cfset _machine.cflocation = _machine.cflocation & "&noitem=#attributes.item#">
		<cfexit method="exittemplate">
	</cfif>
</cfif>
<cfset autoLoadImage = "">
<cfloop index="i" from="1" to="#attributes.maxImages#">
	<cfif StructKeyExists(FORM, "img#i#") AND (FORM["img#i#"] NEQ "")>
		<cfset path = "#request.basepath##_layout.images_path##attributes.item#">
		<cfif NOT DirectoryExists(path)>
			<cfdirectory action="create" directory="#path#">
		</cfif>
		<cfif autoLoadImage EQ "">
			<cfset autoLoadImage = i>
		</cfif>

		<!--- set the desired image width --->
		<cfset imagesize = 1000>



		<cffile
			action="upload"
			filefield="form.img#i#"
			destination="#path#"
			nameconflict="overwrite"
			accept="image/jpeg,image/pjpeg,image/gif,image/x-png">

	   <!--- read the image ---->
	   <cfimage name="uploadedImage"
	   source="#path#/#file.serverFile#" >

		<cfscript>
					/* lets change the orientation first base on exif*/
					orientation  = ImageGetEXIFTag(uploadedImage, 'orientation');
					
					// there is an orientation so lets check it to see what we need to do
					// if isNull() is not available in your version of ColdFusion 
					// use ImageGetEXIFMetadata and then check if the structKeyExists
					if(!isNull(orientation)){ 
						 
						 // look to see if the orientation value tells us there is 
						 // a rotation on it (by looking for the string value)
						 hasRotate = findNoCase('rotate',orientation);
						  
						 /*
						 * it did find it so lets copy the image so the Exif Data is removed for the new image
						 * If not on your phone or desktop (mac) the image will still respect the orientation message
						 * even after we fix it, making it appear wrong
						 */
						 if (hasRotate){
						  // strip out all text in the orientation value to get the degree of orientation
						  rotateValue = reReplace(orientation,'[^0-9]','','all');
						  
						  // rotate image
						  imageRotate(uploadedImage,rotateValue);				  
						 }
						}			
					
			
		</cfscript>	   
	

	   <!--- figure out which way to scale the image --->
	   <cfif uploadedImage.width gt uploadedImage.height>
	         <cfset percentage = (imagesize / uploadedImage.width)>
	      <cfelse>
	         <cfset percentage = (imagesize / uploadedImage.height)>
	   </cfif>

	   <cfset newWidth = round(uploadedImage.width * percentage)>
	   <cfset newHeight = round(uploadedImage.height * percentage)>

	   <!--- see if we need to resize the image, maybe it is already smaller than our desired size --->
	   <cfif uploadedImage.width gt imagesize>
	         <cfimage action="resize"
	       height="#newHeight#"
	       width="#newWidth#"
	       source="#uploadedImage#"
	      destination="#path#/#file.serverFile#"
	       overwrite="true"
	       />
	   </cfif>

		

		<cfscript>
			myImage = CreateObject("Component", "Image").setKey('HTMGB-MGPT0-0W9F0-JVGM5-543MM');
			// proceed image
			myImage.readImage("#cffile.serverDirectory#\#cffile.serverFile#");
			
			
			// myImage.scalePixels(400, 370);
			if(attributes.doNotResize EQ "0"){
				if(isDefined("attributes.maxWidth")){
					if(myImage.getWidth() GT attributes.maxWidth){
						myImage.scalePixels(attributes.maxWidth, myImage.getHeight()*attributes.maxWidth/myImage.getWidth());
					}
				}
				if(isDefined("attributes.maxHeight")){
					if(myImage.getHeight() GT attributes.maxHeight){
						myImage.scalePixels(myImage.getWidth()*attributes.maxHeight/myImage.getHeight(), attributes.maxHeight);
					}
				}

				if(myImage.getWidth() lt 500){
					myImage.scalePixels(500, myImage.getHeight()*500/myImage.getWidth());
				}
				if(myImage.getHeight() lt 500){
					myImage.scalePixels(myImage.getWidth()*500/myImage.getHeight(), 500);
				}
			}


			myImage.writeImage("#cffile.serverDirectory#\#i#.jpg", "jpg");
			// generate thumbnail
			myImage.readImage("#cffile.serverDirectory#\#cffile.serverFile#");
			// myImage.scalePixels(96, 89);
			if(myImage.getWidth() GT 96){
				myImage.scalePixels(96, myImage.getHeight()*96/myImage.getWidth());
			}
			if(myImage.getHeight() GT 89){
				myImage.scalePixels(myImage.getWidth()*89/myImage.getHeight(), 89);
			}
			myImage.writeImage("#cffile.serverDirectory#\#i#thumb.jpg", "jpg");
		</cfscript>

		<cffile action="delete" file="#cffile.serverDirectory#\#cffile.serverFile#">
<!---
		<cffile
			action="upload"
			filefield="form.img#i#"
			destination="#path#"
			nameconflict="overwrite"
			accept="image/jpeg,image/pjpeg,image/gif,image/x-png">

		<cffile action="rename"
			source="#cffile.serverDirectory#\#cffile.serverFile#"
			destination="#i#.jpg">
--->
		<!--- UPDATE ITEM PICTURED TIME --->
		<cfquery datasource="#request.dsn#">
			UPDATE items
			SET dpictured = GETDATE()
			WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>
	</cfif>
</cfloop>

<cfif autoLoadImage NEQ "">
	<cfset _machine.cflocation = _machine.cflocation & "&imgnum=#autoLoadImage#">
</cfif>
<cfif isDefined("attributes.from")>
	<cfset _machine.cflocation = _machine.cflocation & "&from=#attributes.from#">
</cfif>
<cfset _machine.cflocation = _machine.cflocation & "&doNotResize=#attributes.doNotResize#">
