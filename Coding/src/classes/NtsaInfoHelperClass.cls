public class NtsaInfoHelperClass {
private NwAccountDetails[] m_listAccounts;
//method to get account document from notessa
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
	
public NwAccountDetails[] connectToNWAPI(String emailAddress){    
      NwAccountDetails[] accounts = new NwAccountDetails[0];
      HttpRequest req = new HttpRequest();
      req = NtsaInfoHelperClass.setUpHttpRequest(req); 
        String base = 'https://intraapi.newsweaver.com/internal/user/'+emailAddress+'/account_users';        
        req.setEndpoint(base );
        // create the response object
        Http h = new Http();
        HTTPResponse resp;
        try{
            resp = h.send(req);
        }catch(Exception e){
            System.debug('Got exception: ' + e);
            return null;
        }     
        accounts = new NwAccountDetails[0];
        dom.Document doc = resp.getBodyDocument();
        if (doc != null){
          accounts = parseAccounts(doc, accounts);
        }
       	m_listAccounts=accounts;
    	return m_listAccounts;
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
              nwAccount.NTSAaccountId = accountId; 
               nwAccount.NTSAaccountName = accountName;  
               accounts.add(nwAccount); 
              i++;           
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
 
}

  public NwAccountDetails[] getListAccounts(){
    return m_listAccounts;  
  }
  
  //method to set list of available accounts
public void setListAccounts(NwAccountDetails[] nwAccounts){
    m_listAccounts = nwAccounts;
  }

}