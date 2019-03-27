<!---<cf_accelerate>--->
<cfprocessingdirective
    pageEncoding = "utf-8"
    suppressWhiteSpace = "yes">
<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfset startTime = getTickCount() />
<cfparam name="attributes.item">
<cfparam name="attributes.val_itemisTemplate" default="0">
<cfquery name="sqlItem" datasource="#request.dsn#" >
	SELECT top 1 i.commission, i.startprice, i.invoicenum, i.weight, i.title, i.description, i.make,i.model,
		i.model2, i.value AS value1, i.age, i.status AS statusid, i.ebayitem, i.shipper,
		i.tracking, a.email, a.first, a.last, c.name AS category, i.aid, a.store, i.item,
		e.title AS ebtitle, i.dcreated, i.listcount, e.dtstart, e.dtend, e.price,
		e.hbuserid, e.hbfeedbackscore, e.hbemail, i.paid, i.offebay, i.shipped, e.galleryurl,
		s.status AS curStatus, i.bold, i.border, i.highlight, i.vehicle, i.lid, i.dlid,
		u.ready, i.drefund, i.startprice_real, i.buy_it_now, i.dpictured, i.purchase_price, i.label_printed, a.invested,
		i.width, i.height, i.depth, i.shipnote, i.weight_oz, i.internal_itemSKU,i.internal_itemSKU2, i.internal_itemCondition, i.itemManual, i.itemComplete, i.itemTested, i.retailPackingIncluded,
		i.specialNotes, i.internalShipToLocations, i.shipcharge, i.byrOrderQtyToShip, i.status, i.byrCompanyName,i.itemis_template
		<!--- for combined starts--->
		,i.exception,i.ShippedTime,i.PaidTime, i.ebayTxnid, i.upc,i.customer_returned,
		i.mpnNum, i.mpnBrand, i.sub_description, i.ship_dimension_name, i.dummy, i.bonanza_bidder
		,isbn
		<!--- for combined starts ENDS--->
	FROM items i
		INNER JOIN accounts a ON a.id = i.aid
		INNER JOIN categories c ON c.id = i.cid
		LEFT JOIN ebitems e ON e.ebayitem = i.ebayitem
		LEFT JOIN status s ON i.status = s.id
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
</cfquery>

<cfif sqlItem.itemis_template is "1">
	<cfset attributes.val_itemisTemplate = 1>
<cfelse>
	<cfset attributes.val_itemisTemplate = 0>
</cfif>



<!--- for getting combined --->
<!---
i.exception = 0
AND i.paid = '1'
AND i.shipped = '0'
AND i.ShippedTime IS NULL
AND i.drefund IS NULL
AND i.PaidTime IS NOT NULL
--->


<!---<cfquery name="sqlStatusHistory" datasource="#request.dsn#" maxrows="1">
	SELECT new_status, DATEADD(SECOND, [timestamp] + DATEDIFF(SECOND, GETUTCDATE(), GETDATE()), '01/01/1970') AS dstatus_changed
	FROM status_history
	WHERE iid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	ORDER BY 2 DESC
</cfquery>--->

<cfquery name="sqlHistory" datasource="#request.dsn#">
	SELECT ebayitem FROM ebitems
	WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		AND ebayitem != '#sqlItem.ebayitem#'
</cfquery>

<cfquery name="sqlSalesHistory" datasource="#request.dsn#">
	SELECT tid,AmountPaid,AdjustmentAmount,byrName,byrStreet1,byrStreet2,byrCityName,byrStateOrProvince,byrCountry,byrCountryName,byrPhone,byrPostalCode,byrAddressID,byrAddressOwner,byrAddressStatus,byrExternalAddressID,byrCompanyName,byrAddressRecordType,shdShipmentTrackingNumber,shdShippingServiceUsed,CreatedDate,itmItemID,itmStartTime,itmEndTime,itmTitle,stseBayPaymentStatus,stsCheckoutStatus,stsLastTimeModified,stsPaymentMethodUsed,stsCompleteStatus,stsBuyerSelectedShipping,TransactionID,TransactionPrice,BestOfferSale,extExternalTransactionID,extExternalTransactionTime,extFeeOrCreditAmount,extPaymentOrRefundAmount,PaidTime,ShippedTime,itmQuantitySold,itmSKU,salesRecord,listingtype
	from ebtransactions
	WHERE itmitemid = '#sqlItem.ebayitem#'
	and shippedtime != '' and
	stsCompleteStatus ='Complete'
	order by tid desc
</cfquery>

<cfquery name="getSalesRecord" datasource="#request.dsn#">
	SELECT salesRecord
	from ebtransactions
	WHERE TransactionID = '#sqlItem.ebayTxnid#'
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


<cfset c = Val(sqlHistory.RecordCount)>
<cfif Val(sqlItem.ebayitem) GT 0>
	<cfset c = c + 1>
</cfif>
<cfif c NEQ sqlItem.listcount>
	<cfset sqlItem.listcount = c>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET listcount = <cfqueryparam cfsqltype="cf_sql_integer" value="#c#">
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
	</cfquery>
</cfif>
<cfoutput>
	
<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>

<script type="text/javascript" >
	$(function(){
		
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
			
	})
	
	
</script>
	
<script language="javascript" type="text/javascript">
<!--//
function fStatusHistory(ItemID){
	statusWin = window.open("index.cfm?dsp=management.items.status_history&item="+ItemID, "statusWin", "height=600,width=520,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes");
	statusWin.opener = self;
	statusWin.focus();
}
function fLocationHistory(ItemID){
	locationWin = window.open("index.cfm?dsp=management.items.location_history&item="+ItemID, "locationWin", "height=600,width=520,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes");
	locationWin.opener = self;
	locationWin.focus();
}
function fCheck(formObj){
	if(formObj.offebay.checked){
		confirm("Marking this 'Sold off eBay' is very dangerous and could cause major errors. Are you sure you would like to mark this item?");
	}
}
function fCharsLeft(objID, val, maxChars){
	document.getElementById(objID).innerHTML = "(" + (maxChars-val.length) + " chars left)";
}

