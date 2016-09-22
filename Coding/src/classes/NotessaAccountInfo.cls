public class NotessaAccountInfo {
	
	/*** VARIABLES ***/     
    public final Contact proj{get;set;}
    public String accountId;
    public NwAccountDetails[] m_listAccounts = null;
  	public String m_selectedContactId = null;
  	public String m_selectedContactEmail = null;
	public Integer numButtonClicks = 0;
	public boolean loadButtonDisabled = false;
		
	/*** CONSTRUCTOR ***/
	public NotessaAccountInfo(ApexPages.StandardController controller){      
	    proj = (Contact)controller.getRecord();  
	}

    public PageReference incrementLoadButtonClicks() {
            numButtonClicks++;
            loadButtonDisabled = true;
            return null;
    }

    public Integer getNumClicks() {
        return numButtonClicks;
    }
        
	public boolean getIsLoadButtonDisabled() {
		return loadButtonDisabled;
	}

	public List<NWAccountDetails> getAllAccounts(){   
        
        Map<String, String> accountMap = new Map<String, String>();
        m_selectedContactId = proj.Id;
                 
      	if(m_selectedContactEmail == null){
        	LIST<Contact> contacts = [SELECT email FROM Contact WHERE id = :m_selectedContactId];
        	if(contacts.size() == 1 && contacts[0].email != null){
          		m_selectedContactEmail = EncodingUtil.urlEncode(contacts[0].email, 'UTF-8');
        	} else {
        		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
					'An email address is required to check whether a Contact is associated with accounts in Notessa!'));       		
        	}
      	}
      	
      	if(m_selectedContactEmail != null){ 
        	if(getListAccounts() == null || (m_selectedContactId != proj.Id)){
            	connectToNWAPI(m_selectedContactEmail);             
        	}        	
      	}

        return m_listAccounts;
    }

    /*** Querying the API using the primary contact's email address - called from getAllAccounts above..***/
    public void connectToNWAPI(String emailAddress){    
  		
  		//VARIABLES
  		String respStatus, baseUrlEU, baseUrlUS;
  		transient Boolean noEUAccounts = false;
  		transient Boolean noUSAccounts = false;
  		transient Integer i, j;
        transient Http h = new Http();
        transient HTTPResponse resp, respUS;
        transient HttpRequest req = new HttpRequest(); 		  		
  		transient NwAccountDetails[] accountsEU = new NwAccountDetails[0];
  		transient NwAccountDetails[] accountsUS = new NwAccountDetails[0];
  		
  		String numberOfAccountsEU, numberOfAccountsUS;  		
   	 	req = NotessaAccountInfoHelper.setUpHttpRequest(req); //Call method to set all parameters for http request
        
        // Make call to EU API and get response
        baseUrlEU = 'https://intraapi.newsweaver.com/internal/user/'+emailAddress+'/account_users';               
        req.setEndpoint(baseUrlEU ); //http request endpoint set to UK api        
        resp = NotessaAccountInfoHelper.makeCallout(req, h, resp); //Call method to make http request to UK api    
        dom.Document responseDocEU = resp.getBodyDocument(); //xml document       
		
		// Make call to US API and get response
  		baseUrlUS = 'https://intraapi.us.newsweaver.com/internal/user/'+emailAddress+'/account_users';       
    	req.setEndpoint(baseUrlUS ); //http request endpoint set to US api   	
    	respUS = NotessaAccountInfoHelper.makeCallout(req, h, respUS); //Call method to make http request to US api		
  		dom.Document responseDocUS = respUS.getBodyDocument(); //xml document

		
		//Call method to check number of accounts in xml after EU call
		numberOfAccountsEU = NotessaAccountInfoHelper.checkNumberOfAccounts(responseDocEU);
		if(numberOfAccountsEU == '0' || numberOfAccountsEU == null){
			System.debug('No accounts from EU call..');
			noEUAccounts = true; //set boolean for no accounts to true
		} else {
			System.debug('Got accounts from EU call..');
		}
		
		//Call method to check number of accounts in xml after US call
		numberOfAccountsUS = NotessaAccountInfoHelper.checkNumberOfAccounts(responseDocUS);
		if(numberOfAccountsUS == '0' || numberOfAccountsUS == null){
			System.debug('No accounts from US call..');
			noUSAccounts = true; //set boolean for no accounts to true
		} else {
			System.debug('Got accounts from US call..');
		}
		
		if(!noEUAccounts && numberOfAccountsEU != '0'){
			accountsEU = parseAccounts(responseDocEU, accountsEU, baseUrlEU); //parse through xml & build NwAccountDetails object 			
			m_listAccounts=accountsEU;	//Add list of NwAccountDetails to variable reference by VF page
		}
		
		if(!noUSAccounts && numberOfAccountsUS != '0'){
			accountsUS = parseAccounts(responseDocUS, accountsUS, baseUrlUS);
			//System.debug('Contents of accountsUS: ' + accountsUS);
			
			if(m_listAccounts != null){ //Check if any accounts were built in from EU api call
				System.debug('List already has accounts: ' + m_listAccounts);
				m_listAccounts.add(accountsUS[0]);
			} else {
				System.debug('List is empty!');
				m_listAccounts=accountsUS;
			}
		}
		
		if(noEUAccounts && noUSAccounts){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
				'There were no Notessa accounts found in either the EU or the US data centres for this ' + 
				'Contact. Please log into Notessa and check if this Contact has been setup as a user.'));
		}
    }

    public NwAccountDetails[] parseAccounts(dom.Document doc, NwAccountDetails[] accounts, String apiUrl) {     
		Integer i = 0;
 		             
       //Set data centre according to api url
        String accountDataCentre, accountId, accountName, accountStatus, accountType, accountRole, accountProduct; 
        Boolean varsSet;
        
        if(apiUrl.contains('.us.')){
        	accountDataCentre = 'US';
        } else {
        	accountDataCentre = 'EU';
        }
        
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
			
            if(node.getName()=='account_user') {	// Node in xml tree where all account details are located under

             	NwAccountDetails nwAccount = NwAccountDetailsFactory();	// Create instance of the nwAccount to hold values used by VF page
				
				// Reset account variables
				accountId = ''; 
				accountName = '';
				accountStatus = '';
				accountType = '';
				accountRole = '';
				                  	
                
				for(dom.XmlNode childnode : node.getChildElements()) {
					
					varsSet = false;  // Reset variable that checks if account variables have already been set for this acccount
					
					/* Traverse through the xml tree and get account id, name, status & type values*/
                  	if(childnode.getName()=='account'){
                    	accountId = childnode.getAttribute('id', null);                
                    	dom.XmlNode nameNode = childnode.getChildElement('name', null);
                    	accountName = nameNode.getText();
                    	dom.XmlNode statusNode = childnode.getChildElement('lock_status', null);
                    	accountStatus = statusNode.getText();
                    	dom.XmlNode accountTypeNode = childnode.getChildElement('account_type', null);
                    	accountType = accountTypeNode.getText();                   	           
                  	} 

                  	if(childnode.getName()=='account_role'){
                  		dom.XmlNode acRoleNameNode = childnode.getChildElement('name', null);
                  		accountRole = acRoleNameNode.getText();
                  		varsSet = true;
                  	}
					
					if(varsSet != false){ // If this variable is true then account vars have been set above - values ready to be added to nwAccount object

						/* SET VARS */
	                	nwAccount.accountId = accountId; 
	                 	nwAccount.accountName = accountName;  
	                 	nwAccount.accountStatus = accountStatus;
	                 	nwAccount.accountType = accountType;
	                	nwAccount.accountDataCentre = accountDataCentre;
	                	nwAccount.accountProduct = NotessaAccountInfoHelper.getAccountProduct(accountId, accountDataCentre);
	                  	nwAccount.accountRole = accountRole;
	                  	accounts.add(nwAccount); // Add nwAccount object to list of nwAccounts to be returned to page
					}
              }   
          }
      	}
      	      
      	return accounts;
   }
	
   	public PageReference displayMessage(){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Error Retrieving the Account and Publication Details from Newsweaver.Please use the description field'));
    	return null;
   	}             

    public NwAccountDetails NwAccountDetailsFactory(){
    	return new NwAccountDetails();      
    }

	public class NwAccountDetails{
       	String accountName;
       	String accountId;
       	String accountStatus;
       	String accountType;
       	String accountDataCentre;
       	String accountRole;
       	String accountProduct;
       	
       	public String getaccountName(){
        	return accountName; 
       	}
       
       	public void setaccountName(String accName){
        	accountName = accName; 
       	}
       
       	public String getaccountId(){
        	return accountId;
       	}
       
       	public void setaccountId(String accId){
        	accountId = accId; 
       	}     
       
      	public String getaccountStatus(){
        	return accountStatus;
       	}
		
		public String getaccountProduct(){
			return accountProduct;
		}       
		
		public void setaccountProduct(String accProduct){
			accountProduct = accProduct;
		}
		
       	public void setaccountStatus(String accStatus){
       		accountId = accStatus; 
       	}       
       	public String getaccountType(){
        	return accountType;
       	}
       
       	public void setaccountType(String accType){
        	accountType = accType; 
       	}

       	public String getaccountDataCentre(){
       		return accountDataCentre;
       	}
       	
       	public void setaccountDataCentre(String accDataCentre){
       		accountDataCentre = accDataCentre;
       	}
 
        public String getaccountRole(){
       		return accountRole;
       	}
       	
       	public void setaccountRole(String accRole){
       		accountRole = accRole;
       	}
    }
   
    public void setListAccounts(NwAccountDetails[] nwAccounts){
    	m_listAccounts = nwAccounts;
  	}

 	public NwAccountDetails[] getListAccounts(){
    	return m_listAccounts;  
  	}    
}