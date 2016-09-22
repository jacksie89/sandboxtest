@isTest
private class TestNotessaPanelOnCases {
    
    public static testMethod void testpopulatePublicationDetails(){

    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.CaseCampaignPanel;   
        Test.setCurrentPage(pageRef);

		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
		
        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
                
    	String xmlContent = '<publications total="4" uri="https://intraapi.newsweaver.com/internal/account/6862/publications"><publication category="Newsletter" id="10882" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/10882"><name>ABD LN</name><code>abdln</code><lock_status>Active</lock_status><publication_type>Standard</publication_type></publication><publication category="Flyer" id="45124" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/45124"><name>Blank Flyer</name><code>blankflyer</code><lock_status>Active</lock_status><publication_type>Standard</publication_type></publication><publication category="Flyer" id="25211" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/25211"><name>Christmas Card</name><code>christmascard</code><lock_status>Locked</lock_status><publication_type>Standard</publication_type></publication><publication category="Newsletter" id="45114" uri="https://intraapi.newsweaver.com:443/internal/account/6862/publication/45114"><name>Flyer</name><code>flyer</code><lock_status>Locked</lock_status><publication_type>Standard</publication_type></publication></publications>';    	 
    	DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);
		dom.Xmlnode pubRootNode = doc.getRootElement();	
		
		NotessaPanelOnCases.NwPubDetails[] nwPubDetails = controller.populatePublicationDetailsInner(pubRootNode);

		System.assertEquals('10882', nwPubDetails[0].getPublicationId());
		System.assertEquals('ABD LN', nwPubDetails[0].getPublicationName());				

