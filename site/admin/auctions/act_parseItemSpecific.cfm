<!---

attr_tCSId_attributeId
	This format is generated for attributes that are to be displayed in text boxes,
	including other-value attributes (id="-6").  

attr_dCSId_attributeId_metacharacter
	The ending metacharacter is either m (month), d (day), or y (year).
	This format is generated for date drop-down lists if the format of the attribute
	matches the format char_char_char (e.g., "m_d_y") and the widget is a date (type="date").
	For example, for a Year attribute with id = 2 in the characteristic set whose id = 10,
	a drop-down list is generated with the name "attr_d10_2_y".  

attr_dCSId_attributeId_c 
	This format is generated for attributes that should be displayed as text boxes containing
	a full calendar date (e.g., "05/10/06") .  

attr_required_CSId_attributeId=true: 
	This format is generated to identify attributes that become required according to Type 5,
	Value-to-Meta-data (VM) dependencies. SeeChild Required-Status Dependencies
	(Type 5: Value-to-Meta-data).  

attrCSId_attributeId 
	This format is generated for all other attributes.  
--->

<cfparam name="attributes.item">
<cfset asa = ArrayNew(1)>
<cfif isDefined("attributes.FieldNames")>
	<cfloop index="field" list="#attributes.FieldNames#">
		<cfif (Left(field , 4) EQ "attr") AND (ListLen(field, "_") GT 0)>
			<!---<cfoutput><li>#field# = #attributes[field]#</li></cfoutput>--->
			<cfset skipAttribute = FALSE>
			<!--- attr_tCSId_attributeId --->
			<cfif Mid(field, 6, 1) EQ "T">
				<cfset attributeSetID = ListFirst(Mid(field, 7, Len(field)-6), "_")>
				<cfset x = StructNew()>
				<cfset x.attributeID = ListLast(field, "_")>
				<cfif StructKeyExists(attributes, "attr#attributeSetID#_#x.attributeID#")>
					<cfset x.ValueID = attributes["attr#attributeSetID#_#x.attributeID#"]>
				<cfelse>
					<cfset x.ValueID = "">
				</cfif>
				<cfset x.ValueLiteral = attributes[field]>
				<cfset x.metacharacter = "">
			<!--- attr_dCSId_attributeId_metacharacter --->
			<cfelseif (Mid(field, 6, 1) EQ "D") AND ListFindNoCase("m,d,y", ListLast(field, "_"))>
				<cfset attributeSetID = ListFirst(Mid(field, 7, Len(field)-6), "_")>
				<cfset x = StructNew()>
				<cfset x.attributeID = ListGetAt(field, 3, "_")>
				<cfset x.ValueID = "">
				<cfset x.ValueLiteral = attributes[field]>
				<cfset x.metacharacter = ListLast(field, "_")>
			<!--- attr_dCSId_attributeId_c --->
			<cfelseif Mid(field, 6, 1) EQ "D">
				<cfset attributeSetID = ListFirst(Mid(field, 7, Len(field)-6), "_")>
				<cfset x = StructNew()>
				<cfset x.attributeID = ListGetAt(field, 3, "_")>
				<cfset x.ValueID = attributes[field]>
				<cfset x.ValueLiteral = "">
				<cfset x.metacharacter = "">
			<!--- attr_required_CSId_attributeId=true --->
			<cfelseif ListGetAt(field, 2, "_") EQ "required">
				<cfset skipAttribute = TRUE>
			<!--- attrCSId_attributeId --->
			<cfelseif ListLen(field, "_") EQ 2>
				<cfset attributeSetID = ListFirst(Mid(field, 5, Len(field)-4), "_")>
				<cfset x = StructNew()>
				<cfset x.attributeID = ListLast(field, "_")>
				<cfset x.ValueID = attributes[field]>
				<cfset x.ValueLiteral = "">
				<cfset x.metacharacter = "">
				<cfif StructKeyExists(attributes, "attr_T#attributeSetID#_#x.attributeID#")>
					<cfset skipAttribute = TRUE>
				</cfif>
			<cfelse>
				<cfset skipAttribute = TRUE>
			</cfif>
			<cfif NOT skipAttribute>
				<cfset asI = 0>
				<cfloop index="i" from="1" to="#ArrayLen(asa)#">
					<cfif asa[i].attributeSetID EQ attributeSetID>
						<cfset asI = i>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif asI EQ 0>
					<cfset ArrayAppend(asa, StructNew())>
					<cfset asI = ArrayLen(asa)>
					<cfset asa[asI].attributeSetID = attributeSetID>
					<cfset asa[asI].attr = ArrayNew(1)>
				</cfif>
				<cfset ArrayAppend(asa[asI].attr, x)>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
