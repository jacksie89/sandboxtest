public class NotessaAccountInfoOnOrgs {
  
    // VARIABLES      
    public final Account proj{get;set;}
    public String accountId;
    public NwAccountDetails[] m_listAccounts = null;
    public String m_selectedAccountId = null;
    public String m_selectedContactEmail = null;
    public String m_selectedNWOrganisationId = null;
    public String requestLabel;
    public Integer numButtonClicks = 0;
    public boolean loadButtonDisabled = false;
      
    // CONSTRUCTOR 
    public NotessaAccountInfoOnOrgs(ApexPages.StandardController controller){      
        proj = (Account)controller.getRecord();  
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

        //Map<String, String> accountMap = new Map<String, String>();
        m_selectedAccountId = proj.Id;
                 
        LIST<Account> sfOrgs = [SELECT NW_Organisation_Id__c FROM Account WHERE id = :m_selectedAccountId];
        
        if(sfOrgs.size() == 1){
            m_selectedNWOrganisationId = sfOrgs[0].NW_Organisation_Id__c;
        }
            
        if(m_selectedNWOrganisationId != null){ 
            
            if(getListAccounts() == null || (m_selectedNWOrganisationId != proj.Id)){
                connectToNWAPI(m_selectedNWOrganisationId);             
            }          
        }

        return m_listAccounts;       
    }

    public void connectToNWAPI(String nwOrgId){    
        
        //VARIABLES
        String respStatus, base;
        Http h = new Http();
        HTTPResponse resp;
        HttpRequest req = new HttpRequest();
        
        req = NotessaAccountInfoHelper.setUpHttpRequest(req); //Call method to set all parameters for http request
        
        System.debug('Organisation Id is: ' + m_selectedNWOrganisationId);
        NwAccountDetails[] accounts = new NwAccountDetails[0];

        //Set the UK api as the initial url to call
        base = 'https://intraapi.newsweaver.com/internal/accounts?organisation_id='+m_selectedNWOrganisationId;       
        req.setEndpoint(base ); //http request endpoint set to UK api
        
        resp = NotessaAccountInfoHelper.makeCallout(req, h, resp); //Call method to make http request to UK api
        System.debug('Response from makeCallout: ' + resp);
    
        dom.Document responseDoc = resp.getBodyDocument(); //xml document
        
        //Call method to check number of accounts in xml after EU call and if no accounts then setup http request to US api     
        if(NotessaAccountInfoHelper.checkNumberOfAccounts(responseDoc) == '0'){
            System.debug('There were no accounts returned in this call!');
            base = 'https://intraapi.us.newsweaver.com/internal/accounts?organisation_id='+m_selectedNWOrganisationId;       
            req.setEndpoint(base ); //http request endpoint set to UK api
            resp = NotessaAccountInfoHelper.makeCallout(req, h, resp);
            responseDoc = resp.getBodyDocument();
        } else {                            
            System.debug('This call has at least 1 account.');
        }

        //Need to check number of accounts after US call
        //Call method to process response and return xml document
        if(NotessaAccountInfoHelper.checkNumberOfAccounts(responseDoc) == '0'){
            System.debug('Empty list of accounts..');
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
                'There were no Notessa accounts found in either the EU or the US data centres for this ' + 
                'Organisation. Please log into Notessa and check if this Organisation has been setup correctly.'));
            System.debug('Debug 1...');
        } else {
            accounts = parseAccounts(responseDoc, accounts, base);
            m_listAccounts = accounts;
        }
                         
    }
    
    public NwAccountDetails[] parseAccounts(dom.Document doc, NwAccountDetails[] accounts, String apiUrl) {     
               
       //Set data centre according to api url
        String accountDataCentre; 
        
        if(apiUrl.contains('.us.')){
            accountDataCentre = 'US';
        } else {
            accountDataCentre = 'EU';
        }
        
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {

            if(node.getName()=='account') {
                
                // Traverse through the xml tree and get account id, name, status & type values                 
                NwAccountDetails nwAccount = NwAccountDetailsFactory();
                String accountId = node.getAttribute('id', null);                
                dom.XmlNode nameNode = node.getChildElement('name', null);
                String accountName = nameNode.getText();
                dom.XmlNode statusNode = node.getChildElement('lock_status', null);
                String accountStatus = statusNode.getText();
                dom.XmlNode accountTypeNode = node.getChildElement('account_type', null);
                String accountType = accountTypeNode.getText();              
                    
                // SET VARS 
                nwAccount.accountId = accountId; 
                nwAccount.accountName = accountName;  
                nwAccount.accountStatus = accountStatus;
                nwAccount.accountType = accountType;
                nwAccount.accountDataCentre = accountDataCentre;
                nwAccount.accountProduct = NotessaAccountInfoHelper.getAccountProduct(accountId, accountDataCentre);
                accounts.add(nwAccount);   
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
        
        public String getaccountProduct(){
            return accountProduct;
        }       
        
        public void setaccountProduct(String accProduct){
            accountProduct = accProduct;
        }           
    }
   
    public void setListAccounts(NwAccountDetails[] nwAccounts){
        m_listAccounts = nwAccounts;
    }

    public NwAccountDetails[] getListAccounts(){
        return m_listAccounts;  
    }    
}