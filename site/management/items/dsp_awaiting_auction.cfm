<cfif NOT isAllowed("Lister_ListAuction") AND NOT isAllowed("Lister_CreateAuction") AND NOT isAllowed("Lister_EditAuction")>
	<cflocation url="index.cfm?dsp=slim_login&next_dsp=#attributes.dsp#" addtoken="no">
</cfif>

<cfparam name="attributes.orderby" default="6 DESC, 3">
<cfparam name="attributes.customSearchKey" default="">
<cfparam name="attributes.dir" default="ASC">
<cfparam name="attributes.page" default="1">

<cfparam name="dummyValue" default="9999999" >


<!--- ||||||||||
send mail function for incident reports --->
<cfif isdefined("attributes.sendMail_submitted")>
	
	<cfif attributes.IR_TEXT neq "" and attributes.IR_ITEMID neq "" >
		<cfquery name="getItemEmail" datasource="#request.dsn#">
			select * from items
			where item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.IR_ITEMID#">
		</cfquery>	
		
		<cfif getItemEmail.recordCount gte 1>
			<cfquery name="getItemCreator" datasource="#request.dsn#">
				select * from accounts
				where id = #getItemEmail.who_created#
			</cfquery>
			
			<cfif getItemCreator.recordCount gte 1 and isemail(getItemCreator.email)>
			
			
			
				<cfmail from="#_vars.mails.from#" 
						to="#getItemCreator.email#"
						cc="BigBlueWAlerts@gmail.com" 
						type="html"
						subject="Awaiting Auction Error #attributes.IR_ITEMID#" 
						>
					
						Dear #getItemCreator.first#,<br><br>
						
						#attributes.IR_ITEMID# has an issue:<br>
						#attributes.IR_TEXT#<br><br>
						
						--<br>
						Thank You - Big Blue Wholesale<br>
						http://www.instantonlineconsignment.com/<br>
				</cfmail>
				<cfset LogAction("#attributes.IR_ITEMID# - [#getItemCreator.first#] #attributes.IR_TEXT#")>
			</cfif><!--- account existing and valid email --->
		</cfif><!--- valid itemid--->
	</cfif><!--- null items. don't send --->
		<!--- update the item even we haven't sent the email --->
		<cfquery datasource="#request.dsn#">
			update items
			set incident_text = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.IR_TEXT#">
			where item = '#attributes.IR_ITEMID#'
		</cfquery>
</cfif><!---submitted --->

<!---<cfset daysBackdt = DATEADD(DAY, -100, GETDATE()) >--->
<cfset daysBackdt = DATEADD("d", -100, now()) >


<!--- 20190621: Deadlock in the db. solution is limit by using top 200 --->
<cfquery name="sqlTemp" datasource="#request.dsn#" >
	SELECT top 60 i.item, 
		i.title,
		CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END AS drec,
		CASE WHEN i.dreceived=0 THEN '0' ELSE '1' END AS isrec,
		a.id, 
		u.ready, 
		u.sandbox, 
		i.lid, 
		i.dpictured, 
		i.internal_itemCondition,
		i.internal_itemSKU, 
		i.upc
		<!---,i.age as retailprice--->
		
       
		,CASE 
	    WHEN TRY_PARSE(i.age as float) IS NULL
	    THEN #dummyValue# 
	    ELSE CONVERT(float, i.age) <!----- or something huge--->
	  	END as retailPrice <!--- this is use in sorting price --->
	  	,i.age as retailpriceNotParsed <!--- this is for display only --->
	  	,i.buy_it_now
  		,i.internal_itemSKU2
			<!---,(
				SELECT top 1 
				x.item
				FROM items x
				where x.itemis_template = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
				and x.internal_itemCondition =  i.internal_itemCondition 
				and x.internal_itemSKU2 = i.internal_itemSKU2	
			) as itemMatch--->
			,i.incident_text	
  	
	FROM items i 
		INNER JOIN accounts a ON a.id = i.aid
		LEFT JOIN auctions u ON i.item = u.itemid
	WHERE i.status = '3'<!--- Item Received --->
		AND CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END > <cfqueryparam cfsqltype="cf_sql_date" value="#daysBackdt#">	
		and (
			u.ready = ''  
			or u.ready is null 
			or u.ready = 0 <!--- image uploaded and auction auto created. usually happens in the image uploader --->
		)
		AND i.lid != 'RTC'
		AND i.lid != 'DTC'
		AND i.lid != 'RELOT'
		AND i.lid != 'P&S'
		AND i.lid != ''
		AND (i.internal_itemCondition != 'amazon')
		and  i.internal_itemCondition != 'craiglist'
		and  i.internal_itemCondition != 'bonanza'

		<!---AND (i.dpictured IS NULL or i.dpictured = '')--->
		<!---AND CASE WHEN i.dreceived=0 THEN i.dcreated ELSE i.dreceived END > DATEADD(DAY, -100, GETDATE())--->

		
		<cfif session.user.store EQ "202">
			AND a.store = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.store#">
		</cfif>
		<cfif attributes.customSearchKey neq "">
			and (i.internal_itemSKU like '%#attributes.customSearchKey#%')
		</cfif>
	ORDER BY #attributes.orderby# #attributes.dir#
	<!---order by itemMatch desc--->
