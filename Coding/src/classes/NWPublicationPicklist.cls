public with sharing class NWPublicationPicklist {    
    private String [] m_lstPubs  = new String[]{};     
    private NwAccountDetails[] m_listAccounts = null;
    public static NwPubDetails[] m_NWPublications;
    public final SFDC_Projects__c proj{get;set;}
    public String accountById;    
    public String publicationById;            
  public String accountId;
  public String m_selectedContactId = null;
  public String m_selectedContactEmail = null;
    
    public NWPublicationPicklist(ApexPages.StandardController controller){      
        proj = (SFDC_Projects__c)controller.getRecord();  
        String pubIds = proj.refPublications__c;
        setAccountId(proj.refAccount__c);
        
        if(pubIds != null){        
            String[] splitIds = pubIds.split(';');
            setPublications(splitIds);
        }
    }
    
    public void setAccountId(String accId){
    accountId = accId; 
  }
  public String getAccountId(){
    return accountId;  
  }

  public String getPublicationById(){
    String publicationName = '';
    String accId = proj.refAccount__c;
    HttpRequest req = new HttpRequest();
    req = setUpHttpRequest(req);
    Http h = new Http();
        HTTPResponse resp;
        String pubIds = proj.refPublications__c;
        if(pubIds != null){
          for (String splitIds : pubIds.split(';'))
          { 
            String base = 'https://intraapi.newsweaver.com/internal/account/'+accId+'/publication/'+splitIds;       
            req.setEndpoint(base);
              try{
                  resp = h.send(req);
              }catch(Exception e){
                  System.debug('Got exception: ' + e);
             }
             if(resp != null){
             	dom.Document doc = resp.getBodyDocument();
              	publicationName = publicationName + getNodeNameText(doc) + ',';
             }

  

          }
        }
       return publicationName; 
  }
  
  public void setPublicationById(String pubId){
    publicationById = pubId;
  }
  
  public String getAccountById(){
    String accountName = 'Error retieving Account Name';    
    dom.Document doc = getAccountDocument(proj.refAccount__c);
       return getNodeNameText(doc);           
  }
  
  
  public dom.Document getAccountDocument(String accId){
    HttpRequest req = new HttpRequest();
    req = setUpHttpRequest(req); 
        String base = 'https://intraapi.newsweaver.com/internal/account/'+accId;       
        req.setEndpoint(base);
        
        // create the response object
        Http h = new Http();
        HTTPResponse resp;           
      try{
        resp = h.send(req);
      }
      catch(Exception e){
            System.debug('Got exception: ' + e);
              return null;
    }
      dom.Document doc = resp.getBodyDocument();
      return doc;
  }
    
  public dom.Document getAccountPublicationsDocument(String accId){
    HttpRequest req = new HttpRequest();
    req = setUpHttpRequest(req); 
        String base = 'https://intraapi.newsweaver.com/internal/account/'+accId+'/publications';       
        req.setEndpoint(base);
        
        // create the response object
        Http h = new Http();
        HTTPResponse resp;              
        try{
              resp = h.send(req);
        }catch(Exception e){
        	System.debug('Got exception: ' + e);
        	return null;
        }
        dom.Document doc = resp.getBodyDocument();
        return doc;
  }
  
  public void setAccountById(String accId){
    accountById = accId;
  }
    
    public List<SelectOption> getAllAccounts()
    {   

      String contactPageParam = Apexpages.currentPage().getParameters().get('selectedContactId');
        list<SelectOption> options = new List<SelectOption>();
        
        if(contactPageParam == null && m_selectedContactId == null){
          m_selectedContactId = proj.Contact__c;
        }else if(m_selectedContactId == null && contactPageParam != null){
          m_selectedContactId = contactPageParam;
        }
        if(m_selectedContactId != null){          
          if(m_selectedContactEmail == null){
            LIST<Contact> contacts = [SELECT email FROM Contact WHERE id = :m_selectedContactId];
            if(contacts.size() == 1){
              m_selectedContactEmail = EncodingUtil.urlEncode(contacts[0].email, 'UTF-8');
            }
          }
          if(m_selectedContactEmail != null){ 
            if(getListAccounts() == null || (m_selectedContactId != proj.Contact__c)){
                connectToNWAPI(m_selectedContactEmail);             
            }
            Integer i = 0;
            if(getListAccounts() != null){
              for (NwAccountDetails nwAcc:getListAccounts()){
                if((getAccountId() == null) && (i == 0)){
                  setAccountId(nwAcc.getaccountId());
                }
                options.add(new SelectOption(nwAcc.getaccountId(),nwAcc.getaccountName()));
                i++;
              }
            }
          }
        }
        return options;
    }
    
    public List<SelectOption> getAllPublications()
    {    
       list<SelectOption> options = new List<SelectOption>();
       if(m_NWPublications == null && getAccountId() != null){ 
           populatePublicationDetails(getAccountId());    
       }
       if(m_NWPublications != null){
         for(NwPubDetails nwPub:m_NWPublications){
        options.add(new SelectOption(nwPub.getPublicationId(),nwPub.getPublicationName()));
         }         
       }        

       return options;
    }
    
    public void connectToNWAPI(String emailAddress){    
      NwAccountDetails[] accounts = new NwAccountDetails[0];
      HttpRequest req = new HttpRequest();
    req = setUpHttpRequest(req); 
        String base = 'https://intraapi.newsweaver.com/internal/user/'+emailAddress+'/account_users';        
        req.setEndpoint(base );
        // create the response object
        Http h = new Http();
        HTTPResponse resp;
        try{
            resp = h.send(req);
        }catch(Exception e){
        	System.debug('Got exception: ' + e);
        	return;
      	}     
        accounts = new NwAccountDetails[0];
        dom.Document doc = resp.getBodyDocument();
        if (doc != null){
          accounts = parseAccounts(doc, accounts);
        }
        m_listAccounts = accounts;
    }
        
    public NwAccountDetails[] parseAccounts(dom.Document doc, NwAccountDetails[] accounts) {     
  Integer i = 0;
    for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
        if(node.getName()=='account_user') {
            for(dom.XmlNode childnode : node.getChildElements()) {
              if(childnode.getName()=='account'){
                NwAccountDetails nwAccount = NwAccountDetailsFactory();
                String accountId = childnode.getAttribute('id', null);                
                dom.XmlNode nameNode = childnode.getChildElement('name', null);
              String accountName = nameNode.getText();
              nwAccount.accountId = accountId; 
               nwAccount.accountName = accountName;  
               // if no account has been selected load the publications for the first account
              if((getAccountId() == null) && (i == 0)){
                System.debug('In parse Accounts');
                populatePublicationDetails(nwAccount.getaccountId());             
              }  
              accounts.add(nwAccount); 
              i++;           
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
         
    /*This is called when the account Changes*/
    public PageReference updateSelectedAccountId(){
      //populate the publications.
      setAccountId(Apexpages.currentPage().getParameters().get('selectedAccountId'));
      populatePublicationDetails(Apexpages.currentPage().getParameters().get('selectedAccountId'));
      return null;          
    } 
       
    /*This is called when the account Changes*/  
    public void populatePublicationDetails(String newAccountId){
      dom.Document doc = getAccountPublicationsDocument(newAccountId);
      if(doc != null){        
        m_NWPublications = populatePublicationDetailsInner(doc.getRootElement());            
      }
    }
    
     public NwPubDetails[] populatePublicationDetailsInner(dom.XmlNode publicationsNode){

    NwPubDetails[] lstNwPubs = new NwPubDetails[0];
    for (dom.XmlNode publicationNode : publicationsNode.getChildElements()){
      if(publicationNode != null && publicationNode.getName() == 'publication'){
        NwPubDetails publicationDetails = new NwPubDetails();
        dom.Xmlnode publicationNodeName = publicationNode.getChildElement('name', null);
        publicationDetails.publicationName = publicationNodeName.getText();
        publicationDetails.publicationId = publicationNode.getAttribute('id', null); 
        if(publicationDetails.getPublicationId() != null && publicationDetails.getPublicationName() != null){
          lstNwPubs.add(publicationDetails);
        }
      }              
    }
    return lstNwPubs;
  } 

    /*This is called when the contact Changes*/
    public void setSelectedContactId(){
    setListAccounts(null);
    setAccountId(null);
    m_selectedContactEmail = null;
    m_selectedContactId = Apexpages.currentPage().getParameters().get('selectedContactId');
  }
     
   
     /*
  Get the text from the child Name Node.
  */
  public String getNodeNameText(dom.Document doc){
        if (doc != null){
          dom.XmlNode node = doc.getRootElement();
          dom.XmlNode nameNode = node.getChildElement('name', null);
          return nameNode.getText();          
        }
        return '';    
  }
    
    public static HttpRequest setUpHttpRequest(HttpRequest req)
  {
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
    
  public PageReference saverec() 
    {
      proj.refAccount__c = getAccountId();
        if (getPublications() == null)
        {
            System.debug ('No values');
            //return null;
        }else{
            String publicationIds = '';
            for (String s : getPublications())
            {
                publicationIds = publicationIds + s + ';';
            }
            proj.refPublications__c = publicationIds;
        }
      if(proj.Id != null){
        update proj;        
      }else{
        insert proj;
      }     
    PageReference projPage = new ApexPages.StandardController(proj).view();
      projPage.setRedirect(true);      
      return projPage;
      
    }
    
    public NwAccountDetails NwAccountDetailsFactory(){
    return new NwAccountDetails();      
    }
  
  public class NwPubDetails{
       String publicationName;
       String publicationId;
       
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
   }
   
   public class NwAccountDetails{
       String accountName;
       String accountId;
       
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
   }
   
     public void setListAccounts(NwAccountDetails[] nwAccounts){
    m_listAccounts = nwAccounts;
  }
  
  public NwAccountDetails[] getListAccounts(){
    return m_listAccounts;  
  }
  
  public void setNwPublicationDetails (NwPubDetails[] nwPubs)
    {
        m_NWPublications = nwPubs;
    }
    
    public NwPubDetails[] getNwPublicationDetails ()
    {
        return m_NWPublications;
    }   

    public void setPublications (String [] lstPublications)
    {
        m_lstPubs = lstPublications;
    }
    
    public String [] getPublications ()
    {
        return m_lstPubs;
    }   
}