<cfquery name="sqlMenu" datasource="#request.dsn#">
	SELECT pid, title, CASE WHEN pagetype = 1 THEN pagename ELSE 'index.cfm/' + pagename END AS pagename
	FROM store_pages
	WHERE status IN (1, 2)
		AND parentid = 0
	ORDER BY sort, title
</cfquery>
<cfquery name="sqlFooter" datasource="#request.dsn#">
	SELECT pid, title, CASE WHEN pagetype = 1 THEN pagename ELSE 'index.cfm/' + pagename END AS pagename
	FROM store_pages
	WHERE status = 3
	ORDER BY sort, title
</cfquery>
<cffunction name="sectionsMenu" output="false" returntype="string">
	<cfargument name="parentid" type="numeric" required="yes">
	<cfquery name="sqlSections" datasource="#request.dsn#">
		SELECT pid, title, CASE WHEN pagetype = 1 THEN pagename ELSE 'index.cfm/' + pagename END AS pagename
		FROM store_pages
		WHERE parentid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentid#">
		ORDER BY sort, title
	</cfquery>
	<cfsavecontent variable="txt">
		<cfif sqlSections.RecordCount GT 0>
			<cfoutput><ul><cfloop query="sqlSections">
				<li><a href="#pagename#">#title#</a></li></cfloop>
			</ul></cfoutput>
		</cfif>
	</cfsavecontent>
	<cfreturn txt>
</cffunction>

<cfoutput>
<ul id="navmenu">
	<cfif isGuest() OR (session.user.site EQ "ebay")>
		<cfloop query="sqlMenu">
			<li><a href="#pagename#">#title#</a>#sectionsMenu(pid)#</li>
		</cfloop>
	<cfelse>
		<li><a href="JavaScript:void(0);">Public pages...</a>
			<ul>
			<cfloop query="sqlMenu">
				<li><a href="#pagename#">#title#</a>#sectionsMenu(pid)#</li>
			</cfloop>
			</ul>
		</li>
		<cfif isAllowedWS("Store_Accounts") OR isAllowedWS("Store_Vendors")>
			<li><a href="JavaScript:void(0);">Management...</a>
				<ul>
					<cfif isAllowedWS("Store_Accounts")>
						<li><a href="index.cfm?dsp=store.admin.accounts.list">Accounts</a></li>				
					</cfif>
					<cfif isAllowedWS("Store_Vendors")>
						<li><a href="index.cfm?dsp=store.admin.vendors.list">Vendors</a></li>				
					</cfif>
				</ul>
			</li>
		</cfif>
		<cfif isAllowedWS("Store_Categories") OR isAllowedWS("Store_Products")>
			<li><a href="JavaScript:void(0);">Store...</a>
				<ul>
					<cfif isAllowedWS("Store_Categories")>
						<li><a href="index.cfm?dsp=store.admin.categories.list">Categories</a></li>				
					</cfif>
					<cfif isAllowedWS("Store_Products")>
						<li><a href="index.cfm?dsp=store.admin.products.list">Products</a></li>				
					</cfif>
				</ul>
			</li>
		</cfif>
		<cfif isAllowedWS("Store_Orders")>
			<li><a href="JavaScript:void(0);">Orders...</a>
				<ul>
					<cfif isAllowedWS("Store_Orders")>
						<li><a href="index.cfm?dsp=store.admin.orders.list">Orders</a></li>				
					</cfif>
				</ul>
			</li>
		</cfif>
		<cfif isAllowedWS("Store_Pages") OR isAllowedWS("Store_Roles") OR isAllowedWS("Store_Settings") OR isAllowedWS("Store_OrderSettings")>
			<li><a href="JavaScript:void(0);">System...</a>
				<ul>
					<cfif isAllowedWS("Store_Pages")>
						<li><a href="index.cfm?dsp=store.admin.pages.list">Pages</a></li>
					</cfif>
					<cfif isAllowedWS("Store_Settings")>
						<li><a href="index.cfm?dsp=store.admin.settings.list">Settings</a></li>
						<li><a href="index.cfm?dsp=store.admin.settings.list&RefreshAppVars=true">Refresh Settings</a></li>
					</cfif>
					<cfif isAllowedWS("Store_OrderSettings")>
						<li><a href="index.cfm?dsp=store.admin.settings.order">Order Settings</a></li>
					</cfif>
					<cfif isAllowedWS("Store_Roles")>
						<li><a href="index.cfm?dsp=store.admin.roles.list">Roles</a></li>
					</cfif>
				</ul>
			</li>
		</cfif>
	</cfif>
</ul>
</cfoutput>