</cfquery>

<!---<cfdump var="#sqlTemp#">--->


<cfset _paging.RecordCount = sqlTemp.RecordCount>
<cfset _paging.StartRow = (attributes.page-1)*_paging.RowsOnPage + 1>

<cfif isDefined("attributes.printable")>
	<cfset  _machine.layout = "none">
<cfelse>
	<cfoutput>
	<script src="layouts/default/jquery-1.4.3.min.js" language="javascript" type="text/javascript"></script>
		
	<script language="javascript" type="text/javascript">
	<!--//
		function fPage(Page){
			window.location.href = "#_machine.self#&orderby=#attributes.orderby#&dir=#attributes.dir#&page="+Page+"&customSearchKey=#attributes.customSearchKey#";
		}
		function fSort(OrderBy){
			if ('#attributes.orderby#' == OrderBy){
				dir = <cfif attributes.dir EQ "ASC">"DESC"<cfelse>"ASC"</cfif>;
			}else{
				dir = "ASC";
			}
			window.location.href = "#_machine.self#&page=#attributes.page#&orderby="+OrderBy+"&dir="+dir+"&customSearchKey=#attributes.customSearchKey#";
		}
		
		$(function(){
			$('##btn_customSearch').click(function(){
			var $searchTerm = $('##customSearchKey').val();

			if($searchTerm == ""){
				alert('Please enter search Term');
			}else{
				window.location.href = "#_machine.self#&customSearchKey="+$searchTerm;
			}
			
		});
	});
	//-->
	</script>
	</cfoutput>
</cfif>

