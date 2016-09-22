public class NotessaAccountInfoHelper {

	//Return response from http request
	public static HTTPResponse makeCallout(HTTPRequest request, HTTP h, HTTPResponse httpResp){
        
        try{
        	httpResp = h.send(request); //Make the http request
  
        }catch(Exception e){
          System.debug('Got exception: ' + e);
        }
        return httpResp;      
	}
	
	//Read the xml document, check the number of accounts returned in xml & return number of accounts
	public static String checkNumberOfAccounts(dom.Document doc){
		String totalResults;
		
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
			if(node.getName() == 'totalResults'){
				totalResults = node.getText();
			} else if(node.getName() == 'code'){
				totalResults = null;
			}
        }
        
        return totalResults;
	}
	
	public static String getAccountProduct(String nwAccId, String data_centre){
  		//VARIABLES
  		String product_respStatus, product_baseUrl, product_baseUrlUS, product_name;
  		
        Http product_h = new Http();
        HTTPResponse product_resp;
        HttpRequest product_req = new HttpRequest(); 		  		
  		 		
   	 	product_req = setUpHttpRequest(product_req); //Call method to set all parameters for http request

      	//Set the UK api as the initial url to call
        if(data_centre == 'US'){
        	product_baseUrl = 'https://intraapi.us.newsweaver.com/internal/account/'+nwAccId;	
        } else {
        	product_baseUrl = 'https://intraapi.newsweaver.com/internal/account/'+nwAccId;
        }
               
        product_req.setEndpoint(product_baseUrl); //http request endpoint set to UK api
    
        product_resp = makeCallout(product_req, product_h, product_resp); //Call method to make http request to UK api    
        
        dom.Document product_responseDoc = product_resp.getBodyDocument(); //xml document       
		
		for(dom.XmlNode anode : product_responseDoc.getRootElement().getChildElements()) {
			                  	                
          	if(anode.getName()=='product'){
            	product_name = anode.getText();                              	           
          	}
        }
		
        return product_name;			
	}
	
    public static HttpRequest setUpHttpRequest(HttpRequest req){
        // Set the headers as required by the Newsweaver API
        req.setMethod('GET');
        req.setTimeout(60000);   //set timeout to 1 minute     
        req.setHeader('User-Agent', 'Jakarta Commons-HttpClient/3.0.1');
        //req.setHeader('ACCEPT', '*/*');        
        req.setHeader('Authorization', 'Basic c2FsZXNmb3JjZWFkbWluQG5ld3N3ZWF2ZXIuY29tOmExNDI2MjFhZTAyM2U0NzI4MGNiZWI3NDEzNQ==');
        try{
            req.setClientCertificateName('salesforceadministrator');  
        }catch(Exception e){ 
            System.debug('Error setting client certificate');
        }    
        return req;
    }
      	
}