<cfif ListLen(_machine.dsp, ".") EQ 1>
	<cfset _machine.menuName = "management">
	<cfswitch expression="#_machine.dsp#">
		<cfcase value="ship_sold_off">
			<cfset attributes.pageTitle = "Awaiting Shipment (Sold Off eBay):">
			<cfinclude template="dsp_ship_sold_off.cfm">
		</cfcase>
		<cfcase value="gl">
			<cfset attributes.pageTitle = "Generate Label:">
			<cfinclude template="dsp_gl.cfm">
		</cfcase>
		
		<cfcase value="gl_lti">
			<!--- vlad added this 20120131 --->
			<cfset attributes.pageTitle = "Generate Label:">
			<cfinclude template="dsp_gl_lti.cfm">
		</cfcase>
		
		<cfcase value="awaiting">
			<cfset attributes.pageTitle = "Awaiting Shipment:">
			<cfinclude template="dsp_awaiting.cfm">
		</cfcase>
		<cfcase value="awaitingFixedPriceV2">
			<cfset attributes.pageTitle = "Awaiting Linking Fixed Price Items:">
			<cfinclude template="dsp_awaitingFixedPriceV2.cfm">
		</cfcase>
		<cfcase value="awaitingFixedPriceV3">
			<cfset attributes.pageTitle = "Awaiting Linking Fixed Price Items:">
			<cfinclude template="dsp_awaitingFixedPriceV3.cfm">
		</cfcase>		
		<cfcase value="awaitingFixedPrice">
			<cfset attributes.pageTitle = "Awaiting Shipment Fixed Price Items:">
			<cfinclude template="dsp_awaitingFixedPrice.cfm">
		</cfcase>
		<cfcase value="urgent">
			<cfset attributes.pageTitle = "Urgent Shipment:">
			<cfinclude template="dsp_awaiting.cfm">
		</cfcase>
		<cfcase value="combined">
			<cfset attributes.pageTitle = "Combined Shipment:">
			<cfinclude template="dsp_awaiting.cfm">
		</cfcase>
		
		<cfcase value="international">
			<cfset attributes.pageTitle = "International Shipment:">
			<cfinclude template="dsp_awaiting.cfm">
		</cfcase>
		<cfcase value="refund">
			<cfset attributes.pageTitle = "Refund Items:">
			<cfinclude template="dsp_awaiting.cfm">
		</cfcase>
		<cfcase value="confirm,accept" delimiters=",">
			<cfinclude template="dsp_generate_label.cfm">
		</cfcase>
		<cfcase value="confirm_multilabel,accept_multilabel" delimiters=",">
			<cfinclude template="dsp_generate_multilabel.cfm">
		</cfcase>
		<cfcase value="shipping_list">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_shipping_list.cfm">
		</cfcase>
		<cfcase value="shipping_listFixedPrice">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_shipping_listFixedPrice.cfm">
		</cfcase>
		
		<cfcase value="daily_report">
			<cfset _machine.layout = "slip">
			<cfinclude template="dsp_daily_report.cfm">
		</cfcase>
		<cfcase value="note">
			<cfset _machine.layout = "none">
			<cfinclude template="dsp_note.cfm">
		</cfcase>
		<cfcase value="link_to_item">
			<cfinclude template="dsp_link_to_item.cfm">
		</cfcase>
		<cfcase value="link_to_itemMultiV2">
			<cfinclude template="dsp_link_to_itemMultiV2.cfm">
		</cfcase>
		<cfcase value="link_to_itemMulti">
			<cfinclude template="dsp_link_to_itemMulti.cfm">
		</cfcase>
		<cfcase value="awaitingShipFixedItemsOnly">
			<cfset _machine.layout = "default">
			<cfset attributes.pageTitle = "Awaiting Ship Fixed Items Only:">

			<cfinclude template="dsp_awaitingShipFixedItemsOnly.cfm">
		</cfcase>
		<cfcase value="upsSurepostTest">
			<cfset _machine.layout = "default">
			<cfset attributes.pageTitle = "UPS Surepost Test">

			<cfinclude template="upsSurepostTest.cfm">
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
