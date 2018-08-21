<cfoutput>

	<html>
		<head>
			<title>ColdFusion Examples</title>
			<style>
				BODY {font-family:Arial;font-size:small;background:##eeeeee;padding:20px;}
				H1 {color:##000000;text-shadow:0px 1px gold;}
			</style>
		</head>
		<body>

			<!--- TODO:Make a note about using showXmlResponse(), which allows users to retrieve the raw XML result (unformatted) --->
			<h1>Marketplace Web Services (MWS)</h1>
			<dd>
				MWS is a REST-based API. All examples assume you have setup your account and read the introductory guides for integrating Marketplace Web Services.<br/><br/>
				<h2>Feeds</h2>
				<a href="https://images-na.ssl-images-amazon.com/images/G/01/mwsportal/doc/en_US/bde/MWSFeedsApiReference._V169765614_.pdf" target="_blank">Feeds Documentation</a>
				<br/>Amazon MWS supports the management of seller listings for items to be sold on Amazon.com. Listings can be added, deleted, or modified with Amazon MWS. A variety of specialized feed formats are supported to meet a wide range of seller needs. For example, new products can be added to the Amazon catalog by using MWS supported feeds to define new product detail pages on Amazon.com. High volume changes such as product price and quantity updates can be updated using a simplified price and quantity feed that minimizes the data that sellers must provide.
				<br/><br/>
				<ol>
					<li><a href="./examples/mws/mws-submitfeed.cfm">Submit Feed</a></li>
					<br/>Use the submit feed operation to upload files (XML) and any necessary metadata for processing. The ColdFusion library
					automatically handles formatting requests, generating signatures, creating MD5 hashes, and executing REST requests.<br/><br/>
					<li><a href="./examples/mws/mws-getfeedsubmissionlist.cfm">Get Feed Submission Operations</a></li>
					<br/>Use the feed submission retrieval operations to return feeds submitted over the last 90 days, view reports, count submissions, and cancel submissions.<br/><br/>
					<ul style="margin-top:6px;">
						<li><a href="./examples/mws/mws-getallsubmissions.cfm">Get ALL Feed Submissions</a></li>
						This special example shows how all feed submisisons (up to 100) can be returned using tokens.
					</ul>
					<br/>
				</ol>
				<h2>Reports</h2>
				<a href="https://images-na.ssl-images-amazon.com/images/G/03/mwsportal/doc/en_US/bde/MWSReportsApiReference._V170098838_.pdf" target="_blank">Reports Documentation</a>
				<br/>Amazon MWS supports the management of seller orders for items sold on Amazon.com. Orders received can be downloaded and acknowledged using Amazon MWS. A variety of order report formats and actions are supported to meet specific seller needs. For example, order reports can be set up for automatic generation following a schedule that's optimized to match seller workflow.
				<br/><br/>
				<ol>
					<li><a href="./examples/mws/mws-reportrequest.cfm">Request Report</a></li>
					<br/>
					<ul style="margin-top:6px;">
						<li><a href="./examples/mws/mws-getreportrequestlist.cfm">Report Request List</a></li>
						Example of the GetReportRequestList operation. Returns a list of report requests that match the query parameters.<br/><br/>
						<li><a href="./examples/mws/mws-getreportlist.cfm">Report List</a></li>
						Example of the GetReportList operation. Returns a list of reports that match the query parameters.<br/>
					</ul>
					<br/><br/>
					<li><a href="./examples/mws/mws-manageschedule.cfm">Update Report Schedules</a></li>
					<br/>
					<ul style="margin-top:6px;">
						<li><a href="./examples/mws/mws-getschedule.cfm">Get Report Schedule List</a></li>
						Example of the GetReportScheduleList, GetReportScheduleCount operation.<br/><br/>
						<li><a href="examples/mws/mws-reportacknowledgement.cfm">Acknowledge Reports</a></li><br/>
						This is an example of how to acknowledge a report. This example is in a format slightly differing from
						the others in order to support acknowledgement of FeedSummary reports.
					</ul>
					<br/><br/>
				</ol>
				<div style="margin:10px;padding:10px;background:maroon;color:white;border:2px solid gold;">
					Some ColdFusion-specific debugging features that are not part of the Amazon MWS API are included
					in the source code. There are two mathods part of the marketplace.cfc (com.amazon.mws.marketplace)
					specifically for debugging:
					<ol>
						<li><b>getResultDetail(&lt;query_string&gt;)</b> provides detail about how a request is structured, signed, and submitted.</li>
						<li><b>setShowXmlResponse(&lt;true/false&gt;)</b> includes the raw XML response in addition to the formatted results of a request.</li>
						<li><b>setDebug(&lt;true/false&gt;)</b> Turns on lower level debugging. This should be used when you're receiving a ColdFusion error for a request, but want to see the raw error from Amazon.</li>
					</ol>
				</div>
			</dd>
		</body>
	</html>
</cfoutput>