<cfif NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction") AND NOT isAllowed("Lister_ListAuction")>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfparam name="attributes.item">
<cfparam name="catNames.recordcount" default="0" >
<cfinclude template="get_item.cfm">

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
		where categoryid = #sqlAuction.CategoryID#

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
		Order by CategoryLevel desc
	</cfquery>

<cfcatch type="Any" >
</cfcatch>
</cftry>







<!--- PRE POPULATE (PART 1 OF 2) --->
<cfset aPopulate = ArrayNew(1)>
<cfquery datasource="#request.dsn#" name="sqlParent">
	SELECT CategoryID, CategoryLevel, CategoryParentID
	FROM ebcategories
	WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlAuction.SiteID#">
		AND CategoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlAuction.CategoryID#">
</cfquery>
<cfif sqlParent.RecordCount EQ 1>
	<cfset ArrayPrepend(aPopulate, sqlParent.CategoryID)>
	<cfloop condition="sqlParent.CategoryLevel NEQ 1">
		<cfquery datasource="#request.dsn#" name="sqlParent">
			SELECT CategoryID, CategoryLevel, CategoryParentID
			FROM ebcategories
			WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlAuction.SiteID#">
				AND CategoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlParent.CategoryParentID#">
		</cfquery>
		<cfset ArrayPrepend(aPopulate, sqlParent.CategoryID)>
	</cfloop>
</cfif>
<cfif (sqlAuction.SiteID EQ 100) AND (ArrayLen(aPopulate) GT 0)>
	<cfset ArrayDeleteAt(aPopulate, 1)>
</cfif>
<cfoutput>
<script language="javascript">
<!--//
var aPopulate = "#ArrayToList(aPopulate)#".split(",");
var callPopulator = true;
var populatorLevel = 1;
//-->
</script>
</cfoutput>
<!--- / PRE POPULATE (PART 1 OF 2) --->

<cfquery datasource="#request.dsn#" name="sqlInitCategories">
	SELECT CategoryID, CategoryName
	FROM ebcategories
	WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlAuction.SiteID#">
		AND CategoryLevel = <cfif sqlAuction.SiteID EQ 100>2<cfelse>1</cfif>
	ORDER BY CategoryName
</cfquery>

<cfquery datasource="#request.dsn#" name="sqlCustomCategories">
	SELECT CategoryID, Name
	FROM custom_categories
	WHERE SiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sqlAuction.SiteID#">
	ORDER BY SortOrder
</cfquery>

<cfoutput>
<script language="javascript" type="text/javascript">

var oSelect; // object to populate with data
function setCategory(ID){
	if(ID>0){
		document.getElementById("CategoryID").value = ID;
	}
}

/*
function getCategories(ID, num){
	var sURL = "_categories.cfm?SiteID=" + document.getElementById("SiteID").value;
	if(num > 1){
		sURL += "&CategoryID="+ID;
		setCategory(ID);
	}
	oSelect = document.getElementById("cat"+num);
	for(i=num+1; i<7; i++){
		document.getElementById("cat"+i).length = 0;
	}
	// create instance of a new XMLHTTP object because we
	// can't change readystate handler on existing instance
	oHTTP = new ActiveXObject("Microsoft.XMLHTTP");
	if(oHTTP != null){
		oHTTP.onreadystatechange = handler;
		// open HTTP connection and send async request
		oHTTP.open("GET", sURL, true);
		oHTTP.send();
	}else{
		alert("ERROR: Cannot create XMLHTTP object!");
	}
	
	
}
*/

			function getCategories(ID, num){
				var sURL = "_categories.cfm?SiteID=" + document.getElementById("SiteID").value;
				if(num > 1){
					sURL += "&CategoryID="+ID;
					setCategory(ID);
				}	
				oSelect = document.getElementById("cat"+num);
				for(i=num+1; i<7; i++){
					document.getElementById("cat"+i).length = 0;
				}	
										
	            $.ajax({
	                url: sURL,
	                dataType: "text",
	                cache: false,
	                success: function (data) {
	                	/*
	                	var json = $.parseJSON(data);
						var a = json.split("|");

						while(a.length > 0){
							pair = a.shift();
							if(pair.indexOf("~") > 0){
								b = pair.split("~");
								if(2 == b.length){
									oSelect.options[oSelect.length] = new Option(b[1], b[0]);
								}
							}
						}
						*/
						handler(data)
			     						                       
	                },
	                error: function(){
	                	alert('Error in getting categories');
	                }
	            })
	            
	         }
	            