<cfoutput>
<table width="100%" style="text-align: justify;">
<tr><td>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="left"><font size="4"><strong>Awaiting Auction:</strong></font><br></td>
		<td align="right" style="padding-right:10px;">
			<cfif isDefined("attributes.printable")>
				Page #attributes.page# of #Int(0.9999 + _paging.RecordCount/_paging.RowsOnPage)#
			<cfelse>
				<a href="#_machine.self#&page=#attributes.page#&orderby=#attributes.orderby#&dir=#attributes.dir#&printable" target="_blank">Printable version</a>
			</cfif>
		</td>
	</tr>
	</table>
	<cfif NOT isDefined("attributes.printable")>
		<hr size="1" style="color: Black;" noshade>
		<strong>Administrator:</strong> #session.user.first# #session.user.last#<br><br>

		Enter Item Number:<br>
		<form method="POST" action="index.cfm?dsp=admin.auctions.step1">
			<input type="text" size="20" maxlength="18" name="item">
			<input type="submit" value="Create Auction">
		</form>
		<span style="float:right">
			<form action="index.cfm?dsp=management.items.awaiting_auction" method="post">
				<input type="text" name="customSearchKey" id="customSearchKey" value="">
				<input type="button" name="btn_customSearch"  
				id="btn_customSearch" value="Search SKU">
			</form>	
		</span>
		<br><br>
	</cfif>
	
			<table bgcolor="##aaaaaa" border=0 cellspacing="0" cellpadding=0 width="100%">
			<tr><td>
				<table width="1000px"  cellspacing="1" cellpadding="4">
				<tr bgcolor="##F0F1F3" >
				<cfset fontsizeTD = "8pt;">
				<cfif isDefined("attributes.printable")>
					<td class="ColHead" width="5%" >Item ID</td>
					<td class="ColHead" width="13%" >Title (LID)</td>
					<!---<td class="ColHead" width="5%">Time Received</td>--->
					<!---<td class="ColHead" width="10%">Time Pictured</td>--->
					<td class="ColHead" width="5%">Item Condition</td>
					<td class="ColHead" width="5%">SKU</td>
					<cfset fontsizeTD = "12px;">
				<cfelse>
					<td class="ColHead">Email</td>
					<td class="ColHead" width="10%"><a href="JavaScript: void fSort(1);">Item ID</a></td>
					<td class="ColHead" width="30%"><a href="JavaScript: void fSort(2);">Title</a> (<a href="JavaScript: void fSort(8);">LID</a>)</td>
					<td class="ColHead" width="5%"><a href="JavaScript: void fSort(3);">Time Received</a></td>
					<td class="ColHead" width="10%"><a href="JavaScript: void fSort(9);">Item Condition</a></td>
					<td class="ColHead" width="5%"><a href="JavaScript: void fSort(11);">SKU</a></td>
					<td class="ColHead" width="5%">Auction</td>
					<td class="ColHead" width="5%"><a href="JavaScript: void fSort(8);">LID</a></td>
					<td class="ColHead" width="5%">UPC</td>
					<td><a href="JavaScript: void fSort(13);">Retail <br> Price</a></td>
					<td><a href="JavaScript: void fSort(14);">Buy_Now</a></td>
					<td class="ColHead" width="5%">Pictured At</td>
					<!---<td class="ColHead" width="5%"><a href="JavaScript: void fSort('itemMatch');">
						Template<br>Match</a>
						
					</td>--->
				</cfif>
				</tr>
				</cfoutput>
				<cfoutput query="sqlTemp" maxrows="#_paging.RowsOnPage#" startrow="#_paging.StartRow#">
				<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('efefef'))#" >
					<td>
						<input type="text"  name="irText_#sqlTemp.item#" placeholder="Enter Issue" size="20" value="#sqlTemp.incident_text#">
						<button name="btn_ir" value="#sqlTemp.item#" class="ir_sendButton" data-item="#sqlTemp.item#">
							Send
						</button>
					</td>
					<td style="font-size:#fontsizeTD#;text-align:center;"><a href="index.cfm?dsp=management.items.edit&item=#sqlTemp.item#">#sqlTemp.item#</a></td>
					<td style="font-size:#fontsizeTD#;">#sqlTemp.title#<cfif sqlTemp.lid NEQ ""> (#sqlTemp.lid#)</cfif></td>
					<cfif not isDefined("attributes.printable")>
						<td style="text-align:center;"><cfif sqlTemp.isrec EQ "0"><font color="blue"></cfif>#strDate(sqlTemp.drec)#<cfif sqlTemp.isrec EQ "0"></font></cfif></td>
					</cfif>
					<!---<td align="center"><cfif isDate(sqlTemp.dpictured)>#strDate(sqlTemp.dpictured)#<cfelse>N/A</cfif></td>--->
					<td style="font-size:#fontsizeTD#;text-align:center;"><cfif sqlTemp.internal_itemCondition neq ''>#sqlTemp.internal_itemCondition#<cfelse>N/A</cfif></td>
					<td style="font-size:#fontsizeTD#;text-align:center;"><cfif sqlTemp.internal_itemSKU neq ''>#sqlTemp.internal_itemSKU#<cfelse>N/A</cfif></td>
				<cfif NOT isDefined("attributes.printable")>
					
					<td align="center" width="90">
					<cfif sqlTemp.ready NEQ "">
						<cfif isAllowed("Lister_CreateAuction") OR isAllowed("Lister_EditAuction")>
							<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border="0" alt="Edit Auction"></a>
						</cfif>
						<a href="index.cfm?dsp=admin.auctions.preview&item=#sqlTemp.item#" target="_blank"><img src="#request.images_path#icon12.gif" border="0" alt="Preview Auction"></a>
					<cfelse>
						<cfif isAllowed("Lister_CreateAuction")>
							<a href="index.cfm?dsp=admin.auctions.step1&item=#sqlTemp.item#"><img src="#request.images_path#icon1.gif" border="0" alt="Create Auction"></a>
						</cfif>
					</cfif>
		
					<cfif isAllowed("Lister_CreateAuction")>
						<a href="index.cfm?act=admin.auctions.delete&item=#sqlTemp.item#" onClick="return confirm('Deleted auction can never be restored. Are you sure you want to delete this auction?')"><img src="#request.images_path#icon16.gif" border="0" alt="Delete Auction"></a>
					</cfif>
					</td>
					<td align="center"><strong>#sqlTemp.lid#</strong></td>
					<td align="center"><strong>#sqlTemp.upc#</strong></td>
					<td align="center" width="110">
						<!---don't display dummyvalue which is 999999 --->
						
						<!---<cfif dummyValue neq sqlTemp.retailprice>
							#sqlTemp.retailprice#
						<cfelse>
						#sqltemp.retailpriceNotParsed#						
						</cfif>--->
						
						#sqltemp.retailpriceNotParsed#
					</td>
					<!--- buy_it_now buy it now --->
					<td>#sqlTemp.buy_it_now#</td>
					<td>#sqlTemp.dpictured#</td>
					
					<td id="checkboxesMatch">
						<cfquery name="itemMatch" datasource="#request.dsn#">
							SELECT i.item AS itemid, 
							i.title, 
							i.itemis_template_setdate, 
							i.dpictured,
							i.internal_itemSKU,
							i.internal_itemCondition,
							i.internal_itemSKU2
							FROM items i
							where itemis_template = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
							and i.internal_itemCondition =  '#sqlTemp.internal_itemCondition#' 
							and i.internal_itemSKU2 = '#sqlTemp.internal_itemSKU2#'					
						</cfquery>		
						
						<cfif itemMatch.recordCount gte 1>
							<input type="checkbox" name="matchItem" value="#sqlTemp.item#|#itemMatch.itemid#" class="duplicateClass">
						<cfelse>
							N/A	
						</cfif>		
		
					</td>
				</cfif>
				</tr>
				</cfoutput>
				<cfif NOT isDefined("attributes.printable")>
					<cfoutput>
					<tr bgcolor="##FFFFFF">
						<td colspan="6" align="center">
						</cfoutput><cfinclude template="../../../paging.cfm"><cfoutput>
					</td>
					<td colspan="6" align="right">
						<button id="btn_duplidateItem">Duplicate</button>
						<button id="btn_checkAll">Check All</button>
					</td>
					</tr>
					</cfoutput>
				</cfif>
				
				
