<!--- base on postcalc.usps.com/ZoneCharts/Default.aspx  we use: 043 which is the origin zip code of patrick--->




	<cfset zoneChart = structNew()>

	<cfset zoneChart["005"] = 4>

	<cfset zoneChart["006"] = 7>
	<cfset zoneChart["007"] = 7>
	<cfset zoneChart["008"] = 7>	
	<cfset zoneChart["009"] = 7>

	<cfloop from="10" to="65" index="z">
		<cfset zoneChart["0#z#"] = 5>
	</cfloop>
						
	<cfset zoneChart["066"] = 4>
	<cfset zoneChart["067"] = 5>

	<cfloop from="68" to="98" index="z">
		<cfset zoneChart["0#z#"] = 4>
	</cfloop>

	<cfloop from="100" to="119" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="120" to="123" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="124" to="127" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="128" to="129" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="130" to="149" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="150" to="154" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfset zoneChart["155"] = 4>
	<cfset zoneChart["156"] = 3>

	<cfloop from="157" to="159" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="160" to="165" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="166" to="212" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="214" to="239" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="240" to="243" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfset zoneChart["244"] = 4>
	<cfset zoneChart["245"] = 3>

	<cfloop from="246" to="253" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfset zoneChart["254"] = 4>

	<cfloop from="255" to="259" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfset zoneChart["260"] = 3>

	<cfloop from="261" to="264" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfset zoneChart["265"] = 3>
	<cfset zoneChart["266"] = 2>
	<cfset zoneChart["267"] = 4>
	<cfset zoneChart["268"] = 4>

	<cfloop from="270" to="274" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="275" to="279" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="280" to="282" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="283" to="285" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="286" to="289" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="290" to="292" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["293"] = 3>

	<cfloop from="294" to="295" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="296" to="297" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="298" to="299" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="300" to="303" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<!--- 2nd column --->
	<cfset zoneChart["304"] = 4>

	<cfloop from="305" to="307" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="308" to="310" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["311"] = 3>

	<cfloop from="312" to="320" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["321"] = 5>

	<cfloop from="322" to="326" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="327" to="342" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfset zoneChart["344"] = 4>

	<cfloop from="346" to="347" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfset zoneChart["349"] = 5>

	<cfloop from="350" to="352" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="354" to="369" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="370" to="374" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfset zoneChart["375"] = 4>

	<cfloop from="376" to="379" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="380" to="383" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="384" to="385" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="386" to="398" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["399"] = 3>

	<cfloop from="400" to="402" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="403" to="406" index="z">
		<cfset zoneChart["#z#"] = 1>
	</cfloop>

	<cfloop from="407" to="409" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="410" to="412" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="413" to="414" index="z">
		<cfset zoneChart["#z#"] = 1>
	</cfloop>

	<cfloop from="415" to="416" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="417" to="418" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="420" to="426" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfset zoneChart["427"] = 2>

	<cfloop from="430" to="433" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="434" to="436" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="437" to="438" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="439" to="449" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="450" to="462" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="463" to="468" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="469" to="474" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="475" to="477" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="478" to="479" index="z">
		<cfset zoneChart["#z#"] = 2>
	</cfloop>

	<cfloop from="480" to="489" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="490" to="491" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<!--- 3rd column --->
	<cfset zoneChart["492"] = 3>

	<cfloop from="493" to="509" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="510" to="513" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfset zoneChart["514"] = 4>

	<cfloop from="515" to="516" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="520" to="528" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="530" to="532" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="534" to="535" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="537" to="539" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["540"] = 5>

	<cfloop from="541" to="545" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfset zoneChart["546"] = 5>

	<cfloop from="547" to="549" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="550" to="551" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="553" to="567" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="570" to="575" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="576" to="577" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="580" to="584" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="585" to="588" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="590" to="593" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="594" to="596" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfset zoneChart["597"] = 6>

	<cfloop from="598" to="599" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="600" to="611" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="612" to="616" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="617" to="619" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfset zoneChart["620"] = 4>
	<cfset zoneChart["622"] = 4>

	<cfloop from="623" to="627" index="z">
		<cfset zoneChart["#z#"] = 3>
	</cfloop>

	<cfloop from="628" to="631" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="633" to="641" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="644" to="658" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="660" to="662" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="664" to="668" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="669" to="681" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="683" to="693" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="700" to="701" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="703" to="708" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="710" to="714" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="716" to="717" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<!--- 4th column --->
	<cfset zoneChart["718"] = 5>

	<cfloop from="719" to="729" index="z">
		<cfset zoneChart["#z#"] = 4>
	</cfloop>

	<cfloop from="730" to="731" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="733" to="741" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="743" to="770" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="772" to="778" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfset zoneChart["779"] = 6>

	<cfloop from="780" to="782" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="783" to="785" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="786" to="792" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="793" to="794" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="795" to="796" index="z">
		<cfset zoneChart["#z#"] = 5>
	</cfloop>

	<cfloop from="797" to="816" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="820" to="828" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="829" to="838" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="840" to="847" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="850" to="853" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="855" to="857" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="859" to="860" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="863" to="864" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfset zoneChart["865"] = 6>

	<cfloop from="870" to="871" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="873" to="885" index="z">
		<cfset zoneChart["#z#"] = 6>
	</cfloop>

	<cfloop from="889" to="891" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfset zoneChart["893"] = 7>

	<cfloop from="894" to="895" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfset zoneChart["897"] = 8>
	<cfset zoneChart["898"] = 7>

	<cfloop from="900" to="908" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="910" to="928" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="930" to="968" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfset zoneChart["969"] = 9>

	<cfloop from="970" to="978" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfset zoneChart["979"] = 7>

	<cfloop from="980" to="986" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="988" to="989" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="990" to="994" index="z">
		<cfset zoneChart["#z#"] = 7>
	</cfloop>

	<cfloop from="995" to="999" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<!--- exception --->
	<cfloop from="96900" to="96938" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="96945" to="96959" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="96961" to="96969" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

	<cfloop from="96971" to="96999" index="z">
		<cfset zoneChart["#z#"] = 8>
	</cfloop>

<cfparam name="varZip" default="0">

	<!--- check exception first --->
	<cfif varZip gte 96900 and varZip lte 96938>
		<cfset varReturnedZone = 8>
	<cfelseif varZip gte 96945 and varZip lte 96959	>
		<cfset varReturnedZone = 8>
	<cfelseif varZip gte 96961 and varZip lte 96969	>
		<cfset varReturnedZone = 8>
	<cfelseif varZip gte 96971 and varZip lte 96999	>
		<cfset varReturnedZone = 8>
	<cfelse>
		
		<!--- zip not part of exception --->
		<cfif structKeyExists(zoneChart, "#left(varZip,3)#") >
			<cftry>
				<cfset varReturnedZone = zoneChart["#left(varZip,3)#"]>            	            
	        <cfcatch type="Any" >
				<cfset varReturnedZone = "error">
	        </cfcatch>
	        </cftry>			
		<cfelse>
			<!--- zip not found in the struct --->
			<cfset varReturnedZone = "not found">
		</cfif>
					


	</cfif>	
	
	

