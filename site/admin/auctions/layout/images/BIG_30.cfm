<cfoutput><table valign="middle" align="center" cellpadding="0" cellspacing="0" border="0"></cfoutput>
<cfloop index="row" from="1" to="15">
	<cfset isOK = FALSE>
	<cfsavecontent variable="theRow">
		<cfoutput>
		<tr>
			<td width="420" height="390" align="center" valign="middle">
				<cfif FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2-1)#.jpg")>
					<cfscript>
						img = ImageRead("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2-1)#.jpg");
						ImageScaleToFit(img, 420, 350);
						ImageWrite(img, "#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2-1)#_sized.jpg");
						isOK = TRUE;
					</cfscript>
					<img src="#_layout.ia_images##sqlAuction.use_pictures#/#(row*2-1)#_sized.jpg" border="1">
				<cfelse>
					&nbsp;
				</cfif>
			</td>
			<td width="420" height="390" align="center" valign="middle">
				<cfif FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2)#.jpg")>
					<cfscript>
						img = ImageRead("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2)#.jpg");
						ImageScaleToFit(img, 420, 350);
						ImageWrite(img, "#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#(row*2)#_sized.jpg");
						isOK = TRUE;
					</cfscript>
					<img src="#_layout.ia_images##sqlAuction.use_pictures#/#(row*2)#_sized.jpg" border="1">
				<cfelse>
					&nbsp;
				</cfif>
			</td>
		</tr>
		</cfoutput>
	</cfsavecontent>
	<cfif isOK>
		<cfoutput>#theRow#</cfoutput>
	</cfif>
</cfloop>
<cfoutput></table></cfoutput>