<cfoutput>
				</table>
			</td></tr>
			</table>
		
</td></tr>
</table>

<form name="form_duplidateItem" id="form_duplidateItem" 
	method="post" action="index.cfm?dsp=management.items.confirmDuplicateItems">
	<input type="hidden" name="checkedItems" id="checkedItems" value="">
	<input type="hidden" name="submitted" value="true">
</form>


<form name="form_sendMail" id="form_sendMail" 
	method="post" action="index.cfm?dsp=management.items.awaiting_auction&customSearchKey=#attributes.customSearchKey#">
	<input type="hidden" name="ir_itemid" id="ir_itemid" value="">
	<input type="hidden" name="ir_text" id="ir_text" value="">
	<input type="hidden" name="sendMail_submitted" value="true">
</form>

<script type="text/javascript">
	$(function(){
		$('##btn_duplidateItem').click(function(){
			var selected = [];
			$('##checkboxesMatch input:checked').each(function() {
			    selected.push($(this).attr('value'));
			});
			
			//get the checked items and include in the form submit			
			$('##checkedItems').val(selected);
			
			if(countElements(selected) > 0 ){			
				$('##form_duplidateItem').submit();
			}else{
				alert('Select items to Duplicate');
			}				
		});
		
		
		   $('##btn_checkAll').toggle(function(){
		        $('.duplicateClass').attr('checked','checked');
		        $(this).val('uncheck all');
		    },function(){
		        $('.duplicateClass').removeAttr('checked');
		        $(this).val('check all');        
		    })			
			
			$('.ir_sendButton').click(function(){

				var item = $(this).val();
				var cClass = $(this).attr('class') 
				var textVal = $(this).prev('input').val();

				$('##ir_text').val(textVal);
				$('##ir_itemid').val(item);
				$('##form_sendMail').submit();
			})
				
	});//doc ready
	
	function countElements(arr) {    
        var numElements = 0;    
        for ( var indx in arr ) {    
            numElements ++;    
        }    
        return numElements;    
    }
</script>
	
<script language='JavaScript'>
checked = false;
function checkedAll () {
if (checked == false){checked = true}else{checked = false}
for (var i = 0; i < document.getElementById('myform').elements.length; i++) {
document.getElementById('myform').elements[i].checked = checked;
}
}
</script>


</cfoutput>
