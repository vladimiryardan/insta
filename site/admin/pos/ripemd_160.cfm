<!---
Programmer: Tim McCarthy (tim@timmcc.com)
Date: February, 2003
Description:
	Produces a 160-bit condensed representation of a message (attributes.msg) called
	a message digest (caller.msg_digest) using the RIPEMD-160 hash function as
	specified in http://www.esat.kuleuven.ac.be/~bosselae/ripemd160.html
Required parameter: msg
Optional parameter: format="hex" (hexadecimal, default is ASCII text)
Example syntax: <cf_ripemd_160 msg="abcdefghijklmnopqrstuvwxyz">
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

<!--- define permutations --->
<cfset rho = ArrayNew(1)>
<cfset rho[1] = 7>
<cfset rho[2] = 4>
<cfset rho[3] = 13>
<cfset rho[4] = 1>
<cfset rho[5] = 10>
<cfset rho[6] = 6>
<cfset rho[7] = 15>
<cfset rho[8] = 3>
<cfset rho[9] = 12>
<cfset rho[10] = 0>
<cfset rho[11] = 9>
<cfset rho[12] = 5>
<cfset rho[13] = 2>
<cfset rho[14] = 14>
<cfset rho[15] = 11>
<cfset rho[16] = 8>

<cfset pi = ArrayNew(1)>
<cfloop index="i" from="1" to="16">
	<cfset pi[i] = (9*(i-1)+5) Mod 16>
</cfloop>

<!--- define shifts --->
<cfset shift = ArrayNew(2)>
<cfset shift[1][1] = 11>
<cfset shift[1][2] = 14>
<cfset shift[1][3] = 15>
<cfset shift[1][4] = 12>
<cfset shift[1][5] = 5>
<cfset shift[1][6] = 8>
<cfset shift[1][7] = 7>
<cfset shift[1][8] = 9>
<cfset shift[1][9] = 11>
<cfset shift[1][10] = 13>
<cfset shift[1][11] = 14>
<cfset shift[1][12] = 15>
<cfset shift[1][13] = 6>
<cfset shift[1][14] = 7>
<cfset shift[1][15] = 9>
<cfset shift[1][16] = 8>
<cfset shift[2][1] = 12>
<cfset shift[2][2] = 13>
<cfset shift[2][3] = 11>
<cfset shift[2][4] = 15>
<cfset shift[2][5] = 6>
<cfset shift[2][6] = 9>
<cfset shift[2][7] = 9>
<cfset shift[2][8] = 7>
<cfset shift[2][9] = 12>
<cfset shift[2][10] = 15>
<cfset shift[2][11] = 11>
<cfset shift[2][12] = 13>
<cfset shift[2][13] = 7>
<cfset shift[2][14] = 8>
<cfset shift[2][15] = 7>
<cfset shift[2][16] = 7>
<cfset shift[3][1] = 13>
<cfset shift[3][2] = 15>
<cfset shift[3][3] = 14>
<cfset shift[3][4] = 11>
<cfset shift[3][5] = 7>
<cfset shift[3][6] = 7>
<cfset shift[3][7] = 6>
<cfset shift[3][8] = 8>
<cfset shift[3][9] = 13>
<cfset shift[3][10] = 14>
<cfset shift[3][11] = 13>
<cfset shift[3][12] = 12>
<cfset shift[3][13] = 5>
<cfset shift[3][14] = 5>
<cfset shift[3][15] = 6>
<cfset shift[3][16] = 9>
<cfset shift[4][1] = 14>
<cfset shift[4][2] = 11>
<cfset shift[4][3] = 12>
<cfset shift[4][4] = 14>
<cfset shift[4][5] = 8>
<cfset shift[4][6] = 6>
<cfset shift[4][7] = 5>
<cfset shift[4][8] = 5>
<cfset shift[4][9] = 15>
<cfset shift[4][10] = 12>
<cfset shift[4][11] = 15>
<cfset shift[4][12] = 14>
<cfset shift[4][13] = 9>
<cfset shift[4][14] = 9>
<cfset shift[4][15] = 8>
<cfset shift[4][16] = 6>
<cfset shift[5][1] = 15>
<cfset shift[5][2] = 12>
<cfset shift[5][3] = 13>
<cfset shift[5][4] = 13>
<cfset shift[5][5] = 9>
<cfset shift[5][6] = 5>
<cfset shift[5][7] = 8>
<cfset shift[5][8] = 6>
<cfset shift[5][9] = 14>
<cfset shift[5][10] = 11>
<cfset shift[5][11] = 12>
<cfset shift[5][12] = 11>
<cfset shift[5][13] = 8>
<cfset shift[5][14] = 6>
<cfset shift[5][15] = 5>
<cfset shift[5][16] = 5>

