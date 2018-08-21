<cffunction output="true" returntype="void" name="LoginWelcome">
	<cfif isDefined ("session.user")>
		<cfoutput><b>You are currently logged in as #session.user.first# #session.user.last#.  To manage your items, please go to <a href="index.cfm?dsp=account.overview">My Account</a>.</b><br></cfoutput>
	</cfif>
	<cfif isDefined ("session.badlogin")>
		<cfoutput><b><font color="red">The Login information you entered was incorrect, please try again.</font></b><br></cfoutput>
		<cfset StructDelete(session, "badlogin")>
	</cfif>
</cffunction>

<cffunction output="false" returntype="string" name="strDate">
	<cfargument name="dArg" type="any" required="yes">
	<cftry><cfset sResult = "#DateFormat(dArg)# #TimeFormat(dArg)#"><cfcatch type="any"><cfset sResult = "BAD DATE:(#dArg#)"></cfcatch></cftry>
	<cfreturn sResult>
</cffunction>

<cffunction output="false" returntype="string" name="DateTimeStampToEBay">
	<cfargument name="dArg" type="date" required="yes">
	<cfreturn "#DateFormat (DateConvert('local2utc', dArg), 'YYYY-MM-DDT')##TimeFormat (DateConvert('local2utc', dArg), 'HH:MM:SS.LZ')#">
</cffunction>

<cffunction output="false" returntype="string" name="DateTimeToEBay">
	<cfargument name="dArg" type="date" required="yes">
	<cfreturn "#DateFormat (DateConvert('local2utc', dArg), 'YYYY-MM-DD')# #TimeFormat (DateConvert('local2utc', dArg), 'HH:MM:SS')#">
</cffunction>

<cffunction output="false" returntype="date" name="DateTimeFromEBay">
	<cfargument name="sArg" type="string" required="yes">
	<cftry>
		<cfscript>
			sYear = Mid(sArg, 1, 4);
			sMonth = Mid(sArg, 6, 2);
			sDay = Mid(sArg, 9, 2);
			sHour = Mid(sArg, 12, 2);
			sMinute = Mid(sArg, 15, 2);
			sSecond = Mid(sArg, 18, 2);
			return DateConvert('utc2Local', CreateDateTime(sYear, sMonth, sDay, sHour, sMinute, sSecond));
		</cfscript>
		<cfcatch type="any">
			<cfif request.emails.error NEQ "">
				<cfmail
					 from="#_vars.mails.from#"
					to="#request.emails.error#" 
					subject="DateTimeFromEBay(#sArg#)"
				>
					#sArg#:CreateDateTime(#sYear#, #sMonth#, #sDay#, #sHour#, #sMinute#, #sSecond#)
				</cfmail>
			</cfif>
			<cfreturn DateConvert('utc2Local', CreateDateTime(sYear, sMonth, sDay, 0, 0, 0))>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction output="true" returntype="void" name="ShowDateTime">
	<cfargument name="sName" type="string" required="yes">
	<cfargument name="dtDefault" type="date" required="yes">
	<cfoutput>
	<table cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td>
			<select name="#sName#Month">
			<cfloop index="i" from="1" to="12">
				<option value="#i#"<cfif i EQ Month(dtDefault)> selected</cfif>>#MonthAsString(i)#</option>
			</cfloop>
			</select>
		</td>
		<td>
			<select name="#sName#Day">
			<cfloop index="i" from="1" to="#DaysInMonth(dtDefault)#">
				<option value="#i#"<cfif i EQ Day(dtDefault)> selected</cfif>>#i#</option>
			</cfloop>
			</select>
		</td>
		<td>
			<select name="#sName#Year">
			<cfloop index="i" from="#Evaluate(Year(dtDefault)-1)#" to="#Evaluate(Year(Now())+1)#">
				<option value="#i#"<cfif i EQ Year(dtDefault)> selected</cfif>>#i#</option>
			</cfloop>
			</select>
		</td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="#sName#Hour">
			<cfloop index="i" from="0" to="23">
				<option value="#i#"<cfif i EQ Hour(dtDefault)> selected</cfif>>#NumberFormat(i, "00")#</option>
			</cfloop>
			</select>
		</td>
		<td>:</td>
		<td>
			<select name="#sName#Minute">
			<cfloop index="i" from="0" to="59">
				<option value="#i#"<cfif i EQ Minute(dtDefault)> selected</cfif>>#NumberFormat(i, "00")#</option>
			</cfloop>
			</select>
		</td>
		<td>:</td>
		<td>
			<select name="#sName#Second">
			<cfloop index="i" from="0" to="59">
				<option value="#i#"<cfif i EQ Second(dtDefault)> selected</cfif>>#NumberFormat(i, "00")#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	</table>
	</cfoutput>
