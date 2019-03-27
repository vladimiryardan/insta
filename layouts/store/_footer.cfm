<cfoutput>
</td></tr>
</table>
<center><font size="-2"><cfloop query="sqlFooter">
	<cfif CurrentRow NEQ 1> | </cfif><a href="#pagename#">#title#</a></cfloop><br>
&copy; 2004-#Year(Now())# Instant Auctions, LLC. All rights reserved.<BR>Trademarks and logos represented are the property of their respective owners.</font></center>
</body>
</html>
</cfoutput>
