public with sharing class NWAccountInfoHelper {

	private String [] m_lstPubs  = new String[]{};     
    private NwAccountDetails[] m_listAccounts = null;
    public static NwPubDetails[] m_NWPublications;
    public final NW_Account_Info_Test__c proj{get;set;}
    public String accountById;    
    public String publicationById;            
  	public String accountId;
  	public String m_selectedContactId = null;
  	public String m_selectedContactEmail = null;
  	public String nw_account_name = '';
    
    /*What does this do?*/
	public NWAccountInfoHelper(ApexPages.StandardController controller){      
	    proj = (NW_Account_Info_Test__c)controller.getRecord();  //Returns the record that is currently in context, based on the value of the id query string parameter in the Visualforce page URL.
	    //String pubIds = proj.Publication_Name__c; //String to hold publication ids contained in refPublications__c hidden custom field.
	    setAccountId(proj.NW_Account_Name__c); //Set account id
    
	    //if(pubIds != null){        
	        //String[] splitIds = pubIds.split(';'); //split up the array of publication ids
	        //setPublications(splitIds);
	    //}
	    //m_selectedContactEmail = 'demo3@newsweaver.ie';
	    //connectToNWAPI(m_selectedContactEmail);
	}
    
    //Get and set account ids
    public void setAccountId(String accId){
    	accountId = accId; 
  	}	

  	public String getAccountId(){
    	return accountId;  
  	}
  	
  	//public String getPublicationById()
  	
  	//public void setPublicationById(String pubId)
  	
  
  	public String getAccountById(){
    	String accountName = 'Error retieving Account Name';    
    	dom.Document doc = getAccountDocument(proj.NW_Account_Name__c);
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
    
    //public dom.Document getAccountPublicationsDocument(String accId
  	
  	public void setAccountById(String accId){
    	accountById = accId;
  	}
  	
  	public List<SelectOption> getAllAccounts(){   

      m_selectedContactEmail = 'demo3@newsweaver.ie';
	  connectToNWAPI(m_selectedContactEmail);
      
      //String contactPageParam = Apexpages.currentPage().getParameters().get('selectedContactId');
        list<SelectOption> options = new List<SelectOption>();
        
        /*if(contactPageParam == null && m_selectedContactId == null){
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
        return options;*/
        Integer i = 0;
        for (NwAccountDetails nwAcc:getListAccounts()){
                if((getAccountId() == null) && (i == 0)){
                  setAccountId(nwAcc.getaccountId());
                }
                options.add(new SelectOption(nwAcc.getaccountId(),nwAcc.getaccountName()));
                i++;
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
        
        /*accounts = new NwAccountDetails[0];
        dom.Document doc = resp.getBodyDocument();
        if (doc != null){
          accounts = parseAccounts(doc, accounts);
        }
        m_listAccounts = accounts;*/
    }
    
    //public NwAccountDetails[] parseAccounts(dom.Document doc, NwAccountDetails[] accounts)
 	
 	public String getNodeNameText(dom.Document doc){
        if (doc != null){
          dom.XmlNode node = doc.getRootElement();
          dom.XmlNode nameNode = node.getChildElement('name', null);
          return nameNode.getText();          
        }
        return '';    
  	}
  
 	public static HttpRequest setUpHttpRequest(HttpRequest req){
	    // Set the headers as required by the Newsweaver API
	    req.setMethod('GET');
        req.setTimeout(10000);        
        req.setHeader('User-Agent', 'Jakarta Commons-HttpClient/3.0.1');
        req.setHeader('ACCEPT', '*/*');
        req.setHeader('Authorization', 'Basic c2FsZXNmb3JjZWFkbWluQG5ld3N3ZWF2ZXIuY29tOmMzTm9aV1Zv');
        
        /*try{
        req.setClientCertificateName('salesforceadmin');	
        //req.setClientCertificateName('Autotest Api Monkey');
        }catch(Exception e){
        	System.debug('Error setting client certificate');
        }*/
        return req;
  }
  
  public PageReference saverec(){ //Called from projectPublicationPicker VF page when save button is clicked
    
      proj.NW_Account_Name__c = getAccountId();
        /*if (getPublications() == null)
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
      } */    
    PageReference projPage = new ApexPages.StandardController(proj).view();
      projPage.setRedirect(true);      
      return projPage;
    }
  
  	public NwAccountDetails NwAccountDetailsFactory(){
   		return new NwAccountDetails();      
    }
    
    public void setListAccounts(NwAccountDetails[] nwAccounts){
    	m_listAccounts = nwAccounts;
	}
  
	public NwAccountDetails[] getListAccounts(){
    	return m_listAccounts;  
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
}