</cffunction>

<cffunction output="false" returntype="date" name="DateTimeFromForm">
	<cfargument name="sName" type="string" required="yes">
	<cfreturn CreateDateTime(Evaluate ("attributes.#sName#Year"), Evaluate ("attributes.#sName#Month"), Evaluate ("attributes.#sName#Day"), Evaluate ("attributes.#sName#Hour"), Evaluate ("attributes.#sName#Minute"), Evaluate ("attributes.#sName#Second"))>
</cffunction>

<cffunction output="true" returntype="void" name="StateOptions">
	<cfargument name="defState" default="">
	<cfscript>
		aStates = ListToArray("CHOOSE ONE,XX;ALABAMA,AL;ALASKA,AK;AMERICAN SAMOA,AS;ARIZONA,AZ;ARKANSAS,AR;CALIFORNIA,CA;COLORADO,CO;CONNECTICUT,CT;DELAWARE,DE;DISTRICT OF COLUMBIA,DC;FEDERATED STATES OF MICRONESIA,FM;FLORIDA,FL;GEORGIA,GA;GUAM,GU;HAWAII,HI;IDAHO,ID;ILLINOIS,IL;INDIANA,IN;IOWA,IA;KANSAS,KS;KENTUCKY,KY;LOUISIANA,LA;MAINE,ME;MARSHALL ISLANDS,MH;MARYLAND,MD;MASSACHUSETTS,MA;MICHIGAN,MI;MINNESOTA,MN;MISSISSIPPI,MS;MISSOURI,MO;MONTANA,MT;NEBRASKA,NE;NEVADA,NV;NEW HAMPSHIRE,NH;NEW JERSEY,NJ;NEW MEXICO,NM;NEW YORK,NY;NORTH CAROLINA,NC;NORTH DAKOTA,ND;NORTHERN MARIANA ISLANDS,MP;OHIO,OH;OKLAHOMA,OK;OREGON,OR;PALAU,PW;PENNSYLVANIA,PA;PUERTO RICO,PR;RHODE ISLAND,RI;SOUTH CAROLINA,SC;SOUTH DAKOTA,SD;TENNESSEE,TN;TEXAS,TX;UTAH,UT;VERMONT,VT;VIRGIN ISLANDS,VI;VIRGINIA,VA;WASHINGTON,WA;WEST VIRGINIA,WV;WISCONSIN,WI;WYOMING,WY", ";");
		for(i=1;i LTE ArrayLen(aStates); i=i+1){
			if(ListLast(aStates[i]) EQ arguments.defState){
				sSelected = " selected";
			}else{
				sSelected = "";
			}
			WriteOutput("<option value=""#ListLast(aStates[i])#""#sSelected#>#ListFirst(aStates[i])#</option>");
		}
	</cfscript>
</cffunction>

<cffunction output="true" returntype="void" name="SelectOptions">
	<cfargument name="defValue" default="">
	<cfargument name="lsValues" default="">
	<cfscript>
		aValues = ListToArray(arguments.lsValues, ";");
		for(i=1;i LTE ArrayLen(aValues); i=i+1){
			if(ListFirst(aValues[i]) EQ arguments.defValue){
				sSelected = " selected";
			}else{
				sSelected = "";
			}
			WriteOutput("<option value=""#ListFirst(aValues[i])#""#sSelected#>#ListLast(aValues[i])#</option>");
		}
	</cfscript>
</cffunction>

<cfscript>
function isEmail(email){
	if (NOT REFindNoCase("^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,3})$", email)){
		return false;
	}
	return true;
}
function isZIP(zip){
	// valid values:
	// strlen($_POST[zip]) == 5 && !ereg('[0-9]{5}',$_POST[zip])
	// strlen($_POST[zip]) == 10 && !ereg('[0-9]{5}-[0-9]{4}',$_POST[zip])
	if(NOT REFind("^[0-9]{5}$|^[0-9]{5}-[0-9]{4}$", zip)){
		return false;
	}
	return true;
}
function isPhone(phone){
	// valid values:
	// strlen($_POST[phone]) == 14 && !ereg('^\(*[0-9]{3}\)*[[:space:]][0-9]{3}-*[0-9]{4}$',$_POST[phone])
	// strlen($_POST[phone]) == 13 && !ereg('^\(*[0-9]{3}\)*[0-9]{3}-*[0-9]{4}$',$_POST[phone])
	// strlen($_POST[phone]) == 12 && !ereg('[0-9]{3}-[0-9]{3}-[0-9]{4}',$_POST[phone])
	// strlen($_POST[phone]) == 10 && !ereg('[0-9]{10}',$_POST[phone])
	if(NOT REFind("^\(*[0-9]{3}\)*[[:space:]][0-9]{3}-*[0-9]{4}$|^\(*[0-9]{3}\)*[0-9]{3}-*[0-9]{4}$|^[0-9]{3}-[0-9]{3}-[0-9]{4}$|^[0-9]{10}$", phone)){
		return false;
	}
	return true;
}
function CalcEBayFees(finalprice){
	if (finalprice GT 25){
		if (finalprice GT 1000){
			ebayfees = 1.31 + 29.25 + 0.015 * (finalprice - 1000) + 0.4 + 0.4;
		}else{
			ebayfees = 1.31 + (0.0325 * (finalprice - 25)) + 0.4 + 0.4;
		}
	}else{
		ebayfees = 0.0875 * finalprice + 0.35 + 0.35;
	}
	ebayfees = Round(0.4 + (ebayfees * 100)) * .01;
	return ebayfees;
}

