<cfquery name="fedexObj" datasource="cfartgallery"> 
    SELECT * FROM fedexID 
</cfquery>

<cfdump var="#dbo.fedexitems#" />
