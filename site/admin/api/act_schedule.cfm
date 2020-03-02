<cfset sURL		= "http://#CGI.HTTP_HOST##CGI.PATH_INFO#?dsp=admin.api.scheduled_task_061006">

<cfswitch expression="#attributes.action#">
	<cfcase value="run">
		<cfset LogAction("runed scheduled task")>
		<cfthread action="run" name="manual_schedule_run">
			<cfschedule action="run" task="ia_scheduled_task_061006" requesttimeout="240000">
		</cfthread>
	</cfcase>
	<cfcase value="delete">
		<cfset LogAction("delete scheduled task")>
		<cfschedule action="#attributes.action#" task="ia_scheduled_task_061006">
		<cfset attr = StructNew ()>
		<cfset attr.name = "system.schtask_runat">
		<cfset attr.avalue = "none">
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
	</cfcase>
	<cfcase value="update">
		<cfset LogAction("update scheduled task")>
		<cfset runTime = CreateTime(ListFirst(attributes.starttime),ListLast(attributes.starttime),0)>
		<cfschedule action="#attributes.action#" task="ia_scheduled_task_061006" operation="HTTPRequest"
			url="#sURL#" startdate="#Now()#" starttime="#runTime#"
			path="#request.basepath#" file="ia_scheduled_task_061006.html.txt"
			resolveurl="yes" publish="yes"
			interval="43200" <!--- make it run 2x daily 86400/2 --->
			requesttimeout="1000">
		<cfset attr = StructNew ()>
		<cfset attr.name = "system.schtask_runat">
		<cfset attr.avalue = "#runTime#">
		<cfmodule template="../act_updatesetting.cfm" attributecollection="#attr#">
	</cfcase>
</cfswitch>
<cfset _machine.cflocation = "index.cfm?dsp=admin.api.schedule">