function isGuest(){
	if(NOT isDefined("session.user")){
		return TRUE;
	}
	if(session.user.site EQ "wholesale"){
		return FALSE;
	}else{
		return
				(
					(session.user.usertype LT 10)
						AND
					(session.user.rid EQ 10)
				);
	}
}

function isGuestWS(){
	if(isDefined("session.user") AND session.user.site EQ "wholesale"){
		return TRUE;
	}else{
		return FALSE;
		}
}
</cfscript>


<cffunction name="isAllowed" output="false" returntype="boolean">
	<cfargument name="PermissionName" type="string">
	<cfif isDefined("session.user")>
		<cfif session.user.site NEQ "ebay">
			<cfreturn false>
		<cfelseif session.user.usertype GTE 10>
			<cfreturn true>
		<cfelseif session.user.rid EQ 1><!--- CORPORATE --->
			<cfreturn true>
		</cfif>
		<cfreturn StructKeyExists(_security, "_#session.user.rid#") AND StructKeyExists(_security["_#session.user.rid#"], arguments.PermissionName)>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="isAllowedWS" output="false" returntype="boolean">
	<cfargument name="PermissionName" type="string">
	<cfif isDefined("session.user")>
		<cfif session.user.site NEQ "wholesale">
			<cfreturn false>
		<cfelseif session.user.rid EQ 1><!--- CORPORATE --->
			<cfreturn true>
		</cfif>
		<cfreturn StructKeyExists(_securityWS, "_#session.user.rid#") AND StructKeyExists(_securityWS["_#session.user.rid#"], arguments.PermissionName)>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="isGroupMemberAllowed" output="false" returntype="boolean">
	<cfargument name="GroupName" type="string">
	<cfif isDefined("session.user")>
		<cfif session.user.site NEQ "ebay">
			<cfreturn false>
		<cfelseif session.user.usertype GTE 10>
			<cfreturn true>
		<cfelseif session.user.rid EQ 1><!--- CORPORATE --->
			<cfreturn true>
		</cfif>
		<cfloop index="permission" list='#StructKeyList(_security["_#session.user.rid#"])#'>
			<cfif Left(permission, Len(arguments.GroupName)) EQ arguments.GroupName>
				<cfreturn true>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn false>
</cffunction>

<cffunction name="isGroupMemberAllowedWS" output="false" returntype="boolean">
	<cfargument name="GroupName" type="string">
	<cfif isDefined("session.user")>
		<cfif session.user.site NEQ "wholesale">
			<cfreturn false>
		<cfelseif session.user.rid EQ 1><!--- CORPORATE --->
			<cfreturn true>
		</cfif>
		<cfloop index="permission" list='#StructKeyList(_securityWS["_#session.user.rid#"])#'>
			<cfif Left(permission, Len(arguments.GroupName)) EQ arguments.GroupName>
				<cfreturn true>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn false>
</cffunction>

<cffunction name="fChangeLocation" output="true" returntype="void">
	<cfargument name="itemid">
	<cfargument name="newLID">
	<!---
	<cfquery datasource="#request.dsn#" name="sqlCurrent">
		SELECT lid FROM items
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemid#">
	</cfquery>
	--->
	<cfif isDefined("session.user.accountid")>
		<cfset aid = session.user.accountid>
	<cfelse>
		<cfset aid = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET lid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newLID#">,
			dlid = GETDATE()
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemid#">
	</cfquery>
	<cfquery datasource="#request.dsn#">
		INSERT INTO location_history
		(itemid, lid, aid)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newLID#">,
			<cfqueryparam cfsqltype="cf_sql_int" value="#aid#">
		)
	</cfquery>
	<cfset LogAction("item #arguments.itemid# location set to #arguments.newLID#")>
