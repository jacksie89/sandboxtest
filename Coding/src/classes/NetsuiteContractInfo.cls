public class NetsuiteContractInfo {

    public final Account proj{get;set;}
    public Netsuite[] listContracts = null;
    public String m_selectedNWOrganisationId = null;
    public String m_selectedAccountId = null;
    
    // CONSTRUCTOR 
    public NetsuiteContractInfo(ApexPages.StandardController controller){      
        proj = (Account)controller.getRecord();  
    }

    public List<Netsuite> getAllContracts(){   

        m_selectedAccountId = proj.Id;
        LIST<Account> sfOrgs = [SELECT NW_Organisation_Id__c FROM Account WHERE id = :m_selectedAccountId];
        if(sfOrgs.size() == 1){
            m_selectedNWOrganisationId = sfOrgs[0].NW_Organisation_Id__c;
        }

        if(sfOrgs.size() == 1){
            m_selectedNWOrganisationId = sfOrgs[0].NW_Organisation_Id__c;
        }
        
        connectToRestlet(m_selectedNWOrganisationId);
        
        return listContracts;       
    }
    
    public void connectToRestlet(String nwOrgId){    
        
        //VARIABLES
        integer totalSize = 0;
        String respStatus, base;
        Http h = new Http();
        HTTPResponse resp;
        HttpRequest req = new HttpRequest();
        req = setUpHttpRequest(req); //Call method to set all parameters for http request
        Netsuite[] contracts = new Netsuite[0];


        //Set the UK api as the initial url to call
        //base = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=265&deploy=1&custentity23=NWO033410412';
        base = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=269&deploy=2&custentity23=' + nwOrgId;       
        //base = 'https://rest.na1.netsuite.com/app/site/hosting/restlet.nl?script=269&deploy=1&custentity23=' + nwOrgId;
        req.setEndpoint(base ); 
        
        resp = makeCallout(req, h, resp); 
    
        JSONParser parser = JSON.createParser(resp.getBody());

		try {
        	contracts = parseContracts(parser, contracts);
        	System.debug('Value of contracts: ' + contracts);
        	if(contracts != null){
            	listContracts = contracts;
            } else {
            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
                	'There were no active contracts found in Netsuite for this Organisation. ' + 
                	'Please log into Netsuite and check if this Organisation has been setup correctly.'));
        	}
        } catch (Exception e) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
                'There were no active contracts found in Netsuite for this Organisation. ' + 
                'Please log into Netsuite and check if this Organisation has been setup correctly.'));
        }
                     
    }

    public Netsuite[] parseContracts(JSONParser theParser, Netsuite[] theContracts) {     

        System.JSONToken token;
        Decimal contractVal;
        Netsuite ns = NSContractDetailsFactory();
        List<Netsuite> tmpCons = new List<Netsuite>();
        String startDate, endDate, con_currency, account_names, text;
        
        System.debug('Inside parseContracts method');
        
        theParser.nextToken();  // Eat first START_OBJECT {
        theParser.nextToken();     // Eat token = FIELD_NAME; text = postalcodes
        
        if(theParser.getText() == 'error'){
            theContracts = null;
            return theContracts;
        } else {
            System.debug('Contract details retrieved successfully from Netsuite');
        }
        
        theParser.nextToken();     // Eat first START_ARRAY [
        theParser.nextToken();     // Eat the first object's START_OBJECT {
        theParser.nextToken();
        theParser.nextToken();
        
        //Netsuite[] contracts = new Netsuite[0];
                
        while ((token = theParser.nextToken()) != null) {

            if ((token = theParser.getCurrentToken()) != JSONToken.END_OBJECT) {
                
                text = theParser.getText();
               
                //System.debug('INNER TOKEN IS: ' + token);
                if (token == JSONToken.FIELD_Name && text == 'custrecord_contracts_start_date') {
                    token=theParser.nextToken();
                    startDate = theParser.getText();
                    ns.ContractStartDate = startDate;
                    System.debug('Start Date is: ' + startDate);
                
                } else if (token == JSONToken.FIELD_Name && text == 'custrecord_contracts_end_date') {
                    token=theParser.nextToken();
                    endDate = theParser.getText();
                    ns.ContractEndDate = endDate;
                    System.debug('End Date is: ' + endDate);
                
                } else if (token == JSONToken.FIELD_Name && text == 'custrecord_swe_annual_contract_val_net') {
                    token=theParser.nextToken();
                    contractVal = theParser.getDecimalValue();
                    contractVal = contractVal.setScale(2);
                    ns.ContractValue = contractVal;
                    System.debug('Contract Value is: ' + contractVal);
                
                } else if (token == JSONToken.FIELD_Name && text == 'custrecord28') {
                    token=theParser.nextToken();
                    account_names = theParser.getText();
                    ns.accountNames = account_names;
                    //System.debug('Account names are: ' + parser.getText());
                
                } else if (token == JSONToken.FIELD_Name && text == 'custrecord_swe_contract_currency') {
                    theParser.nextToken();
                    theParser.nextToken();
                    token=theParser.nextToken();
                    con_currency = theParser.getText();
                    ns.conCurrency = con_currency;
                    System.debug('Currency is: ' + con_currency);
                
                } else {
                    //System.debug('Parser Text is: ' + text);
                }  
                
            } else {

                theContracts.add(ns);
                tmpCons.add(ns);
                
                System.debug('theContracts List: ' + theContracts);
                System.debug('tmpCons List: ' + tmpCons);
                
                //Reset variables
                startDate = '';
                endDate = '';
                contractVal = 0.0;
                con_currency = '';
                account_names = '';
                
                ns = NSContractDetailsFactory(); // Declare new instance of factory for new contract object
                theParser.nextToken();
                theParser.nextToken();
            }
            
        }
        
        return theContracts;
   }

    //Return response from http request
    public HTTPResponse makeCallout(HTTPRequest request, HTTP h, HTTPResponse httpResp){
        
        try{
            httpResp = h.send(request); //Make the http request
  
        }catch(Exception e){
          System.debug('Got exception: ' + e);
        }
        return httpResp;      
    }
    
    public static HttpRequest setUpHttpRequest(HttpRequest req){
        
        String accountId = '3551380';
        String username = 'salesforceadmin@newsweaver.com';
        String password = 'PJsbq8jHghZG7lK3TkBS';
        String accountRole = '3';
        String authorizationHeader;
        
        req.setMethod('GET');
        req.setTimeout(60000);   //set timeout to 1 minute             
        authorizationHeader = 'NLAuth nlauth_account='+ accountId +',nlauth_email=' + username + ',nlauth_signature='+ password +',nlauth_role='+ accountRole;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        return req;
    }
    
    public Netsuite NSContractDetailsFactory(){
        return new Netsuite();      
    }
    
    public class Netsuite {

        public String contractStartDate;
        public String contractEndDate;
        public Decimal contractValue;
        public String conCurrency;
        public String accountNames;
        
        public String getContractStartDate(){
            return contractStartDate;
        }

        public String getContractEndDate(){
            return contractEndDate;
        }
    
        public Decimal getContractValue(){
            return contractValue;
        }
        
        public String getconCurrency(){
            return conCurrency;
        }
        
        public String getAccountNames(){
            return accountNames;
        }
    
        public void setContractStartDate(String conStartDate){
            contractStartDate = conStartDate; 
        }   
        
        public void setContractEndDate(String conEndDate){
            contractEndDate = conEndDate; 
        }
    
        public void setContractValue(Double conValue){
            contractValue = Decimal.valueOf(conValue);
            contractValue = contractValue.setScale(2); 
        }
        
        public void setconCurrency(String contractCurrency){
            conCurrency = contractCurrency;
        }
        
        public void setAccountNames(String accNames){
            accountNames = accNames;
        }
    }

    public void setListContracts(Netsuite[] nsContracts){
        listContracts = nsContracts;
    }

    public Netsuite[] getListContracts(){
        return listContracts;  
    } 
}