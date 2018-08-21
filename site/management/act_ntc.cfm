<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>
<cfparam name="attributes.dsp" default="management.need_return">

<cfparam name="attributes.ntcITEMS" default="">
<cfif Trim(attributes.ntcITEMS) NEQ "">
	<cfloop index="itemid" list="#attributes.ntcITEMS#">
		<cfset fChangeStatus (itemid, 12)><!--- NEED TO CALL --->
	</cfloop>
</cfif>

<cfparam name="attributes.ntrITEMS" default="">
<cfif Trim(attributes.ntrITEMS) NEQ "">
	<cfloop index="itemid" list="#attributes.ntrITEMS#">
		<cfset fChangeStatus (itemid, 16)><!--- NEED TO RELOT --->
	</cfloop>
</cfif>

<cfparam name="attributes.ap3ITEMS" default="">
<cfif Trim(attributes.ap3ITEMS) NEQ "">
	<cfset attributes.exception = "2"><!--- AP 25+ Days --->
	<cfset attributes.items = attributes.ap3ITEMS>
	<cfinclude template="../admin/act_exception.cfm">
</cfif>

<cfparam name="attributes.relITEMS" default="">
<cfif Trim(attributes.relITEMS) NEQ "">
	<cfloop index="itemid" list="#attributes.relITEMS#">
		<cfset fChangeStatus (itemid, 14)><!--- ITEM RELOTTED --->
	</cfloop>
</cfif>

<cfparam name="attributes.dtcITEMS" default="">
<cfif Trim(attributes.dtcITEMS) NEQ "">
	<cfloop index="itemid" list="#attributes.dtcITEMS#">
		<cfset fChangeStatus(itemid, 13)><!--- DONATED TO CHARITY --->
		<cfset fChangeLocation(itemid, "DTC")>
	</cfloop>
</cfif>

<cfparam name="attributes.ntdITEMS" default="">
<cfif Trim(attributes.ntdITEMS) NEQ "">
	<cfloop index="itemid" list="#attributes.ntdITEMS#">
		<cfset fChangeStatus(itemid, 13)><!--- DONATED TO CHARITY --->
	</cfloop>
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=" & attributes.dsp>
