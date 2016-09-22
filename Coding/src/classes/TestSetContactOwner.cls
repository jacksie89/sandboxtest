/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestSetContactOwner {

    static testMethod void singleInsertTest() {
        
        User salesUser = TestDataFactory.createTestUser('Sales');
        List<User> csmUsers = TestDataFactory.createTestUsers('Account');
        
        User csmUser = csmUsers[0];
        User csmUser2 = csmUsers[1];
        String currentUserId = UserInfo.getUserId();
        
        List<Contact> myCons = new List<Contact>();
        Set<Id> csmUserIds = new Set<Id>();
        
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id csmUserId2 = csmUser2.Id;
        
        //Add ids to set of ids for @future method
        csmUserIds.add(csmUserId);
        csmUserIds.add(csmUserId2);
            	
    	//create Active Customer Type Account
        List<Account> customerTypeAccounts = TestDataFactory.createTestAccounts('Test Active Customer Type Account', 'Customer', 1, salesUserId, csmUserId);
        
        //create Prospect Account
        List<Account> prospectTypeAccounts = TestDataFactory.createTestAccounts('Test Prospect Type Account', 1, salesUserId, csmUserId);
        
        //create Active Account with no CSM
        List<Account> customerTypeAccountsNOCSM = TestDataFactory.createTestAccountsNOCSM('Test Active Customer Type Account NO CSM', 'Customer', 1, salesUserId);
        
        //create Active Account with active CSM to be deactivated
    	List<Account> thirdPartyTypeAccounts = TestDataFactory.createTestAccounts('Test Active Third Party Type Account', 'Third Party', 1, salesUserId, csmUserId);

		//create a Contact for active customer account
        List<Contact> testCustomerAccountContacts = TestDataFactory.createTestContacts('CustomerContact', 'jbloggs@bloggsinc.com', 1, customerTypeAccounts[0].Id);
        
        //create a Contact for propsect account with active CSM
        List<Contact> testProspectAccountContacts = TestDataFactory.createTestContacts('ProspectContact', 'jdoe@testnotessaorg.com', 1, prospectTypeAccounts[0].Id);
        
        //create a Contact for active account with no CSM
        List<Contact> testCustomerAccountContactsNOCSM = TestDataFactory.createTestContacts('NoCSMContact', 'bwayne@testnotessaorg.com', 1, customerTypeAccountsNOCSM[0].Id);
        
        //create a Contact for active account with no CSM
        List<Contact> testThirdPartyAccountContacts = TestDataFactory.createTestContacts('ThirdPartyContact', 'glineker@testnotessaorg.com', 1, thirdPartyTypeAccounts[0].Id);
        
        //Assert that contact for active account with active CSM has been assigned CSM as owner
        Contact mySavedContact = [Select Id, OwnerId from Contact Where Id =: testCustomerAccountContacts[0].Id];
        System.assertEquals(csmUserId, mySavedContact.OwnerId);
        
        //Assert that contact for prospect account with active CSM has been assigned Org owner
        Contact mySavedSecondContact = [Select Id, OwnerId from Contact Where Id =: testProspectAccountContacts[0].Id];
        System.assertEquals(salesUserId, mySavedSecondContact.OwnerId);
        
        //Assert that contact for active account with no CSM has been assigned current user
        Contact mySavedThirdContact = [Select Id, OwnerId from Contact Where Id =: testCustomerAccountContactsNOCSM[0].Id];
        System.assertEquals(currentUserId, mySavedThirdContact.OwnerId);

	    //Call @future method to deactivate organisation CSM - necessary to perform separate DML operation
	    //in a separate class with an @future method to avoid MIXED_DML_OPERATION error
	    
	    test.startTest();
	    UserOperations.myUpdateUser();
	    test.stopTest();
	        
	    //Need to requery the same users after the update
        List<User> csmUsersUpdated = TestDataFactory.createTestUsers('Account');
        User csmUserUpdated = csmUsers[0];
        User csmUser2Updated = csmUsers[1];
        
	    //create a Contact for active account with inactive CSM
	    List<Contact> testContactInactiveCSM = TestDataFactory.createTestContacts('ContactInactiveCSM', 'jdaniels@testnotessaorg.com', 1, customerTypeAccounts[0].Id);            
	    try {
	     	insert testContactInactiveCSM[0];	
	    }catch (Exception e){
	       	System.debug('Contact info: ' + testContactInactiveCSM[0]);	
	    }
	        
        //Assert that contact for active account with inactive CSM has been assigned current user as owner
        Contact mySavedContactInactiveCSM = [Select Id, OwnerId from Contact Where Email='jdaniels@testnotessaorg.com'];
        System.assertEquals(currentUserId, mySavedContactInactiveCSM.OwnerId);
        
        //Assert that contact for active account with no CSM has not been assigned current user
        Contact mySavedFourthContact = [Select Id, OwnerId from Contact Where Email='glineker@testnotessaorg.com'];
        System.assertnOTEquals(currentUserId, mySavedFourthContact.OwnerId);
    }

	static testMethod void deactivateSingleContactTest(){
        
        User salesUser = TestDataFactory.createTestUser('Sales');
        List<User> csmUsers = TestDataFactory.createTestUsers('Account');		
        
        User csmUser = csmUsers[0];
        User csmUser2 = csmUsers[1];
        
        String currentUserId = UserInfo.getUserId();
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id csmUserId2 = csmUser2.Id;
        Set<Id> csmUserIds = new Set<Id>();
        //Add ids to set of ids for @future method
        csmUserIds.add(csmUserId);
        csmUserIds.add(csmUserId2);

    	//create Active Customer Type Account
        List<Account> customerTypeAccounts = TestDataFactory.createTestAccounts('Test Active Customer Type Account', 'Customer', 1, salesUserId, csmUserId);

		//create a Contact for active customer account
        List<Contact> testCustomerAccountContacts = TestDataFactory.createTestContacts('CustomerContact', 'jbloggs@bloggsinc.com', 1, customerTypeAccounts[0].Id);

		testCustomerAccountContacts[0].Contact_Status__c = 'Inactive';
		testCustomerAccountContacts[0].Status_Inactive_Reason__c = 'Organisation no longer a client';
		
		update testCustomerAccountContacts[0];
		
		List<Contact> savedTestCustomerACContact = [Select Contact_Status__c, Status_Inactive_Reason__c from Contact Where Email = 'jbloggs@bloggsinc.com'];
		savedTestCustomerACContact[0].Contact_Status__c = 'Active';
		update savedTestCustomerACContact[0];
		
		// Assert that contact's Status Inactive reason has been cleared as this contact has been reactivated
		Contact mySavedContact = [Select Id, OwnerId, Status_Inactive_Reason__c from Contact Where Email='jbloggs@bloggsinc.com'];
		System.assertEquals(null, mySavedContact.Status_Inactive_Reason__c);
	}

	static testMethod void deactivateMultipleContactsTest(){
        
        User salesUser = TestDataFactory.createTestUser('Sales');
        List<User> csmUsers = TestDataFactory.createTestUsers('Account');		
        
        User csmUser = csmUsers[0];
        User csmUser2 = csmUsers[1];
        
        String currentUserId = UserInfo.getUserId();
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id csmUserId2 = csmUser2.Id;
        Set<Id> csmUserIds = new Set<Id>();
        //Add ids to set of ids for @future method
        csmUserIds.add(csmUserId);
        csmUserIds.add(csmUserId2);

    	//create Active Customer Type Account
        List<Account> customerTypeAccounts = TestDataFactory.createTestAccounts('Test Active Customer Type Account', 'Customer', 1, salesUserId, csmUserId);

		//create a Contact for active customer account
        List<Contact> testCustomerAccountContacts = TestDataFactory.createTestContacts('CustomerContact', 102, customerTypeAccounts[0].Id);
		
		for(Integer i=0; i<testCustomerAccountContacts.size(); i++){
			testCustomerAccountContacts[i].Contact_Status__c = 'Inactive';
			testCustomerAccountContacts[i].Status_Inactive_Reason__c = 'Organisation no longer a client';
		}
		
		update testCustomerAccountContacts;
		
		// List back updated contacts and assert that there are 10 and that they are Inactive and have a Status Inactive Reason
		List<Contact> savedTestCustomerACContacts = [Select Contact_Status__c, Status_Inactive_Reason__c from Contact Where Email Like '%@testAccountNewsweaver.com%'];
		System.assertEquals(102, savedTestCustomerACContacts.size());
		System.assertEquals('Inactive', savedTestCustomerACContacts[11].Contact_Status__c);
		System.assertNotEquals(null, savedTestCustomerACContacts[11].Status_Inactive_Reason__c);
		System.assertEquals('Inactive', savedTestCustomerACContacts[95].Contact_Status__c);
		System.assertNotEquals(null, savedTestCustomerACContacts[95].Status_Inactive_Reason__c);
		
		for(Integer i=0; i<savedTestCustomerACContacts.size(); i++){
			savedTestCustomerACContacts[i].Contact_Status__c = 'Active';
		}
		
		update savedTestCustomerACContacts;
		
		// Assert that contact's Status is Active and the Status Inactive reason has been cleared as this contact has been reactivated
		List<Contact> savedTestCustomerACContacts2 = [Select Contact_Status__c, Status_Inactive_Reason__c from Contact Where Email Like '%@testAccountNewsweaver.com%'];
		System.assertEquals('Active', savedTestCustomerACContacts2[33].Contact_Status__c);
		System.assertEquals(null, savedTestCustomerACContacts2[33].Status_Inactive_Reason__c);
		System.assertEquals('Active', savedTestCustomerACContacts2[67].Contact_Status__c);
		System.assertEquals(null, savedTestCustomerACContacts2[67].Status_Inactive_Reason__c);
	}

    
    static testMethod void multipleInsertTest() {
    	User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');

        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
                
        List<Contact> myCons = new List<Contact>();
        List<Id> organisationIds = new List<Id>();
        List<String> contactEmails = new List<String>();
 		Contact[] contacts = new List<Contact>();
 		
     	//create Active Customer Type Account
        List<Account> customerTypeAccounts = TestDataFactory.createTestAccounts('Test Active Customer Type Account', 'Customer', 1, salesUserId, csmUserId);
       	organisationIds.add(customerTypeAccounts[0].Id);

        //create Prospect Account createTestAccountsNOCSM(String accountName, String accountType, Integer numAccts, Id orgOwner)
        List<Account> prospectTypeAccounts = TestDataFactory.createTestAccountsNOCSM('Test Prospect Type Account', 'Prospect', 1, salesUserId);
        organisationIds.add(prospectTypeAccounts[0].Id);    	
	    
	    //List of contacts will contain a mix of contacts from both Customer & Prospect Orgs
	    for (Integer i=0;i<102;i++){    	
	    	if(i<51){
		    	contactEmails.add('jbloggs' + i + '@bloggsinc.com');
	    	} else {
	    		contactEmails.add('jdoe' + i + '@notessatestorg.com');
	    	}
	    }
	    
	    //insert contacts;
	    List<Contact> testMixedAccountContacts = TestDataFactory.createTestContacts(contactEmails, 102, organisationIds);
        
        // Assert that contacts with Customer Orgs that have CSMs assigned have their owner set to that CSM
        List<Contact> csmOwnedContacts = [Select Id, OwnerId from Contact Where Email Like '%@bloggsinc.com%'];
        System.assertEquals(csmUserId, csmOwnedContacts[9].OwnerId);
        System.assertEquals(csmUserId, csmOwnedContacts[44].OwnerId);

        // Assert that contacts with Prospect Orgs that have no CSMs assigned have their owner set to the Sales user
        List<Contact> salesOwnedContacts = [Select Id, OwnerId from Contact Where Email Like '%@notessatestorg.com%'];
        System.assertEquals(salesUserId, salesOwnedContacts[12].OwnerId);
        System.assertEquals(salesUserId, salesOwnedContacts[31].OwnerId); 
    }
}