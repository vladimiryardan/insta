<!---<cfdump var="#form#">--->

<!---<cfdump var="#form.BASE64DATA#">--->
<!---<cfset myImage = ImageReadBase64("#form.BASE64DATA#") > --->

<!---destination="test_my64.jpeg"--->
<!---format="jpeg"---> 

<!---	<cfset myImage = ImageReadBase64("#form.BASE64DATA#") >
	<cfimage 
		source="#trim(form.BASE64DATA)#"  
		action="writeToBrowser" 
		isbase64="yes" >--->
	<!--- writeToBrowser might be disabled in our serve settings --->
	<!---<cfimage 
		source="#trim(form.BASE64DATA)#"  
		action="writeToBrowser" 
		isbase64="yes" >--->
	
	<!--- this works
	<cfimage 
		source="1.jpg" 		
		action="write" 
		destination="2.jpg" >		
	 --->	
	
<!---	<cfif fileexists("2.jpg")>
		<cffile action="delete" file="2.jpg" >
	</cfif>	--->
	
<cfoutput>
		<cfset myImage = ImageReadBase64("#form.BASE64DATA#") >
		<cfimage 
			source="#trim(form.BASE64DATA)#"  
			action="write" 
			destination="2.jpg" 
			isbase64="yes" 
			overwrite="yes" >
			
			
	<img src="2.jpg">
</cfoutput>