		System.assertEquals('45124', nwPubDetails[1].getPublicationId());
		System.assertEquals('Blank Flyer', nwPubDetails[1].getPublicationName());
		System.assertEquals(2, nwPubDetails.size()); //Should only return 2 active publication and ignore the 2 locked publications
   }

   public static testMethod void testgetNodeNameText(){ 
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.CaseCampaignPanel;   
        Test.setCurrentPage(pageRef);

		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);

    	String xmlContent = '<account uri="https://intraapi.newsweaver.com/internal/account/261"><link href="https://intraapi.newsweaver.com:443/internal/account/261/account_users" rel="http://api-info.newsweaver.com/internal/rels/account.account_user" title="Account_users"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/publications" rel="http://api-info.newsweaver.com/internal/rels/account.publication" title="Publications"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/account_roles" rel="http://api-info.newsweaver.com/internal/rels/account.account_role" title="Account_roles"/><link href="https://intraapi.newsweaver.com:443/internal/account/261/publication_roles" rel="http://api-info.newsweaver.com/internal/rels/account.publication_role" title="Publication_roles"/><name>Steph Account</name><code>sdf</code><lock_status>Active</lock_status><activation_date>2011-02-15T00:00:00Z</activation_date><account_owner><country>Ireland</country><company>Company</company><use_eucpd>false</use_eucpd><eucpd_location>Austria</eucpd_location></account_owner><mail_server><server_pool>Pool B - nw006.com</server_pool><is_on_probation>true</is_on_probation></mail_server><account_settings><use_account_quota>false</use_account_quota><force_strong_password>false</force_strong_password><domain_extension>.ie</domain_extension><show_advanced>true</show_advanced><enable_api>false</enable_api><lock_sections>false</lock_sections><disable_access_to_subscriber_metric_data>false</disable_access_to_subscriber_metric_data><article_edition_locks>true</article_edition_locks><article_auto_saves>true</article_auto_saves></account_settings></account>';    	 
    	DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);

		String accountName = controller.getNodeNameText(doc);		
		System.assertEquals('Steph Account',accountName); 
		String accountName2 = controller.getNodeNameText(null);		
		System.assertEquals('',accountName2); 
   }
    
   public static testMethod void testparseAccounts(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.CaseCampaignPanel;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
        
    	controller.setAccountId('345345354345345');
		
		//NWPublicationPicklist.NwAccountDetails[] accounts = new NWPublicationPicklist.NwAccountDetails[0];
		String xmlContent = '<account_users total="1" uri="https://intraapi.newsweaver.com/internal/user/bizofemail@newsweaver.ie/account_users"><account_user id="2761" uri="https://intraapi.newsweaver.com:443/internal/user/2991/account_user/2761"><link href="https://intraapi.newsweaver.com:443/internal/user/2991" rel="http://api-info.newsweaver.com/internal/rels/user.user" title="User (2991)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441" rel="http://api-info.newsweaver.com/internal/rels/account.account" title="Account (2441)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1" rel="http://api-info.newsweaver.com/internal/rels/account_role.account_role" title="Account Role (1)"/><user id="2991" type="User" uri="https://intraapi.newsweaver.com:443/internal/user/2991"><email_address>bizofemail@newsweaver.ie</email_address><first_name>denise</first_name><last_name>cox</last_name><lock_status>Active</lock_status></user><account id="2441" uri="https://intraapi.newsweaver.com:443/internal/account/2441"><name>biz of email</name><code>bizofemail</code><lock_status>Active</lock_status><account_type>Standard</account_type></account><account_role id="1" uri="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1"><name>Account Administrator</name><lock_status>Active</lock_status></account_role></account_user></account_users>';
		DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);
		
		NotessaPanelOnCasesHelper.NwAccountDetails[] accounts = new NotessaPanelOnCasesHelper.NwAccountDetails[0];
		accounts = ntsaPOCH.parseAccounts(doc, accounts, 'https://intraapi.newsweaver.com/internal/user/bizofemail@newsweaver.ie/account_users');	
		System.assertEquals(1, accounts.size());
	}
	
   	public static testMethod void testGetAccountDocument(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.CaseCampaignPanel;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
        
		//NWPublicationPicklist.NwAccountDetails[] accounts = new NWPublicationPicklist.NwAccountDetails[0];
		String xmlContent = '<account_users total="1" uri="https://intraapi.newsweaver.com/internal/user/bizofemail@newsweaver.ie/account_users"><account_user id="2761" uri="https://intraapi.newsweaver.com:443/internal/user/2991/account_user/2761"><link href="https://intraapi.newsweaver.com:443/internal/user/2991" rel="http://api-info.newsweaver.com/internal/rels/user.user" title="User (2991)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441" rel="http://api-info.newsweaver.com/internal/rels/account.account" title="Account (2441)"/><link href="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1" rel="http://api-info.newsweaver.com/internal/rels/account_role.account_role" title="Account Role (1)"/><user id="2991" type="User" uri="https://intraapi.newsweaver.com:443/internal/user/2991"><email_address>bizofemail@newsweaver.ie</email_address><first_name>denise</first_name><last_name>cox</last_name><lock_status>Active</lock_status></user><account id="2441" uri="https://intraapi.newsweaver.com:443/internal/account/2441"><name>biz of email</name><code>bizofemail</code><lock_status>Active</lock_status><account_type>Standard</account_type></account><account_role id="1" uri="https://intraapi.newsweaver.com:443/internal/account/2441/account_role/1"><name>Account Administrator</name><lock_status>Active</lock_status></account_role></account_user></account_users>';
		DOM.Document doc = new DOM.Document();        
		doc.load(xmlContent);
		
		DOM.Document accountDoc = controller.getAccountDocument('2441');           		
   	}
	
	public static testMethod void getAccountId(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.CaseCampaignPanel;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
        
		ApexPages.currentPage().getParameters().put('selectedAccountId', 'id1');
		controller.updateSelectedAccountId();
        System.assertEquals('id1', controller.getAccountId());
	}
	
	public static testMethod void testGetSetNwPublications(){

    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.caseCampaignPicker;   
        Test.setCurrentPage(pageRef);
		//NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);

        NotessaPanelOnCases.NwPubDetails[] nwPubs = new NotessaPanelOnCases.NwPubDetails[0];
        NotessaPanelOnCases.NwPubDetails ndetails = new NotessaPanelOnCases.NwPubDetails();
        ndetails.setPublicationName('test');
        ndetails.setPublicationId('test');
        
        nwPubs.add(ndetails);
        controller.setNwPublicationDetails(nwPubs);
        NotessaPanelOnCases.NwPubDetails[] nwPubs2 = controller.getNwPublicationDetails();
        System.assertEquals(ndetails.getPublicationName(), nwPubs2[0].getPublicationName());
        System.assertEquals(ndetails.getPublicationId(), nwPubs2[0].getPublicationId());
	}	

   	public static testMethod void testgetAllPublications(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.caseCampaignPicker;   
        Test.setCurrentPage(pageRef);
		//NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
        
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);

		NotessaPanelOnCasesHelper.NwAccountDetails[] accounts = new NotessaPanelOnCasesHelper.NwAccountDetails[0];
		
		NotessaPanelOnCasesHelper.NwAccountDetails[] detailsList = new NotessaPanelOnCasesHelper.NwAccountDetails[0];
		NotessaPanelOnCasesHelper.NwAccountDetails nwAcct1= new NotessaPanelOnCasesHelper.NwAccountDetails();
		nwAcct1.setNTSAaccountName('accountName1');
		nwAcct1.setNTSAaccountId('id1');
		
		NotessaPanelOnCases.NwPubDetails[] pubDetailsList = new NotessaPanelOnCases.NwPubDetails[0];
		NotessaPanelOnCases.NwPubDetails nwPub1= new NotessaPanelOnCases.NwPubDetails();		
		nwPub1.setPublicationName('pubName');
		nwPub1.setPublicationId('pubId');
		pubDetailsList.add(nwPub1);
		controller.setNwPublicationDetails(pubDetailsList); 
			
		detailsList.add(nwAcct1);
		
		List<SelectOption> options = controller.getAllPublications();
		System.assertEquals(1, options.size());
		System.assertEquals('pubName', options[0].getLabel());
		System.assertEquals('pubId', options[0].getValue());
		
		nwAcct1.setNTSAaccountId(null);
		ApexPages.currentPage().getParameters().put('selectedAccountId', 'id1');
		options = controller.getAllPublications();
		System.assertEquals(1, options.size());
		System.assertEquals('pubName', options[0].getLabel());
		System.assertEquals('pubId', options[0].getValue());
   	}

   public static testMethod void testgetAllAccounts(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.caseCreateEditBilling;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];

		// Create contact
        List<Contact> testContacts = TestDataFactory.createTestContacts('BC TestContact', 1, myAccount.Id);
        Contact myContact = testContacts[0];
                
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
		
		ApexPages.currentPage().getParameters().put('selectedContactId', 'id1');
        controller.setSelectedContactId();
        System.assertEquals('id1', controller.m_selectedContactId);
        System.assertEquals(null, ntsaPOCH.getListAccounts());
        System.assertEquals(null, controller.getAccountId());
        
        ntsaPOCH.setListAccounts(null);
		List<SelectOption> options = controller.getAllAccounts();
		System.assertEquals(0, options.size());
		
		NotessaPanelOnCasesHelper.NwAccountDetails[] detailsList = new NotessaPanelOnCasesHelper.NwAccountDetails[0];
		NotessaPanelOnCasesHelper.NwAccountDetails nwAcct1= new NotessaPanelOnCasesHelper.NwAccountDetails();
		nwAcct1.setNTSAaccountName('accountName1');
		nwAcct1.setNTSAaccountId('id1');
		nwAcct1.setaccountDataCentre('EU');
		nwAcct1.setNTSAaccountStatus('Active');
		detailsList.add(nwAcct1);		
		
		String dataCentre = nwAcct1.getaccountDataCentre();
		String accountStatus = nwAcct1.getNTSAAccountStatus();
		ntsaPOCH.setListAccounts(detailsList);
		options = controller.getAllAccounts();
		
		/*System.assertEquals(1, options.size());
		System.assertEquals('accountName1', options[0].getLabel());
		System.assertEquals('id1', options[0].getValue());
		
		ntsaPOCH.setListAccounts(null);
		options = controller.getAllAccounts();
		System.assertEquals(0, options.size());*/		
   }

	public static testMethod void testsaveRec(){
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.caseCreateEditBilling;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];

		// Create contact
        List<Contact> testContacts = TestDataFactory.createTestContacts('BC TestContact', 1, myAccount.Id);
        Contact myContact = testContacts[0];
                
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
		
		controller.setAccountId('accId');
		String[] splitIds = '123;456;789;198'.split(';');
		controller.setPublications(splitIds);
		controller.accIdIsChanged = true;
		controller.saverec();
		List<Case> savedCase = [SELECT refAccount__c FROM Case WHERE Subject = 'My Test Case'];
		System.assertEquals('accId', savedCase[0].refAccount__c);
			
		splitIds = '3278;3984;934875'.split(';');
		controller.setAccountIds(splitIds);
		controller.accIdIsChanged = true;
		controller.saverec();		
	}

    public static testMethod void testgetPublicationById(){    	
    	//Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.caseCampaignPicker;   
        Test.setCurrentPage(pageRef);
		NotessaPanelOnCasesHelper ntsaPOCH = new NotessaPanelOnCasesHelper();
		
		// Create Test User
		User salesUser = TestDataFactory.createTestUser('Sales');
		User csmUser = TestDataFactory.createTestUser('Account');
		Id salesUserId = salesUser.Id;
		Id csmUserId = csmUser.Id;

		// Create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];

		// Create contact
        List<Contact> testContacts = TestDataFactory.createTestContacts('BC TestContact', 1, myAccount.Id);
        Contact myContact = testContacts[0];
                
        // Create Case
		Case myCase = new Case (subject='My Test Case', OwnerId=salesUserId, AccountId=myAccount.Id, Complaint__c = False, priority = 'Medium');
		insert myCase;    	
        
        myCase.refPublications__c = '3278;3984;934875';

        //Instantiate and construct the controller class - all values will be null initially
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);
        NotessaPanelOnCases controller = new NotessaPanelOnCases(sc);
		
		controller.setAccountById('test1');
		System.assertEquals('test1',controller.accountById);
		
		controller.setPublicationById('test1');
		System.assertEquals('test1',controller.publicationById);
    }
}