<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "system">
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="schedule,api" delimiters=",">
			<cfinclude template="dsp_schedule.cfm">
		</cfcase>
		<cfcase value="second_chance">
			<cfinclude template="dsp_second_chance.cfm">
		</cfcase>
		<cfcase value="scheduled_task_061006">
			<cfset _machine.layout = "none">
			<cfinclude template="st_runall.cfm">
		</cfcase>
		
		<cfcase value="st_getEbayQuantity">
			<cfset _machine.layout = "none">
			<cfinclude template="st_getEbayQuantity.cfm">
		</cfcase>
		
		<cfcase value="dsp_addScheduleGetEbayQty">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_addScheduleGetEbayQty.cfm">
		</cfcase>		

		<cfcase value="st_alertAmazonQty">
			<cfset _machine.layout = "none">
			<cfinclude template="st_alertAmazonQty.cfm">
		</cfcase>	

		<cfdefaultcase>
			<cfthrow type="machine" message="Unknown display (#_machine.dsp#)">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfset _machine.module = ListFirst(_machine.dsp, ".")>
	<cfset _machine.dsp = ListRest(_machine.dsp, ".")>
	<cfinclude template="#_machine.module#\dsp_index.cfm">
</cfif>