function handler(data) {


			// clear existing options
			oSelect.length = 0;
			// populate with new options
			var a = data.split("|");
			var b;
			while(a.length > 0){
				pair = a.shift();
				if(pair.indexOf("~") > 0){
					b = pair.split("~");
					if(2 == b.length){
						oSelect.options[oSelect.length] = new Option(b[1], b[0]);
					}
				}
			}
			
			<!--- PRE POPULATE (PART 2 OF 3) --->
			if(callPopulator){
				if(populatorLevel<=aPopulate.length){
					populatorLevel++;
					populator();
				}else{
					callPopulator = false;
				}
			}

	
}
function fCharsLeft(objID, val, maxChars){
	document.getElementById(objID).innerHTML = "(" + (maxChars-val.length) + " chars left)";
}

</script>
<table width="100%" style="text-align: justify;">
<tr><td>
	<font size="4"><strong>Auction Management - Step 1 of 4:</strong></font><br>
	<hr size="1" style="color: Black;" noshade>
	<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

	<table width="100%" bgcolor="##aaaaaa" border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<form method="POST" action="index.cfm?act=admin.auctions.step1">
		<input type="hidden" name="item" value="#sqlAuction.itemid#">
		<table width="100%" border="0" cellpadding="4" cellspacing="1">
		<tr bgcolor="##F0F1F3">
			<td width="25%" valign="middle" align="right"><b>Item Number:</b></td>
			<td align="left"><b>#sqlAuction.itemid#</b></td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>eBay Title:</b></td>
			<td align="left">
				<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td><input type="text" name="Title" value="#HTMLEditFormat(sqlAuction.Title)#" size="80" maxlength="80" onChange="fCharsLeft('dynaTitle', this.value, 80)" onKeyUp="fCharsLeft('dynaTitle', this.value, 80)"></td>
					<td id="dynaTitle">(#80-Len(sqlAuction.Title)# chars left)</td>
				</tr>
				<tr><td colspan="2"><small>80 Chars. Max</small></td></tr>
				</table>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>eBay Subtitle:</b></td>
			<td align="left">
				<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td><input type="text" name="SubTitle" value="#sqlAuction.SubTitle#" size="55" maxlength="55" onChange="fCharsLeft('dynaSubTitle', this.value, 55)" onKeyUp="fCharsLeft('dynaSubTitle', this.value, 55)"></td>
					<td id="dynaSubTitle">(#55-Len(sqlAuction.SubTitle)# chars left)</td>
				</tr>
				<tr><td colspan="2"><small>55 Chars. Max ($0.50 fee)</small></td></tr>
				</table>
			</td>
		</tr>
	<cfif isAllowed("Lister_ChangeAccount")>
		<cfquery datasource="#request.dsn#" name="sqlEBAS">
			SELECT eBayAccount, UserID
			FROM ebaccounts
		</cfquery>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>List as Seller:</b></td>
			<td align="left">
				<select id="ebayaccount" name="ebayaccount">
					<cfloop query="sqlEBAS">
						<option value="#eBayAccount#"<cfif sqlAuction.ebayaccount EQ eBayAccount> selected</cfif>>#UserID#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</cfif>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Market:</b></td>
			<td align="left"><select id="SiteID" name="SiteID" onChange="getCategories(this.value, 1)">#SelectOptions(sqlAuction.SiteID, "0,eBay;100,eBay Motors")#</select></td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="top" align="right"><b>Category ##</b></td>
			<td>
				<table cellpadding="0" cellspacing="0">
				<tr>
					<td width="100">
						<input type="text" size="5" name="CategoryID" id="CategoryID" value="#sqlAuction.CategoryID#">
					</td>
					<td>
						<cfoutput>
						<select onChange="setCategory(this.value)">
						<option value="0">select from recently used categories</option>
						<cfloop index="i" from="1" to="#ArrayLen(application.recentCategories)#">
							<option value="#application.recentCategories[i].CategoryID#">#application.recentCategories[i].CategoryName#</option>
						</cfloop>
						</select>
						</cfoutput>
					</td>
				</tr>
				</table>
				<br>
				<cfif catNames.RecordCount gte 1>
					<cfloop query="catNames" >
						<cfif catNames.IsLast()>
							(#catnames.CATEGORYID#)
						</cfif>
						#catNames.categoryName#<br>
						</cfloop>
				</cfif>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF"><td valign="middle" align="center" colspan="2">
			<table cellpadding="5" cellspacing="0" border="0">
			<tr>
				<td><select size="10" style="width:300px;" id="cat1" name="cat1" onChange="getCategories(this.value, 2)"><cfloop query="sqlInitCategories"><option value="#CategoryID#">#CategoryName#</option></cfloop></select></td>
				<td><select size="10" style="width:300px;" id="cat2" name="cat2" onChange="getCategories(this.value, 3)"></select></td>
			</tr>
			<tr>
				<td><select size="10" style="width:300px;" id="cat3" name="cat3" onChange="getCategories(this.value, 4)"></select></td>
				<td><select size="10" style="width:300px;" id="cat4" name="cat4" onChange="getCategories(this.value, 5)"></select></td>
			</tr>
			<tr>
				<td><select size="10" style="width:300px;" id="cat5" name="cat5" onChange="getCategories(this.value, 6)"></select></td>
				<td><select size="10" style="width:300px;" id="cat6" name="cat6" onChange="setCategory(this.value)"></select></td>
			</tr>
			</table>
		</td></tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Main Store Category:</b></td>
			<td align="left">
				<select name="StoreCategoryID">
					<option value="0"<cfif sqlAuction.StoreCategoryID EQ 0> selected</cfif>>NONE</option>
 					<cfloop query="sqlCustomCategories">
						<option value="#sqlCustomCategories.CategoryID#"<cfif sqlAuction.StoreCategoryID EQ sqlCustomCategories.CategoryID> selected</cfif>>#sqlCustomCategories.Name#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr bgcolor="##F0F1F3">
			<td valign="middle" align="right"><b>Second Store Category:</b></td>
			<td align="left">
				<select name="StoreCategory2ID">
					<option value="0"<cfif sqlAuction.StoreCategory2ID EQ 0> selected</cfif>>NONE</option>
 					<cfloop query="sqlCustomCategories">
						<option value="#sqlCustomCategories.CategoryID#"<cfif sqlAuction.StoreCategory2ID EQ sqlCustomCategories.CategoryID> selected</cfif>>#sqlCustomCategories.Name#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td colspan="2">
				<br><b>Item Description:</b><br><br>
</cfoutput>

<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{internal_item_condition}', sqlDefault.internal_itemCondition, 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{item_title}', sqlDefault.title, 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{itemManual}', YesNoFormat(sqlDefault.itemManual), 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{itemComplete}', YesNoFormat(sqlDefault.itemComplete), 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{itemTested}', YesNoFormat(sqlDefault.itemTested), 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{retailPackingIncluded}', YesNoFormat(sqlDefault.retailPackingIncluded), 'ALL')#>
<cfset sqlAuction.Description = #Replace(sqlAuction.Description, '{retailPrice}', sqlDefault.age, 'ALL')#>
<cfset sqlAuction.Description =	#Replace(sqlAuction.Description, '{Sub_item_Description}', sqlDefault.sub_description, 'ALL')#>

<cfif sqlDefault.specialNotes eq "">
	<cfset sqlDefault.specialNotes = "N/A">
</cfif>
<cfset sqlAuction.Description =  #Replace(sqlAuction.Description, '{specialNotes}', sqlDefault.specialNotes , 'ALL')#>



		
<cfoutput>
			<textarea cols="90" rows="13" name="Description" id="Description">#sqlAuction.Description#</textarea><br>
			</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="middle" align="right"><b>Video URL:</b></td>
			<td align="left"><input type="text" name="videoURL" value="#sqlAuction.videoURL#" size="50" maxlength="250"></td>
		</tr>
		</table>
	</td></tr>
	</table>
</td></tr>
</table>
<br>
<center>
<input type="submit" value="Next" name="ItemSpecific" width="100" style="width:100px;">
&nbsp;&nbsp;&nbsp;
<input type="submit" value="Skip Item Specific" name="next" width1="100" style1="width:100px;">
<br><br>
<input type="submit" name="finish" value="Finish" width="100" style="width:100px;">
</form>
</center>
<br>
</cfoutput>

<!--- PRE POPULATE (PART 3 OF 3) --->
<cfoutput>
<script language="javascript">

function populator(){
	oSelect = document.getElementById("cat"+populatorLevel);
	for(i=0; i<oSelect.length; i++){
		if(oSelect.options[i].value == aPopulate[populatorLevel-1]){
			oSelect.selectedIndex = i;
			break;
		}
	}
	if(populatorLevel<6){
		getCategories(aPopulate[populatorLevel-1], populatorLevel+1);
	}else{
		setCategory(aPopulate[populatorLevel-1]);
	}
}


</script>


	<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
	<script src="ckeditor/ckeditor.js"></script>
	<script>
	    // Replace the <textarea id="editor1"> with a CKEditor
	    // instance, using default configuration.
	    CKEDITOR.replace( 'Description',{
	    	extraPlugins : 'filemanager'
	    } );
	
	$(function(){
		
		populator();
	});
	
	</script>
	
	
	
</cfoutput>
<!--- / PRE POPULATE (PART 3 OF 3) --->