</cffunction>

<cffunction name="fChangeStatus" output="true" returntype="query">
	<cfargument name="item">
	<cfargument name="newstatus">

	<cfquery datasource="#request.dsn#" name="sqlItem">
		SELECT i.status, a.email, a.first, a.last, i.ebayitem, s.status AS old_status_name, s2.status AS new_status_name
		FROM items i
			INNER JOIN accounts a ON i.aid = a.id
			LEFT JOIN status s ON s.id = i.status
			LEFT JOIN status s2 ON s2.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newstatus#">
		WHERE i.item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
	</cfquery>

	<cfif sqlItem.status EQ arguments.newstatus>
		<cfreturn sqlItem><!--- return old status --->
	</cfif>

	<cfset LogAction("changed item #arguments.item# status from (#sqlItem.old_status_name#) to (#sqlItem.new_status_name#)")>

	<cfquery datasource="#request.dsn#">
		UPDATE items
		SET status = '#arguments.newstatus#'
		<cfif arguments.newstatus EQ 3><!--- Item Received  --->
			, dreceived = GETDATE()
		<cfelseif ListFind("9,10,11,13", arguments.newstatus)><!--- Returned to Client, Awaiting Shipment, Paid and Shipped, Donated to Charity --->
			, exception = 0
		</cfif>
		WHERE item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
	</cfquery>

	<cfquery datasource="#request.dsn#">
		INSERT INTO status_history (iid, timestamp, old_status, new_status)
		VALUES ('#arguments.item#', DATEDIFF(SECOND, '01/01/1970', GETUTCDATE()), '#sqlItem.status#', '#arguments.newstatus#')
	</cfquery>

	<cfswitch expression="#arguments.newstatus#">
<!--- TODO - ENABLE WHEN API WORKS
		<cfcase value="3"><!--- ITEM RECEIVED --->
			<cfif isEmail(sqlItem.email)>
				<cfmail to="#sqlItem.email#" from="info@instantauctions.net" subject="Instant Auctions: Item #arguments.item# Received">
Dear #sqlItem.first# #sqlItem.last#,

#_vars.emails.item_received_message#

--
Instant Auctions Support
http://www.instantauctions.net/
				</cfmail>
			</cfif>
		</cfcase>
--->
		<cfcase value="4"><!--- AUCTION LISTED --->
			<cfif isEmail(sqlItem.email)>
				<cfmail server="#_vars.mails.server#" port="#_vars.mails.port#" from="#_vars.mails.from#" to="#sqlItem.email#" subject="Instant Auctions: Item #arguments.item# Listed as #sqlItem.ebayitem#">
Dear #sqlItem.first# #sqlItem.last#,

#_vars.emails.auction_listed_message#

http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#sqlItem.ebayitem#

--
Instant Auctions Support
http://www.instantauctions.net/
				</cfmail>
			</cfif>
		</cfcase>
		<cfcase value="9"><!--- RTC --->
			<cfset fChangeLocation(arguments.item, "RTC")>
		</cfcase>
	</cfswitch>

	<cfreturn sqlItem><!--- return old status --->

</cffunction>

<cffunction output="false" returntype="void" name="LogAction">
	<cfargument name="sAction" type="string" required="yes">
	<cfif isDefined("session.user.accountid")>
		<cfset aid = session.user.accountid>
	<cfelse>
		<cfset aid = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		INSERT INTO logs
		(aid, activity, dwhen)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#aid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(arguments.sAction, 200)#" maxlength="200">,
			GETDATE()
		)
	</cfquery>
</cffunction>

<!--- Item Related Expenses --->
<cffunction output="false" returntype="void" name="LogIRE">
	<cfargument name="tid" type="numeric" required="yes">
	<cfargument name="amount" type="numeric" required="yes">
	<cfargument name="itemid" type="string" required="yes">
	<cfargument name="ebayitem" type="string" required="yes">
	<cfif isDefined("session.user.accountid")>
		<cfset aid = session.user.accountid>
	<cfelse>
		<cfset aid = 0>
	</cfif>
	<cfquery datasource="#request.dsn#">
		INSERT INTO ire_data
		(aid_create, tid, amount, itemid, ebayitem)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#aid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tid#">,
			<cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ebayitem#">
		)
	</cfquery>
</cffunction>

