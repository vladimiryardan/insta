<!---
Programmer: Tim McCarthy (tim@timmcc.com)
Date: February, 2003
Description:
	Produces a 256-bit condensed representation of a message (attributes.msg) called
	a message digest (caller.msg_digest) using the Secure Hash Algorithm (SHA-256) as
	specified in FIPS PUB 180-2 (http://csrc.nist.gov/publications/fips/fips180-2/fips180-2.pdf)
	On August 26, 2002, NIST announced the approval of FIPS 180-2, Secure Hash Standard,
	which contains the specifications for the Secure Hash Algorithms (SHA-1, SHA-256, SHA-384,
	and SHA-256) with several examples.  This standard became effective on February 1, 2003.
Required parameter: msg
Optional parameter: format="hex" (hexadecimal, default is ASCII text)
Example syntax: <cf_sha_256 msg="abcdefghijklmnopqrstuvwxyz">
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

<!--- first sixty-four prime numbers --->
<cfset prime = ArrayNew(1)>
<cfset prime[1] = 2>
<cfset prime[2] = 3>
<cfset prime[3] = 5>
<cfset prime[4] = 7>
<cfset prime[5] = 11>
<cfset prime[6] = 13>
<cfset prime[7] = 17>
<cfset prime[8] = 19>
<cfset prime[9] = 23>
<cfset prime[10] = 29>
<cfset prime[11] = 31>
<cfset prime[12] = 37>
<cfset prime[13] = 41>
<cfset prime[14] = 43>
<cfset prime[15] = 47>
<cfset prime[16] = 53>
<cfset prime[17] = 59>
<cfset prime[18] = 61>
<cfset prime[19] = 67>
<cfset prime[20] = 71>
<cfset prime[21] = 73>
<cfset prime[22] = 79>
<cfset prime[23] = 83>
<cfset prime[24] = 89>
<cfset prime[25] = 97>
<cfset prime[26] = 101>
<cfset prime[27] = 103>
<cfset prime[28] = 107>
<cfset prime[29] = 109>
<cfset prime[30] = 113>
<cfset prime[31] = 127>
<cfset prime[32] = 131>
<cfset prime[33] = 137>
<cfset prime[34] = 139>
<cfset prime[35] = 149>
<cfset prime[36] = 151>
<cfset prime[37] = 157>
<cfset prime[38] = 163>
<cfset prime[39] = 167>
<cfset prime[40] = 173>
<cfset prime[41] = 179>
<cfset prime[42] = 181>
<cfset prime[43] = 191>
<cfset prime[44] = 193>
<cfset prime[45] = 197>
<cfset prime[46] = 199>
<cfset prime[47] = 211>
<cfset prime[48] = 223>
<cfset prime[49] = 227>
<cfset prime[50] = 229>
<cfset prime[51] = 233>
<cfset prime[52] = 239>
<cfset prime[53] = 241>
<cfset prime[54] = 251>
<cfset prime[55] = 257>
<cfset prime[56] = 263>
<cfset prime[57] = 269>
<cfset prime[58] = 271>
<cfset prime[59] = 277>
<cfset prime[60] = 281>
<cfset prime[61] = 283>
<cfset prime[62] = 293>
<cfset prime[63] = 307>
<cfset prime[64] = 311>

<!--- constants --->
<cfset k = ArrayNew(1)>
<cfloop index="i" from="1" to="64">
	<cfset k[i] = Int(prime[i]^(1/3)*2^32)>
</cfloop>

<!--- initial hash values --->
<cfset h = ArrayNew(1)>
<cfloop index="i" from="1" to="8">
	<cfset h[i] = Int(Sqr(prime[i])*2^32)>
	<cfloop condition="(h[i] LT -2^31) OR (h[i] GE 2^31)">
		<cfset h[i] = h[i] - Sgn(h[i])*2^32>
	</cfloop>
</cfloop>

<cfset w = ArrayNew(1)>

<!--- process the msg 512 bits at a time --->
<cfloop index="n" from="1" to="#Evaluate(Len(padded_hex_msg)/128)#">
	
	<!--- initialize the eight working variables --->
	<cfset a = h[1]>
	<cfset b = h[2]>
	<cfset c = h[3]>
	<cfset d = h[4]>
	<cfset e = h[5]>
	<cfset f = h[6]>
	<cfset g = h[7]>
	<cfset hh = h[8]>
	
	<!--- nonlinear functions and message schedule --->
	<cfset msg_block = Mid(padded_hex_msg,128*(n-1)+1,128)>
	<cfloop index="t" from="0" to="63">
		
		<cfif t LE 15>
			<cfset w[t+1] = InputBaseN(Mid(msg_block,8*t+1,8),16)>
		<cfelse>
			<cfset smsig0 = BitXor(BitXor(BitOr(BitSHRN(w[t-15+1],7),BitSHLN(w[t-15+1],32-7)),BitOr(BitSHRN(w[t-15+1],18),BitSHLN(w[t-15+1],32-18))),BitSHRN(w[t-15+1],3))>
			<cfset smsig1 = BitXor(BitXor(BitOr(BitSHRN(w[t-2+1],17),BitSHLN(w[t-2+1],32-17)),BitOr(BitSHRN(w[t-2+1],19),BitSHLN(w[t-2+1],32-19))),BitSHRN(w[t-2+1],10))>
			<cfset w[t+1] = smsig1 + w[t-7+1] + smsig0 + w[t-16+1]>
		</cfif>
		<cfloop condition="(w[t+1] LT -2^31) OR (w[t+1] GE 2^31)">
			<cfset w[t+1] = w[t+1] - Sgn(w[t+1])*2^32>
		</cfloop>
		
		<cfset bgsig0 = BitXor(BitXor(BitOr(BitSHRN(a,2),BitSHLN(a,32-2)),BitOr(BitSHRN(a,13),BitSHLN(a,32-13))),BitOr(BitSHRN(a,22),BitSHLN(a,32-22)))>
		<cfset bgsig1 = BitXor(BitXor(BitOr(BitSHRN(e,6),BitSHLN(e,32-6)),BitOr(BitSHRN(e,11),BitSHLN(e,32-11))),BitOr(BitSHRN(e,25),BitSHLN(e,32-25)))>
		<cfset ch = BitXor(BitAnd(e,f),BitAnd(BitNot(e),g))>
		<cfset maj = BitXor(BitXor(BitAnd(a,b),BitAnd(a,c)),BitAnd(b,c))>
		
		<cfset t1 = hh + bgsig1 + ch + k[t+1] + w[t+1]>
		<cfset t2 = bgsig0 + maj>
		<cfset hh = g>
		<cfset g = f>
		<cfset f = e>
		<cfset e = d + t1>
		<cfset d = c>
		<cfset c = b>
		<cfset b = a>
		<cfset a = t1 + t2>
		
		<cfloop condition="(a LT -2^31) OR (a GE 2^31)">
			<cfset a = a - Sgn(a)*2^32>
		</cfloop>
		<cfloop condition="(e LT -2^31) OR (e GE 2^31)">
			<cfset e = e - Sgn(e)*2^32>
		</cfloop>
		
	</cfloop>
	
	<cfset h[1] = h[1] + a>
	<cfset h[2] = h[2] + b>
	<cfset h[3] = h[3] + c>
	<cfset h[4] = h[4] + d>
	<cfset h[5] = h[5] + e>
	<cfset h[6] = h[6] + f>
	<cfset h[7] = h[7] + g>
	<cfset h[8] = h[8] + hh>
	
	<cfloop index="i" from="1" to="8">
		<cfloop condition="(h[i] LT -2^31) OR (h[i] GE 2^31)">
			<cfset h[i] = h[i] - Sgn(h[i])*2^32>
		</cfloop>
	</cfloop>
	
</cfloop>

<cfloop index="i" from="1" to="8">
	<cfset h[i] = RepeatString("0",8-Len(FormatBaseN(h[i],16))) & UCase(FormatBaseN(h[i],16))>
</cfloop>

<cfset caller.msg_digest = h[1] & h[2] & h[3] & h[4] & h[5] & h[6] & h[7] & h[8]>
