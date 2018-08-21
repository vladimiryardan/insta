<cfoutput>
	<!DOCTYPE html>
	<html>
	<head>
	<title>Title of the document</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

	<script src="http://izhuk.com/imaging/service/"></script>
	<!---<script src="js/imaging.js"></script>--->
	<script src="js/resources.js"></script>   <!-- Contains text messages and icons -->
  		
	</head>
	
	<body>
	
	
	<canvas id="imaging" width="900" height="600" style="border:1px solid black;outline:none"></canvas>

<form id="save_form" name="save_form" method="POST" action="save_image.cfm">
    <input type="hidden" id="file_ext" name="file_ext" />
    <input type="hidden" id="base64data" name="base64data" />
</form>
	
	<script type="text/javascript" >
		
	    var params = {
			resources : RESOURCES // resource text messages (defined in resources.js),
			,save : saveImage
			
	    };
    	
		var imaging = new Imaging( document.getElementById('imaging'), params );	 
		var image_url = urlParam('image');  
		imaging.loadImage(image_url ? image_url : (image_url = '1.jpg'));
		imaging.loadImage(image_url);
    	
    	
    	//console.log(imaging.getImageData() )
    	 //http://instantonlineconsignment.com/images/201.13227.167/1.jpg

		
		// Saves the processed image
		function saveImage() {
		    // if crop selector is drawn apply it
		    if (imaging.getSelector()) imaging.doAction('crop');
		
		    // You can check the output image size and if it is not satisfactory refuse saving
		    // var size = imaginggetImageSize();
		    // ...
		
		    // Get Image Data, extract image type (jpeg,png) and the data itself (base64 encoded),
		    // and submit them to save.php
		    var imageData = imaging.getImageData({ format: getMimeFromFileExt(image_url) });
		    
		    var matches = imageData.substring(0,imageData.indexOf('base64,')+7).match(/^data:.+\/(.+);base64,(.*)$/);
		    if (matches) {
			document.getElementById('file_ext').value = matches[1];
			document.getElementById('base64data').value = imageData.substring(imageData.indexOf('base64,')+7);
			document.getElementById('save_form').submit();
		    }
		    else window.alert('Wrong data format');
		}
				

		// A utility function to choose the appropriate mime type basing on the file extension
		function getMimeFromFileExt(filename) {
		    if (filename) {
			var re = /(?:\.([^.]+))?$/;
			var ext = re.exec(filename)[1];
			if (ext) {
			    switch(ext.toLowerCase()) {
				case 'jpeg': return 'image/jpeg';
				case 'jpg' : return 'image/jpeg';
			    }
			}
			return 'image/png'; // use png by default
		    }
		    return 'image/jpeg'; // if !filename assume jpeg
		}
		
		// A utility function to read URL parameters
		function urlParam(name){ // returns URL parameter
		    var results = new RegExp('[\?&]'+name+'=([^&##]*)').exec(window.location.href);
		    return results != null ? decodeURIComponent(results[1] || 0) : null;
		}
		
	</script>
	</body>
	
	</html>
</cfoutput>