<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="amazon_unshipped">
			<cfinclude template="dsp_amazon_unshipped.cfm">
		</cfcase>
		<cfcase value="st_amazonItems">
			<cfset _machine.layout = "none">
			<cfinclude template="st_amazonItems.cfm">
		</cfcase>
		<cfcase value="dsp_link_to_item">
			<cfinclude template="dsp_link_to_item.cfm">
		</cfcase>
		<cfcase value="dsp_multi_linkto_item">
			<cfinclude template="dsp_multi_linkto_item.cfm">
		</cfcase>
		<cfcase value="st_ListOrderItems">
			<cfinclude template="st_ListOrderItems.cfm">
		</cfcase>
		<cfcase value="amazon_paidshipped">
			<cfinclude template="dsp_amazon_paidshipped.cfm">
		</cfcase>
		<cfcase value="amazon_itemMgmt">
			<cfinclude template="dsp_amazon_itemMgmt.cfm">
		</cfcase>
		<cfcase value="item_received">
			<cfinclude template="dsp_item_received.cfm">
		</cfcase>
		<cfcase value="st_SubmitFeed">
			<cfinclude template="st_SubmitFeed_PO_fullfillment_data.cfm">
		</cfcase>
		<cfcase value="st_CheckSubmissionIDS">
			<cfinclude template="st_GetFeedSubmissionList.cfm">
		</cfcase>
		<cfcase value="st_CheckSubmission_result">
			<cfinclude template="st_GetFeedSubmissionResult.cfm">
		</cfcase>
		<cfcase value="amazon_skucount">
			<cfinclude template="dsp_amazon_skucount.cfm">
		</cfcase>
		<!--- vlad test --->
		<cfcase value="st_amazonItemsv2">
			<cfset _machine.layout = "none">
			<cfinclude template="st_amazonItemsv2.cfm">
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
