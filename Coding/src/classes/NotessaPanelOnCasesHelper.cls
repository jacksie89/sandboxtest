public with sharing class NotessaPanelOnCasesHelper {

	public NwAccountDetails[] m_listAccounts;
	public String notessaAccountDataCentre;
	
  	public dom.Document getAccountDocument(String accId, String theDataCentre){
		System.debug('Inside helper class, accId: ' + accId);
		System.debug('Inside helper class, data centre: ' + theDataCentre);    	
    	String baseUrl;
		theDataCentre = theDataCentre.toLowerCase();

        if(theDataCentre != 'eu'){
        	baseUrl = 'https://intraapi.'+theDataCentre+'.newsweaver.com/internal/account/'+accId;
        } else {
        	baseUrl = 'https://intraapi.newsweaver.com/internal/account/'+accId;
        }
  		dom.Document responseDoc = apiCallHelper(baseUrl); //Call apiCaller method to make call and generate xml response document

      	return responseDoc;
  	}
  
	//method to Get the text from the child Name Node.
  	public String getNodeNameText(dom.Document doc){
    	if (doc != null){
        	dom.XmlNode node = doc.getRootElement();
          	dom.XmlNode nameNode = node.getChildElement('name', null);
          	return nameNode.getText();          
        }
        return '';    
  	}
  
	//method to create API get request
 	public static HttpRequest setUpHttpRequest(HttpRequest req){
    
    	// Set the headers as required by the Newsweaver API
    	req.setMethod('GET');
        req.setTimeout(10000);        
        req.setHeader('User-Agent', 'Jakarta Commons-HttpClient/3.0.1');
        req.setHeader('ACCEPT', '*/*');        
        req.setHeader('Authorization', 'Basic c2FsZXNmb3JjZWFkbWluQG5ld3N3ZWF2ZXIuY29tOmExNDI2MjFhZTAyM2U0NzI4MGNiZWI3NDEzNQ==');
        
        try{
        	req.setClientCertificateName('salesforceadministrator');    
        }catch(Exception e){
            System.debug('Error setting client certificate');
        }
        
        return req;
  	}	
	
	public NwAccountDetails[] connectToNWAPI(String emailAddress){    
      	System.debug('Inside connectToNWAPI method with email .... ' + emailAddress);
       	NwAccountDetails[] accountsEU = new NwAccountDetails[0];
  		NwAccountDetails[] accountsUS = new NwAccountDetails[0];
      	String respStatus, baseUrlEU, baseUrlUS;
      	String numberOfAccountsEU, numberOfAccountsUS;
      	Boolean noEUAccounts = false;
  		Boolean noUSAccounts = false;
		
        //Start by setting URL to call EU API
  		baseUrlEU = 'https://intraapi.newsweaver.com/internal/user/'+emailAddress+'/account_users';
  		dom.Document responseDocEU = apiCallHelper(baseUrlEU); //Call apiCaller method to make call and generate xml response document
  		
		//Now Set URL to call US API
  		baseUrlUS = 'https://intraapi.us.newsweaver.com/internal/user/'+emailAddress+'/account_users';  		
  		dom.Document responseDocUS = apiCallHelper(baseUrlUS);//Call apiCaller method to make call and generate xml response document
  		        
		//Call method to check number of accounts in xml after EU call
		numberOfAccountsEU = checkNumberOfAccounts(responseDocEU);
		
		//if no accounts found in EU data centre set flag to true
		if(numberOfAccountsEU == '0' || numberOfAccountsEU == null){
			noEUAccounts = true; 
		}
		
		//Call method to check number of accounts in xml after US call
		numberOfAccountsUS = checkNumberOfAccounts(responseDocUS);
		
		//if no accounts found in US data centre set flag to true
		if(numberOfAccountsUS == '0' || numberOfAccountsUS == null){
			noUSAccounts = true; //set boolean for no accounts to true
		}

		//Now parse through accounts for EU data centre if found
		if(!noEUAccounts && numberOfAccountsEU != '0'){
			accountsEU = parseAccounts(responseDocEU, accountsEU, baseUrlEU); //parse through xml & build NwAccountDetails object 			
			m_listAccounts=accountsEU;	//Add list of NwAccountDetails to variable reference by VF page
		}
		
		//Now parse through accounts for US data centre if found
		if(!noUSAccounts && numberOfAccountsUS != '0'){
			accountsUS = parseAccounts(responseDocUS, accountsUS, baseUrlUS);

			if(m_listAccounts != null && accountsUS.size() > 0){ //Check if any accounts were built in from EU api call
				m_listAccounts.add(accountsUS[0]);
			} else if(accountsUS.size() > 0){
				m_listAccounts=accountsUS; //Set accounts from US API to be the list of accounts to return
			}
		}

    	return m_listAccounts;
    }

	public dom.Document apiCallHelper(String baseUrl){
		Http h = new Http();
        HTTPResponse resp;		        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl);
        req = setUpHttpRequest(req);
        
        resp = makeCallout(req, h, resp); //Call method to make http request to EU API     
		System.debug('Response returned: ' + resp);
		dom.Document responseDoc = resp.getBodyDocument(); //store response in xml document  
		System.debug('Response doc: ' + resp.getBody());     
		return responseDoc;
	}
		
	//Return response from http request
	public HTTPResponse makeCallout(HTTPRequest request, HTTP h, HTTPResponse httpResp){
        
        try{
        	if(!Test.isRunningTest()){
        		httpResp = h.send(request); //Make the http request
  				System.debug('Make callout success..');
  				System.debug('Reponse is: ' + httpResp);
        	} else {
        		System.debug('Test class is running - mockup callout httpResponse');
        		HttpResponse testResponse = new HttpResponse();
        		testResponse.setHeader('Content-Type', 'text/xml');
        		testResponse.setBody('<?xml version="1.0" encoding="UTF-8"?>' + 
'<?xml-stylesheet href="https://intraapi.newsweaver.com/nwinternalapistatic/ntsa-api.xsl" type="text/xsl"?>' +
'<?xml-stylesheet href="https://intraapi.newsweaver.com/nwinternalapistatic/ntsa-api.css" type="text/css"?>' +
'<account id="541" uri="https://intraapi.newsweaver.com/internal/account/541"><link href="https://intraapi.newsweaver.com/internal/account/541/account_users" rel="http://api-info.newsweaver.com/internal/rels/account.account_user" title="Account_users"/><link href="https://intraapi.newsweaver.com/internal/account/541/publications" rel="http://api-info.newsweaver.com/internal/rels/account.publication" title="Publications"/><link href="https://intraapi.newsweaver.com/internal/account/541/account_roles" rel="http://api-info.newsweaver.com/internal/rels/account.account_role" title="Account_roles"/><link href="https://intraapi.newsweaver.com/internal/account/541/publication_roles" rel="http://api-info.newsweaver.com/internal/rels/account.publication_role" title="Publication_roles"/><link href="https://intraapi.newsweaver.com/internal/account/541/account_restricted_ips" rel="http://api-info.newsweaver.com/internal/rels/account.account_restricted_ip" title="Account_restricted_ips"/><link href="https://intraapi.newsweaver.com/internal/account/541/microsite_restricted_ips" rel="http://api-info.newsweaver.com/internal/rels/account.microsite_restricted_ip" title="Microsite_restricted_ips"/><name>Newsweaver Communications</name><code>nw-int</code><account_type>Standard</account_type><lock_status>Active</lock_status><country>Ireland</country><company>Newsweaver</company><mail_server><server_pool>Pool F - nw010.com</server_pool></mail_server><account_settings><account_quota>1800</account_quota><max_users>25</max_users><domain_extension>.co.uk</domain_extension><api_mode>Production</api_mode><disable_access_to_subscriber_metric_data>false</disable_access_to_subscriber_metric_data><allow_salesforce_integration>true</allow_salesforce_integration><enable_remember_me>true</enable_remember_me><restrict_access_to_ip_addresses>true</restrict_access_to_ip_addresses><restrict_api_access_to_ip_addresses>false</restrict_api_access_to_ip_addresses><security_quota>1800</security_quota><quota_type>MONTHLY</quota_type><advanced_audience_management>true</advanced_audience_management></account_settings><product>Internal Connect</product></account>');
        		testResponse.setStatusCode(200);
        		httpResp = testResponse;
        	}
        		
        	
        }catch(Exception e){ //Catch communication exception and display error message on page.
          System.debug('Got exception: ' + e);
          Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+
				'Error encountered trying to access Internal API! '));
        }
        return httpResp;      
	}

	//Read the xml document, check the number of accounts returned in xml & return number of accounts
	public String checkNumberOfAccounts(dom.Document doc){

		String totalResults;

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
			if(node.getName() == 'totalResults'){
				totalResults = node.getText();
			} else if(node.getName() == 'code'){ //Indicates no accounts were found.
				totalResults = null;
			}
        }
        return totalResults;
	}
		        
    public NwAccountDetails[] parseAccounts(dom.Document doc, NwAccountDetails[] accounts, String apiUrl) {     

		String accountId, accountName, accountStatus;
		
       //Set data centre according to api url
        String accountDataCentre; 
        if(apiUrl.contains('.us.')){
        	accountDataCentre = 'US';
        } else {
        	accountDataCentre = 'EU';
        }
        notessaAccountDataCentre = accountDataCentre;            	
    	System.debug('Inside parseAccounts, Data Centre is: ' + accountDataCentre);
    	for(dom.XmlNode node : doc.getRootElement().getChildElements()) {

        	if(node.getName()=='account_user') {
            	
            	for(dom.XmlNode childnode : node.getChildElements()) {
              	
              		if(childnode.getName()=='account'){
                		
                		NwAccountDetails nwAccount = NwAccountDetailsFactory(); //Create new account object
                		accountId = childnode.getAttribute('id', null);                
                		
                		dom.XmlNode nameNode = childnode.getChildElement('name', null);
              			accountName = nameNode.getText();
              			
              			dom.XmlNode statusNode = childnode.getChildElement('lock_status', null);
              			accountStatus = statusNode.getText();
              			
              			//SET VARS
              			nwAccount.NTSAaccountId = accountId; 
               			nwAccount.NTSAaccountName = accountName;  
               			nwAccount.NTSAaccountDataCentre = accountDataCentre;
               			nwAccount.NTSAaccountStatus = accountStatus;
               			
               			//Filter out locked accounts
               			if(accountStatus != 'Locked'){
               				accounts.add(nwAccount);	
               			}          
              		}                              
            	}
        	}
  		}      
  		return accounts;
 	} 
 
	public NwAccountDetails NwAccountDetailsFactory(){
    	return new NwAccountDetails();      
    } 

	//NwAccountDetails defined - i.e. class to hold id and name of notessa accounts    
	public class NwAccountDetails{
    	String NTSAaccountName;
       	String NTSAaccountId;
       	String NTSAaccountDataCentre;
       	String NTSAaccountStatus;
       	
       	public String getNTSAaccountName(){
        	return NTSAaccountName; 
       	}
       
       	public void setNTSAaccountName(String accName){
        	NTSAaccountName = accName; 
       	}
       
       	public String getNTSAaccountId(){
        	return NTSAaccountId;
       	} 
       
       	public void setNTSAaccountId(String accId){
        	NTSAaccountId = accId; 
       	}   
       	public String getaccountDataCentre(){
       		return NTSAaccountDataCentre;
       	}
       	
       	public void setaccountDataCentre(String accDataCentre){
       		NTSAaccountDataCentre = accDataCentre;
       	}
       	public String getNTSAAccountStatus(){
       		return NTSAaccountStatus;
       	}
       	
       	public void setNTSAAccountStatus(String accStatus){
       		NTSAaccountStatus = accStatus;
       	}
	}

  	public NwAccountDetails[] getListAccounts(){
    	return m_listAccounts;  
  	}
  
  	//method to set list of available accounts
	public void setListAccounts(NwAccountDetails[] nwAccounts){
    	System.debug('setListAccounts: ' + nwAccounts);
    	m_listAccounts = nwAccounts;
  	}
}