<!---
Programmer: Tim McCarthy (tim@timmcc.com)
Date: February, 2003
Description:
	Produces a 160-bit condensed representation of a message (attributes.msg) called
	a message digest (caller.msg_digest) using the Secure Hash Algorithm (SHA-1)
	as specified in FIPS PUB 180-1 (http://www.itl.nist.gov/fipspubs/fip180-1.htm)
Required parameter: msg
Optional parameter: format="hex" (hexadecimal, default is ASCII text)
Example syntax: <cf_sha_1 msg="abcdefghijklmnopqrstuvwxyz">
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
<cfset hex_msg_len = FormatBaseN(4*Len(hex_msg),16)>

<!--- pad the msg to make it a multiple of 512 bits long --->
<cfset padded_hex_msg = hex_msg & "80" & RepeatString("0",128-((Len(hex_msg)+2+16) Mod 128)) & RepeatString("0",16-Len(hex_msg_len)) & hex_msg_len>

<!--- initialize the buffers --->
<cfset h = ArrayNew(1)>
<cfset h[1] = InputBaseN("0x67452301",16)>
<cfset h[2] = InputBaseN("0xefcdab89",16)>
<cfset h[3] = InputBaseN("0x98badcfe",16)>
<cfset h[4] = InputBaseN("0x10325476",16)>
<cfset h[5] = InputBaseN("0xc3d2e1f0",16)>

<cfset w = ArrayNew(1)>

<!--- process the msg 512 bits at a time --->
<cfloop index="n" from="1" to="#Evaluate(Len(padded_hex_msg)/128)#">
	
	<cfset msg_block = Mid(padded_hex_msg,128*(n-1)+1,128)>
	
	<cfset a = h[1]>
	<cfset b = h[2]>
	<cfset c = h[3]>
	<cfset d = h[4]>
	<cfset e = h[5]>
	
	<cfloop index="t" from="0" to="79">
		
		<!--- nonlinear functions and constants --->
		<cfif t LE 19>
			<cfset f = BitOr(BitAnd(b,c),BitAnd(BitNot(b),d))>
			<cfset k = InputBaseN("0x5a827999",16)>
		<cfelseif t LE 39>
			<cfset f = BitXor(BitXor(b,c),d)>
			<cfset k = InputBaseN("0x6ed9eba1",16)>
		<cfelseif t LE 59>
			<cfset f = BitOr(BitOr(BitAnd(b,c),BitAnd(b,d)),BitAnd(c,d))>
			<cfset k = InputBaseN("0x8f1bbcdc",16)>
		<cfelse>
			<cfset f = BitXor(BitXor(b,c),d)>
			<cfset k = InputBaseN("0xca62c1d6",16)>
		</cfif>
		
		<!--- transform the msg block from 16 32-bit words to 80 32-bit words --->
		<cfif t LE 15>
			<cfset w[t+1] = InputBaseN(Mid(msg_block,8*t+1,8),16)>
		<cfelse>
			<cfset num = BitXor(BitXor(BitXor(w[t-3+1],w[t-8+1]),w[t-14+1]),w[t-16+1])>
			<cfset w[t+1] = BitOr(BitSHLN(num,1),BitSHRN(num,32-1))>
		</cfif>
		
		<cfset temp = BitOr(BitSHLN(a,5),BitSHRN(a,32-5)) + f + e + w[t+1] + k>
		<cfset e = d>
		<cfset d = c>
		<cfset c = BitOr(BitSHLN(b,30),BitSHRN(b,32-30))>
		<cfset b = a>
		<cfset a = temp>
		
		<cfset num = a>
		<cfloop condition="(num LT -2^31) OR (num GE 2^31)">
			<cfset num = num - Sgn(num)*2^32>
		</cfloop>
		<cfset a = num>
		
	</cfloop>
	
	<cfset h[1] = h[1] + a>
	<cfset h[2] = h[2] + b>
	<cfset h[3] = h[3] + c>
	<cfset h[4] = h[4] + d>
	<cfset h[5] = h[5] + e>
	
	<cfloop index="i" from="1" to="5">
		<cfloop condition="(h[i] LT -2^31) OR (h[i] GE 2^31)">
			<cfset h[i] = h[i] - Sgn(h[i])*2^32>
		</cfloop>
	</cfloop>
	
</cfloop>

<cfloop index="i" from="1" to="5">
	<cfset h[i] = RepeatString("0",8-Len(FormatBaseN(h[i],16))) & UCase(FormatBaseN(h[i],16))>
</cfloop>

<cfset caller.msg_digest = h[1] & h[2] & h[3] & h[4] & h[5]>
