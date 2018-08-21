<cfscript>
	_layout = StructNew();
	_layout.ia_design = "https://#CGI.HTTP_HOST#/site/admin/auctions/layout/common/";
	_layout.ia_images = "https://#CGI.HTTP_HOST#/images/";
	_layout.aNames = ArrayNew(1);
	_layout.aNames[1] = "CD Player";
	_layout.aNames[2] = "Home Theatre";
	_layout.aNames[3] = "Antique Frame";
	_layout.aNames[4] = "Books";
	_layout.aNames[5] = "Musical Instruments";
	_layout.aNames[6] = "Toys";
	_layout.aNames[7] = "Travel-Landmarks";
	_layout.aNames[8] = "Sporting Goods";
	_layout.aNames[9] = "Floral Pattern";
	_layout.aNames[10] = "Western";
	_layout.aNames[11] = "Vacation Getaway";
	_layout.aNames[12] = "Jewelry and Watches";
	_layout.aNames[13] = "Wood Border";
	_layout.aNames[14] = "Construction";
	_layout.aNames[15] = "DVDs/Movies";
	_layout.aNames[16] = "Road Trip";
	_layout.aNames[17] = "Travel-Plane";
	_layout.aNames[18] = "Anniversary Gifts";
	_layout.aNames[19] = "Costumes/Masks";
	_layout.aNames[20] = "Wedding Bells";
	_layout.aNames[21] = "Casino Gambling";
	_layout.aNames[22] = "Mens Clothing";
	_layout.aNames[23] = "CDs/Music";
	_layout.aNames[24] = "Gold Frame";
	_layout.aNames[25] = "Baby Clothes";
	_layout.aNames[26] = "Hawaii Surf";
	_layout.aNames[27] = "Musical Instruments 2";
	_layout.aNames[28] = "Office Supplies";
	_layout.aNames[29] = "Pet Silouettes";
	_layout.aNames[30] = "Video Games";
	_layout.aNames[31] = "Historical";
	_layout.aNames[32] = "Fathers Day";
	_layout.aNames[33] = "Halloween";
	_layout.aNames[34] = "Mothers Day";
	_layout.aNames[35] = "Patriotic Flag";
	_layout.aNames[36] = "Valentines Days";
	_layout.aNames[37] = "Wine/Drinks";
	_layout.aNames[38] = "Retro Car Dash";
	_layout.aNames[39] = "Route 66";
	_layout.aNames[40] = "Running Shoes";
	_layout.aNames[41] = "Golfing";
	_layout.aNames[42] = "Childrens Toys";
	_layout.aNames[43] = "Christmas";
	_layout.aNames[44] = "Easter";
	// NEW ITEMS
	_layout.aNames[45] = "Video Games";
	_layout.aNames[46] = "Antiques";
	_layout.aNames[47] = "Antiques 3";
	_layout.aNames[48] = "Watches";
	_layout.aNames[49] = "Jeans";
	_layout.aNames[50] = "Trailers";
	_layout.aNames[51] = "Photography";
	_layout.aNames[52] = "Collectibles Figurines";
	_layout.aNames[53] = "Clothing Modern";
	_layout.aNames[54] = "Christmas Tree";
	_layout.aNames[55] = "Snowman";
	_layout.aNames[56] = "Jewelry";
	_layout.aNames[57] = "X-Treme Sports";
	_layout.aNames[58] = "Bookmarks";
	_layout.aNames[59] = "Coins Red";
	_layout.images_path = "images/";
	function fShowImage(num){
		if(FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#arguments.num#.jpg")){
			WriteOutput('<a href="##" onClick="return false;" onMouseOver="document.clicPicBig.src=preloadedImage#arguments.num#.src; return false;"><img src="#_layout.ia_images##sqlAuction.use_pictures#/#arguments.num#thumb.jpg" border="1"></a>');
			variables.jsPreload = variables.jsPreload & "var preloadedImage#arguments.num#=new Image(); preloadedImage#arguments.num#.src='#_layout.ia_images##sqlAuction.use_pictures#/#arguments.num#.jpg';";
		}else{
			WriteOutput('&nbsp;');
		}
	}
	function fAddAttribute(xmlDoc, attributeID, ValueID, ValueLiteral, metacharacter){
		var i = 0;
		var x = xmlElemNew(arguments.xmlDoc, "Attribute");
		StructInsert(x.xmlAttributes, "attributeID", arguments.attributeID);
		if(metacharacter EQ "Y"){
			x.Value = xmlElemNew(arguments.xmlDoc, "Value");
			x.Value.ValueID = xmlElemNew(arguments.xmlDoc, "ValueID");
			x.Value.ValueID.xmlText = "-5";
			x.Value.ValueLiteral = xmlElemNew(arguments.xmlDoc, "ValueLiteral");
			x.Value.ValueLiteral.xmlText = arguments.ValueLiteral & "0000";
			return x;
		}
		if(ListLen(arguments.ValueID) GT 1){
			for(i=1; i LTE ListLen(arguments.ValueID); i=i+1){
				ArrayAppend(x.xmlChildren, xmlElemNew(arguments.xmlDoc, "Value"));
				theValue = x.xmlChildren[ArrayLen(x.xmlChildren)];
				theValue.ValueID = xmlElemNew(arguments.xmlDoc, "ValueID");
				theValue.ValueID.xmlText = ListGetAt(arguments.ValueID, i);
			}
		}else{
			x.Value = xmlElemNew(arguments.xmlDoc, "Value");
			if(arguments.ValueID NEQ ""){
				x.Value.ValueID = xmlElemNew(arguments.xmlDoc, "ValueID");
				x.Value.ValueID.xmlText = arguments.ValueID;
			}
			if(arguments.ValueLiteral NEQ ""){
				x.Value.ValueLiteral = xmlElemNew(arguments.xmlDoc, "ValueLiteral");
				x.Value.ValueLiteral.xmlText = arguments.ValueLiteral;
			}
		}
		return x;
	}
	function addSelectedAttributes(xmlDoc, attributeID, ValueID, ValueLiteral, metacharacter){
		var i = 0;
		var x = xmlElemNew(arguments.xmlDoc, "Attribute");
		StructInsert(x.xmlAttributes, "id", arguments.attributeID);
		if(metacharacter EQ "Y"){
			x.Value = xmlElemNew(arguments.xmlDoc, "Value");
			x.Value.Year = xmlElemNew(arguments.xmlDoc, "Year");
			x.Value.Year.xmlText = arguments.ValueLiteral;
			return x;
		}
		if(ListLen(arguments.ValueID) GT 1){
			for(i=1; i LTE ListLen(arguments.ValueID); i=i+1){
				ArrayAppend(x.xmlChildren, xmlElemNew(arguments.xmlDoc, "Value"));
				StructInsert(x.xmlChildren[ArrayLen(x.xmlChildren)].xmlAttributes, "id", ListGetAt(arguments.ValueID, i));
			}
		}else{
			x.Value = xmlElemNew(arguments.xmlDoc, "Value");
			if(arguments.ValueID NEQ ""){
				StructInsert(x.Value.xmlAttributes, "id", arguments.ValueID);
			}
			if(arguments.ValueLiteral NEQ ""){
				x.Value.Name = xmlElemNew(arguments.xmlDoc, "Name");
				x.Value.Name.xmlText = arguments.ValueLiteral;
			}
		}
		return x;
	}
</cfscript>
