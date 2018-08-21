<cfif isGuest()>
	<cflocation url="index.cfm?dsp=slim_login" addtoken="no">
</cfif>

<cfset _machine.cflocation = "index.cfm?dsp=management.records&item=#attributes.item#">

<cfquery name="sqlTemp" datasource="#request.dsn#">
	SELECT CASE WHEN i.commission = 0 THEN a.commission ELSE i.commission END AS commission,
		r.finalprice, r.highbidder, i.offebay, r.shipping, r.actualshipping, i.vehicle
	FROM items i
		INNER JOIN records r ON i.item = r.itemid
		INNER JOIN accounts a ON i.aid = a.id
	WHERE i.item = '#attributes.item#'
</cfquery>
<cfif sqlTemp.RecordCount EQ 0>
	<cfexit method="exittemplate">
</cfif>

<cfscript>
variables.salestax			= 0;

// CALCULATE FEES

if ((sqlTemp.offebay NEQ "1") AND ((sqlTemp.highbidder EQ "") OR (sqlTemp.highbidder EQ "No%20Bids%20Yet") OR (sqlTemp.highbidder EQ "Did%20Not%20Sell"))){
	variables.finalprice		= 0;
	variables.ourfees		= 0;
	variables.paypalfees		= 0;
	variables.shipping		= 0;
	variables.actualshipping	= 0;
}else{
	variables.finalprice		= sqlTemp.finalprice;
	variables.ebayfees		= CalcEBayFees(variables.finalprice);
	variables.paypalfees		= Round(40 + (2.9 * variables.finalprice)) * .01;
	variables.shipping		= sqlTemp.shipping;
	variables.actualshipping	= sqlTemp.actualshipping;

	// our fees
	if (sqlTemp.commission NEQ "0") {
		variables.ourfees = (sqlTemp.commission / 100) *  variables.finalprice;
	}else if (sqlTemp.vehicle EQ "0") {
		if (variables.finalprice GT 28.54){
			if (variables.finalprice GT 499.99){
				if (variables.finalprice GT 999.99){
					variables.ourfees = 0.18 * variables.finalprice;
				}else{
					variables.ourfees = 0.23 * variables.finalprice;
				}
			}else{
				variables.ourfees = 0.28 * variables.finalprice;
			}
		} else {
			variables.ourfees = variables.finalprice - variables.ebayfees - variables.paypalfees;
			if (variables.ourfees GT 7.99){
				variables.ourfees = 7.99;
			}
		}
		if ( variables.ourfees LT 0 ) {
			variables.ourfees = 0;
		}
	}else{
		if (variables.finalprice GT 10000) {
			if (variables.finalprice GT 30000) {
				variables.ourfees = 0.05 * variables.finalprice;
			}else{
				variables.ourfees = 0.07 * variables.finalprice;
			}
		}else{
			variables.ourfees = 0.1 * variables.finalprice;
		}
	}						
	variables.ourfees = Round(0.4 + (variables.ourfees * 100)) * .01 + variables.salestax;
	}

if (sqlTemp.vehicle EQ "0") {
	variables.ebayfees = CalcEBayFees(variables.finalprice);
}else{
	variables.ebayfees = 0;
	variables.paypalfees = 0;
}

variables.checkamount = variables.finalprice - variables.ebayfees - variables.ourfees - variables.paypalfees;
if (variables.checkamount LT 0){
	variables.checkamount = 0;
}
variables.netincome = variables.ourfees + variables.shipping - variables.actualshipping;
</cfscript>
<cfset variables.checkamount = Round(variables.checkamount*100)*0.01>
<cfquery datasource="#request.dsn#">
	UPDATE records
	SET ebayfees = '#variables.ebayfees#',
		ourfees = '#variables.ourfees#',
		checkamount = '#variables.checkamount#',
		paypalfees = '#variables.paypalfees#',
		netincome = '#variables.netincome#'
	WHERE itemid = '#attributes.item#'
</cfquery>
