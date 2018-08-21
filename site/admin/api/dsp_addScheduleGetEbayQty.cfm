
<cfoutput>
	<cfdump var="#now()#">
</cfoutput>


<cfschedule action = "update" 
    task = "Get_Ebay_Quantity"
    operation = "HTTPRequest"
    url = "http://www.instantonlineconsignment.com/index.cfm?dsp=admin.api.st_getEbayQuantity"
    startDate = "#DateFormat(Now())#"
    startTime = "07:30 PM"
    interval = "daily"
    resolveURL = "Yes"
    requestTimeOut = "3600"
	publish="yes"
	file="st_getEbayQuantity.html"
	path="#GetDirectoryFromPath(ExpandPath('*.*'))#">
<cfschedule action="run" task="Get_Ebay_Quantity" requesttimeout="10800">


<!---
<!-- This sets the initial task, if your just wanting to set the schedule -->
<cfschedule action = "update"
    task = "Monthly_EOD_Archives"<!---Monthly_EOD_Archives--->
    operation = "HTTPRequest"
    url = "http://www.instantonlineconsignment.com/index.cfm?dsp=admin.eodMonthlySnapshots"
    startDate = "#DateFormat(Now())#"
    startTime = "11:55 PM"
    interval = "daily"
    resolveURL = "Yes"
    requestTimeOut = "3600"
	publish="yes"
	file="Monthly_EOD_Archives.html"
	path="#GetDirectoryFromPath(ExpandPath('*.*'))#">
<cfschedule action="run" task="Monthly_EOD_Archives" requesttimeout="10800">--->

