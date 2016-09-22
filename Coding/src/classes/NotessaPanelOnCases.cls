public with sharing class NotessaPanelOnCases {

    //VARIABLES
    private String [] m_lstPubs  = new String[]{};     
    public static NwPubDetails[] m_NWPublications;
    public final Case proj{get;set;}
    public String accountById;    
    public String publicationById;            
        public String accountId, dataCentre;
        public String m_selectedContactId = null;
        public String m_selectedContactEmail = null;
        public String accountRef;
        public String pubIds;
        private String[] accountIds = new String[]{}; //array to hold list of selected account ids
        public String selectedAccounts; //string to hold selected account ids
        public Boolean accIdIsChanged = false;      
        public Boolean disabl {get;set;}
        
        //create instance of helper class containing methods for connecting to Notessa API
        public NotessaPanelOnCasesHelper ntsahelper = new NotessaPanelOnCasesHelper();

        //class to hold list of available notessa accounts    
        private NotessaPanelOnCasesHelper.NwAccountDetails[] m_listAccounts = null;
    
    //CONSTRUCTOR
    public NotessaPanelOnCases(ApexPages.StandardController controller){      
    
        proj = (Case)controller.getRecord();  
        System.debug('refAccount__c check 1: ' + proj.refAccount__c);

        //if ref_Account is set on the case, get this, otherwise launch a warning message
        if(proj.refAccount__c == 'none' || proj.refAccount__c == null){
                System.debug('Account Ref Debug 2...');
                disabl = true; 
                selectedAccounts = System.currentPagereference().getParameters().get('refAccountVar');
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+
                                'A Notessa Account Needs To Be Added To This Case.'));         
        
        } else{ 
                System.debug('Account Ref Debug 1...');
                selectedAccounts=proj.refAccount__c;  
        }           
            
        if(selectedAccounts != null){ //split out the selecteAccounts string into an array of selected account ids     
                String[] splitIds = selectedAccounts.split(';');

            if(splitIds.size() == 1){
                setAccountId(splitIds[0]);
                setAccountIds(splitIds);
            } else {
                setAccountIds(splitIds);
            }      
        }
        
        if (proj.refPublications__c!= null) { //if refPublications is set on the case
                pubIds = proj.refPublications__c;
        } else {
            //else look for publications(campaigns) ref parameter in url
            pubIds=System.currentPagereference().getParameters().get('refCampaignVar');
        }     
        
        if(pubIds != null){        
            String[] splitIds = pubIds.split(';');
            setPublications(splitIds);
        }
    }
    
    public void setAccountId(String accId){
        accountId = accId;
        // Need to set flag for disabling save button to false if valid newsweaver account id is found otherwise launch warning message
        if(accId != null && accId.containsAny('0123456789')){
                System.debug('SetAccountId - Account has been selected!!');
                disabl = false;
        } else {
                System.debug('No account has been selected!!');
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+
                                'A Notessa Account Needs To Be Added To This Case.'));
                disabl = true;                  
        }        
    }
  
        public String getAccountId(){ // Called from caseCampaignPicker VF page - Edit on Case
        return accountId;  
        }

        public void setAccountIds(String[] accId){ //method to set accountIds
        accountIds = accId;
    }

        public String[] getAccountIds(){ //method to get accountIds 
        return accountIds; 
    }

    public void setPublications (String [] lstPublications){
        m_lstPubs = lstPublications;
    }
    
    public String [] getPublications (){ // Called from caseCampaignPicker VF page - Edit on Case
        return m_lstPubs;
    }
        
        public void setDataCentre(String accDataCentre){
        dataCentre = accDataCentre; 
    }
  
        public String getDataCentre(){ // Called from caseCampaignPicker VF page - Edit on Case
        return dataCentre;  
        }

        public String getAccountById(){ //Called from CaseCampaignPanel VF page - Read only on Case
        String accountName = '';    
        String tmp_refAccount, tmp_refAccountNew;
        tmp_refAccount = proj.refAccount__c;
        
        String l_dataCentre = proj.refDataCentre__c;
        
        for(String ref : accountIds){
                // Handle situation where the 'Please select...' option is clicked
                if(ref.equals('none')){
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+
                                'Notessa Account/Campaign Not Specified! '));
                } else {
                        dom.Document doc = ntsahelper.getAccountDocument(ref, l_dataCentre);
                        if(accountIds.size() > 1){
                                accountName = accountName + getNodeNameText(doc) + ', ';                        
                        } else {
                                accountName = accountName + getNodeNameText(doc);                                       
                        }       
                }
                
        }        
        
                if(accountName != '' || accountName != null){           
                        return accountName;
                } else {
                        proj.refAccount__c = null;
                        proj.refDataCentre__c = null;
                        return null;
                }                  
        }
        
        public void setAccountById(String accId){
        accountById = accId;
    }

        public String getPublicationById(){ //Called from CaseCampaignPanel VF page - Read only on Case
        
        //VARIABLES
        String publicationName = '';
        String accId = proj.refAccount__c;
        String pubIds = proj.refPublications__c;
        String base;
        
        if(pubIds != null){
                
                for (String splitIds : pubIds.split(';')){ 
            
                //Need to establish where to make api call to to get publications for account
                        //System.debug('Inside getPublicationById data centre is: ' + proj.refDataCentre__c);
                        System.debug('Account Ids: ' + accountIds);
                        if(proj.refDataCentre__c == 'EU'){
                                base = 'https://intraapi.newsweaver.com/internal/account/'+accountIds[0]+'/publication/'+splitIds;      
                        } else {
                                base = 'https://intraapi.us.newsweaver.com/internal/account/'+accountIds[0]+'/publication/'+splitIds;
                        }
                
                dom.Document doc = ntsahelper.apiCallHelper(base);
                publicationName = publicationName + getNodeNameText(doc) + ',';
                }
        }
        return publicationName; 
        }
  
        public void setPublicationById(String pubId){
        publicationById = pubId;
        }

        public dom.Document getAccountDocument(String accId){
        HttpRequest req = new HttpRequest();
        req = NtsaInfoHelperClass.setUpHttpRequest(req); 
        String base;
        
        //Need to establish where to make api call to to get publications for account
        if(getDataCentre() == 'EU'){
                base = 'https://intraapi.newsweaver.com/internal/account/'+accId;       
        } else {
                base = 'https://intraapi.us.newsweaver.com/internal/account/'+accId;
        }
               
        req.setEndpoint(base);
        
        // create the response object
        Http h = new Http();
        HTTPResponse resp;           
        try{
                resp = h.send(req);
        } catch(Exception e){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+
                                'Error encountered trying to access Internal API! '));
            return null;
        }
        dom.Document doc = resp.getBodyDocument();
        return doc;
        }
    
    public List<SelectOption> getAllAccounts(){  // Called from caseCampaignPicker VF page - Edit on Case 
                                                                                                //to populate accounts pick list
        String contactPageParam = Apexpages.currentPage().getParameters().get('selectedContactId');
        
        list<SelectOption> options = new List<SelectOption>();

        if(contactPageParam == null && m_selectedContactId == null){
                m_selectedContactId = proj.ContactId; //Set contact Id to be the case contact Id
        } else if(m_selectedContactId == null && contactPageParam != null){
                m_selectedContactId = contactPageParam;
        }
      
        if(m_selectedContactId != null){ //Get Email address of Contact         

                if(m_selectedContactEmail == null){
                LIST<Contact> contacts = [SELECT email FROM Contact WHERE id = :m_selectedContactId];
                
                if(contacts.size() == 1){
                        m_selectedContactEmail = EncodingUtil.urlEncode(contacts[0].email, 'UTF-8');
                }
                }
          
                if(m_selectedContactEmail != null){ 
                                
                                //For new cases there will be no accounts initially so need to retrieve accounts
                if(ntsahelper.getListAccounts() == null || (m_selectedContactId != proj.ContactId)){
                        
                        //Call method in helper class to check both EU & US API's for accounts linked to this email                 
                        ntsahelper.connectToNWAPI(m_selectedContactEmail);                                                                                                                           
                }
                //All accounts for contact email will be returned..

                Integer i = 0;
                
                if(ntsahelper.getListAccounts() != null){
                        
                        String pageUrl = ApexPages.currentPage().getUrl();
                        // Only add 'Please select..' option to edit design page that contains single select picklist
                        if(pageUrl.contains('caseCampaignPicker')){
                                options.add(new SelectOption('none', 'Please select..'));
                        }
                        
                        //Loop through list of Notessa Account objects containing Notessa Account Id & Account Name
                        for (NotessaPanelOnCasesHelper.NwAccountDetails nwAcc:ntsahelper.getListAccounts()){
                                
                                if((getAccountId() == null) && (!pageUrl.contains('caseCampaignPicker')) && (i == 0)){
                                        setAccountId(nwAcc.getNTSAaccountId());                                         
                                } 
                                                                
                                if(getDataCentre() == null){ // && getAccountId() != 'none'){
                                        setDataCentre(nwAcc.getaccountDataCentre()); //Only needs to be set once
                                }
                                
                                //Add notessa account Id as value and account name as label to pick list on VF page
                                options.add(new SelectOption(nwAcc.getNTSAaccountId(),nwAcc.getNTSAaccountName()));
                                i++;
                        }
                }
                }
        }

        if(!accIdIsChanged && getAccountId() == null){
                setAccountId('none');   
        }

        return options;
    }
    
    public List<SelectOption> getAllPublications(){ // Called from caseCampaignPicker VF page - Edit on Case
                                                                                        // populates publications pick list
        list<SelectOption> options = new List<SelectOption>();
        
        if(getAccountId() == null && accountIds.isEmpty() == false){
                populatePublicationDetails(accountIds[0]);
        }
        if(m_NWPublications == null && getAccountId() != null){ 
                populatePublicationDetails(getAccountId()); //Call method to get publication details     
        }
        
        // m_NWPublications now containing list of Notessa Publication objects (name & id)
        if(m_NWPublications != null){
                //loop through list and add each publication to pick list: id as value and name as Label
                for(NwPubDetails nwPub:m_NWPublications){
                        options.add(new SelectOption(nwPub.getPublicationId(),nwPub.getPublicationName()));
                }         
        }        
        
        return options;
    }

       
    /*This is called when the account Changes*/  
    public void populatePublicationDetails(String newAccountId){
        dom.Document doc = getAccountPublicationsDocument(newAccountId);
        if(doc != null){        
                m_NWPublications = populatePublicationDetailsInner(doc.getRootElement());            
        }
    }
        
        //Call the Notessa API and return the results of the call in an xml document
        public dom.Document getAccountPublicationsDocument(String accId){
        
        HttpRequest req = new HttpRequest();
        req = NtsaInfoHelperClass.setUpHttpRequest(req); 
        String base;
        //Need to establish where to make api call to to get publications for account
        //System.debug('Inside getAccountPublicationsDocument data centre is: ' + getDataCentre());
        if(getDataCentre() == 'EU'){
                base = 'https://intraapi.newsweaver.com/internal/account/'+accId+'/publications';       
        } else {
                base = 'https://intraapi.us.newsweaver.com/internal/account/'+accId+'/publications';
        }
               
        req.setEndpoint(base);
        
        // create the response object
        Http h = new Http();
        HTTPResponse resp;              
        try{
                resp = h.send(req);
        } catch(Exception e){
            //System.debug('Got exception: ' + e);
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+
                                'Error encountered trying to access Internal API! '));
            return null;
        }
        dom.Document doc = resp.getBodyDocument();
        return doc;
        }
        
        //Takes the xml document returned above & parses through the xml and return list of publication objects
        //containing Notessa publication name and publication ID    
    public NwPubDetails[] populatePublicationDetailsInner(dom.XmlNode publicationsNode){

        NwPubDetails[] lstNwPubs = new NwPubDetails[0];
        String publicationName, publicationId, publicationStatus;
        
        for (dom.XmlNode publicationNode : publicationsNode.getChildElements()){
                
                if(publicationNode != null && publicationNode.getName() == 'publication'){
                        
                        NwPubDetails publicationDetails = new NwPubDetails(); //Create new publication object - necessary to do this here
                                                                                                                        //if more than 1 publication exists in the account
                        
                        dom.Xmlnode publicationNodeName = publicationNode.getChildElement('name', null);
                        publicationName = publicationNodeName.getText();
                        
                        publicationId = publicationNode.getAttribute('id', null); 
                        
                        dom.Xmlnode publicationNodeStatus = publicationNode.getChildElement('lock_status', null);
                        publicationStatus = publicationNodeStatus.getText();
                                                
                        //SET VARS
                        publicationDetails.publicationName = publicationName;
                        publicationDetails.publicationId = publicationId;
                        publicationDetails.publicationStatus = publicationStatus;
                        
                        //Adding filter for excluding locked publications in listing
                        if(publicationId != null && publicationName != null && publicationStatus != 'Locked'){
                                lstNwPubs.add(publicationDetails);
                        }
                }              
        }
        return lstNwPubs;
        } 

    /*This is called when the contact Changes*/
    public void setSelectedContactId(){
        ntsahelper.setListAccounts(null);
        setAccountId(null);
        m_selectedContactEmail = null;
        m_selectedContactId = Apexpages.currentPage().getParameters().get('selectedContactId');
        }
        
    /*Get the text from the child Name Node.*/
        public String getNodeNameText(dom.Document doc){
    
        if (doc != null){
                dom.XmlNode node = doc.getRootElement();
                dom.XmlNode nameNode = node.getChildElement('name', null);
                return nameNode.getText();          
        }
        return '';    
        }
        
        public PageReference saverec() {
        
        String selectedAccounts = ' ';          

                //Check if change is coming from Design case select list
                if(accIdIsChanged){                     
                        proj.refAccount__c = getAccountId(); //Update field with current account id
                        proj.refPublications__c = ''; //clear the current publication ids as the account has been changed
                                        
                } else {
                
                for(String ref :getAccountIds()){       //Otherwise handle multiple account selection from multi select list
                        selectedAccounts= selectedAccounts + ref + ';';
                }       
                proj.refAccount__c=selectedAccounts; // Update field with multiple accounts             
                }
                proj.refDataCentre__c = getDataCentre(); //Update field with current data centre
        
        // Check if publications have been selected
        if (getPublications() == null || getPublications().isEmpty()){
            System.debug ('No values');
            System.debug('Param values: ' + System.currentPagereference().getParameters().get('refCampaignVar'));
            //return null;
        } else {
            String publicationIds = '';
            for (String s : getPublications()){ // Loop through all publications and string of publication ids
                publicationIds = publicationIds + s + ';';
            }
            proj.refPublications__c = publicationIds; // Update field with publication ids
        }
        
        if(proj.Id != null){
                update proj;        
        } else {
                insert proj;
        }     
        
        PageReference projPage = new ApexPages.StandardController(proj).view();
        projPage.setRedirect(true);      
        return projPage;
    }

    
        public PageReference displayMessage(){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Error Retrieving the Account and Publication Details from Newsweaver.Please use the description field'));
        return null;
        }
         
    /*This is called when the account Changes*/
    public PageReference updateSelectedAccountId(){
        //populate the publications.
        accIdIsChanged = false;         
        setAccountId(Apexpages.currentPage().getParameters().get('selectedAccountId'));
        proj.refAccount__c = getAccountId();
        populatePublicationDetails(Apexpages.currentPage().getParameters().get('selectedAccountId'));
        accIdIsChanged = true;
        return null;          
    } 
        public class NwPubDetails{
    
        String publicationName;
        String publicationId;
        String publicationStatus;
        
        public String getPublicationName(){
                return publicationName; 
        }
       
        public void setPublicationName(String pubName){
                publicationName = pubName; 
        }
       
        public String getPublicationId(){
                return publicationId;
        }
       
        public void setPublicationId(String pubId){
                publicationId = pubId;
        }
        
        public String getPublicationStatus(){
                return publicationStatus; 
        }
       
        public void setPublicationStatus(String pubStatus){
                publicationStatus = pubStatus; 
        }           
        }
   
        public void setNwPublicationDetails (NwPubDetails[] nwPubs){
        m_NWPublications = nwPubs;
    }
    
    public NwPubDetails[] getNwPublicationDetails (){
        return m_NWPublications;
    }   
}