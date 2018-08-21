<!---  --->
<cfapplication
	name="instantauctions_amazon"
	clientmanagement="no"
	sessionmanagement="yes"
	setclientcookies="yes"
	setdomaincookies="no"
	sessiontimeout="#CreateTimeSpan(0,1,0,0)#"
	applicationtimeout="#CreateTimeSpan(1,0,0,0)#"
	clientstorage="cookie">