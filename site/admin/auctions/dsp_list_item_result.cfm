<cfparam name="attributes.sandbox" default="false">
<cfscript>
	if(attributes.sandbox){
		_ebay.VIEW_ITEM_URL			= "http://cgi.sandbox.ebay.com/ws/eBayISAPI.dll?ViewItem&item=";
	}else{
		_ebay.VIEW_ITEM_URL			= "http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=";
	}

	WriteOutput("<div class=""info"">ItemID = #_ebay.xmlResponse.xmlRoot.ItemID.xmlText#</div>");
	if(StructKeyExists(_ebay.xmlResponse.xmlRoot, "Fees")){
		Fees = _ebay.xmlResponse.xmlRoot.Fees.xmlChildren;
		WriteOutput("<center><h2>FEES:</h2>");
		total = 0;
		for(i=1; i LTE ArrayLen(Fees); i=i+1){
			fee = Val(Fees[i].Fee.xmlText);
			if(Fees[i].Name.xmlText EQ "ListingFee"){
				total = fee;
			}else if (fee GT 0){
				WriteOutput("<b>#Fees[i].Name.xmlText# = #DollarFormat(fee)#</b><br>");
			}else{
				WriteOutput("#Fees[i].Name.xmlText# = #DollarFormat(fee)#<br>");
			}
		}
		WriteOutput("<h2>Total = #DollarFormat(total)#</h2>");
	}
</cfscript>
<cfif ListFindNoCase("AddItem,RelistItem", attributes.CallName)>
	<cfinclude template="act_just_listed.cfm">
	<cfoutput>
	<h1>Item was listed successfully.<br>Click <a target="_blank" href="#_ebay.VIEW_ITEM_URL##_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">#_ebay.xmlResponse.xmlRoot.ItemID.xmlText#</a> to view the item on eBay.</h1>
	</cfoutput>
<cfelseif attributes.CallName EQ "AddSecondChanceItem">
	<cfoutput><h1>CONGRATULATIONS! Second Chance Item was added successfully. Click <a target="_blank" href="#_ebay.VIEW_ITEM_URL##_ebay.xmlResponse.xmlRoot.ItemID.xmlText#">here</a> to view item on eBay</h1></cfoutput>
<cfelse>
	<cfoutput><button onClick="window.location.href = 'index.cfm?dsp=admin.auctions.list2sandbox&item=#attributes.item#&CallName=AddItem&sandbox=#attributes.sandbox#';">List Item</button></center><br><br></cfoutput>
</cfif>
