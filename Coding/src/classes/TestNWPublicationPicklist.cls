@isTest
private class TestNWPublicationPicklist{
	
	public static testMethod SFDC_Projects__c createProject(){
    	//create first Project
        Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        insert newAccount;
         
        Contact newContact = new Contact (FirstName='Joe', 
                                         LastName='Schmoe',
                                         AccountId=newAccount.id,
                                         email='bizofemail@newsweaver.com');
        newContact.MailingCountry = 'Ireland';
        newContact.OtherCountry = 'Ireland';
        insert newContact;
         
        SFDC_Projects__c project1 = new SFDC_Projects__c (Summary__c='unitTest', No_Templates__c = 3, Organisation__c = newAccount.Id, Contact__c = newContact.Id,  Start_Date__c = System.now(), Expected_Completion_Date__c = System.now());
        insert project1;
        return project1;
    }
    
    	public static testMethod SFDC_Projects__c createProject2(){
    	//create first Project
        Account newAccount = new Account (name='XXX Organization');
        newAccount.BillingCountry = 'Ireland';
        insert newAccount;
        
        Contact newContact = new Contact (FirstName='Jim', 
                                         LastName='Schmock',
                                         AccountId=newAccount.id,
                                         email='jschmock@newsweaver.com');
        newContact.MailingCountry = 'Ireland';
        newContact.OtherCountry = 'Ireland';
        insert newContact;
         
        SFDC_Projects__c project2 = new SFDC_Projects__c (Summary__c='secondUnitTest', No_Templates__c = 3, Organisation__c = newAccount.Id, Contact__c = newContact.Id,  Start_Date__c = System.now(), Expected_Completion_Date__c = System.now());
        return project2;
    }
    
    
    public static testMethod void testpopulatePublicationDetails(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
        
    	String xmlContent = '<publications total="4" uri="https://intraapi.newsweaver.com/internal/account/6862/publications"><publication category="Newsletter" id="10882" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/10882"><name>ABD LN</name><code>abdln</code><lock_status>Active</lock_status><publication_type>Standard</publication_type></publication><publication category="Flyer" id="45124" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/45124"><name>Blank Flyer</name><code>blankflyer</code><lock_status>Active</lock_status><publication_type>Standard</publication_type></publication><publication category="Flyer" id="25211" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/25211"><name>Christmas Card</name><code>christmascard</code><lock_status>Locked</lock_status><publication_type>Standard</publication_type></publication><publication category="Newsletter" id="45114" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/45114"><name>Flyer</name><code>flyer</code><lock_status>Locked</lock_status><publication_type>Standard</publication_type></publication></publications>';    	 
    	DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);
		dom.Xmlnode pubRootNode = doc.getRootElement();	
		
		NWPublicationPicklist.NwPubDetails[] nwPubDetails = controller.populatePublicationDetailsInner(pubRootNode);

		System.assertEquals('10882', nwPubDetails[0].getPublicationId());
		System.assertEquals('ABD LN', nwPubDetails[0].getPublicationName());				

