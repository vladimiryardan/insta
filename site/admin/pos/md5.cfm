<!---
Programmer: Tim McCarthy (tim@timmcc.com)
Date: February, 2003
Description:
	Produces a 128-bit condensed representation of a message (attributes.msg) called
	a message digest (caller.msg_digest) using the RSA MD5 message-digest algorithm
	as specified in RFC 1321 (http://www.ietf.org/rfc/rfc1321.txt)
Required parameter: msg
Optional parameter: format="hex" (hexadecimal, default is ASCII text)
Example syntax: <cf_md5 msg="abcdefghijklmnopqrstuvwxyz">
Output variable: caller.msg_digest
Note:
	This version accepts input in both ASCII text and hexadecimal formats.
	Previous versions did not accept input in hexadecimal format.
--->

<!--- default value of optional parameter --->
<cfparam name="attributes.format" default="">

<!--- convert the msg to ASCII binary-coded form --->
<cfif attributes.format EQ "hex">
	<cfset hex_msg = attributes.msg>
<cfelse>
	<cfset hex_msg = "">
	<cfloop index="i" from="1" to="#Len(attributes.msg)#">
		<cfset hex_msg = hex_msg & Right("0"&FormatBaseN(Asc(Mid(attributes.msg,i,1)),16),2)>
	</cfloop>
</cfif>

<!--- compute the msg length in bits --->
<cfset hex_msg_len = Right(RepeatString("0",15)&FormatBaseN(4*Len(hex_msg),16),16)>
<cfset temp = "">
<cfloop index="i" from="1" to="8">
	<cfset temp = temp & Mid(hex_msg_len,-2*(i-8)+1,2)>
</cfloop>
<cfset hex_msg_len = temp>

<!--- pad the msg to make it a multiple of 512 bits long --->
<cfset padded_hex_msg = hex_msg & "80" & RepeatString("0",128-((Len(hex_msg)+2+16) Mod 128)) & hex_msg_len>

<!--- initialize MD buffer --->
<cfset h = ArrayNew(1)>
<cfset h[1] = InputBaseN("0x67452301",16)>
<cfset h[2] = InputBaseN("0xefcdab89",16)>
<cfset h[3] = InputBaseN("0x98badcfe",16)>
<cfset h[4] = InputBaseN("0x10325476",16)>

<cfset var = ArrayNew(1)>
<cfset var[1] = "a">
<cfset var[2] = "b">
<cfset var[3] = "c">
<cfset var[4] = "d">

<cfset m = ArrayNew(1)>

<cfset t = ArrayNew(1)>
<cfset k = ArrayNew(1)>
<cfset s = ArrayNew(1)>
<cfloop index="i" from="1" to="64">
	<cfset t[i] = Int(2^32*abs(sin(i)))>
	<cfif i LE 16>
		<cfif i EQ 1>
			<cfset k[i] = 0>
		<cfelse>
			<cfset k[i] = k[i-1] + 1>
		</cfif>
		<cfset s[i] = 5*((i-1) MOD 4) + 7>
	<cfelseif i LE 32>
		<cfif i EQ 17>
			<cfset k[i] = 1>
		<cfelse>
			<cfset k[i] = (k[i-1]+5) MOD 16>
		</cfif>
		<cfset s[i] = 0.5*((i-1) MOD 4)*((i-1) MOD 4) + 3.5*((i-1) MOD 4) + 5>
	<cfelseif i LE 48>
		<cfif i EQ 33>
			<cfset k[i] = 5>
		<cfelse>
			<cfset k[i] = (k[i-1]+3) MOD 16>
		</cfif>
		<cfset s[i] = 6*((i-1) MOD 4) + ((i-1) MOD 2) + 4>
	<cfelse>
		<cfif i EQ 49>
			<cfset k[i] = 0>
		<cfelse>
			<cfset k[i] = (k[i-1]+7) MOD 16>
		</cfif>
		<cfset s[i] = 0.5*((i-1) MOD 4)*((i-1) MOD 4) + 3.5*((i-1) MOD 4) + 6>
	</cfif>
</cfloop>

<!--- process the msg 512 bits at a time --->
<cfloop index="n" from="1" to="#Evaluate(Len(padded_hex_msg)/128)#">
	
	<cfset a = h[1]>
	<cfset b = h[2]>
	<cfset c = h[3]>
	<cfset d = h[4]>
	
	<cfset msg_block = Mid(padded_hex_msg,128*(n-1)+1,128)>
	<cfloop index="i" from="1" to="16">
		<cfset sub_block = "">
		<cfloop index="j" from="1" to="4">
			<cfset sub_block = sub_block & Mid(msg_block,8*i-2*j+1,2)>
		</cfloop>
		<cfset m[i] = InputBaseN(sub_block,16)>
	</cfloop>
	
	<cfloop index="i" from="1" to="64">
		
		<cfif i LE 16>
			<cfset f = BitOr(BitAnd(Evaluate(var[2]),Evaluate(var[3])),BitAnd(BitNot(Evaluate(var[2])),Evaluate(var[4])))>
		<cfelseif i LE 32>
			<cfset f = BitOr(BitAnd(Evaluate(var[2]),Evaluate(var[4])),BitAnd(Evaluate(var[3]),BitNot(Evaluate(var[4]))))>
		<cfelseif i LE 48>
			<cfset f = BitXor(BitXor(Evaluate(var[2]),Evaluate(var[3])),Evaluate(var[4]))>
		<cfelse>
			<cfset f = BitXor(Evaluate(var[3]),BitOr(Evaluate(var[2]),BitNot(Evaluate(var[4]))))>
		</cfif>
		
		<cfset temp = Evaluate(var[1]) + f + m[k[i]+1] + t[i]>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = Evaluate(var[2]) + BitOr(BitSHLN(temp,s[i]),BitSHRN(temp,32-s[i]))>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = SetVariable(var[1],temp)>
		
		<cfset temp = var[4]>
		<cfset var[4] = var[3]>
		<cfset var[3] = var[2]>
		<cfset var[2] = var[1]>
		<cfset var[1] = temp>
		
	</cfloop>
	
	<cfset h[1] = h[1] + a>
	<cfset h[2] = h[2] + b>
	<cfset h[3] = h[3] + c>
	<cfset h[4] = h[4] + d>
	
	<cfloop index="i" from="1" to="4">
		<cfloop condition="(h[i] LT -2^31) OR (h[i] GE 2^31)">
			<cfset h[i] = h[i] - Sgn(h[i])*2^32>
		</cfloop>
	</cfloop>
	
</cfloop>

<cfloop index="i" from="1" to="4">
	<cfset h[i] = Right(RepeatString("0",7)&UCase(FormatBaseN(h[i],16)),8)>
</cfloop>

<cfloop index="i" from="1" to="4">
	<cfset temp = "">
	<cfloop index="j" from="1" to="4">
		<cfset temp = temp & Mid(h[i],-2*(j-4)+1,2)>
	</cfloop>
	<cfset h[i] = temp>
</cfloop>

<cfset caller.msg_digest = h[1] & h[2] & h[3] & h[4]>
