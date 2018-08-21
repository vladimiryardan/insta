<cfif NOT isAllowed("Items_CreateNew")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>


<cfparam name="attributes.accountid" default="">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.sku" default="">
<cfparam name="attributes.upc" default="Does Not Apply">
<cfparam name="attributes.mpnBrand" default="Does Not Apply">
<cfparam name="attributes.mpnNum" default="Does Not Apply">

<cfparam name="attributes.itemCondition" default="">
<cfparam name="attributes.brand" default="">
<cfparam name="attributes.model" default="">
<cfparam name="attributes.age" default="">
<cfparam name="attributes.value" default="">
<cfparam name="attributes.desc" default="">
<cfparam name="attributes.startprice_real" default="9.99">
<cfparam name="attributes.startprice" default="0">
<cfparam name="attributes.buy_it_now" default="">
<cfparam name="attributes.weight" default="">
<cfparam name="attributes.width" default="1">
<cfparam name="attributes.height" default="1">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.commission" default="">
<cfparam name="attributes.purchase_price" default="0">
<cfparam name="attributes.bold" default="0">
<cfparam name="attributes.border" default="0">
<cfparam name="attributes.highlight" default="0">
<cfparam name="attributes.vehicle" default="0">
<cfparam name="attributes.weight_oz" default="">
<cfparam name="attributes.description" default="">

<cfparam name="attributes.itemManual" default="0">
<cfparam name="attributes.itemComplete" default="1">
<cfparam name="attributes.itemTested" default="1">
<cfparam name="attributes.retailPackingIncluded" default="0">
<cfparam name="attributes.specialNotes" default="N/A">
<cfparam name="attributes.categoryid" default="0">
<cfparam name="attributes.lid" default="">



<cfparam name="attributes.sub_description" default="">
<cfparam name="attributes.ship_dimension_name" default="">

<cfparam name="catNames.recordcount" default="0" >

<cfparam name="attributes.shipNotes" default="" >
<cfparam name="attributes.redirectLocation" default="" >
<cfparam name="attributes.AUTOSUBMIT" default="" >
<cfparam name="attributes.orig_item" default="" >
<cfparam name="attributes.dummy" default="0" >
<cfparam name="attributes.isbn" default="" >
<cfparam name="attributes.model2" default="">


<cftry>
<!--- get the path of the category --->
<cfquery name="recurseCategory" datasource="#request.dsn#" >
			-- Creating CTE
		WITH categoryMaster
		AS
		(
		SELECT  ec1.CategoryID,
		      ec1.CategoryLevel,
		      ec1.CategoryName,
		      ec1.CategoryParentID
		FROM    ebcategories ec1
		where categoryid = #attributes.categoryid#

		UNION ALL

		SELECT ec2.CategoryID,
		       ec2.CategoryLevel,
		       ec2.CategoryName,
		       ec2.CategoryParentID
		FROM    categoryMaster cm
		INNER JOIN ebcategories ec2 ON ec2.CategoryID = cm.CategoryParentID

		)

		-- Viewing Data
		SELECT top 6
		*
		FROM   categoryMaster
	</cfquery>



	<!--- remove dups --->
	<cfquery dbtype="query" name="catNames">
		SELECT Distinct(CategoryID) as CategoryID,CategoryName
		FROM recurseCategory
		Order by CategoryLevel asc
	</cfquery>

<cfquery name="getSubdescriptionsCat" datasource="#request.dsn#">
	SELECT Distinct subdescription_category      	
	from subdescriptions	
	order by 1 asc
</cfquery>


<cfquery name="getSubdescriptions" datasource="#request.dsn#">
	SELECT 
		subdescription_id
      	,subdescription_text
      	,subdescription_category
      	,subdescription_name
	from subdescriptions
	
	order by subdescription_category asc, subdescription_name asc	
</cfquery>