		System.assertEquals('45124', nwPubDetails[1].getPublicationId());
		System.assertEquals('Blank Flyer', nwPubDetails[1].getPublicationName());
		System.assertEquals(4, nwPubDetails.size());

   }
   
   public static testMethod void testgetNodeNameText(){ 
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);

    	String xmlContent = '<account uri="https://intraapi.newsweaver.com/internal/account/261"><link href="https://intraapi.newsweaver.com:443/internal/account/261/account_users" rel="http://api-info.newsweaver.com/internal/rels/account.account_user" title="Account_users"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/publications" rel="http://api-info.newsweaver.com/internal/rels/account.publication" title="Publications"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/account_roles" rel="http://api-info.newsweaver.com/internal/rels/account.account_role" title="Account_roles"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/publication_roles" rel="http://api-info.newsweaver.com/internal/rels/account.publication_role" title="Publication_roles"/><name>Steph Account</name><code>sdf</code><lock_status>Active</lock_status><activation_date>2011-02-15T00:00:00Z</activation_date><account_owner><country>Ireland</country><company>Company</company><use_eucpd>false</use_eucpd><eucpd_location>Austria</eucpd_location></account_owner><mail_server><server_pool>Pool B - nw006.com</server_pool><is_on_probation>true</is_on_probation></mail_server><account_settings><use_account_quota>false</use_account_quota><force_strong_password>false</force_strong_password><domain_extension>.ie</domain_extension><show_advanced>true</show_advanced><enable_api>false</enable_api><lock_sections>false</lock_sections><disable_access_to_subscriber_metric_data>false</disable_access_to_subscriber_metric_data><article_edition_locks>true</article_edition_locks><article_auto_saves>true</article_auto_saves></account_settings></account>';    	 
    	DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);

		String accountName = controller.getNodeNameText(doc);		
		System.assertEquals('Steph Account',accountName); 
		String accountName2 = controller.getNodeNameText(null);		
		System.assertEquals('',accountName2); 
   }
   
    public static testMethod void testgetPublicationById(){    	
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);

   		String accountName2 = controller.getAccountById();
		controller.setPublicationById('test1');
		System.assertEquals('test1',controller.publicationById);
		controller.setAccountById('test1');
		System.assertEquals('test1',controller.accountById);		
		String publicationName2 = controller.getPublicationById();	
		System.assertEquals('', accountName2);
		System.assertEquals('', publicationName2);	
    }   
   
   public static testMethod void testgetAllAccounts(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);

		NWPublicationPicklist.NwAccountDetails[] detailsList = new NWPublicationPicklist.NwAccountDetails[0];
		NWPublicationPicklist.NwAccountDetails nwAcct1= new NWPublicationPicklist.NwAccountDetails();
		nwAcct1.setaccountName('accountName1');
		nwAcct1.setaccountId('id1');
		detailsList.add(nwAcct1);		
		controller.setListAccounts(detailsList);
		List<SelectOption> options = controller.getAllAccounts();
		System.assertEquals(1, options.size());
		System.assertEquals('accountName1', options[0].getLabel());
		System.assertEquals('id1', options[0].getValue());
		
		controller.setListAccounts(null);
		options = controller.getAllAccounts();
		System.assertEquals(0, options.size());		
   }
   
   public static testMethod void testgetAllPublications(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);

		NWPublicationPicklist.NwAccountDetails[] detailsList = new NWPublicationPicklist.NwAccountDetails[0];
		NWPublicationPicklist.NwAccountDetails nwAcct1= new NWPublicationPicklist.NwAccountDetails();
		nwAcct1.setaccountName('accountName1');
		nwAcct1.setaccountId('id1');
		
		NWPublicationPicklist.NwPubDetails[] pubDetailsList = new NWPublicationPicklist.NwPubDetails[0];
		NWPublicationPicklist.NwPubDetails nwPub1= new NWPublicationPicklist.NwPubDetails();		
		nwPub1.setPublicationName('pubName');
		nwPub1.setPublicationId('pubId');
		pubDetailsList.add(nwPub1);
		controller.setNwPublicationDetails(pubDetailsList); 
			
		detailsList.add(nwAcct1);
		
		controller.setListAccounts(detailsList);
		
		List<SelectOption> options = controller.getAllPublications();
		System.assertEquals(1, options.size());
		System.assertEquals('pubName', options[0].getLabel());
		System.assertEquals('pubId', options[0].getValue());
		
		controller.setAccountId(null);
		ApexPages.currentPage().getParameters().put('selectedAccountId', 'id1');
		options = controller.getAllPublications();
		System.assertEquals(1, options.size());
		System.assertEquals('pubName', options[0].getLabel());
		System.assertEquals('pubId', options[0].getValue());
   }
   
   public static testMethod void testparseAccounts(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
    	controller.setAccountId('345345354345345');
		NWPublicationPicklist.NwAccountDetails[] accounts = new NWPublicationPicklist.NwAccountDetails[0];
		String xmlContent = '<account_users total="1" uri="https://intraapi.newsweaver.com/internal/user/bizofemail@newsweaver.ie/account_users"><account_user id="2761" uri="https://intraapi.newsweaver.com:443/internal/user/2991/account_user/2761"><link href="https://intraapi.newsweaver.com:443/internal/user/2991" rel="http://api-info.newsweaver.com/internal/rels/user.user" title="User (2991)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441" rel="http://api-info.newsweaver.com/internal/rels/account.account" title="Account (2441)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1" rel="http://api-info.newsweaver.com/internal/rels/account_role.account_role" title="Account Role (1)"/><user id="2991" type="User" uri="https://intraapi.newsweaver.com:443/internal/user/2991"><email_address>bizofemail@newsweaver.ie</email_address><first_name>denise</first_name><last_name>cox</last_name><lock_status>Active</lock_status></user><account id="2441" uri="https://intraapi.newsweaver.com:443/internal/account/2441"><name>biz of email</name><code>bizofemail</code><lock_status>Active</lock_status><account_type>Standard</account_type></account><account_role id="1" uri="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1"><name>Account Administrator</name><lock_status>Active</lock_status></account_role></account_user></account_users>';
		DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);
		accounts = controller.parseAccounts(doc, accounts);
		System.assertEquals(1, accounts.size());
	}
	
	public static testMethod void testsaveRec(){
    	//Use the PageReference Apex class to instantiate a page 
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875'; 
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
		controller.setAccountId('accId');
		String[] splitIds = '123;456;789;198'.split(';');
		controller.setPublications(splitIds);
		controller.saverec();
		List<SFDC_Projects__c> savedProj = [SELECT refAccount__c FROM SFDC_Projects__c WHERE Summary__c = 'unitTest'];
		System.assertEquals('accId', savedProj[0].refAccount__c);
		
		
		SFDC_Projects__c projectUnsaved = createProject2();
		sc = new ApexPages.standardController(projectUnsaved);
		controller = new NWPublicationPicklist(sc);
		controller.saverec();
		savedProj = [SELECT refAccount__c FROM SFDC_Projects__c WHERE Summary__c = 'secondUnitTest'];
		System.assertNotEquals(null, savedProj[0].Id);
	}

	
	public static testMethod void testGetSetNwPublications(){
		//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
        NWPublicationPicklist.NwPubDetails[] nwPubs = new NWPublicationPicklist.NwPubDetails[0];
        NWPublicationPicklist.NwPubDetails ndetails = new NWPublicationPicklist.NwPubDetails();
        ndetails.setPublicationName('test');
        ndetails.setPublicationId('test');
        
        nwPubs.add(ndetails);
        controller.setNwPublicationDetails(nwPubs);
        NWPublicationPicklist.NwPubDetails[] nwPubs2 = controller.getNwPublicationDetails();
        System.assertEquals(ndetails.getPublicationName(), nwPubs2[0].getPublicationName());
        System.assertEquals(ndetails.getPublicationId(), nwPubs2[0].getPublicationId());
	}
	
	public static testMethod void testsetSelectedContactId(){
		//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
        ApexPages.currentPage().getParameters().put('selectedContactId', 'id1');
        controller.setSelectedContactId();
        System.assertEquals('id1', controller.m_selectedContactId);
        System.assertEquals(null, controller.getListAccounts());
        System.assertEquals(null, controller.getAccountId());
        
	}
	
	public static testMethod void testupdateSelectedAccountId(){
		//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
        ApexPages.currentPage().getParameters().put('selectedAccountId', 'id1');
        controller.updateSelectedAccountId();
        System.assertEquals('id1', controller.getAccountId());
        PageReference pr = controller.displayMessage();       
	}
	
	/*public static testMethod void testCallOutLimitMet()
	{		
		//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProjectPublicationPicker;   
        Test.setCurrentPage(pageRef);
    	SFDC_Projects__c project1=createProject();
    	project1.refPublications__c = '3278;3984;934875';
    	
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(project1);
        NWPublicationPicklist controller = new NWPublicationPicklist(sc);
        controller.m_calloutLimit = 10;
		dom.Document dom = controller.getAccountDocument('id');
		System.assertEquals(null, dom);
		String pubName = controller.getPublicationById();
		System.assertEquals('', pubName);
	}*/	
	   
}