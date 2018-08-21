<cfoutput>
	
<style type="text/css">

	##itmDisplay ul {
	    /*border: 1px solid ##444;*/
	    display: inline-block;
	    position: relative;
		    height: auto;
		    list-style: outside none none;
		    width: 1000px;
	}

	li.limg {
	   display:inline-block;
	}
		

	.item-html1:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/1.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html2:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/2.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html3:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/3.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html4:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/4.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html5:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/5.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html6:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/6.jpg) no-repeat;
		background-size: 50%;
	}					
	.item-html7:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/7.jpg) no-repeat;
		background-size: 50%;
	}		
	.item-html8:hover ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/8.jpg) no-repeat;
		background-size: 50%;
	}		

	
	<!---target --->
	.item-html1:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/1.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html2:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/2.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html3:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/3.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html4:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/4.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html5:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/5.jpg) no-repeat;
		background-size: 50%;
	}	
	.item-html6:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/6.jpg) no-repeat;
		background-size: 50%;
	}					
	.item-html7:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/7.jpg) no-repeat;
		background-size: 50%;
	}		
	.item-html8:target ~ li div.clicPicBig {
		background: url(#_layout.ia_images##sqlAuction.use_pictures#/8.jpg) no-repeat;
		background-size: 50%;
	}
	

	.clicPicBig {
	    /*
	    left: 150px;
	    position: absolute;
	    top: 0;
	    background-image: url(#_layout.ia_images##sqlAuction.use_pictures#/1.jpg);
	    width:750px;
	    height:1000px;
	    background-size: 750px;
	    background-repeat:no-repeat;
	    */
	    
    
	    
	    /**/
	    background-image: url(#_layout.ia_images##sqlAuction.use_pictures#/1.jpg);
	    background-size: 50%;
	    background-repeat: no-repeat;
	    width: 100%;
	    height: 0;
	    padding-top: 66.64%; /* (img-height / img-width * container-width) 
	    
  	/*
  	background-image: url(#_layout.ia_images##sqlAuction.use_pictures#/1.jpg);      
  	background-repeat: no-repeat;
  	background-size: cover;
  	height: 65vw;       
	*/		
		
			    
	    /*
	    background-size: 750px;
	    background-repeat:no-repeat;
		background-size:contain;
		background-position:center;
	    */
	}	
		 
</style>


<table valign="middle" align="center" cellpadding="0" cellspacing="0" border="0" style='table-layout:fixed'>
<tr>
	<td valign="top" id="itmDisplay">
		
			<!--- image display --->
			<ul>
		    
			    <cfloop from="1" to="8" index="i" >
				    <cfset imgNum = i>
				    <cfif FileExists("#request.basepath##_layout.images_path##sqlAuction.use_pictures#/#imgNum#.jpg")>
				    <li class="item-html#imgNum# limg" id="item-html#imgNum#">
				        <a class="showImage#imgNum#" href="##item-html#imgNum#">
				        	<img src="#_layout.ia_images##sqlAuction.use_pictures#/#imgNum#thumb.jpg" border="1" >
				        </a>
				    </li>
				    </cfif>
			    </cfloop>
			
			<li class="lastElementBig" >
				<div class="clicPicBig">
				</div>					
			</li>    
		    
			    			    	    	    
			    			        			    			    			    			    
			</ul>
	</td>

</tr>
</table>


</cfoutput>
