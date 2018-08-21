<cfset request.title = "Shipment Note - " & request.title>

<cfif isDefined("attributes.close")>
	<cfoutput>
	<table height="290" align="center">
	<tr><td valign="middle">
		Shipment note was updated.
	</td></tr>
	</table>
	<script language="javascript" type="text/javascript">
	<!--//
		/*
		window.onunload = refreshParent;
        function refreshParent() {
            var loc = window.opener.location;
            window.opener.location = loc;
        }
        */
		
		//self.opener.location.reload();
		window.opener.location.reload()	
		var i = setInterval(function(){clearInterval(i);window.close();}, 500);
	//-->
	</script>
	</cfoutput>
<cfelse>
	<cfquery name="sqlNote" datasource="#request.dsn#">
		SELECT shipnote FROM items
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.itemid#">
	</cfquery>
		<cfoutput>
		<br>
		<center>
		<h3>Shipment Note for item #attributes.itemid#</h3>
		<form id="f" name="f" action="index.cfm?act=admin.ship.setnote" method="post">
		<input type="hidden" name="itemid" value="#attributes.itemid#">
		<textarea cols="90" rows="13" name="shipnote" id="shipnote">#sqlNote.shipnote#</textarea><br>
	<cfif isAllowed("Listings_EditShippingNote")>
		<input type="submit" value="Save" width="140" style="width:140px;">
	</cfif>
		&nbsp;&nbsp;&nbsp;
		<input type="button" value="Close" width="140" style="width:140px;" onClick="window.close();">
		</form>
		</center>
		</cfoutput>
</cfif>

<cfoutput>

	
	<!---:vladedit: 20150902 --->
	<script src="ckeditor/ckeditor.js"></script>
	<script>
	    // Replace the <textarea id="editor1"> with a CKEditor
	    // instance, using default configuration.
	    CKEDITOR.replace( 'shipnote',{
	    	extraPlugins : 'filemanager'
	    } );
	</script>
</cfoutput>