var total = 0;
function fSum(){
	var res = document.all.startprice;
	if(typeof document.all.vehicle !== "undefined" && !document.all.vehicle.checked){
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
		if(typeof document.all.bold !== "undefined" && document.all.bold.checked) total += 1.25;
		if(typeof document.all.border !== "undefined" && document.all.border.checked) total += 3.75;
		if(typeof document.all.highlight !== "undefined" && document.all.highlight.checked) total += 6.25;
		var obj = document.all.suma;
		obj.value = "$" + total;

	}else{
		total = 99;
		if(typeof document.all.bold !== "undefined" && document.all.bold.checked) total += 1.25;
		if(typeof document.all.border !== "undefined" && document.all.border.checked) total += 3.75;
		if(typeof document.all.highlight !== "undefined" && document.all.highlight.checked) total += 6.25;
		var obj = document.all.suma;
		obj.value = "$" + total;
	}
}
function fShipNote(itemid){
	ShipNoteWin = window.open("index.cfm?dsp=admin.ship.note&itemid="+itemid, "ShipNoteWin", "height=300,width=600,location=no,scrollbar=yes,menubar=yes,toolbars=yes,resizable=yes");
	ShipNoteWin.opener = self;
	ShipNoteWin.focus();
}
//-->
</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Item Management:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>
	<h3>

	</h3>
	<cfif isDefined("attributes.msg")>
		<cfswitch expression="#attributes.msg#">
			<cfcase value="1"><cfoutput><font color=red><b>Item changed sucessfully!</b><br><br></font></cfoutput></cfcase>
			<cfcase value="2"><cfoutput><font color=red><b>Please enter the eBay Item Number first!</b></font><br><br></cfoutput></cfcase>
		</cfswitch>
	</cfif>

<table width=100%><tr><td>

<cfif isAllowed("Items_ChangeStatus") OR (isAllowed("Items_NormalChangeStatus") AND ListFind("2,3,9,12", sqlItem.statusid))>
	<!--- Change Status --->
	<form method="POST" action="index.cfm?act=management.items.change_status">
	<input type="hidden" name="item" value="#sqlItem.item#">
	<input type="hidden" name="ebayitem" value="#sqlItem.ebayitem#">
	<b>Change Item Status: </b>
	<select name="newstatusid">
	<cfquery name="sqlStatus" datasource="#request.dsn#">
		SELECT id, status FROM status ORDER BY id ASC
	</cfquery>
	

	
	<cfloop query="sqlStatus">
		<cfif isAllowed("Items_ChangeStatus") OR ListFind("2,3,9,12", sqlStatus.id)>
			<option value="#sqlStatus.id#"<cfif sqlStatus.id EQ sqlItem.statusid> selected</cfif>>#sqlStatus.status#</option>
		</cfif>
	</cfloop>
	</select>
	<input type="submit" value="Change Status">
	</form>
</cfif>

	<!---Item Owner --->
	<br><br><b>Item Owner:</b> <a href="index.cfm?dsp=account.edit&id=#sqlItem.aid#">#sqlItem.first# #sqlItem.last#</a>
	<a href="mailto:#sqlItem.email#?subject=Instant Auctions: Item #sqlItem.item#"><img src="#request.images_path#icon5.gif" align="middle" border=0></a><br><br>
	<input type="button" value="Print Label" onClick="javascript:document.getElementById('label_printed').value = '1';document.getElementById('updateStatus').submit();nw=window.open('index.cfm?dsp=management.items.itemslip&item=#sqlItem.item#','NewWin','height=250,width=355,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');nw.opener=self;return false;">
	<input type="button" value="Print Signing Sheet" onClick="javascript:nw=window.open('index.cfm?dsp=management.items.customerslip&item=#sqlItem.item#','NewWin','height=500,width=750,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes');nw.opener=self;return false;"><br><br>

	<cfif isAllowed("Items_AuctionFeeRecords")>
		<cfif (sqlItem.ebayitem NEQ "") OR (sqlItem.offebay EQ "1")>
			<b>Auction Record: </b><a href="index.cfm?dsp=management.records&item=#sqlItem.item#">View All Fees</a><br><br>
		<cfelse>
			<b>Auction Record Not Found: </b>Enter eBay Item Number<br><br>
		</cfif>
		<cfif sqlItem.invoicenum NEQ "">
			<b>Invoice: </b> <a href="/invoices/Invoice #sqlItem.store#.#sqlItem.aid#.#sqlItem.invoicenum#.htm" target="_blank">View Invoice</a><br><br>
		</cfif>
	</cfif>

	<cfif isAllowed("Items_ViewItemLogs")>
		<b>Item Log: </b> <a href="index.cfm?dsp=admin.logs&srch=#sqlItem.item#">View</a><br><br>
	</cfif>

	<cfif isAllowed("Items_ViewItemLogs")>
		<a href="index.cfm?dsp=management.items.templateList">Template List</a>
		<form action="index.cfm?act=management.items.itemis_template" name="TemplateForm" method="POST">
			Item is a Template:
			<label for="rdio_ItemTemplateYes">
				<input type="radio" name="rdio_ItemTemplate" id="rdio_ItemTemplateYes" value="1" <cfif attributes.val_itemisTemplate>checked</cfif> > Yes |
			</label>
			<label for="rdio_ItemTemplateNo">
				<input type="radio" name="rdio_ItemTemplate" id="rdio_ItemTemplateNo"  value="0" <cfif not attributes.val_itemisTemplate>checked</cfif> > No
			</label>
			<button type="submit">Save</button>
			<input type="hidden" name="item" value="#attributes.item#">
		</form><br><br>
	</cfif>