<cfset k1 = ArrayNew(1)>
<cfset k2 = ArrayNew(1)>
<cfset r1 = ArrayNew(1)>
<cfset r2 = ArrayNew(1)>
<cfset s1 = ArrayNew(1)>
<cfset s2 = ArrayNew(1)>

<cfloop index="i" from="1" to="16">
	
	<!--- define constants --->
	<cfset k1[i] = 0>
	<cfset k1[i+16] = Int(2^30*Sqr(2))>
	<cfset k1[i+32] = Int(2^30*Sqr(3))>
	<cfset k1[i+48] = Int(2^30*Sqr(5))>
	<cfset k1[i+64] = Int(2^30*Sqr(7))>
	
	<cfset k2[i] = Int(2^30*2^(1/3))>
	<cfset k2[i+16] = Int(2^30*3^(1/3))>
	<cfset k2[i+32] = Int(2^30*5^(1/3))>
	<cfset k2[i+48] = Int(2^30*7^(1/3))>
	<cfset k2[i+64] = 0>
	
	<!--- define word order --->
	<cfset r1[i] = i-1>
	<cfset r1[i+16] = rho[i]>
	<cfset r1[i+32] = rho[rho[i]+1]>
	<cfset r1[i+48] = rho[rho[rho[i]+1]+1]>
	<cfset r1[i+64] = rho[rho[rho[rho[i]+1]+1]+1]>
	
	<cfset r2[i] = pi[i]>
	<cfset r2[i+16] = rho[pi[i]+1]>
	<cfset r2[i+32] = rho[rho[pi[i]+1]+1]>
	<cfset r2[i+48] = rho[rho[rho[pi[i]+1]+1]+1]>
	<cfset r2[i+64] = rho[rho[rho[rho[pi[i]+1]+1]+1]+1]>
	
	<!--- define rotations --->
	<cfset s1[i] = shift[1][r1[i]+1]>
	<cfset s1[i+16] = shift[2][r1[i+16]+1]>
	<cfset s1[i+32] = shift[3][r1[i+32]+1]>
	<cfset s1[i+48] = shift[4][r1[i+48]+1]>
	<cfset s1[i+64] = shift[5][r1[i+64]+1]>
	
	<cfset s2[i] = shift[1][r2[i]+1]>
	<cfset s2[i+16] = shift[2][r2[i+16]+1]>
	<cfset s2[i+32] = shift[3][r2[i+32]+1]>
	<cfset s2[i+48] = shift[4][r2[i+48]+1]>
	<cfset s2[i+64] = shift[5][r2[i+64]+1]>
	
</cfloop>

<!--- define buffers --->
<cfset h = ArrayNew(1)>
<cfset h[1] = InputBaseN("0x67452301",16)>
<cfset h[2] = InputBaseN("0xefcdab89",16)>
<cfset h[3] = InputBaseN("0x98badcfe",16)>
<cfset h[4] = InputBaseN("0x10325476",16)>
<cfset h[5] = InputBaseN("0xc3d2e1f0",16)>

<cfset var1 = ArrayNew(1)>
<cfset var1[1] = "a1">
<cfset var1[2] = "b1">
<cfset var1[3] = "c1">
<cfset var1[4] = "d1">
<cfset var1[5] = "e1">

<cfset var2 = ArrayNew(1)>
<cfset var2[1] = "a2">
<cfset var2[2] = "b2">
<cfset var2[3] = "c2">
<cfset var2[4] = "d2">
<cfset var2[5] = "e2">

<cfset x = ArrayNew(1)>