<cffunction output="false" returntype="void" name="LogDynamicIRE">
	<cfargument name="gid" type="numeric" required="yes">
	<cfargument name="title" type="string" required="yes">
	<cfargument name="amount" type="numeric" required="yes">
	<cfargument name="itemid" type="string" required="yes">
	<cfargument name="ebayitem" type="string" required="yes">
	<cfif isDefined("session.user.accountid")>
		<cfset aid = session.user.accountid>
	<cfelse>
		<cfset aid = 0>
	</cfif>
	<cfquery datasource="#request.dsn#" name="sqlIREType">
		SELECT tid
		FROM ire_types
		WHERE title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">;
	</cfquery>
	<cfif sqlIREType.RecordCount EQ 0>
		<cfquery datasource="#request.dsn#" name="sqlIREType">
			INSERT INTO ire_types
			(gid, title, note)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.gid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="Automatically added at #DateFormat(Now())# #TimeFormat(Now())# for account #aid#">
			);
			SELECT @@IDENTITY AS tid;
		</cfquery>
	</cfif>
	<cfquery datasource="#request.dsn#">
		INSERT INTO ire_data
		(aid_create, tid, amount, itemid, ebayitem)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_integer" value="#aid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#sqlIREType.tid#">,
			<cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ebayitem#">
		)
	</cfquery>
</cffunction>

<!--- SETTINGS --->
<cffunction output="false" returntype="string" name="getVar">
	<cfargument name="sname" required="yes" type="string">
	<cfargument name="sdefault" required="yes" type="string">
	<cfargument name="stype" required="yes" type="string">
	<cfscript>
		var vargroup = ListFirst(arguments.sname, ".");
		var varname = ListRest(arguments.sname, ".");
		if(NOT StructKeyExists(application, "vars")){
			application.vars = StructNew();
		}
	</cfscript>
	<cfif NOT isDefined("application.vars.#arguments.sname#")>
		<cfquery name="sqlVar" datasource="#request.dsn#">
			SELECT avalue FROM settings WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sname#">
		</cfquery>
		<cfif NOT StructKeyExists(application.vars, vargroup)>
			<cfset application.vars[vargroup] = StructNew()>
		</cfif>
		<cfif sqlVar.RecordCount EQ 1>
			<cfset application.vars[vargroup][varname] = sqlVar.avalue>
		<cfelse>
			<cfquery name="sqlVar" datasource="#request.dsn#">
				INSERT INTO settings
				(name, avalue, type)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sname#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.sdefault#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stype#">
				)
			</cfquery>
			<cfset application.vars[vargroup][varname] = arguments.sdefault>
		</cfif>
	</cfif>
	<cfreturn application.vars[vargroup][varname]>
</cffunction>

<cfset request.getVar = getVar>

<cffunction output="false" returntype="string" name="MakePageName">
	<cfargument name="pagename" required="yes" type="string">
	<cfargument name="suggestion" required="yes" type="string">
	<cfif Trim(arguments.pagename) EQ "">
		<cfset arguments.pagename = Replace(arguments.suggestion, " ", "_", "ALL") & ".html">
	</cfif>
	<cfreturn LCase(REReplace(arguments.pagename, "[^a-zA-Z0-9_/.]*", "", "ALL"))>
</cffunction>


<cffunction output="false" returntype="string" name="getVarWS">
	<cfargument name="sname" required="yes" type="string">
	<cfargument name="sdefault" required="yes" type="string">
	<cfargument name="stype" required="yes" type="string">
	<cfscript>
		var vargroup = ListFirst(arguments.sname, ".");
		var varname = ListRest(arguments.sname, ".");
		if(NOT StructKeyExists(application, "varsWS")){
			application.varsWS = StructNew();
		}
	</cfscript>
	<cfif NOT isDefined("application.varsWS.#arguments.sname#")>
		<cfquery name="sqlVar" datasource="#request.dsn#">
			SELECT avalue FROM store_settings WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sname#">
		</cfquery>
		<cfif NOT StructKeyExists(application.varsWS, vargroup)>
			<cfset application.varsWS[vargroup] = StructNew()>
		</cfif>
		<cfif sqlVar.RecordCount EQ 1>
			<cfset application.varsWS[vargroup][varname] = sqlVar.avalue>
		<cfelse>
			<cfquery name="sqlVar" datasource="#request.dsn#">
				INSERT INTO store_settings
				(name, avalue, type)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sname#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.sdefault#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stype#">
				)
			</cfquery>
			<cfset application.varsWS[vargroup][varname] = arguments.sdefault>
		</cfif>
	</cfif>
	<cfreturn application.varsWS[vargroup][varname]>
</cffunction>



<cfset request.getVarWS = getVarWS>


