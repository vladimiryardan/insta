<cfset appletPath = "site/imaging/applet/">

<cfinclude template="get_item.cfm">

<cfif attributes.imgnum GT ListLast(sqlAuction.imagesLayout, '_')>
	<cfset attributes.imgnum = 1>
</cfif>

<cfparam name="attributes.from" default="N/A">
<cfparam name="attributes.doNotResize" default="0">

<cfoutput>
<h3 style="margin-bottom:5px; margin-top:5px;" align="center">EDITING PHOTO ###attributes.imgnum#</h3>
<applet <!---width="100%" height="70%"---> width="714" height="607" id="appa"
	codebase="#appletPath#" archive="imagings.jar" code="Main.class">
<cfif FileExists('#ExpandPath("images")#\#attributes.item#\#attributes.imgnum#.jpg')>
  <param name="load" value="#_layout.images_path##attributes.item#\#attributes.imgnum#.jpg">
</cfif>
  <param name="visible_buttons"  value="open,save,paste,print,resize,crop,cclockw,clockw,fliph,flipv,vars,undo,redo,zoom">
  <param name="prescale"  value="3M">
  <param name="filename" value="#attributes.imgnum#.jpg">
  <param name="jpeg_quality"  value="75">
  <param name="save" value="site/admin/auctions/save_image.cfm?item=#attributes.item#&imgnum=#attributes.imgnum#&from=#attributes.from#&doNotResize=#attributes.doNotResize#">
  <param name="maxsize" value="800,600,auto">
  <param name="minsize" value="500,500,auto"><!--- due to ebays policy of 500 minimum longest side we need this --->

</applet>
</cfoutput>
