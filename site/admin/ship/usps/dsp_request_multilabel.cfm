<cfif NOT isAllowed("Listings_CreateLabel")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>



<cfinclude template="../inc_shippingCostUPSPreviewMulti.cfm" >
<cfinclude template="inc_shippingCostUSPSPreviewMulti.cfm" >
<cfinclude template="../fedex/inc_fedexPreviewMulti.cfm" >
	


<cfoutput>
<style type="text/css">
	##comlist{background-color:##AAAAAA;}
	##comlist th{background-color:##F0F1F3; font-weight:bold; text-align:center;}
	##comlist td{background-color:white; width:10%; text-align:center;}
	##comlist th a, ##comlist th a:visited{color:red;}
	##comlist th a:hover{color:green;}
</style>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>USPS Label:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#
	<br><br>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<form method="POST" action="index.cfm?dsp=#attributes.dsp#">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Item Details</b></td></tr>
		<tr bgcolor="##FFFFFF"><td colspan="2">
			<table cellpadding="3" cellspacing="1" id="comlist">
			<tr>
				<th colspan="2">Item Owner</td>
				<th>Item Number</td>
				<th>eBay Number</td>
				<th>Created On</td>
				<th>Weight</th>
				<th>Value</th>
				<th>Bidder</th>
			</tr>
			</cfoutput>
			<cfoutput query="sqlItem" group="item">
			<tr>
				<td><a href="mailto:#sqlItem.hbemail#?subject=Instant Auctions: Item #item#"><img src="#request.images_path#emailblue.gif" align="middle" border=0></a></td>
				<td><a href="index.cfm?dsp=account.edit&id=#aid#">#first# #last#</a></td>
				<td><a href="index.cfm?dsp=management.items.edit&item=#item#">#item#</a></td>
				<td align="center"><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#ebayitem#" target="_blank">#ebayitem#</a></td>
				<td align="center">#DateFormat(dcreated)# #TimeFormat(dcreated)#</td>
				<td align="center">#weight#</td>
				<td align="right">#DollarFormat(price)#</td>
				<td>#hbuserid#</td>
			</tr>
			</cfoutput>
			<cfoutput>
			</table>
		</td></tr>
		
            	<!--- catch PO box in ups --->
            	<cfif lcase(pageData.TO_Address1).startsWith("po") or lcase(pageData.TO_Address1).startsWith("p.o") 
            	      or lcase(pageData.TO_Address1) contains "p.o box">
            		<tr>
            			<td colspan="2" align="center">
            				<div style="color:white;background-color:##E81747;padding:10px;font-weight:bold">
            					ALERT! The Address is possibly a PO box. UPS does not ship to PO box.
            				</div>
            			</td>
            		</tr>
            	</cfif>
		
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>General</b></td></tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Description:</b></td>
			<td>#sqlItem.title#</td>
		</tr>
		<cfif sqlItem.shipnote NEQ "">
			<tr bgcolor="##FFFFFF">
				<td valign="middle"><b>Ship Note:</b></td>
				<td style="background-color:yellow;">#sqlItem.shipnote#</td>
			</tr>
		</cfif>
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Ship To</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Name:</b></td>
			<td><input type="text" size="40" maxlength="45" name="TO_Name" value="#pageData.TO_Name#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Company:</b></td>
			<td><input type="text" size="40" maxlength="45" name="TO_Firm" value="#pageData.TO_Firm#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Street/Address 1:</b></td>
			<td><input type="text" size="40" maxlength="45" name="TO_Address1" value="#pageData.TO_Address1#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Room/Floor/Address 2:</b></td>
			<td valign="middle"><b>Department/Address 3</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="45" name="TO_Address2" value="#pageData.TO_Address2#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="45" name="TO_Address3" value="#pageData.TO_Address3#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Country:</b></td>
			<td valign="middle"><b>Postal/ZIP Code &reg;</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td>
				<cfif ListFindNoCase("US,CA", pageData.TO_Country)>
					<select name="TO_Country" onChange="fSateProvince(this.value)" style="width:277px">
					<cftry>
					#SelectOptions(pageData.TO_Country, countriesList)#
					<cfcatch type="Any">
						UNDEFINED
						#cfcatch.message#<br>
					</cfcatch>
	    			</cftry>
					</select>
				<cfelse>
					<input type="text" size="40" maxlength="80" name="TO_Country" value="#pageData.TO_Country#" style="font-size: 11px;">
				</cfif>
			</td>
			<td><input type="text" size="40" maxlength="80" name="TO_PostalCode" value="#pageData.TO_PostalCode#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>City:</b></td>
			<td valign="middle"><b id="spOBJ">State</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="45" name="TO_City" value="#pageData.TO_City#" style="font-size: 11px;"></td>
			<td><span style="color:blue">[#trim(parseState(pageData.TO_Province))#](#pageData.TO_Province#)</span>
				<cfif ListFindNoCase("US,CA", pageData.TO_Country)>
					<select name="TO_Province" id="TO_Province" size="1" style="width:213px;">
					<option value="XX">SELECT ONE</option>
					</select>
				<cfelse>
					<input type="text" size="40" maxlength="80" name="TO_Province" value="#pageData.TO_Province#" style="font-size: 11px;">
				</cfif>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Telephone:</b></td>
			<td valign="middle"><b>E-mail Address:</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td><input type="text" size="40" maxlength="80" name="TO_Phone" value="#pageData.TO_Phone#" style="font-size: 11px;"></td>
			<td><input type="text" size="40" maxlength="80" name="TO_Email" value="#pageData.TO_Email#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3"><td colspan="2"><b>Package</b></td></tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Mail Class:</b></td>
			<td>
				<select name="MailClass" style="width:277px;">
				#SelectOptions(pageData.MailClass, MailClassList)#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Weight:</b></td>
			<td>
				<input type="text" size="2" maxlength="3" name="Weight" id="dWeight" value="#pageData.weight#" style="font-size: 11px; width:60px;" required="true">
				<b>pounds</b>
				and
				<input type="text" size="5" maxlength="5" name="WeightOz" id="WeightOz" value="#pageData.WeightOz#" style="font-size: 11px; width:60px;" required="true">
				<b>ounces</b>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Declared Value:</b></td>
			<td><input type="text" size="40" maxlength="80" name="DeclaredValue" value="#pageData.DeclaredValue#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Insurance:</b></td>
			<td>
				<select name="InsuredMail" style="width:277px;">
				#SelectOptions(pageData.InsuredMail, InsuredMailList)#
				</select>
			</td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Width (WD):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Width" id="dWidth" value="#pageData.width#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Height (hgt):</b></td>
			<td><input type="text" size="40" maxlength="80" name="Height" id="cHeight" value="#pageData.height#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Length (LEN):</b></td>
			<td><input type="text" size="40" maxlength="80" name="depth" id="ddepth" value="#pageData.depth#" style="font-size: 11px;"></td>
		</tr>	
		
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle"><b>Test:</b></td>
			<td><input type="checkbox" name="Test" value="YES"<cfif pageData.Test EQ "YES"> checked</cfif>></td>
		</tr>
		<cfset bgcolorUPS = "">
		<cfset bgcolorUSPS = "">
		<cfset bgcolorFedex = "">
		
		<cfif isdefined("totalSum") and isdefined("uspsPriceDisplay")>
			<cfif totalSum and uspsPriceDisplay>
				<cfset bgcolorUPS = "red">
				<cfset bgcolorUSPS = "green">
			<cfelse>
				<cfset bgcolorUPS = "green">
				<cfset bgcolorUSPS = "red">
			</cfif>
		</cfif>
		<tr bgcolor="##FFFFFF">
			<td colspan="3" height="50px" background-color="gray">
				
				<cfset upsRatePreview = 0>
				<cfset uspsRatePreview = 0>
				<cfset fedexRatePreview = 0>
				<cfset shippingRatesArray = ArrayNew(1)>
				
				<cfif isdefined("totalSum")>
					<cfset upsRatePreview = totalSum>
					<cfset ArrayAppend(shippingRatesArray, "#upsRatePreview#")>
				</cfif>
				
				<cfif isdefined("uspsPriceDisplay")>
					<cfset uspsRatePreview = uspsPriceDisplay>
					 <cfset ArrayAppend(shippingRatesArray, "#uspsRatePreview#")> 
				</cfif>
				
				<cfif structKeyExists(result,'rates')>
					<cfset fedexRatePreview = result.rates[1].totalnetcharge>	
					<cfset ArrayAppend(shippingRatesArray, "#fedexRatePreview#")> 
				</cfif>
				
				<cfset ArraySort(shippingRatesArray, "numeric", "asc") >
				
				<cfparam name="totalSum" default="0" >
				<cfparam name="USPSPRICEDISPLAY" default="0" >
				<cfscript>
					shipStruct = structnew();
					shipStruct.fedex = {price = fedexRatePreview, department = "fedex"};
					shipStruct.ups = {price = totalSum, department = "ups"};
					shipStruct.usps = {price = uspsPriceDisplay, department="usps"};
					shippingSorted = structSort(shipStruct, "numeric", "asc", "price");
				</cfscript>

		<cfloop from="1" to="#arrayLen(shippingSorted)#" index="x">
						<cfif x eq 1>
							<cfset color = "green" >
						</cfif>
						
						<cfif x eq 2>
							<cfset color = "##feb300" >
						</cfif>
						
						<cfif x eq 3>
							<cfset color = "red" >
						</cfif>		
						
			
						<cfif shipStruct[shippingSorted[x]].department is "ups">
							<div style="color:##FEB300;" class="shippingRate">
							UPS#dollarformat(shipStruct[shippingSorted[x]].price)#
							</div>
							
						</cfif>
			
						
						<cfif shipStruct[shippingSorted[x]].department is "usps">
						
							<div style="color:##0000FF;" class="shippingRate">
								USPS #dollarformat(uspsPriceDisplay)#
							</div>
							
						</cfif>
						
						<cfif shipStruct[shippingSorted[x]].department is "fedex">
							
							<div style="color:##d227f4;" class="shippingRate">
							FEDEX #dollarformat(fedexRatePreview)#
							</div>	
											
						</cfif>			
				</cfloop>	
			</td>
		</tr>		
		
		<tr bgcolor="##F0F1F3"><td colspan="2" align="center">
			<input type="submit" class="shippingButton" style="color:white; font-weight:bold; background-color:blue;" name="submit" value="Request USPS Label">
			<br><hr>	
			<input type="button" class="shippingButton" style="color:white; font-weight:bold; background-color:##feb300;" value="Go to UPS Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.confirm_multilabel';">
			&nbsp;&nbsp;&nbsp;
			<input type="button" class="shippingButton" style="color:white; background-color:##d227f4;" value="Go to FEDEX Label Generation" onClick="document.location = 'index.cfm?dsp=admin.ship.fedex.FedexMulti&item=#attributes.item#';">
		</td></tr>
		</form>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<br>


<cfif ListFindNoCase("US,CA", pageData.TO_Country)>
<script language="javascript" type="text/javascript">
<!--//
function fSateProvince(country){
	if(country=="US"){
		document.getElementById("spOBJ").innerHTML = "State:";
		a = "XX,SELECT ONE;AL,Alabama;AK,Alaska;AZ,Arizona;AR,Arkansas;CA,California;CO,Colorado;CT,Connecticut;DE,Delaware;DC,District of Columbia;FL,Florida;GA,Georgia;HI,Hawaii;ID,Idaho;IL,Illinois;IN,Indiana;IA,Iowa;KS,Kansas;KY,Kentucky;LA,Louisiana;ME,Maine;MD,Maryland;MA,Massachusetts;MI,Michigan;MN,Minnesota;MS,Mississippi;MO,Missouri;MT,Montana;NE,Nebraska;NV,Nevada;NH,New Hampshire;NJ,New Jersey;NM,New Mexico;NY,New York;NC,North Carolina;ND,North Dakota;OH,Ohio;OK,Oklahoma;OR,Oregon;PA,Pennsylvania;RI,Rhode Island;SC,South Carolina;SD,South Dakota;TN,Tennessee;TX,Texas;UT,Utah;VT,Vermont;VA,Virginia;WA,Washington;WV,West Virginia;WI,Wisconsin;WY,Wyoming".split(";");
	}else{
		document.getElementById("spOBJ").innerHTML = "Province:";
		a = "XX,SELECT ONE;AB,Alberta;BC,British Columbia;MB,Manitoba;NB,New Brunswick;NF,Newfoundland;NT,Northwest Territories;NS,Nova Scotia;NU,Nunavut;ON,Ontario;PE,Prince Edward Island;QC,Quebec;SK,Saskatchewan;YT,Yukon".split(";");
	}
	obj = document.getElementById("TO_Province");
	obj.options.length = 0;
	for(i=0; i<a.length; i++){
		b = a[i].split(",");
		obj.options[i] = new Option(b[1], b[0]);
		if("#parseState(pageData.TO_Province)#" == b[0]){
			obj.options[i].selected = true;
		}
	}
}
fSateProvince("#pageData.TO_Country#");
//-->
</script>

</cfif>
</cfoutput>