<!--- get dimensions --->
<cfquery datasource="#request.dsn#" name="get_ShipDimensions">
	Select * from ship_dimensions
	order by ship_dimension_name asc
</cfquery>

<cfcatch type="Any" >
</cfcatch>
</cftry>

<cfoutput>
<style type="text/css">
.dsp_none {
	display:none;
}

select option[disabled] {
    display: none;
}

</style>
<script language="javascript" type="text/javascript">
<!--//
var total = 0;
function fSum(){

	var res = document.getElementById('startprice');

	if(!document.getElementById("vehicle").checked){
		if(res.value > 0){
			if (res.value > 100){
				if (res.value > 500){
					total = (res.value * .02);
				}else{
					total = 10;
				}
			}else{
				total = 5;
			}
		}else{
			total = 0;
		}
		if(document.getElementById("bold").checked) total += 1.25;
		if(document.getElementById("border").checked) total += 3.75;
		if(document.getElementById("highlight").checked) total += 6.25;
		var obj = document.getElementById("suma");
		obj.value = "$" + total;

	}else{
		total = 99;
		if(document.getElementById("bold").checked) total += 1.25;
		if(document.getElementById("border").checked) total += 3.75;
		if(document.getElementById("highlight").checked) total += 6.25;
		var obj = document.getElementById("suma");
		obj.value = "$" + total;
	}
}
	function fCharsLeft(objID, val, maxChars){
		document.getElementById(objID).innerHTML = "(" + (maxChars-val.length) + " chars left)";
	}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Item Management &gt; Create Item:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<cfif isDefined("attributes.msg")>
		<cfswitch expression="#attributes.msg#">
			<cfcase value="1"><cfoutput><font color=red><b>Purchase Price is required for liquidation account's items!</b><br><br></font></cfoutput></cfcase>
			<cfcase value="2"><cfoutput><font color=red><b>Purchase Price exceeds investment amount. Investment left for liquidation account is #DollarFormat(investment_balance)#</b><br><br></font></cfoutput></cfcase>
		</cfswitch>
	</cfif>

	<form method="POST" id="form1" action="index.cfm?act=management.items.create" >
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" >
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Account ID:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="10" name="accountid" value="#attributes.accountid#" style="font-size: 11px;"></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>SKU:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="55" name="itemSKU" id="itemSKU" value="#attributes.sku#" style="font-size: 11px;"></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>UPC:</b></td>
			<td width="70%" align="left">
			<input type="text" size="20" maxlength="55" name="upc" id="upc" 
				 value="#attributes.upc#" style="font-size: 11px;">
			</td>
		</tr>
	
		<!---:vladedit: 20150731 adding of mpn required by ebay --->
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Brand:</b></td><td width="70%" align="left">
			<input type="text" size="20" maxlength="65" name="mpnBrand" id="mpnBrand" value="#attributes.mpnBrand#" style="font-size: 11px;">
		</td></tr>

		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>MPN ##:</b></td><td width="70%" align="left">
			<input type="text" size="20" maxlength="65" name="mpnNum" id="mpnNum" value="#attributes.mpnNum#" style="font-size: 11px;">
		</td></tr>
		<!---MPN ENDS --->
		
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Model:</b></td><td width="70%" align="left">
			<input type="text" size="20" maxlength="65" name="model2" id="model2" value="#attributes.model2#" style="font-size: 11px;">
		</td></tr>
		

		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>ISBN:</b></td><td width="70%" align="left">
			<input type="text" size="20" maxlength="65" name="isbn" 
			id="isbn" value="#attributes.isbn#" style="font-size: 11px;" placeholder="Books only">
		</td></tr>
				
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Title:</b></td>
			<td width="70%" align="left">
				<input type="text" 
				size="70" 
				maxlength="80" 
				name="title" 
				value="#HTMLEditFormat(attributes.title)#" style="font-size: 11px;" onChange="fCharsLeft('dyna', this.value, 80)" 
			onKeyUp="fCharsLeft('dyna', this.value, 80)">
			<font id="dyna">(#80-Len(attributes.title)# chars left)</font>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Item Condition:</b></td>
			<td width="70%" align="left">
			<select name="itemCondition" id="itemCondition">
				<option value="" <cfif #lcase(attributes.itemCondition)# eq "">selected</cfif>>Select Item Condition</option>
				<option value="New" <cfif #lcase(attributes.itemCondition)# eq "new">selected</cfif>>New</option>
				<!---<option value="EXCELLENT" <cfif #lcase(attributes.itemCondition)# eq "excellent">selected</cfif>>Excellent</option>--->
				<option value="New (Other) Opened" <cfif #lcase(attributes.itemCondition)# eq "New (Other) Opened">selected</cfif>>New (Other) Opened</option>
				<!---<option value="GOOD" <cfif #lcase(attributes.itemCondition)# eq "good">selected</cfif>>GOOD</option>
				<option value="FAIR" <cfif #lcase(attributes.itemCondition)# eq "fair">selected</cfif>>FAIR</option>--->
				<option value="USED" <cfif #lcase(attributes.itemCondition)# eq "used">selected</cfif>>USED</option>
				<option value="AS-IS"<cfif #lcase(attributes.itemCondition)# eq "as-is">selected</cfif>>AS-IS</option>
				<option value="SELLER REFURBISHED" <cfif #lcase(attributes.itemCondition)# eq "used">selected</cfif>>SELLER REFURBISHED</option>
				<option value="NEW WITHOUT TAGS" <cfif #lcase(attributes.itemCondition)# eq "used">selected</cfif>>NEW WITHOUT TAGS</option>
				<option value="NEW WITH DEFECT" <cfif #lcase(attributes.itemCondition)# eq "new with defect">selected</cfif>>NEW WITH DEFECT</option>
					<option value="New With Box" <cfif #lcase(attributes.itemCondition)# eq "New With Box">selected</cfif>>New With Box</option>
					<option value="New With Tags" <cfif #lcase(attributes.itemCondition)# eq "New With Tags">selected</cfif>>New With Tags</option>
					<option value="New Without Box" <cfif #lcase(attributes.itemCondition)# eq "New Without Box">selected</cfif>>New Without Box</option>
					<option value="Preowned" <cfif #lcase(attributes.itemCondition)# eq "Preowned">selected</cfif>>Preowned</option>
					<option value="Amazon" <cfif #lcase(attributes.itemCondition)# eq "amazon">selected</cfif>>Amazon</option>
					<option value="Craiglist" <cfif #lcase(attributes.itemCondition)# eq "Craiglist">selected</cfif>>Craiglist</option>
					<option value="Bonanza" <cfif lcase(attributes.itemCondition) eq "Bonanza">selected</cfif>>Bonanza</option>
			</select>
			</td>
		</tr>
		
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Sub Description:</b></td><td width="70%" align="left">
			
			<select name="ctrl_subItemDescription" id="ctrl_subItemDescription">
					<option value="">-- Select Sub Description --</option>
					<cfloop query="getSubdescriptionsCat" >
							<optgroup label="#getSubdescriptionsCat.subdescription_category#">													
							<cfloop query="getSubdescriptions">
		      					<cfif getSubdescriptionsCat.subdescription_category is getSubdescriptions.subdescription_category>		      						
		      						<option value="#subdescription_text#"  >#subdescription_name#</option>
		      					</cfif>
							</cfloop>						
					</cfloop>
					
				</select><br />
				
			<textarea name="sub_description" id="sub_description" rows="5" cols="40" style="font-size: 11px;">#attributes.sub_description#</textarea>
			<br><a href="index.cfm?dsp=management.items.subDescriptions.subDescriptionsList">Sub Description List</a>
			</td></tr>

		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Category ID:</b></td><td width="70%" align="left"><input type="hidden" name="cat" value="75">75  &nbsp;&nbsp;&nbsp;(Note:75 is custom)</td></tr>
		<!--- 20130529 display the category map. --->




		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>EBAY Category ID:</b></td><td width="70%" align="left"> #attributes.categoryid#</td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Category Map:</b></td>
			<td width="70%" align="left">
					<cfif catNames.RecordCount gte 1>
					<cfloop query="catNames" >
						#catNames.categoryName#<br>
						</cfloop>
					</cfif>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>LID:</b></td>
			<td width="70%" align="left"> 
				<input type="text" size="20" maxlength="20" name="lid" id="lid" value="#attributes.lid#" style="font-size: 11px;" >
			</td>
		</tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Retail:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="20" name="age" value="#attributes.age#" style="font-size: 11px;"></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Description:</b></td><td width="70%" align="left"><textarea name="description" rows="5" cols="40" style="font-size: 11px;">#attributes.description#</textarea></td></tr>
		
		
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Special Notes:</b></td><td width="70%" align="left"><textarea name="specialNotes" rows="5" cols="40" style="font-size: 11px;">#attributes.specialNotes#</textarea></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Starting Price:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="80" name="startprice_real" style="font-size: 11px;" value="#attributes.startprice_real#"></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>BBW Price:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="80" name="startprice" id="startprice" style="font-size: 11px;" value="#attributes.startprice#" onBlur="fSum()"></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Buy It Now:</b></td><td width="70%" align="left">
			<input type="text" size="20" maxlength="80" name="buy_it_now" style="font-size: 11px;" value="#attributes.buy_it_now#"></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Weight (lbs):</b></td><td width="70%" align="left"><input type="text" size="5" maxlength="5" name="weight" value="#attributes.weight#" style="font-size: 11px;"></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Weight (oz):</b></td><td width="70%" align="left"><input type="text" size="5" maxlength="5" name="weight_oz" id="weight_oz" value="#attributes.weight_oz#" style="font-size: 11px;"></td></tr>


		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Dimensions:</b></td>
			<td>
				<select name="ship_dimension_name" id="ship_dimension_name">
					<option value="" selected="selected" >--Select--</option>
					<cfloop query="get_ShipDimensions">
						<option 
							value="#get_ShipDimensions.ship_dimensionid#"
							data-width="#get_ShipDimensions.ship_dimension_width#"
							data-length="#get_ShipDimensions.ship_dimension_length#"
							data-height="#get_ShipDimensions.ship_dimension_heigth#"
							<cfif attributes.ship_dimension_name is get_ShipDimensions.ship_dimension_name>selected</cfif>
							>	
							#get_ShipDimensions.ship_dimension_name#						
						</option>
					</cfloop>
				</select>
				<span class="floatRight"><a href="index.cfm?dsp=admin.ship.shippingDimensions.dimensionList">Dimension List</a></span>
			</td>			
		</tr>
		
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Width (in):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="width_dimension" id="width_dimension" value="#attributes.width#" style="font-size: 11px;"></td>
		</tr>
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Height (in):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="height_dimension" id="height_dimension" value="#attributes.height#" style="font-size: 11px;"></td>
		</tr>
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Length (in):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="depth_dimension" id="depth_dimension"  value="#attributes.depth#" style="font-size: 11px;"></td>
		</tr>
	
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Dummy Item:</b></td>
			<td width="70%" align="left">
				<input type="checkbox" name="dummy" value="1" <cfif attributes.dummy is "1">checked</cfif>>
			</td>
		</tr>
						
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Internal Ship To:</b></td>
			<td align="left">
				<select name="internalShipToLocations">
					#SelectOptions('USA', "US,USA;WorldWide,Worldwide;None,Pickup Only")#
				</select>
			</td>
		</tr>

		
		
		<!--- 20110512 commented out coz patrick doesn't use it. VLAD --->

			<!---<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="right" >
			<b>Width (in):</b></td><td  width="70%" align="left">
			<input type="text" size="5" maxlength="3" name="width_is" value="#attributes.width#" style="font-size: 11px;"></td></tr>
				
			<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="right"><b>Height (in):</b></td>
				<td width="70%" align="left">
					<input type="text" size="5" maxlength="3" name="height_is" value="#attributes.height#" style="font-size: 11px;"></td></tr>
						
			<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="right">
				<b>Depth (in):</b></td><td width="70%" align="left">
				<input type="text" size="5" maxlength="3" name="depth" value="#attributes.depth#" style="font-size: 11px;"></td></tr>--->
			
			<tr bgcolor="##FFFFFF" class="dsp_none"><td valign="middle" align="right"><b>Commission:</b></td><td width="70%" align="left"><input type="text" size="20" maxlength="80" name="commission" style="font-size: 11px;" value="#attributes.commission#"<cfif NOT isAllowed("Items_EditCommission")> disabled</cfif>><i>(leave blank for account default)</i></td></tr>


		<!--- 20101204 commented out coz patrick doesn't use it. VLAD --->
			<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="center" colspan="2"><b>Features</b> <a href="#request.images_path#features.jpg" target="_new"><img src="#request.images_path#look.png" border="0"></a></td></tr>
			<tr bgcolor="##FFFFFF" class="dsp_none"><td></td><td valign="middle" align="left"><input type="checkbox" name="bold" id="bold" value="1" onClick="fSum()"<cfif attributes.bold EQ 1> checked</cfif>> Bold ($1.25)</td></tr>
			<tr bgcolor="##FFFFFF" class="dsp_none"><td></td><td valign="middle" align="left"><input type="checkbox" name="border" id="border" value="1" onClick="fSum()"<cfif attributes.border EQ 1> checked</cfif>> Border ($3.75)</td></tr>
			<tr bgcolor="##FFFFFF" class="dsp_none"><td></td><td valign="middle" align="left"><input type="checkbox" name="highlight" id="highlight" value="1" onClick="fSum()"<cfif attributes.highlight EQ 1> checked</cfif>> Highlight ($6.25)</td></tr>
			<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="center" colspan="2"><b>Special</b></td></tr>
			<tr bgcolor="##FFFFFF" class="dsp_none"><td></td><td valign="middle" align="left"><input type="checkbox" name="vehicle" id="vehicle" value="1" onClick="fSum()"<cfif attributes.vehicle EQ 1> checked</cfif>> Vehicle ($99)</td></tr>


		<tr bgcolor="##F0F1F3" class="dsp_none"><td valign="middle" align="right"><b>Total:</b></td><td><input type="text" size="5" name="suma" id="suma" value="$0" disabled></td></tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Purchase Price:</b></td><td><input type="text" size="5" name="purchase_price" id="purchase_price" value="#attributes.purchase_price#" style="font-size: 11px;"></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Multiple Items:</b></td><td><input type="text" size="5" name="qty_multiple" value="1" style="font-size: 11px;"> <small>Number of similar items to be created</small></td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Manual Included:</b></td>
		<td>
				<select name="itemManual">
					<option value="0" <cfif attributes.itemManual eq 0>selected</cfif>>No</option>
					<option value="1" <cfif attributes.itemManual eq 1>selected</cfif>>Yes</option>
				</select>
		</td></tr>
		<!---<tr bgcolor="##FFFFFF"><td valign="middle" align="right"><b>Fixed Auction:</b></td>
		<td>
				<select name="fixedAuction">
					<option value="0" <cfif attributes.itemManual eq 0>selected</cfif>>No</option>
					<option value="1" <cfif attributes.itemManual eq 1>selected</cfif>>Yes</option>
				</select>
		</td></tr>--->		
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Item is Complete:</b></td>
		<td>
			<select name="itemComplete">
				<option value="0" <cfif attributes.itemComplete eq 0>selected</cfif>>No</option>
				<option value="1" <cfif attributes.itemComplete eq 1>selected</cfif>>Yes</option>
			</select>
		</td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Item tested:</b></td>
		<td>
			<select name="itemTested">
				<option value="0" <cfif attributes.itemTested eq 0>selected</cfif>>No</option>
				<option value="1" <cfif attributes.itemTested eq 1>selected</cfif>>Yes</option>
			</select>
		<td>

		</td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Retail Packing Included:</b></td>
		<td>
			<select name="retailPackingIncluded">
				<option value="0" <cfif attributes.retailPackingIncluded is "0">selected</cfif>>No</option>
				<option value="1" <cfif attributes.retailPackingIncluded is "1">selected</cfif>>Yes</option>
			</select>
		</td></tr>
	<!--- 20110512 Item specifics Vlad --->
		<tr bgcolor="##D7E1ED" >
			<td valign="middle" align="center" colspan="2"><strong>EBAY Item Specifics:</strong></td>
		</tr>



<!--- pull in the itemspecifics for this item --->
<cfquery name="getItemSpecifics" datasource="#request.dsn#">
	Select *
	FROM auction_itemspecifics
	WHERE 1=1
	<!--- if category id is 0 --->
	<cfif attributes.categoryid neq 0>
		and itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	<cfelse>
		and itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
	</cfif>
</cfquery>

<cfif getItemSpecifics.recordcount gte 1>

<cfloop query="getItemSpecifics">
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>#getItemSpecifics.iname#:</b></td>
			<td>
				<cfif getItemSpecifics.selection_mode is "freetext">
					Enter your Own:
					<input type="text" name="#rereplace(getItemSpecifics.iname,'[^A-Za-z0-9]','','all')#" value="#getItemSpecifics.ivalue#" >
					<input type="hidden" name="itemspecifics_#getItemSpecifics.iname#" value="#getItemSpecifics.ivalue#">
				<cfelse>
					<input type="hidden" name="itemspecifics_#getItemSpecifics.iname#" value="#getItemSpecifics.ivalue#">
					<input type="hidden" name="#rereplace(getItemSpecifics.iname,'[^A-Za-z0-9]','','all')#" value="#getItemSpecifics.ivalue#" >
				</cfif>
				<input type="hidden" name="mode_#rereplace(getItemSpecifics.iname,'[^A-Za-z0-9]','','all')#"	value="#getItemSpecifics.selection_mode#">

			</td>
		</tr>
</cfloop>


<cfelse><!--- no auction_itemspecifics records lets do api calll --->
<!---GetCategorySpecifics  starts--->
<cfset _ebay.CallName ="GetCategorySpecifics">
<cfset _ebay.XMLRequest = '<?xml version="1.0" encoding="utf-8"?>
<#_ebay.CallName#Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#_ebay.RequestToken#</eBayAuthToken>
	</RequesterCredentials>

	<WarningLevel>High</WarningLevel>
  <CategorySpecific>
    <CategoryID>#attributes.categoryid#</CategoryID>
  </CategorySpecific>
  <IncludeConfidence>true</IncludeConfidence>
  <MaxValuesPerName>50</MaxValuesPerName>
  <MaxNames>50</MaxNames>
</#_ebay.CallName#Request>'>
<cfset _ebay.ThrowOnError = false>
<cfinclude template="../../api/act_call.cfm">
<!---GetCategorySpecifics  ENDS--->

<!---<cfdump var="#_ebay.xmlResponse#">--->
<cfif isDefined("_ebay.xmlResponse") AND (_ebay.Ack EQ "Success")>
	<cfif isdefined("_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation")>
			<cfloop index="i" from="1" to="#ArrayLen(_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation)#">
				<cfset iName = "#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].Name.XmlText#" >
				<cfset vRulesMaxValues = "#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].ValidationRules.MaxValues.XmlText#" >
				<cfset vRulesSelMode = "#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].ValidationRules.SelectionMode.XmlText#" >
				<cfset HelpURL = "">
				<cftry>
				<cfset HelpURL = "#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].HelpURL.XmlText#">
				<cfcatch></cfcatch>
				</cftry>

				<cfset countVrecom = 0>
				<cftry>
					<cfset countVrecom = "#ArrayLen(_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].ValueRecommendation)#">
				<cfcatch>
					<cfset countVrecom = 0>
				</cfcatch>
				</cftry>

				<tr bgcolor="##F0F1F3">
					<td valign="middle" align="right"><b>#iName#:</b></td>
					<td>
					<select name="itemspecifics_#iName#" <cfif vRulesSelMode is "prefilled">onfocus="this.defaultIndex=this.selectedIndex;" onchange="this.selectedIndex=this.defaultIndex;"</cfif> >
						<option value=""></option>
						<cfloop index="vc" from="1" to="#countVrecom#">
							<option values="#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].ValueRecommendation[vc].Value.XmlText#">
								#_ebay.xmlResponse.GetCategorySpecificsResponse.Recommendations.NameRecommendation[i].ValueRecommendation[vc].Value.XmlText#
							</option>
						</cfloop>
					</select>

					<!--- selection mode for editing item specifics offline ---><!---remove the special characters --->
					<input type="hidden" name="mode_#rereplace(iname,'[^A-Za-z0-9]','','all')#"	value="#vRulesSelMode#">
					<!--- selection mode to allow text input--->
					<cfif vRulesSelMode is "freetext">
						Enter your own:<input type="text" name="#rereplace(iname,'[^A-Za-z0-9]','','all')#"	value="" style=" border:1px solid ##666699;padding: 5px;" >
					<cfelse>
						<!--- this should have no value coz its not freetext --->
						<input type="hidden" name="#rereplace(iname,'[^A-Za-z0-9]','','all')#" value="" >
					</cfif>
					<cfif HelpURL neq ""><a href="#HelpURL#" target="_blank">Help</a></cfif>
					</td>
				<td>&nbsp;</td>
				</tr>

			</cfloop>

	<cfelse>
		<tr bgcolor="##F0F1F3" >
			<td valign="middle" align="center" colspan="2">No Item Specifics Found!</td>
		</tr>
	</cfif>

</cfif>




</cfif>



		</table>
	</td></tr>
	</table>
	<br>
	<!---<center><input type="submit" value="Create Item"></center>--->
		<center><input type="submit" value="Create Item"></center>
		
		
		<input type="hidden" name="shipNotes" value="#attributes.shipNotes#"> 
		<input type="hidden" name="redirectLocation" value="#attributes.redirectLocation#">
		<input type="hidden" name="autoSubmit" id="autoSubmit" value="#attributes.autoSubmit#" >
		<input type="hidden" name="orig_item" value="#attributes.orig_item#">		
	<br>
	</form>
</td></tr>
</table>
<script language="javascript" type="text/javascript">
<!--//
fSum();
//-->
</script>

<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
<script src="layouts/default/jquery.validate.js" language="javascript" type="text/javascript"></script>

<style type="text/css">
* { font-family: Verdana; font-size: 96%; }
label { width: 10em; float: left; }
label.error { float: none; color: red; padding-left: .5em; vertical-align: top; }
/*p { clear: both; }*/
.submit { margin-left: 12em; }
em { font-weight: bold; padding-right: 1em; vertical-align: top; }
</style>

 <script>
  $(document).ready(function(){
			    $("##form1").validate({
				    rules:{
				    	itemSKU: "required",
				    	itemCondition: "required",
				    	weight: {
				    		required: true,
				    		number:true
							//,integer:true
				    	},
				    	purchase_price : {
				    		required: true,
				    		number:true,
				    		integer:true
				    	},
				    	mpnBrand: "required",
				    	mpnNum: "required",
				    	upc : {
				    		upc_Check: true
				    	},
				    	lid :{
				    		required: true
				    	}
				    },
				    messages: {
				        itemSKU: "<span style='font-size:10px;'>Please Enter SKU</span>",
				        itemCondition: "<span style='font-size:10px;'>Please Select Item Condition</span>",
				        weight: {
				        	required: "<span style='font-size:10px;'>Please Enter Weight</span>",
				        	number: "<span style='font-size:10px;'>Please Enter Number</span>"
				        	//,integer: "<span style='font-size:10px;'>Please Enter value greater than zero!</span>"
				        },
				        purchase_price : {
				        	required: "<span style='font-size:10px;'>Please Enter Purchase Price</span>",
				        	number: "<span style='font-size:10px;'>Please Enter Number</span>",
				        	integer: "<span style='font-size:10px;'>Please Enter value greater than zero!</span>"
				        },
				        mpnBrand: "<span style='font-size:10px;'>Please Enter MPN Brand</span>",
				        mpnNum: "<span style='font-size:10px;'>Please Enter MPN Number</span>",
				        upc: "<span style='font-size:10px;'>needs to be 12 or 13 numbers or the words 'Does Not Apply'.  Anything else should be illegal and error.</span>",
				        lid: "<span style='font-size:10px;'>Value Required</span>"
				    }
					});

		         $.validator.addMethod('integer', function(value, element, param) {
		             return (value != 0);
		         }, 'Please enter a non zero integer value!');
	         
				$.validator.addMethod("upc_Check", function(value, element, param) { 
					
					var LengthVal = value.length;
					//length 12 to 13
					if(LengthVal > 11 && LengthVal < 15){
						//does not apply check
						if(value.toLowerCase() == "does not apply"){
							return true;
						}	
						
					    var intRegex = /^\d+$/;
					    if(intRegex.test(value)) {
					        return true;
					    }
					}

					return false;
					
						
				 // return this.optional(element) || value === param; 
				}, "needs to be 12 or 13 numbers or the words 'Does Not Apply'.  Anything else should be illegal and error.");	         
	         
			$('##ctrl_subItemDescription').change(function(){
				var txt = $("textarea##sub_description");	
							
				txt.val(  $(this).val() );	
				
			});
			
			$('##itemCondition').change(function(){
				var itemCondition = $(this).val();				
				
				
	            $.ajax({
	                url: "cfc/ajax.cfc?method=getSubdescriptions&returnformat=json",
	                dataType: "text",
	                cache: false,
	                data:{
	                	parentCondition: itemCondition
	                	},
	                success: function (data) {
	                	var json = $.parseJSON(data);
	                	
	                	var options = '<option value="">Select Sub Description</option>'
	                	+ '<optgroup label="' + itemCondition + '">';
	                	
						for(var i=0; i < json.length; i++)
					     {
							//console.log(json[i].subdescription_category);
							//lets recreate the ctrl_subItemDescription
							options += '<option value="' + json[i].subdescription_text + '">' + json[i].subdescription_name + '</option>';
					     }	
					    options += '</optgroup>';                 	
	                	$("select##ctrl_subItemDescription").html(options);
     						                       
	                }
	            })
            				
			});//itemCondition	change	


			// JavaScript using jQuery
		
		    $('##ship_dimension_name').change(function(){
		       var selected = $(this).find('option:selected');
		       var width = selected.data('width'); 
		       var length = selected.data('length');
		       var heigth = selected.data('height');
		       
		       $('##height_dimension').val(heigth);
		       $('##width_dimension').val(width);
		       $('##depth_dimension').val(length);		      
		      
		    });
		
			
			var $autoSubmit = $('##autoSubmit').val();
			if($autoSubmit == "true"){		
				$('##form1').submit();
			}	         
  });
  

  </script>
</cfoutput>
