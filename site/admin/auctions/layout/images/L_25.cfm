<cfoutput>
<table valign="middle" align="center" cellpadding="10" cellspacing="0" border="0">
<cfloop index="i" from="0" to="9" step="5">
<tr><cfloop index="j" from="1" to="5"><td align="center" valign="middle">#fShowImage(i+j)#</td></cfloop></tr>
</cfloop>
<tr>
	<td align="center" valign="middle">#fShowImage(11)#</td>
	<td align="center" valign="middle">#fShowImage(12)#</td>
	<td align="center" valign="middle" rowspan="3" colspan="3" width="400" height="300">
		<img name="clicPicBig" src="#_layout.ia_images##sqlAuction.use_pictures#/1.jpg" border="1">
	</td>
</tr>
<cfloop index="i" from="13" to="16" step="2">
<tr><td align="center" valign="middle">#fShowImage(i)#</td><td align="center" valign="middle">#fShowImage(i+1)#</td></tr>
</cfloop>
<cfloop index="i" from="16" to="26" step="5">
<tr><cfloop index="j" from="1" to="5"><td align="center" valign="middle">#fShowImage(i+j)#</td></cfloop></tr>
</cfloop>
</table>
</cfoutput>