</td><td><cfif sqlItem.galleryurl NEQ ""><a href="#sqlItem.galleryurl#" target="_blank"><img src="#sqlItem.galleryurl#" width=150 border=1></cfif>
</td></tr></table>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<form  id="updateStatus" name="updateStatus"  method="POST" action="index.cfm?act=management.items.update" onSubmit="return fCheck(this)">
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Item Number:</b></td>
			<td width="70%" align="left"><b>#sqlItem.item#</b></td>
		</tr>
	<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><a href="JavaScript: fStatusHistory('#sqlItem.item#')"><b>Item Status:</b></a></td>
			<td width="70%" align="left"><!---<b>#sqlItem.curStatus#</b> <cfif sqlItem.statusid EQ sqlStatusHistory.new_status>(<i>#strDate(sqlStatusHistory.dstatus_changed)#</i>)</cfif>---></td><!--- vlad commented this out coz its slows the page. 20120504 --->
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><a href="JavaScript: fLocationHistory('#sqlItem.item#')"><b>Location ID:</b></a></td>
			<td width="70%" align="left"><cfif sqlItem.lid NEQ ""><b>#sqlItem.lid#</b> <i>(#DateFormat(sqlItem.dlid)# #TimeFormat(sqlItem.dlid)#)<cfelse>NONE</cfif></i></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right" >
				<a href="index.cfm?dsp=admin.auctions.upload_pictures&items=#attributes.item#" >
					<b>Pictured At:</b>
				</a>
			</td>
			<td width="70%" align="left">
				<cfif isDate(sqlItem.dpictured)>#strDate(sqlItem.dpictured)#<cfelse>N/A</cfif>
				 
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Created On:</b></td>
			<td width="70%" align="left">#DateFormat(sqlItem.dcreated)# #TimeFormat(sqlItem.dcreated)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Times Listed:</b></td>
			<td width="70%" align="left"><cfif (sqlItem.statusid LT 4) AND (sqlItem.ebayitem EQ "")>0<cfelse>#sqlItem.listcount#</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Category:</b></td>
			<td width="70%" align="left">#sqlItem.category#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>SKU:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="50" name="internal_itemSKU" value="#sqlItem.internal_itemSKU#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>SKU2:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="70" name="internal_itemSKU2" value="#sqlItem.internal_itemSKU2#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>UPC:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="70" name="upc" value="#sqlItem.upc#" style="font-size: 11px;"></td>
		</tr>
		<!---
		:vladedit: 20150731
		The combination of Brand and MPN required by ebay in some categories. listings will not push through for some category if MPN is no provided
		--->
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Brand:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="65" name="mpnBrand" value="#sqlItem.mpnbrand#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>MPN ##:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="65" name="mpnNum" value="#sqlItem.mpnNum#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Model:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="65" name="model2" value="#sqlItem.model2#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>ISBN:</b></td>
			<td width="70%" align="left"><input type="text" size="40" maxlength="65" name="isbn" 
			value="#sqlItem.isbn#" style="font-size: 11px;" placeholder="Books only"></td>
		</tr>		
	
		<!--- MPN ENDS --->
					
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Title:</b></td>
			<td width="70%" align="left"><input type="text" size="80" maxlength="80" name="title" value="#HTMLEditFormat(sqlItem.title)#" style="font-size: 11px;"<cfif NOT isAllowed("Items_EditDescriptions")> disabled</cfif>></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Internal Item Condition:</b></td>
			<td width="70%" align="left">
				<select name="itemCondition" id="itemCondition">
					<option value="">Select Item Condition</option>
					<option value="New" <cfif #lcase(sqlItem.internal_itemCondition)# eq "new">selected</cfif>>New</option>
					<!---<option value="Excellent" <cfif #lcase(sqlItem.internal_itemCondition)# eq "excellent">selected</cfif>>Excellent</option>--->
					<option value="Open Box" <cfif #lcase(sqlItem.internal_itemCondition)# eq "Open Box">selected</cfif>>Open Box</option>
					<!---
					<option value="GOOD" <cfif #lcase(sqlItem.internal_itemCondition)# eq "good">selected</cfif>>GOOD</option>
					<option value="FAIR" <cfif #lcase(sqlItem.internal_itemCondition)# eq "fair">selected</cfif>>FAIR</option>
					--->
					<option value="USED" <cfif #lcase(sqlItem.internal_itemCondition)# eq "used">selected</cfif>>USED</option>
					<option value="AS-IS"<cfif #lcase(sqlItem.internal_itemCondition)# eq "as-is">selected</cfif>>AS-IS</option>
					<option value="SELLER REFURBISHED" <cfif #lcase(sqlItem.internal_itemCondition)# is "seller refurbished">selected</cfif>>SELLER REFURBISHED</option>
					<option value="NEW WITHOUT TAGS" <cfif #lcase(sqlItem.internal_itemCondition)# is "new without tags">selected</cfif>>NEW WITHOUT TAGS</option>
					<option value="NEW WITH DEFECT" <cfif #lcase(sqlItem.internal_itemCondition)# is "new with defect">selected</cfif>>NEW WITH DEFECT</option>
					<option value="New With Box" <cfif #lcase(sqlItem.internal_itemCondition)# eq "new with box">selected</cfif>>New With Box</option>
					<option value="New With Tags" <cfif #lcase(sqlItem.internal_itemCondition)# eq "new with tags">selected</cfif>>New With Tags</option>
					<option value="New Without Box" <cfif #lcase(sqlItem.internal_itemCondition)# eq "new without box">selected</cfif>>New Without Box</option>
					<option value="Preowned" <cfif #lcase(sqlItem.internal_itemCondition)# eq "preowned">selected</cfif>>Preowned</option>
					<option value="Amazon" <cfif #lcase(sqlItem.internal_itemCondition)# eq "amazon">selected</cfif>>Amazon</option>
					<option value="Craiglist" <cfif #lcase(sqlItem.internal_itemCondition)# eq "Craiglist">selected</cfif>>Craiglist</option>
					<option value="Bonanza" <cfif #lcase(sqlItem.internal_itemCondition)# eq "Bonanza">selected</cfif>>Bonanza</option>
				</select>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Sub Description:</b></td>
			<td width="70%" align="left">
				<select name="ctrl_subItemDescription" id="ctrl_subItemDescription">
					<option value="">-- Select Sub Description --</option>
					<cfloop query="getSubdescriptionsCat" >
						<optgroup label="#getSubdescriptionsCat.subdescription_category#">							
							<cfloop query="getSubdescriptions">
		      					<cfif getSubdescriptionsCat.subdescription_category is getSubdescriptions.subdescription_category>
		      						
		      						<option value="#subdescription_text#">#subdescription_name#</option>
		      					</cfif>
							</cfloop>						
						</optgroup>
					</cfloop>
					
				</select>
				<br>
				<textarea name="sub_description" id="sub_description" rows="5" cols="40" style="font-size: 11px;"<cfif NOT isAllowed("Items_EditDescriptions")> disabled</cfif>>#sqlItem.sub_description#</textarea>
			<br><a href="index.cfm?dsp=management.items.subDescriptions.subDescriptionsList">Sub Description List</a>
		</td>
		</tr>		
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Retail Price:</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="20" name="age" value="#sqlItem.age#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Description:</b></td>
			<td width="70%" align="left"><textarea name="description" rows="5" cols="40" style="font-size: 11px;"<cfif NOT isAllowed("Items_EditDescriptions")> disabled</cfif>>#sqlItem.description#</textarea></td>
		</tr>
				
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Special Notes:</b></td>
			<td width="70%" align="left">
				<textarea name="specialNotes" rows="5" cols="40" style="font-size: 11px;"<cfif NOT isAllowed("Items_EditDescriptions")> disabled</cfif>
				onChange="fCharsLeft('dynaTitle', this.value, 999)" onKeyUp="fCharsLeft('dynaTitle', this.value, 999)">#sqlItem.specialNotes#</textarea>
			<br><div id="dynaTitle">(#999-Len(sqlItem.specialNotes)# chars left)</div>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Note:</b></td>
			<td width="70%" align="left"><cfif isAllowed("Listings_EditShippingNote")><a href="javascript: fShipNote('#sqlItem.item#')"><cfif sqlItem.shipnote EQ ""><img src="#request.images_path#icon14.gif" border=0><cfelse>Edit</cfif></a><cfelse><cfif sqlItem.shipnote EQ "">N/A<cfelse><a href="javascript: fShipNote('#sqlItem.item#')">View</a></cfif></cfif> #sqlItem.shipnote#</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Starting Price:</b></td>
			<td width="70%" align="left"><input type="text" size="10" maxlength="10" name="startprice_real" value="#sqlItem.startprice_real#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<!---<td valign="middle" align="right"><b>Reserve Price:</b></td>--->
			<td valign="middle" align="right"><b>LOW Price:</b></td>
			<td width="70%" align="left"><input type="text" size="10" maxlength="10" name="startprice" value="#sqlItem.startprice#" style="font-size: 11px;"<cfif NOT isAllowed("Items_EditDescriptions")> disabled</cfif> onBlur="fSum()"></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Buy It Now:</b></td>
			<td width="70%" align="left"><input type="text" size="10" maxlength="10" name="buy_it_now" value="#sqlItem.buy_it_now#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Weight (lbs):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="5" name="weight" value="#sqlItem.weight#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Weight (oz):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="5" name="weight_oz" value="#sqlItem.weight_oz#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Internal Ship To:</b></td>
			<td align="left">
				<select name="internalShipToLocations">
					#SelectOptions(sqlItem.internalShipToLocations, "WorldWide,Worldwide;US,USA;None,Pickup Only")#
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Dimensions:</b></td>
			<td>
				<select name="shippingDimensions" id="shippingDimensions">
					<option value="" selected="selected" >--Select--</option>
					<cfloop query="get_ShipDimensions">
						<option 
							value="#get_ShipDimensions.ship_dimensionid#"
							data-width="#get_ShipDimensions.ship_dimension_width#"
							data-length="#get_ShipDimensions.ship_dimension_length#"
							data-height="#get_ShipDimensions.ship_dimension_heigth#"
							<cfif sqlItem.ship_dimension_name is get_ShipDimensions.ship_dimension_name>selected</cfif>
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
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="width" value="#sqlItem.width#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Height (in):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="height" value="#sqlItem.height#" style="font-size: 11px;"></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Length (in):</b></td>
			<td width="70%" align="left"><input type="text" size="5" maxlength="3" name="depth" value="#sqlItem.depth#" style="font-size: 11px;"></td>
		</tr>

		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Customer Picked Up Item:</b></td>
			<td width="70%" align="left"><cfif NOT isAllowed("Items_ChangeStatus")><input type="hidden" name="returned" value="na">N/A<cfelse><input type="checkbox" name="returned" value="1"<cfif sqlItem.statusid EQ "9"><!--- Returned to Client ---> checked</cfif>></cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Dummy Item:</b></td>
			<td width="70%" align="left">
				<input type="checkbox" name="dummy" value="1" <cfif sqlItem.dummy is "1">checked</cfif>>
			</td>
		</tr>		
		
		
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Commission:</b></td>
			<td width="70%" align="left"><input style="font-size: 11px;" type="text" name="commission" size="5" maxlen="5" value="#sqlItem.commission#"<cfif NOT isAllowed("Items_EditCommission")> disabled</cfif>>%</td>
		</tr>
		<!--- hide/remove coz Patrick doesn't use it. 20101204
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Features:</b></td>
			<td width="70%" align="left">
				<input type="checkbox" name="bold" value="1" onClick="fSum()" <cfif sqlItem.bold EQ "1">checked</cfif>> Bold ($1.25)
				<input type="checkbox" name="border" value="1" onClick="fSum()" <cfif sqlItem.border EQ "1">checked</cfif>> Border ($3.75)
				<input type="checkbox" name="highlight" value="1" onClick="fSum()" <cfif sqlItem.highlight EQ "1">checked</cfif>> Highlight ($6.25)
			</td>
		</tr>
		--->
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Total:</b></td>
			<td width="70%" align="left">
				<!---<input type="checkbox" name="vehicle" value="1" onClick="fSum()" <cfif sqlItem.vehicle EQ "1">checked</cfif>> Vehicle ($99)--->
				<br><input type="text" size="5" name="suma" value="$0" disabled>
				<script language="javascript" type="text/javascript">
				<!--//
				fSum();
				//-->
				</script>
			</td>
		</tr>

<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Manual Included:</b></td>
		<td>
				<select name="itemManual">
					<option value="0" <cfif sqlItem.itemManual eq 0 or sqlItem.itemManual eq "">selected</cfif>>No</option>
					<option value="1" <cfif sqlItem.itemManual eq 1>selected</cfif>>Yes</option>
				</select>
		</td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Item is Complete:</b></td>
		<td>
			<select name="itemComplete">
				<option value="0" <cfif sqlItem.itemComplete eq 0>selected</cfif>>No</option>
				<option value="1" <cfif sqlItem.itemComplete eq 1 or sqlItem.itemManual eq "">selected</cfif>>Yes</option>
			</select>
		</td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Item tested:</b></td>
		<td>
			<select name="itemTested">
				<option value="0" <cfif sqlItem.itemTested eq 0>selected</cfif>>No</option>
				<option value="1" <cfif sqlItem.itemTested eq 1 or sqlItem.itemManual eq "">selected</cfif>>Yes</option>
			</select>
		<td>

		</td></tr>
		<tr bgcolor="##F0F1F3"><td valign="middle" align="right"><b>Retail Packing Included:</b></td>
		<td>
			<select name="retailPackingIncluded">
				<option value="0" <cfif sqlItem.retailPackingIncluded eq 0>selected</cfif>>No</option>
				<option value="1" <cfif sqlItem.retailPackingIncluded eq 1 or sqlItem.itemManual eq "">selected</cfif>>Yes</option>
			</select>
		</td></tr>


		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Sold off eBay:</b></td>
			<td width="70%" align="left"><input type="checkbox" name="offebay" value="1"<cfif sqlItem.offebay EQ "1" or sqlItem.offebay EQ "2"> checked</cfif>></td>
		</tr>
<cfif sqlItem.offebay EQ "1">
<cfquery name="getAmazonOrderId" datasource="#request.dsn#">
	select amazon_item_amazonorderid
	from amazon_items
	where items_itemid = '#attributes.item#'
</cfquery>
		<tr bgcolor="##E2A7A7">
			<td valign="middle" align="right"><b>Amazon OrderID:</b></td>
			<td width="70%" align="left"><cfif getAmazonOrderId.RecordCount gte 1>#getAmazonOrderId.amazon_item_amazonorderid#<cfelse>Not Found</cfif></td>
		</tr>
		<tr bgcolor="##E2A7A7">
			<td valign="middle" align="right"><b>Buyer Company:</b></td>
			<td width="70%" align="left">#sqlItem.byrCompanyName#</td>
		</tr>
</cfif>
		<cfif sqlItem.offebay EQ "1">
			<cfquery datasource="#request.dsn#" name="sqlRecord">
				SELECT finalprice, dended
				FROM records
				WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
			</cfquery>
			<tr bgcolor="##FFFFFF">
				<td valign="middle" align="right"><b>End Time:</b></td>
				<td width="70%" align="left"><input type="text" name="dended" value="#sqlRecord.dended#"></td>
			</tr>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Final Price:</b></td>
				<td width="70%" align="left"><input type="text" name="price" value="#DollarFormat(sqlRecord.finalprice)#"></td>
			</tr>
		</cfif>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Purchase Price:</b></td>
			<td width="70%" align="left">#DollarFormat(sqlItem.purchase_price)#</td>
		</tr>

	<!--- lets display profit if item is sold in ebay --->
	<cfif sqlItem.ebayitem NEQ "">
		<cfquery name="sqlTransact" datasource="#request.dsn#" maxrows="1">
			SELECT AmountPaid FROM ebtransactions
			WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlItem.ebayitem#">
			ORDER BY tid DESC
		</cfquery>
		<cfquery datasource="#request.dsn#" name="sqlRecord">
			SELECT finalprice, dended
			FROM records
			WHERE itemid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.item#">
		</cfquery>


			<cftry>

				<!--- lets display profit but watch out for combined--->
				<cfif sqlItem.exception eq 0 and
				sqlItem.paid eq '1' and
				<!---sqlItem.shipped eq '0' and--->
				isdate(sqlItem.ShippedTime) and
				sqlItem.drefund is "" and
				isdate(sqlItem.PaidTime) and
				sqlItem.status eq '11' and
				round(sqlTransact.AmountPaid) gt round(sqlRecord.finalprice) <!--- free shipping should not be combined --->
				>

					<tr bgcolor="##F0F1F3">
						<td valign="middle" align="right"><b>Profit:</b></td>
						<td width="70%" align="left">#DollarFormat(sqlRecord.finalprice-sqlItem.purchase_price)# (note this item is combined or shipping fee paid)


						 <!---#sqlTransact.AmountPaid# - #sqlItem.shipcharge# - #sqlItem.purchase_price#---></td>
					</tr>
				<cfelse>
					<tr bgcolor="##F0F1F3">
						<td valign="middle" align="right"><b>Profit:</b></td>
						<td width="70%" align="left">#DollarFormat(sqlTransact.AmountPaid - (sqlItem.shipcharge+sqlItem.purchase_price))# <!---#sqlTransact.AmountPaid# - #sqlItem.shipcharge# - #sqlItem.purchase_price#---></td>
					</tr>
				</cfif>

	        <cfcatch type="Any" >

	        </cfcatch>
	        </cftry>



<!---
i.exception = 0
AND i.paid = '1'
AND i.shipped = '0'
AND i.ShippedTime IS NULL
AND i.drefund IS NULL
AND i.PaidTime IS NOT NULL
--->
	</cfif><!--- sqlItem.ebayitem NEQ ""> --->

	<!--- lets display profit if item is sold off ebay --->
	<cfif sqlItem.offebay is 1 and sqlItem.status eq '11'><!--- '11'PAID AND SHIPPED --->
		<!--- lets display profit --->
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Profit:</b></td>
			<td width="70%" align="left">
				<cftry>
	          	#DollarFormat(sqlRecord.finalprice - (sqlItem.purchase_price+sqlItem.shipcharge))# <!---#sqlTransact.AmountPaid# - #sqlItem.shipcharge# - #sqlItem.purchase_price#--->
	             <cfcatch type="Any" >
				 	 <span style="color:red"></span>Error in generating profit
	             </cfcatch>
	             </cftry>
			</td>
		</tr>
	</cfif>


		<!---20100806 vlad adds this --->
		<tr bgcolor="##ffffff">
		<td valign="middle" align="right"><b>Label Printed:</b></td>
		<td>
			<select name="label_printed" id="label_printed">
				<option value="0" <cfif sqlItem.label_printed eq 0>selected</cfif>>No</option>
				<option value="1" <cfif sqlItem.label_printed eq 1>selected</cfif>>Yes</option>
			</select>
		</td>
		<tr bgcolor="##F0F1F3">
		<td valign="middle" align="right"><b>Customer Returned item:</b></td>
		<td>
			<select name="customer_returned" id="customer_returned">
				<option value="0" <cfif sqlItem.customer_returned eq 0>selected</cfif>>No</option>
				<option value="1" <cfif sqlItem.customer_returned eq 1>selected</cfif>>Yes</option>
			</select>
		</td>
		</tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<br>
<input type="hidden" name="item" value="#sqlItem.item#">
<center>
<input type="submit" value="Save Changes">
</form>
<cfif isAllowed("Items_Delete")>
<form method="POST" action="index.cfm?act=management.items.delete">
<input type="hidden" name="item" value="#sqlItem.item#">
<input type="submit" value="Delete Item" onClick="return confirm('Are you SURE you wish to delete Item #sqlItem.item# from the database?');">
</form>
</cfif>
</center>
<br>

<form method="POST" action="index.cfm?dsp=management.items.create">
<input type="hidden" name="item" value="#sqlItem.item#">
<input type="hidden" name="accountid" value="#sqlItem.aid#">
<input type="hidden" name="title" value="#HTMLEditFormat(sqlItem.title)#">
<input type="hidden" name="age" value="#sqlItem.age#">
<input type="hidden" name="description" value="#HTMLEditFormat(sqlItem.description)#">
<input type="hidden" name="specialNotes" value="#HTMLEditFormat(sqlItem.specialNotes)#">
<input type="hidden" name="startprice" value="#sqlItem.startprice#">
<input type="hidden" name="weight" value="#sqlItem.weight#">
<input type="hidden" name="weight_oz" value="#sqlItem.weight_oz#">
<input type="hidden" name="width" value="#sqlItem.width#">
<input type="hidden" name="height" value="#sqlItem.height#">
<input type="hidden" name="depth" value="#sqlItem.depth#">
<input type="hidden" name="label_printed" value="#sqlItem.label_printed#">
<input type="hidden" name="upc" value="#sqlItem.upc#">
<cfif sqlItem.invested GT 0>
	<input type="hidden" name="startprice_real" value="#sqlItem.startprice_real#">
	<input type="hidden" name="buy_it_now" value="#sqlItem.buy_it_now#">
	<input type="hidden" name="commission" value="#sqlItem.commission#">
	<input type="hidden" name="purchase_price" value="#sqlItem.purchase_price#">
	<input type="hidden" name="bold" value="#sqlItem.bold#">
	<input type="hidden" name="border" value="#sqlItem.border#">
	<input type="hidden" name="highlight" value="#sqlItem.highlight#">
	<input type="hidden" name="vehicle" value="#sqlItem.vehicle#">
</cfif>


<!---<center><input type="submit" value="Create Similar Item"></center>--->
<center><input type="button" value="Create Similar Item" onclick="location.href='index.cfm?dsp=management.items.copy&item=#attributes.item#'"></center>
</form><br>
</cfoutput>

<!--- EBAY DATA --->
<cfif isAllowed("Items_EditEBayData")>
<cfoutput>
<center>
<table bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0" width="100%">
<tr><td>
	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
</cfoutput>
<cfif sqlHistory.RecordCount GT 0>
<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right" ><b>eBay History:</b></td>
			<td width="70%"  align="left" >
				<cfset histcount = 1>
				<cfloop query="sqlHistory">
					<a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlHistory.ebayitem#" target="_blank">#sqlHistory.ebayitem#</a>&nbsp;
					<cfif not histcount mod 5><br></cfif>
					<cfset histcount++>
				</cfloop>

			</td>
		</tr>
</cfoutput>
<!--- 20111208 display fixedprice Sales History --->
<cfoutput>
	<cfif sqlSalesHistory.recordcount gte 1>
			<cfif sqlSalesHistory.listingtype is "FixedPriceItem">
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Sales History:</b></td>
				<td width="70%" align="left">
					<cfloop query="sqlSalesHistory">
					<a href="index.cfm?dsp=management.items.salesedit&tid=#sqlSalesHistory.tid#">#sqlSalesHistory.salesRecord#</a>
					</cfloop>
				</td>
			</tr>
			</cfif>
	</cfif>
</cfoutput>
<!--- display fixedprice Sales History --->
</cfif>
<cfoutput>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>eBay Item Number:</b></td>
			<td width="70%" align="left">
			<cfif sqlItem.ebayitem NEQ "">
				<table>
				<tr>
				<td><a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#" target="_blank">#sqlItem.ebayitem#</a></td>
				<form method="POST" action="index.cfm?act=management.items.delete_ebay">
				<td>
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Delete" class="button">
				</td>
				</form>
				<td width="50" align="right"><a href="index.cfm?act=admin.api.second_chance&ebayitem=#sqlItem.ebayitem#"><img alt="Second Chance" src="#request.images_path#icon15.gif" border="0"></a></td>
				<cfif (sqlItem.statusid NEQ "4") AND (sqlItem.ready EQ 1) AND isAllowed("Lister_ListAuction")><!--- Auction Listed --->
					<td width="30" align="right"><a href="index.cfm?dsp=admin.auctions.relist_item&item=#sqlItem.item#"><img alt="Relist Item" src="#request.images_path#icon8.gif" border="0"></a></td>
				</cfif>
				<cfif ListFindNoCase('5,7,10,11',sqlItem.statusid) AND isAllowed("Other_disputes")>
					<td>
						<a href="index.cfm?act=api.disputes.add_step1&eb_ID=#sqlItem.ebayitem#"><img alt="Create Dispute" src="#request.images_path#icon10.gif" border="0"></a>
					</td>
				</cfif>
				<cfif isAllowed("Other_MyMessages")>
					<td><a href="index.cfm?dsp=api.mymessages.send_invoice&item=#sqlItem.ebayitem#">Send Invoice</a></td>
				</cfif>
				</tr>
				</table>
			<cfelse>
				<form method="POST" action="index.cfm?act=management.items.add_ebay">
					<input style="font-size: 11px;" type="text" name="ebayitem" size="20" maxlength="80">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Save" class="button">
				</form>
			</cfif>

		<cfif isAllowed("Lister_ListAuction")>
			<cfif sqlItem.statusid EQ "3"><!--- Item Received --->
				<br>
				<cfif sqlItem.ready NEQ "">
					<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlItem.item#">Edit Auction</a>
					| <a href="index.cfm?dsp=admin.auctions.preview&item=#sqlItem.item#" target="_blank">Preview Auction</a>
					| <a href="index.cfm?act=admin.auctions.delete&item=#sqlItem.item#" onClick="return confirm('Deleted auction can never be restored. Are you sure you want to delete this auction?')">Delete Auction</a>
				<cfelse>
					<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlItem.item#">Create Auction</a>
				</cfif>
			<cfelse>
				<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlItem.item#">Edit Auction</a>
				<!--- display delete button for paid and shipped 20130130 --->
				<cfif sqlItem.status is "11">
					<a href="index.cfm?act=admin.auctions.delete&item=#sqlItem.item#" onClick="return confirm('Deleted auction can never be restored. Are you sure you want to delete this auction?')">Delete Auction</a>
				</cfif>
			</cfif>
			<cfif (sqlItem.statusid NEQ "4") AND (sqlItem.ready EQ 1) AND (sqlItem.ebayitem EQ "")><!--- Auction Listed --->
				| <a href="index.cfm?dsp=admin.auctions.relist_item&item=#sqlItem.item#"><img alt="Relist Item" src="#request.images_path#icon8.gif" border="0"></a>
			</cfif>
			<cfif (sqlItem.statusid EQ "4")><!--- Auction Listed --->
				| <a href="index.cfm?dsp=admin.auctions.end_item&item=#sqlItem.item#">End Auction</a>
			</cfif>
		</cfif>
			</td>
		</tr>
</cfoutput>
	<cfset HasNoTransactions = true>
	<cfif sqlItem.ebayitem NEQ "">
		<cfquery name="sqlTransaction" datasource="#request.dsn#" maxrows="1">
<!---			SELECT * FROM ebtransactions
			WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlItem.ebayitem#">
			ORDER BY tid DESC--->
			SELECT *
<!---				itmTitle,

				itmStartTime,
				itmEndTime,
				byrName,
				byrCityName,
				byrStateOrProvince,
				TransactionID,
				AmountPaid,
				PaidTime,
				stsPaymentMethodUsed,
				extExternalTransactionID,
				ShippedTime,
				STSCHECKOUTSTATUS,
				STSCOMPLETESTATUS--->
			FROM ebtransactions
			WHERE itmItemID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#sqlItem.ebayitem#">
			ORDER BY tid DESC
		</cfquery>
		<cfif sqlTransaction.RecordCount GT 0>
			<cfset HasNoTransactions = false>
		</cfif>
	</cfif>
	<cfif HasNoTransactions>
		<cfoutput>

		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>eBay Title:</b></td>
			<td width="70%" align="left">#sqlItem.ebtitle#<cfif sqlItem.drefund NEQ "">(Refunded: #sqlItem.drefund#)</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Start Time:</b></td>
			<td width="70%" align="left">#strDate(sqlItem.dtstart)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>End Time:</b></td>
			<td width="70%" align="left"><cfif sqlItem.offebay EQ "1">#strDate(sqlRecord.dended)#<cfelse>#strDate(sqlItem.dtend)#</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Final Price:</b></td>
			<td width="70%" align="left"><cfif sqlItem.offebay EQ "1">#DollarFormat(sqlRecord.finalprice)#<cfelse>#DollarFormat(sqlItem.price)#</cfif></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Shipping Price:</b></td>
			<td width="70%" align="left"><cfif isnumeric(sqlItem.shipcharge)> #dollarformat(sqlItem.shipcharge)#</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>High Bidder:</b></td>
			<td width="70%" align="left"><cfif sqlItem.hbuserid EQ "">N/A<cfelse><a href="http://contact.ebay.com/ws/eBayISAPI.dll?ReturnUserEmail&requested=#sqlItem.hbuserid#&iid=#sqlItem.ebayitem#&frm=285">#sqlItem.hbuserid#</a> (<a href="http://feedback.ebay.com/ws/eBayISAPI.dll?ViewFeedback&userid=#sqlItem.hbuserid#">#sqlItem.hbfeedbackscore#</a>)</cfif></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Email:</b></td>
			<td width="70%" align="left"><cfif sqlItem.hbemail EQ "">N/A<cfelse><a href="mailto:#sqlItem.hbemail#">#sqlItem.hbemail#</a></cfif></td>
		</tr>
		<cfif getSalesRecord.recordcount gte 1>
			<tr bgcolor="##FFFFFF">
				<td valign="middle" align="right"><b>Sales Record:</b></td>
				<td width="70%" align="left">#getSalesRecord.salesRecord#</td>
			</tr>
		</cfif>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Address:</b></td>
			<td width="70%" align="left"><a href="JavaScript: fAddress('#attributes.item#');">Click to view/edit</a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Paid:</b></td>
			<td width="70%" align="left">
				</cfoutput><cfinclude template="inc_paid.cfm"><cfoutput>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Amount Paid:</b></td>
			<td width="70%" align="left">N/A</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Time Paid:</b></td>
			<td width="70%" align="left">N/A</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Method of Payment:</b></td>
			<td width="70%" align="left">N/A</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Transaction ID:</b></td>
			<td width="70%" align="left">N/A</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Shipped:</b></td>
			<td width="70%" align="left">
				#YesNoFormat(sqlItem.shipped)#
			<cfif isAllowed("Listings_CreateLabel")>
				#RepeatString("&nbsp;", 10)#
				<a href="index.cfm?act=admin.api.complete_sale&shipped=<cfif sqlItem.shipped EQ "1">0<cfelse>1</cfif>&itemid=#sqlItem.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=0&nextdsp=#URLEncodedFormat('management.items.edit&item=#sqlItem.item#')#" onClick="return confirm('Are you sure to change item status on eBay?');">Mark as <cfif sqlItem.shipped EQ "1">NOT </cfif>Shipped</a>
			</cfif>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Tracking Number:</b></td>
			<td width="70%" align="left">
			<cfif sqlItem.tracking NEQ "">
				<cfif sqlItem.shipper EQ "UPS">
					<a href="http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#sqlItem.tracking#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12" target="_blank">#sqlItem.tracking#</a>
				<cfelseif sqlItem.shipper EQ "USPS">
					<a href="http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#sqlItem.tracking#" target="_blank">#sqlItem.tracking#</a>
				<cfelseif sqlItem.shipper EQ "FEDEX">
					<a href="https://www.fedex.com/apps/fedextrack/?tracknumbers=#sqlItem.tracking#&cntry_code=us" target="_blank">#sqlItem.tracking#</a>
				<cfelse>
					#sqlItem.tracking#
				</cfif>
				<form method="POST" action="index.cfm?act=management.items.delete_track">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Delete" class="button">
				</form>
			<cfelse>
				<form method="POST" action="index.cfm?act=management.items.add_track">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input style="font-size: 11px;" type="text" name="tracking" size="20" maxlength="80">
					<input type="hidden" name="admin" value="1">
					<input type="submit" value="Save" class="button">
				</form>
			</cfif>
			</td>
		</tr>
		<!--- bonanza bidder: 20161004--->
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Bonanza Bidder:</b></td>
			<td width="70%" align="left">
			<cfif sqlItem.bonanza_bidder NEQ "">
					#sqlItem.bonanza_bidder#
				<form method="POST" action="index.cfm?act=management.items.delete_bonanzaBidder">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Delete" class="button">
				</form>
			<cfelse>
				<form method="POST" action="index.cfm?act=management.items.add_bonanzaBidder">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input style="font-size: 11px;" type="text" name="bonanza_bidder" size="20" maxlength="80">
					<input type="hidden" name="admin" value="1">
					<input type="submit" value="Save" class="button">
				</form>
			</cfif>
			</td>
		</tr>
			
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Time Shipped:</b></td>
			<td width="70%" align="left">N/A</td>
		</tr>
		</cfoutput>
	<cfelse>
		<cfoutput>

		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right">
				<b>eBay Title:</b></td>
			<td width="70%" align="left">#sqlTransaction.itmTitle#</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Start Time:</b></td>
			<td width="70%" align="left">#strDate(sqlTransaction.itmStartTime)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>End Time:</b></td>
			<td width="70%" align="left">#strDate(sqlTransaction.itmEndTime)#</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Final Price:</b></td>
			<td width="70%" align="left">#DollarFormat(sqlItem.price)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Shipping Price:</b></td>
			<td width="70%" align="left"><cfif isnumeric(sqlItem.shipcharge)> #dollarformat(sqlItem.shipcharge)#</cfif></td>
		</tr>

		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>High Bidder:</b></td>
			<td width="70%" align="left">
				<cfif sqlItem.hbuserid EQ "">N/A
				<cfelse><a href="http://contact.ebay.com/ws/eBayISAPI.dll?ReturnUserEmail&requested=#sqlItem.hbuserid#&iid=#sqlItem.ebayitem#&frm=285">#sqlItem.hbuserid#</a> (<a href="http://feedback.ebay.com/ws/eBayISAPI.dll?ViewFeedback&userid=#sqlItem.hbuserid#">#sqlItem.hbfeedbackscore#</a>)
				<cfif sqlItem.statusid EQ "11">
					<br><i>(<a href="index.cfm?dsp=management.returnemail&hbuserid=#sqlItem.hbuserid#&email=#sqlItem.hbemail#&item=#ListGetAt(sqlItem.item, 1, ".")##ListGetAt(sqlItem.item, 2, ".")#">Return Item Email</a>)</i>
				</cfif>
				</cfif></td>
		</tr>
		<cfif getSalesRecord.recordcount gte 1>
			<tr bgcolor="##FFFFFF">
				<td valign="middle" align="right"><b>Sales Record:</b></td>
				<td width="70%" align="left">#getSalesRecord.salesRecord#</td>
			</tr>
		</cfif>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Email:</b></td>
			<td width="70%" align="left"><cfif sqlItem.hbemail EQ "">N/A<cfelse><a href="mailto:#sqlItem.hbemail#">#sqlItem.hbemail#</a></cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Address:</b></td>
			<td width="70%" align="left"><a href="JavaScript: fAddress('#attributes.item#');"><cfif sqlTransaction.byrName EQ "">Click to view/edit<cfelse>#sqlTransaction.byrCityName#, #sqlTransaction.byrStateOrProvince#</cfif></a></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Paid:</b></td>
			<td width="70%" align="left">
				<!-- #sqlTransaction.stsCheckoutStatus# (Checkout Status) -->
				</cfoutput><cfinclude template="inc_paid.cfm"><cfoutput>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Amount Paid:</b></td>
			<td width="70%" align="left">#DollarFormat(sqlTransaction.AmountPaid)#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Time Paid:</b></td>
			<td width="70%" align="left"><cfif sqlTransaction.PaidTime EQ "">N/A<cfelse>#strDate(sqlTransaction.PaidTime)#</cfif></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Method of Payment:</b></td>
			<td width="70%" align="left">#sqlTransaction.stsPaymentMethodUsed#</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Transaction ID:</b></td>
			<td width="70%" align="left">
				<cfif sqlTransaction.extExternalTransactionID EQ "">
					N/A
				<cfelse>
					<cfif sqlTransaction.stsPaymentMethodUsed EQ "PayPal">
						<a target="_blank" href="https://history.paypal.com/us/cgi-bin/webscr?return_to=&history_cache=&item=0&search_type=#sqlTransaction.extExternalTransactionID#+&search_first_type=trans_id&span=broad&for=4&from_a=11&from_b=4&from_c=2005+&to_a=12&to_b=4&to_c=2005+&cmd=_history-search&submit.x=Submit&form_charset=UTF-8">#sqlTransaction.extExternalTransactionID#</a>
					<cfelse>
						#sqlTransaction.extExternalTransactionID#
					</cfif>
				</cfif>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Shipped:</b></td>
			<td width="70%" align="left">
				<!-- #sqlTransaction.stsCompleteStatus# (Complete Status) -->
				#YesNoFormat(sqlItem.shipped)#
			<cfif isAllowed("Listings_CreateLabel")>
				#RepeatString("&nbsp;", 10)#
				<a href="index.cfm?act=admin.api.complete_sale&shipped=<cfif sqlItem.shipped EQ "1">0<cfelse>1</cfif>&itemid=#sqlItem.item#&ebayitem=#sqlItem.ebayitem#&TransactionID=0&nextdsp=#URLEncodedFormat('management.items.edit&item=#sqlItem.item#')#" onClick="return confirm('Are you sure to change item status on eBay?');">Mark as <cfif sqlItem.shipped EQ "1">NOT </cfif>Shipped</a>
			</cfif>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Tracking Number:</b></td>
			<td width="70%" align="left">
			<cfif sqlItem.tracking NEQ "">
				<cfif sqlItem.shipper EQ "UPS">
					<a href="http://wwwapps.ups.com/WebTracking/processInputRequest?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&tracknum=#sqlItem.tracking#&AgreeToTermsAndConditions=yes&track.x=31&track.y=12" target="_blank">#sqlItem.tracking#</a>
				<cfelseif sqlItem.shipper EQ "USPS">
					<a href="http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#sqlItem.tracking#" target="_blank">#sqlItem.tracking#</a>
				<cfelseif sqlItem.shipper EQ "FEDEX">
					<a href="https://www.fedex.com/apps/fedextrack/?tracknumbers=#sqlItem.tracking#&cntry_code=us" target="_blank">#sqlItem.tracking#</a>
				<cfelse>
					#sqlItem.tracking#
				</cfif>
				<form method="POST" action="index.cfm?act=management.items.delete_track">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Delete" class="button">
				</form>
			<cfelse>
				<form method="POST" action="index.cfm?act=management.items.add_track">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input style="font-size: 11px;" type="text" name="tracking" size="20" maxlength="80">
					<input type="hidden" name="admin" value="1">
					<input type="submit" value="Save" class="button">
				</form>
			</cfif>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Time Shipped:</b></td>
			<td width="70%" align="left"><cfif sqlTransaction.ShippedTime EQ "">N/A<cfelse>#strDate(sqlTransaction.ShippedTime)#</cfif></td>
		</tr>
		<cfif sqlItem.byrOrderQtyToShip gte 1>
			<tr bgcolor="##F0F1F3">
				<td valign="middle" align="right"><b>Quantity:</b></td>
				<td width="70%" align="left">#sqlItem.byrOrderQtyToShip#</td>
			</tr>
		</cfif>
		</cfoutput>
	</cfif>
<cfoutput>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Carrier:</b></td>
			<td width="70%" align="left">
			<cfif sqlItem.shipper NEQ "">
				#sqlItem.shipper#
				<form method="POST" action="index.cfm?act=management.items.delete_carrier">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="submit" value="Delete" class="button">
				</form>
			<cfelse>
				<form method="POST" action="index.cfm?act=management.items.add_carrier">
					<input type="hidden" name="item" value="#sqlItem.item#">
					<input type="hidden" name="admin" value="1">
					<select style="font-size: 11px;" name="carrier">
						<option value="UPS">UPS</option>
						<option value="USPS">USPS</option>
						<option value="FedEx">FedEx</option>
						<option value="DHL">DHL</option>
					</select>
					<input type="submit" value="Save" class="button">
				</form>
			</cfif>
			</td>
		</tr>

		</table>
	</td></tr>
	</table>
</td></tr>
</table>



		<cfset eTime = getTickCount() />
<!---		<h1>
			Page load time:<br>
			<!--- something that you want to measure --->
			<cfoutput>That took #(startTime-eTime)/1000# seconds!</cfoutput>
		</h1>--->


<!--- http://www.bennadel.com/blog/659-Determine-How-Long-Your-ColdFusion-Page-Has-Been-Running-Using-GetPageContext-.htm --->
<cfset intRunTimeInSeconds = DateDiff(
"s",
GetPageContext().GetFusionContext().GetStartTime(),
Now()
) />



<!---
Output the number of seconds in which the page has
been processing.
--->
<h3>Page load #intRunTimeInSeconds# Seconds! (#(eTime-startTime)/1000#)
</h3>

</cfoutput>

</cfif>
</cfprocessingdirective>
<!---</cf_accelerate>--->