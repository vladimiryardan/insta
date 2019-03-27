<cfif isDefined("_machine.menu")>
	<cfparam name="_machine.menuType" default="">
	<cfswitch expression="#_machine.menuType#">
		<cfcase value="detailed">
		</cfcase>
		<cfdefaultcase>
			<cfoutput>
			</td></tr>
			</table>
			</cfoutput>
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfoutput>
	</td></tr>
	</table>
	</cfoutput>
</cfif>
<cfoutput>
</td></tr>
</table>
<center><font size="-2"><a href="index.cfm?dsp=about">About Us</a> | <a href="index.cfm?dsp=contact">Contact Us</a> | <a href="index.cfm?dsp=privacy">Privacy Policy</a><br>
&copy; 2004-2006 Instant Auctions, LLC. All rights reserved.<BR>Trademarks and logos represented are the property of their respective owners.</font></center>
</body>
</html>
</cfoutput>
