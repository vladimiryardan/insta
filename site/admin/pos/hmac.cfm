<!---
Programmer: Tim McCarthy (tim@timmcc.com)
Date: February, 2003
Description:
	Implements HMAC, a mechanism for message authentication using hash functions
	as specified in RFC 2104 (http://www.ietf.org/rfc/rfc2104.txt).  HMAC requires
	a hash function H and a secret key K and is computed as follows:
		H(K XOR opad, H(K XOR ipad, data)), where
			ipad = the byte 0x36 repeated 64 times
			opad = the byte 0x5c repeated 64 times
			data = the data to be authenticated
Required parameters: data, key
Optional parameters:
	data_format: hex = data is in hexadecimal format (default is ASCII text)
	key_format: hex = key is in hexadecimal format (default is ASCII text)
	hash_function: md5, sha1, sha256, or ripemd160 (default is md5)
	output_bits: truncate output to leftmost bits indicated (default is all)
Nested custom tags: md5.cfm, ripemd_160.cfm, sha_1.cfm, sha_256.cfm
Example syntax: <cf_hmac data="what do ya want for nothing?" key="Jefe">
Output variable: caller.digest
Note:
	This version accepts input in both ASCII text and hexadecimal formats.
	Previous versions did not accept input in hexadecimal format.
--->
<!--- default values of optional parameters --->
<cfparam name="attributes.data_format" default="">
<cfparam name="attributes.key_format" default="">
<cfparam name="attributes.hash_function" default="md5">
<cfparam name="attributes.output_bits" default="256">

<!--- Figure out what's coming in for troubleshooting --->
<cfset caller.incoming=attributes.data>


<!--- convert data to ASCII binary-coded form --->
<cfif attributes.data_format EQ "hex">
	<cfset hex_data = attributes.data>
<cfelse>
	<cfset hex_data = "">
	<cfloop index="i" from="1" to="#Len(attributes.data)#">
		<cfset hex_data = hex_data & Right("0"&FormatBaseN(Asc(Mid(attributes.data,i,1)),16),2)>
	</cfloop>
</cfif>

<!--- convert key to ASCII binary-coded form --->
<cfif attributes.key_format EQ "hex">
	<cfset hex_key = attributes.key>
<cfelse>
	<cfset hex_key = "">
	<cfloop index="i" from="1" to="#Len(attributes.key)#">
		<cfset hex_key = hex_key & Right("0"&FormatBaseN(Asc(Mid(attributes.key,i,1)),16),2)>
	</cfloop>
</cfif>

<cfset key_len = Len(hex_key)/2>

<!--- if key longer than 64 bytes, use hash of key as key --->
<cfif key_len GT 64>
	<cfswitch expression="#attributes.hash_function#">
		<cfcase value="md5">
			<cf_md5 msg="#hex_key#" format="hex">
		</cfcase>
		<cfcase value="sha1">
			<cf_sha_1 msg="#hex_key#" format="hex">
		</cfcase>
		<cfcase value="sha256">
			<cf_sha_256 msg="#hex_key#" format="hex">
		</cfcase>
		<cfcase value="ripemd160">
			<cf_ripemd_160 msg="#hex_key#" format="hex">
		</cfcase>
	</cfswitch>
	<cfset hex_key = msg_digest>
	<cfset key_len = Len(hex_key)/2>
</cfif>

<cfset key_ipad = "">
<cfset key_opad = "">
<cfloop index="i" from="1" to="#key_len#">
	<cfset key_ipad = key_ipad & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(hex_key,2*i-1,2),16),InputBaseN("36",16)),16),2)>
	<cfset key_opad = key_opad & Right("0"&FormatBaseN(BitXor(InputBaseN(Mid(hex_key,2*i-1,2),16),InputBaseN("5c",16)),16),2)>
</cfloop>
<cfset key_ipad = key_ipad & RepeatString("36",64-key_len)>
<cfset key_opad = key_opad & RepeatString("5c",64-key_len)>

<cfswitch expression="#attributes.hash_function#">
	<cfcase value="md5">
		<cf_md5 msg="#key_ipad##hex_data#" format="hex">
		<cf_md5 msg="#key_opad##msg_digest#" format="hex">
	</cfcase>
	<cfcase value="sha1">
		<cf_sha_1 msg="#key_ipad##hex_data#" format="hex">
		<cf_sha_1 msg="#key_opad##msg_digest#" format="hex">
	</cfcase>
	<cfcase value="sha256">
		<cf_sha_256 msg="#key_ipad##hex_data#" format="hex">
		<cf_sha_256 msg="#key_opad##msg_digest#" format="hex">
	</cfcase>
	<cfcase value="ripemd160">
		<cf_ripemd_160 msg="#key_ipad##hex_data#" format="hex">
		<cf_ripemd_160 msg="#key_opad##msg_digest#" format="hex">
	</cfcase>
</cfswitch>

<cfset caller.digest = Left(msg_digest,attributes.output_bits/4)>
