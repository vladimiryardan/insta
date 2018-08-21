<cfif NOT isAllowed("Items_ItemLocation")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>




<cfparam name="attributes.itemid" default="">
<cfparam name="attributes.lid" default="">
<cfoutput>
<table width="100%" style="text-align: justify;">
<tr>
	<td width="50%">
		<font size="4"><strong>Item Location:</strong></font><br>
		<a href="index.cfm?dsp=management.items.locationlist" target="_blank">Location List</a> <a href="index.cfm?dsp=management.items.locationlisterrors" target="_blank">Location Errors</a>
	</td>
	<td width="50%">
		<b>Print Daily Report For: </b>
		<a href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(DateAdd('d', -1, Now()))#" target="_blank">Yesterday</a>
		&nbsp;|&nbsp;
		<a href="index.cfm?dsp=admin.packing_daily_report&repday=#DateFormat(Now())#" target="_blank">Today</a>
	</td>
</tr>
</table><br>
<script language="javascript">
<!--//
function fTrace(s){
	window.status = s;
}
var ready2submit = true;
function handler() {
	// see if loading is complete
	if(oHTTP.readyState == 4){
		// check if there were no errors
		if(oHTTP.status == 200){
			fTrace(String(oHTTP.responseText).split("~").pop());
		}else{
			fTrace("XMLHTTP ERROR: " + oHTTP.responseText);
		}
		ready2submit = true;
	}
}
var sURL = "";
var oHTTP;
function scheduledTask(){
	if(ready2submit && (queue.length>0)){
		ready2submit = false;
		sURL = queue.shift();
		fTrace("set locations: " + sURL);
		sURL = "index.cfm?act=management.items.set_locations&" + sURL;
		oHTTP = new ActiveXObject("Microsoft.XMLHTTP");
		if(oHTTP != null){
			oHTTP.onreadystatechange = handler;
		}else{
			fTrace("ERROR: Cannot create Microsoft.XMLHTTP object!");
		}
		oHTTP.open("GET", sURL, true);
		oHTTP.send();
	}
}
var queue = new Array();
var params = "items=";
setInterval(scheduledTask, 2000); // every two seconds
function fSubmit(){
	

	
	var obj = document.getElementById("SCAN");
	if((String(obj.value).split(".")).length != 3){
		if(params != "items="){
			params += "&lid=" + escape(obj.value);
			queue.push(params);
			params = "items=";
		}
	}else{
		if(params != "items="){
			params += ",";
		}
		params += obj.value;
	}
	obj.value = "";
	return false;
}
//-->
</script>
<br><table width=100%><tr><td width=50% align=left>
<font size="8">Enter Item Number<br>or Location ID:</font><br>
<form action="" method="post" onSubmit="return fSubmit();">
	<input type="text" size="20" maxlength="18" id="SCAN" name="SCAN">
	<input type="submit" value="Next">
</form>
</td></tr></table>
<br><br>
<script language="javascript" type="text/javascript">
<!--
document.getElementById("SCAN").focus();
//-->
</script>
</cfoutput>
