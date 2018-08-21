<cfquery name="sqlItem" datasource="#request.dsn#">
	SELECT ByrCountry
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
</cfquery>
<cfif isDefined("attributes.worldwide") OR ((sqlItem.RecordCount EQ 1) AND (sqlItem.ByrCountry NEQ "US"))>
	<cfcontent reset="yes">
	<cfdocument format="pdf" margintop="#_vars.usps.CustomForm_TopPadding#">
		<cfoutput><img src="usps/#attributes.itemid#.gif" width="#_vars.usps.CustomForm_Width#" style="margin:0 0 0 0;"></cfoutput>
	</cfdocument>
<cfelse>
	<!---<cfoutput><img src="usps/#attributes.itemid#.jpg" height="363"><img src="usps/sticker.jpg" height="363"><script type="text/javascript" language="javascript1.2">window.print();</script></cfoutput>--->
		<cfoutput><img src="usps/#attributes.itemid#.jpg" height="363"><script type="text/javascript" language="javascript1.2">window.print();</script></cfoutput>
</cfif>
