<cfquery name="sqlData" datasource="#request.dsn#" maxrows="1">
	SELECT item, title, make, model, age, value, description, weight, startprice, 
	status, dcreated, specialNotes,internal_itemSKU,internal_itemCondition, lid
	FROM items
	WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>
<cfif sqlData.status LT 3>
	<cfset fChangeStatus(attributes.item, 3)><!--- ITEM RECEIVED --->
</cfif>
<cfoutput query="sqlData">
<center>
	<table width=100%>
	<tr>
	<td width="33%" align="left"><font size="2"><strong>#DateFormat(dcreated, "mm/dd/yyyy")#</font></strong></td>
	<td width="33%" align="center"><strong><font size=2>Store: #ListFirst(item,".")#</font></strong></td>
	<td width="33%" align="right"><cfif startprice GT 0><font size=3><strong>R</strong></font></cfif>#sqlData.lid#&nbsp;&nbsp;</td><!---spaces on lid is needed coz of IE bug --->
	</tr>
	</table>
<strong><font size="6">#ListRest(item, ".")#</font><br><font size="2">
<cfif Len(title) LT 1>...<cfelse><cfif Len(title) GT 80>#Left(title, 77)#...<cfelse>#title#</cfif></cfif><br></strong>
<!---<cfif Len(description) LT 1>...<cfelseif Len(description) GT 110>#Left(description, 107)#...<cfelse>#description#</cfif>--->
<cfif Len(specialNotes) LT 1>...<cfelseif Len(specialNotes) GT 110>#Left(specialNotes, 107)#...<cfelse>#specialNotes#</cfif>
<br>
<!---strong>Weight:</strong> #weight# lbs. --->
<strong style="font-size:16px;">Retail:</strong> <font style="font-size:16px;">#Replace(LCase(age), " ", "", "ALL")#</font>
&nbsp;&nbsp;
<!---<strong style="font-size:16px;">BBW Price:</strong> <font style="font-size:21px;"><cfif startprice GT 0><u>#DollarFormat(startprice)#</u><cfelse>#DollarFormat(startprice)#</cfif></font><br>--->
<strong style="font-size:16px;">SKU:</strong><font style="font-size:21px;">#internal_itemSKU#</font><br>
<strong style="font-size:16px;">IIC:</strong><font style="font-size:16px;"> #internal_itemCondition#</font>
<br>
<font size=3 face="IABarcode">*#item#*</font><br>


<script type="text/javascript" language="javascript1.2">window.print();</script>

</cfoutput>