<cffunction name="returnSurepostPrice" access="private" hint="Given a zip. The function returns Surepost price. Returns 0 if nothing found with the given zip and weight arguments">
	<cfargument name="ReceiverZip" required="true" >
	<cfargument name="itemWeight" required="true" hint="weight of the item to be shipped in pounds (LBS)" >
	<cfset local.receiver3char = left(arguments.ReceiverZip,3)>
	
	<!---
	For shipments originating in ZIP Codes 403-01 to 405-99. To determine zone
	take the first three digits of the receiver's ZIP Code and refer to the chart below:
	--->
	
	<cfset local.returnVal.price = 0 >
	<cfset local.returnVal.zone = 0 >
	
	<!---															alaska	hawaii	Puerto rico				(army post/air fleet)			
	Wgt in 	US48	US48	US48	US48	US48	US48	US48	AK		HI		PR		Other 			APO/FPO
	lbs																						US Territories
	Zones	2		3		4		5		6		7		8		9		10		11		12				13
	1		6.94 	6.94 	6.94 	7.03 	7.28 	7.38 	7.49 	14.16 	14.16 	14.16 	14.16 			11.86 
	2		6.94 	7.14 	7.71 	7.87 	8.21 	8.38 	8.62 	16.74 	16.74 	16.74 	16.74 			13.04 
	3		6.94 	7.44 	8.13 	8.37 	8.72 	9.01 	9.52 	18.94 	18.94 	18.94 	18.94 			14.49 
	4		6.95 	7.62 	8.52 	8.90 	9.16 	9.59 	10.21 	20.32 	20.32 	20.32 	20.32 			16.28 
	5		6.98 	7.68 	8.83 	9.24 	9.45 	9.95 	10.71 	21.41 	21.41 	21.41 	21.41 			18.67 
	6		7.22 	7.90 	8.94 	9.42 	9.68 	10.20 	10.80 	22.89 	22.89 	22.89 	22.89 			21.50 
	7		7.62 	8.10 	9.10 	9.63 	9.85 	10.47 	11.21 	26.21 	26.21 	26.21 	26.21 			24.18 
	8		7.76 	8.30 	9.25 	9.81 	10.16 	10.79 	11.59 	27.97 	27.97 	27.97 	27.97 			27.14 
	9		7.98 	8.49 	9.37 	9.89 	10.37 	11.24 	12.32 	29.49 	29.49 	29.49 	29.49 			29.62 
	--->

	<cfset local.objSurePost = structnew()>
	<!--- zone 2 --->
	<cfset local.objSurePost.us48.zone2[1] = 6.94>
	<cfset local.objSurePost.us48.zone2[2] = 6.94>
	<cfset local.objSurePost.us48.zone2[3] = 6.94>
	<cfset local.objSurePost.us48.zone2[4] = 6.95>
	<cfset local.objSurePost.us48.zone2[5] = 6.98>
	<cfset local.objSurePost.us48.zone2[6] = 7.22>
	<cfset local.objSurePost.us48.zone2[7] = 7.62>
	<cfset local.objSurePost.us48.zone2[8] = 7.76>
	<cfset local.objSurePost.us48.zone2[9] = 7.98>
	<!--- zone 3 --->
	<cfset local.objSurePost.us48.zone3[1] = 6.94>
	<cfset local.objSurePost.us48.zone3[2] = 7.14>
	<cfset local.objSurePost.us48.zone3[3] = 7.44>
	<cfset local.objSurePost.us48.zone3[4] = 7.62>
	<cfset local.objSurePost.us48.zone3[5] = 7.68>
	<cfset local.objSurePost.us48.zone3[6] = 7.90>
	<cfset local.objSurePost.us48.zone3[7] = 8.10>
	<cfset local.objSurePost.us48.zone3[8] = 8.30>
	<cfset local.objSurePost.us48.zone3[9] = 8.49>
	<!--- zone 4 --->
	<cfset local.objSurePost.us48.zone4[1] = 6.94>
	<cfset local.objSurePost.us48.zone4[2] = 7.71>
	<cfset local.objSurePost.us48.zone4[3] = 8.13>
	<cfset local.objSurePost.us48.zone4[4] = 8.52>
	<cfset local.objSurePost.us48.zone4[5] = 8.83>
	<cfset local.objSurePost.us48.zone4[6] = 8.94>
	<cfset local.objSurePost.us48.zone4[7] = 9.10>
	<cfset local.objSurePost.us48.zone4[8] = 9.25>
	<cfset local.objSurePost.us48.zone4[9] = 9.37>
	<!--- zone 5 --->
	<cfset local.objSurePost.us48.zone5[1] = 7.03>
	<cfset local.objSurePost.us48.zone5[2] = 7.87>
	<cfset local.objSurePost.us48.zone5[3] = 8.37>
	<cfset local.objSurePost.us48.zone5[4] = 8.90>
	<cfset local.objSurePost.us48.zone5[5] = 9.24>
	<cfset local.objSurePost.us48.zone5[6] = 9.42>
	<cfset local.objSurePost.us48.zone5[7] = 9.63>
	<cfset local.objSurePost.us48.zone5[8] = 9.81>
	<cfset local.objSurePost.us48.zone5[9] = 9.89>
	<!--- zone 6 --->
	<cfset local.objSurePost.us48.zone6[1] = 7.03>
	<cfset local.objSurePost.us48.zone6[2] = 7.87>
	<cfset local.objSurePost.us48.zone6[3] = 8.37>
	<cfset local.objSurePost.us48.zone6[4] = 8.90>
	<cfset local.objSurePost.us48.zone6[5] = 9.24>
	<cfset local.objSurePost.us48.zone6[6] = 9.42>
	<cfset local.objSurePost.us48.zone6[7] = 9.63>
	<cfset local.objSurePost.us48.zone6[8] = 9.81>
	<cfset local.objSurePost.us48.zone6[9] = 9.89>
	
	<!--- zone 7 --->
	<cfset local.objSurePost.us48.zone7[1] = 7.38>
	<cfset local.objSurePost.us48.zone7[2] = 8.38>
	<cfset local.objSurePost.us48.zone7[3] = 9.01>
	<cfset local.objSurePost.us48.zone7[4] = 9.59>
	<cfset local.objSurePost.us48.zone7[5] = 9.95>
	<cfset local.objSurePost.us48.zone7[6] = 10.20>
	<cfset local.objSurePost.us48.zone7[7] = 10.47>
	<cfset local.objSurePost.us48.zone7[8] = 10.79>
	<cfset local.objSurePost.us48.zone7[9] = 11.24>
	
	<!--- zone 8 --->
	<cfset local.objSurePost.us48.zone8[1] = 7.49>
	<cfset local.objSurePost.us48.zone8[2] = 8.62>
	<cfset local.objSurePost.us48.zone8[3] = 9.52>
	<cfset local.objSurePost.us48.zone8[4] = 10.21>
	<cfset local.objSurePost.us48.zone8[5] = 10.71>
	<cfset local.objSurePost.us48.zone8[6] = 10.80>
	<cfset local.objSurePost.us48.zone8[7] = 11.21>
	<cfset local.objSurePost.us48.zone8[8] = 11.59>
	<cfset local.objSurePost.us48.zone8[9] = 12.32>
	
	<!--- zone 9 - 12 have the same price --->
	<cfset local.objSurePost.us48.zone9[1] = 14.16>
	<cfset local.objSurePost.us48.zone9[2] = 16.74>
	<cfset local.objSurePost.us48.zone9[3] = 18.94>
	<cfset local.objSurePost.us48.zone9[4] = 20.32>
	<cfset local.objSurePost.us48.zone9[5] = 21.41>
	<cfset local.objSurePost.us48.zone9[6] = 22.89>
	<cfset local.objSurePost.us48.zone9[7] = 26.21>
	<cfset local.objSurePost.us48.zone9[8] = 27.97>
	<cfset local.objSurePost.us48.zone9[9] = 29.49>
	<!--- zone 10 --->
	<cfset local.objSurePost.us48.zone10[1] = 14.16>
	<cfset local.objSurePost.us48.zone10[2] = 16.74>
	<cfset local.objSurePost.us48.zone10[3] = 18.94>
	<cfset local.objSurePost.us48.zone10[4] = 20.32>
	<cfset local.objSurePost.us48.zone10[5] = 21.41>
	<cfset local.objSurePost.us48.zone10[6] = 22.89>
	<cfset local.objSurePost.us48.zone10[7] = 26.21>
	<cfset local.objSurePost.us48.zone10[8] = 27.97>
	<cfset local.objSurePost.us48.zone10[9] = 29.49>
	<!--- zone 11 --->
	<cfset local.objSurePost.us48.zone11[1] = 14.16>
	<cfset local.objSurePost.us48.zone11[2] = 16.74>
	<cfset local.objSurePost.us48.zone11[3] = 18.94>
	<cfset local.objSurePost.us48.zone11[4] = 20.32>
	<cfset local.objSurePost.us48.zone11[5] = 21.41>
	<cfset local.objSurePost.us48.zone11[6] = 22.89>
	<cfset local.objSurePost.us48.zone11[7] = 26.21>
	<cfset local.objSurePost.us48.zone11[8] = 27.97>
	<cfset local.objSurePost.us48.zone11[9] = 29.49>
	<!--- zone 12 --->
	<cfset local.objSurePost.us48.zone12[1] = 14.16>
	<cfset local.objSurePost.us48.zone12[2] = 16.74>
	<cfset local.objSurePost.us48.zone12[3] = 18.94>
	<cfset local.objSurePost.us48.zone12[4] = 20.32>
	<cfset local.objSurePost.us48.zone12[5] = 21.41>
	<cfset local.objSurePost.us48.zone12[6] = 22.89>
	<cfset local.objSurePost.us48.zone12[7] = 26.21>
	<cfset local.objSurePost.us48.zone12[8] = 27.97>
	<cfset local.objSurePost.us48.zone12[9] = 29.49>
	<!--- zone 13 --->
	<cfset local.objSurePost.us48.zone13[1] = 11.86>
	<cfset local.objSurePost.us48.zone13[2] = 13.04>
	<cfset local.objSurePost.us48.zone13[3] = 14.49>
	<cfset local.objSurePost.us48.zone13[4] = 16.28>
	<cfset local.objSurePost.us48.zone13[5] = 18.67>
	<cfset local.objSurePost.us48.zone13[6] = 21.50>
	<cfset local.objSurePost.us48.zone13[7] = 24.18>
	<cfset local.objSurePost.us48.zone13[8] = 27.14>
	<cfset local.objSurePost.us48.zone13[9] = 29.62>
	

	<cfquery name="local.getGround" datasource="#request.dsn#" >
		SELECT A.destzip, A.Ground FROM
		(
		select 
		Convert(int, SUBSTRING(destzip,1,3)) StartNum,
		Convert(int, SUBSTRING(destzip,5,3)) EndNum,
		*
		from upsSurepostZipZones
		) AS A
		
		WHERE '#receiver3char#' >= A.StartNum AND '#receiver3char#' <= A.EndNum
	
	</cfquery>
	
	<cfif local.getGround.recordCount gte 1>

		<cfif structkeyExists(local.objSurePost.us48,"zone#abs(getGround.ground)#")
		and structkeyExists(local.objSurePost.us48['zone#abs(getGround.ground)#'],"#round(arguments.itemWeight)#")>
		
			<cfset local.returnVal.price = local.objSurePost.us48['zone#abs(getGround.ground)#'][#round(arguments.itemWeight)#]>
			<cfset local.returnVal.zone = abs(getGround.ground) >
		</cfif>
		
		
	</cfif>
	
	<cfreturn local.returnVal>

</cffunction>

<cffunction name="auctionPrices" output="true" >
	
						
		<cfreturn 		'<option value="0.0">-- Select --</option>
						<option value=".01">.01</option>
						<option value="0.99">0.99</option>
						
						<option value="4.99">4.99</option>
						<option value="6.99">6.99</option>
						<option value="9.99">9.99</option>
						<option value="12.99">12.99</option>
						
						<option value="14.99">14.99</option>
						<option value="19.99">19.99</option>
						<option value="24.99">24.99</option>
						<option value="29.98">29.98</option>
						<option value="34.99">34.99</option>
						<option value="39.99">39.99</option>
						<option value="44.98">44.98</option>
						<option value="49.99">49.99</option>
						<option value="54.98">54.98</option>
						
						<option value="59.98">59.98</option>
						<option value="64.97">64.97</option>
						<option value="69.99">69.99</option>
						<option value="74.97">74.97</option>
						<option value="79.97">79.97</option>
						<option value="84.99">84.99</option>
						<option value="89.97">89.97</option>
						<option value="94.97">94.97</option>
						<option value="99.99">99.99</option>
						<option value="109.97">109.97</option>
						<option value="119.95">119.95</option>
						<option value="129.97">129.97</option>
						<option value="149.95">149.95</option>
						<option value="199.97">199.97</option>
						
						<option value="249.98">249.98</option>
						<option value="299.97">299.97</option>
						
						<option value="399.98">399.98</option>
						<option value="499.98">499.98</option>' >
</cffunction>	

<cffunction name="parseState" output="false" >
	<cfargument name="state" >
	
		<cfif len(arguments.state) GT 2 >
			<!--- greater than 2 then lets match to db --->
			<cfquery datasource="#request.dsn#" name="getInitial">
				SELECT initial 
				from usStates
				WHERE  state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.state#">
			</cfquery>
			
			<cfif getInitial.recordCount gte 1>
				<cfreturn trim(getInitial.initial)>
			<cfelse>
				<cfreturn arguments.state>
			</cfif>
		
		 <cfelse>
			<cfreturn arguments.state>	
		 </cfif>	
	
	<cfreturn arguments.state>
</cffunction>