<!--- process msg in 16-word blocks --->
<cfloop index="n" from="1" to="#Evaluate(Len(padded_hex_msg)/128)#">
	
	<cfset a1 = h[1]>
	<cfset b1 = h[2]>
	<cfset c1 = h[3]>
	<cfset d1 = h[4]>
	<cfset e1 = h[5]>
	
	<cfset a2 = h[1]>
	<cfset b2 = h[2]>
	<cfset c2 = h[3]>
	<cfset d2 = h[4]>
	<cfset e2 = h[5]>
	
	<cfset msg_block = Mid(padded_hex_msg,128*(n-1)+1,128)>
	<cfloop index="i" from="1" to="16">
		<cfset sub_block = "">
		<cfloop index="j" from="1" to="4">
			<cfset sub_block = sub_block & Mid(msg_block,8*i-2*j+1,2)>
		</cfloop>
		<cfset x[i] = InputBaseN(sub_block,16)>
	</cfloop>
	
	<cfloop index="j" from="1" to="80">
		
		<!--- nonlinear functions --->
		<cfif j LE 16>
			<cfset f1 = BitXor(BitXor(Evaluate(var1[2]),Evaluate(var1[3])),Evaluate(var1[4]))>
			<cfset f2 = BitXor(Evaluate(var2[2]),BitOr(Evaluate(var2[3]),BitNot(Evaluate(var2[4]))))>
		<cfelseif j LE 32>
			<cfset f1 = BitOr(BitAnd(Evaluate(var1[2]),Evaluate(var1[3])),BitAnd(BitNot(Evaluate(var1[2])),Evaluate(var1[4])))>
			<cfset f2 = BitOr(BitAnd(Evaluate(var2[2]),Evaluate(var2[4])),BitAnd(Evaluate(var2[3]),BitNot(Evaluate(var2[4]))))>
		<cfelseif j LE 48>
			<cfset f1 = BitXor(BitOr(Evaluate(var1[2]),BitNot(Evaluate(var1[3]))),Evaluate(var1[4]))>
			<cfset f2 = BitXor(BitOr(Evaluate(var2[2]),BitNot(Evaluate(var2[3]))),Evaluate(var2[4]))>
		<cfelseif j LE 64>
			<cfset f1 = BitOr(BitAnd(Evaluate(var1[2]),Evaluate(var1[4])),BitAnd(Evaluate(var1[3]),BitNot(Evaluate(var1[4]))))>
			<cfset f2 = BitOr(BitAnd(Evaluate(var2[2]),Evaluate(var2[3])),BitAnd(BitNot(Evaluate(var2[2])),Evaluate(var2[4])))>
		<cfelse>
			<cfset f1 = BitXor(Evaluate(var1[2]),BitOr(Evaluate(var1[3]),BitNot(Evaluate(var1[4]))))>
			<cfset f2 = BitXor(BitXor(Evaluate(var2[2]),Evaluate(var2[3])),Evaluate(var2[4]))>
		</cfif>
		
		<cfset temp = Evaluate(var1[1]) + f1 + x[r1[j]+1] + k1[j]>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = BitOr(BitSHLN(temp,s1[j]),BitSHRN(temp,32-s1[j])) + Evaluate(var1[5])>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = SetVariable(var1[1],temp)>
		<cfset temp = SetVariable(var1[3],BitOr(BitSHLN(Evaluate(var1[3]),10),BitSHRN(Evaluate(var1[3]),32-10)))>
		
		<cfset temp = var1[5]>
		<cfset var1[5] = var1[4]>
		<cfset var1[4] = var1[3]>
		<cfset var1[3] = var1[2]>
		<cfset var1[2] = var1[1]>
		<cfset var1[1] = temp>
		
		<cfset temp = Evaluate(var2[1]) + f2 + x[r2[j]+1] + k2[j]>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = BitOr(BitSHLN(temp,s2[j]),BitSHRN(temp,32-s2[j])) + Evaluate(var2[5])>
		<cfloop condition="(temp LT -2^31) OR (temp GE 2^31)">
			<cfset temp = temp - Sgn(temp)*2^32>
		</cfloop>
		<cfset temp = SetVariable(var2[1],temp)>
		<cfset temp = SetVariable(var2[3],BitOr(BitSHLN(Evaluate(var2[3]),10),BitSHRN(Evaluate(var2[3]),32-10)))>
		
		<cfset temp = var2[5]>
		<cfset var2[5] = var2[4]>
		<cfset var2[4] = var2[3]>
		<cfset var2[3] = var2[2]>
		<cfset var2[2] = var2[1]>
		<cfset var2[1] = temp>
		
	</cfloop>
	
	<cfset t = h[2] + c1 + d2>
	<cfset h[2] = h[3] + d1 + e2>
	<cfset h[3] = h[4] + e1 + a2>
	<cfset h[4] = h[5] + a1 + b2>
	<cfset h[5] = h[1] + b1 + c2>
	<cfset h[1] = t>
	
	<cfloop index="i" from="1" to="5">
		<cfloop condition="(h[i] LT -2^31) OR (h[i] GE 2^31)">
			<cfset h[i] = h[i] - Sgn(h[i])*2^32>
		</cfloop>
	</cfloop>
	
</cfloop>

<cfloop index="i" from="1" to="5">
	<cfset h[i] = Right(RepeatString("0",7)&UCase(FormatBaseN(h[i],16)),8)>
</cfloop>

<cfloop index="i" from="1" to="5">
	<cfset temp = "">
	<cfloop index="j" from="1" to="4">
		<cfset temp = temp & Mid(h[i],-2*(j-4)+1,2)>
	</cfloop>
	<cfset h[i] = temp>
</cfloop>

<cfset caller.msg_digest = h[1] & h[2] & h[3] & h[4] & h[5]>
