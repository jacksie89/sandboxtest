@isTest
private class TestMasterOpportunity {
/*
    static testMethod void testClosedWonActionsForContacts() {
    
        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
            
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 5, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
              
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices); //prods, 4, pricebookId, uPrices

        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;
       
        //add contact roles
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
    
        for(Integer i=0; i<testContacts.size(); i++){
            OpportunityContactRole cr = new OpportunityContactRole(opportunityId=testOpportunities[0].id,contactId=testContacts[i].id,role='Business User');
            oppContactRoles.add(cr);
        }
        insert oppContactRoles; //insert list of contact roles

        testOpportunities[0].StageName = 'Closed-Won';
        update testOpportunities[0];
        
        //get the account
        List<Account> reSsavedAccount = [SELECT Status__c, Type FROM Account WHERE Id =: testAccounts[0].Id];
        System.assertEquals('Pending', reSsavedAccount[0].Status__c);
        System.assertEquals('Customer', reSsavedAccount[0].Type);
        
        List<OpportunityContactRole> contactsIds = ([ SELECT ContactId FROM OpportunityContactRole WHERE opportunityId = :testOpportunities[0].Id]);
        List<Id> conIds = new List<Id>();
        
        for(OpportunityContactRole ocr : contactsIds){
          conIds.add(ocr.ContactId);
        }
        //System.assertNotEquals(null, contactsIds[0].ContactId);
        System.assertNotEquals(0, conIds.size());
        System.debug('contactsIds contents: ' + conIds);
            
        //Query back contact statuses and assert that they have been updated by closed-won trigger actions
        List<Contact> theContacts = ([ SELECT Contact_Status__c FROM Contact WHERE id IN :conIds]);
        System.assertEquals('Active', theContacts[0].Contact_Status__c);
        System.assertEquals('Active', theContacts[2].Contact_Status__c);
        System.assertEquals('Active', theContacts[4].Contact_Status__c);      
    }

    static testMethod void testClosedWonActionsForCases() {
    
        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
            
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<RecordType> caseRecordType = [Select Id From RecordType Where Name = 'Master Case'];        
        List<RecordType> billingCaseRecordType = [Select Id From RecordType Where Name = 'Billing'];
        List<Group> onboardingQueue = [Select Id From Group Where Name = 'New Onboarding Queue'];
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 5, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 3, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;
       
        //add contact roles
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
    
        for(Integer i=0; i<testContacts.size(); i++){
            OpportunityContactRole cr = new OpportunityContactRole(opportunityId=testOpportunities[0].id,contactId=testContacts[i].id,role='Business User');
            oppContactRoles.add(cr);
        }
        insert oppContactRoles; //insert list of contact roles

        //Insert the Master Onboarding Case
        Case masterCase = new Case(AccountId=testOpportunities[1].AccountId, contactId=testContacts[1].Id, Onboarding_Related_Opp__c=testOpportunities[1].Id, Type='Account Onboarding', 
            Status='New', Subject='Closed-Won: ' + testOpportunities[1].Name, Communication_Type__c=testOpportunities[1].Communication_Type__c, 
            Origin='Closed Opportunity', Priority='Medium', RecordTypeId=caseRecordType[0].Id);
        insert masterCase;

        //Create Billing case
        Case billingCase = new Case(contactId=testContacts[1].Id, CurrencyIsoCode=masterCase.CurrencyIsoCode, Onboarding_Related_Opp__c=testOpportunities[1].Id, 
            ParentId=masterCase.Id, RecordTypeId=billingCaseRecordType[0].Id, Status='New', Subject='Closed-Won: ' + testOpportunities[1].Name);
        insert billingCase;
        
        // Set all opp stages to Closed-Won
        for(Integer i=0; i<testOpportunities.size(); i++){
            testOpportunities[i].StageName = 'Closed-Won';
            oppsToUpdate.add(testOpportunities[i]);
        }
        
        update oppsToUpdate;

        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> opp1Cases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId From Case Where Onboarding_Related_Opp__c =: testOpportunities[0].Id];
        
        System.assertEquals(2, opp1Cases.size()); // Assert that both master & billing cases have been created
        System.assertEquals(null, opp1Cases[0].ParentId); // Assert that first case is master onboarding case
        
        System.assertNotEquals(null, opp1Cases[1].ParentId); // Assert that second case is billing case
        System.assertEquals(caseRecordType[0].Id, opp1Cases[0].RecordTypeId); // Assert that first case record type is master
        System.assertEquals(onboardingQueue[0].Id, opp1Cases[0].OwnerId); // Assert that first case owner is New Onboarding Queue
        System.assertEquals(billingCaseRecordType[0].Id, opp1Cases[1].RecordTypeId); // Assert that second case record type is billing
        System.assertEquals('Master onboarding case', opp1Cases[0].Subject);
        System.assertEquals('Billing onboarding case', opp1Cases[1].Subject);
    
        // List back all cases from the second opportunity - this opp already had cases manually created for both Master & Billing cases
        List<Case> opp2Cases = [Select contactId, Subject, ParentId From Case Where Onboarding_Related_Opp__c =: testOpportunities[1].Id];
    
        System.assertEquals(2, opp2Cases.size()); // Assert that both master & billing cases have been created
        System.assertEquals(null, opp2Cases[0].ParentId); // Assert that first case is master onboarding case
        System.assertNotEquals(null, opp2Cases[1].ParentId); // Assert that second case is billing case              
        System.assertNotEquals('Master onboarding case', opp2Cases[0].Subject); // Assert that master case contains manual subject specified above & not automated subject line
        System.assertNotEquals('Billing onboarding case', opp2Cases[1].Subject); // Assert that billing case contains manual subject specified above & not automated subject line


        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> opp3Cases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId From Case Where Onboarding_Related_Opp__c =: testOpportunities[2].Id];
        System.assertEquals(2, opp3Cases.size()); // Assert that both master & billing cases have been created
        System.assertEquals(caseRecordType[0].Id, opp3Cases[0].RecordTypeId); // Assert that first case record type is master
        System.assertEquals(onboardingQueue[0].Id, opp3Cases[0].OwnerId); // Assert that first case owner is New Onboarding Queue
        System.assertEquals(billingCaseRecordType[0].Id, opp3Cases[1].RecordTypeId); // Assert that second case record type is billing
        System.assertEquals('Master onboarding case', opp3Cases[0].Subject);
        System.assertEquals('Billing onboarding case', opp3Cases[1].Subject);

        // List back the Account for the opp and check the Communication Type has been set correctly
        List<Opportunity> opp1 = [Select AccountId, Communication_Type__c From Opportunity Where Id =: testOpportunities[0].Id];
        List<Account> oppAccount = [Select Communication_Type_Org__c From Account Where Id =: opp1[0].AccountId];
        
        System.assertEquals(opp1[0].Communication_Type__c, oppAccount[0].Communication_Type_Org__c);
    }   

    static testMethod void testForCaseType() {
    
        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
            
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<RecordType> caseRecordType = [Select Id From RecordType Where Name = 'Master Case'];        
        List<RecordType> billingCaseRecordType = [Select Id From RecordType Where Name = 'Billing'];
        List<Group> onboardingQueue = [Select Id From Group Where Name = 'New Onboarding Queue'];
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 5, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 4, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;
       
        //add contact roles
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
    
        for(Integer i=0; i<testContacts.size(); i++){
            OpportunityContactRole cr = new OpportunityContactRole(opportunityId=testOpportunities[0].id,contactId=testContacts[i].id,role='Business User');
            oppContactRoles.add(cr);
        }
        insert oppContactRoles; //insert list of contact roles

        testOpportunities[0].StageName = 'Closed-Won';
        testOpportunities[0].Solution_Category__c = 'Additional Quota';
      
        update testOpportunities[0];

        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> opp1Cases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId, Type From Case Where Onboarding_Related_Opp__c =: testOpportunities[0].Id];
        
        System.assertEquals(null, opp1Cases[0].ParentId); // Assert that first case is master onboarding case        
        System.assertEquals('Additional Emails', opp1Cases[0].Type);

		// Update 2nd opp and assert case created values
        testOpportunities[1].StageName = 'Closed-Won';
        testOpportunities[1].Solution_Category__c = 'New Customer';
      
        update testOpportunities[1];

        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> opp2Cases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId, Type From Case Where Onboarding_Related_Opp__c =: testOpportunities[1].Id];
        
        System.assertEquals(null, opp2Cases[0].ParentId); // Assert that first case is master onboarding case        
        System.assertEquals('Account Onboarding', opp2Cases[0].Type);

		// Update 3rd opp and assert case created values
        testOpportunities[2].StageName = 'Closed-Won';
        testOpportunities[2].Solution_Category__c = 'Services';
      
        update testOpportunities[2];

        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> opp3Cases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId, Type From Case Where Onboarding_Related_Opp__c =: testOpportunities[2].Id];
        
        System.assertEquals(null, opp3Cases[0].ParentId); // Assert that first case is master onboarding case        
        System.assertEquals('Account Onboarding', opp2Cases[0].Type);		    
    }
    
    static testMethod void testCaseTypeExpandOnboarding(){

        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;
    
        OpportunityContactRole cr = new OpportunityContactRole(opportunityId=testOpportunities[0].id,contactId=testContacts[0].id,role='Business User');
        insert cr; //insert list of contact roles
        
		// Update opp and assert case created values
        testOpportunities[0].StageName = 'Closed-Won';
        //testOpportunities[0].Solution_Category__c = 'Add User Licences';
      	testOpportunities[0].Solution_Category__c = 'Additional Quota';
      	Test.startTest();
        update testOpportunities[0];
		Test.stopTest();
		
        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> oppCases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId, Type From Case Where Onboarding_Related_Opp__c =: testOpportunities[0].Id];
        
        System.assertEquals(null, oppCases[0].ParentId); // Assert that first case is master onboarding case        
        //System.assertEquals('Additional Users', oppCases[0].Type);
        System.assertEquals('Additional Emails', oppCases[0].Type);    	
    }   

	static testMethod void testCommsTypeAssignedToOrgs(){
        
        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
            
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 3, salesUserId, csmUserId);
        testAccounts[1].Communication_Type_Org__c = 'External Comms';
        update testAccounts[1];
                  
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 5, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create an opportunity with Comms type but Org with no comms type        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;     
        
        test.startTest();
        testOpportunities[0].StageName = 'Closed-Won';
        update testOpportunities[0];
        
        // create an opportunity with Internal Comms type but Org with External Comms Type        
        List<Opportunity> testOpportunities2 = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[1].Id);
        testOpportunities2[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli2 = new OpportunityLineItem(Quantity=1, UnitPrice=900.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities2[0].Id);    
        insert oli2;        
        
        testOpportunities2[0].StageName = 'Closed-Won';
        update testOpportunities2[0];        
        
        test.stopTest();
        
        // Query back first opportunity & account & assert that it's Org now has the Communications Type value from the Opp      
        List<Opportunity> orgForFirstOpp = [Select Id, Communication_Type__c From Opportunity Where AccountId =: testAccounts[0].Id];
        List<Account> savedOrg1 = [Select Communication_Type_Org__c From Account Where Id =: testAccounts[0].Id];
        System.assertEquals(orgForFirstOpp[0].Communication_Type__c, savedOrg1[0].Communication_Type_Org__c);

        // Query back second opportunity & account & assert that it's Org now has the Communications Type value from the Opp   
        List<Opportunity> orgForSecondOpp = [Select Id, Communication_Type__c From Opportunity Where AccountId =: testAccounts[1].Id];
        List<Account> savedOrg2 = [Select Communication_Type_Org__c From Account Where Id =: testAccounts[1].Id];
        System.assertNotEquals(orgForSecondOpp[0].Communication_Type__c, savedOrg2[0].Communication_Type_Org__c);
        System.assertEquals(savedOrg2[0].Communication_Type_Org__c, 'Internal Comms;External Comms');
    }

    static testMethod void testCommsTypeAssignedToOrgsBulkTest(){
        
        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
        
        List<Account> accountsToUpdate = new List<Account>();
            
        List<Opportunity> oppsToUpdateOrgNoCommsType = new List<Opportunity>();
        List<Opportunity> oppsToUpdateOrgIntCommsType = new List<Opportunity>();
        List<Opportunity> oppsToUpdateOrgExtCommsType = new List<Opportunity>();
        List<Opportunity> allOppsToUpdate = new List<Opportunity>();
        
        List<OpportunityLineItem> olis1 = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olis2 = new List<OpportunityLineItem>();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 3, salesUserId, csmUserId);
        testAccounts[1].Communication_Type_Org__c = 'External Comms';
        testAccounts[2].Communication_Type_Org__c = 'Internal Comms;External Comms';
        
        accountsToUpdate.add(testAccounts[1]);
        accountsToUpdate.add(testAccounts[2]);
        update accountsToUpdate;
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create opportunities with Internal Comms type but Org with External Comms Type        
        List<Opportunity> testOpps1 = TestDataFactory.createTestOpportunities('Test Opp No Org Comms Type', 5, testAccounts[0].Id);

        for(Integer i=0; i < testOpps1.size(); i++){
            testOpps1[i].Pricebook2Id = pricebookId;
            OpportunityLineItem oppli = new OpportunityLineItem(Quantity=1, UnitPrice=999.99, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpps1[i].Id);
            olis1.add(oppli);
            testOpps1[i].StageName = 'Closed-Won';
            oppsToUpdateOrgNoCommsType.add(testOpps1[i]);
        }
        
        // create opportunities with Internal Comms type but Org with External Comms Type        
        List<Opportunity> testOpps2 = TestDataFactory.createTestOpportunities('Test Opp Ext Org Comms Type', 5, testAccounts[1].Id);        
 
        for(Integer j=0; j < testOpps2.size(); j++){
            testOpps2[j].Pricebook2Id = pricebookId;
            testOpps2[j].StageName = 'Closed-Won';
            // add the line item
            OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpps2[j].Id);    
            olis1.add(oli);
            oppsToUpdateOrgIntCommsType.add(testOpps2[j]);
        }

        // create opportunities with Internal Comms type but Org with External Comms Type        
        List<Opportunity> testOpps3 = TestDataFactory.createTestOpportunities('Test Opp Ext Org Comms Type', 5, testAccounts[2].Id);        
 
        for(Integer k=0; k < testOpps3.size(); k++){
            testOpps3[k].Pricebook2Id = pricebookId;
            testOpps3[k].StageName = 'Closed-Won';
            // add the line item
            OpportunityLineItem opplitem = new OpportunityLineItem(Quantity=1, UnitPrice=1222.22, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpps3[k].Id);    
            olis1.add(opplitem);
            oppsToUpdateOrgExtCommsType.add(testOpps3[k]);
        }
        
        insert olis1;
        
        allOppsToUpdate.addall(oppsToUpdateOrgNoCommsType);
        allOppsToUpdate.addall(oppsToUpdateOrgIntCommsType);
        allOppsToUpdate.addall(oppsToUpdateOrgExtCommsType);
        Test.startTest();
        update allOppsToUpdate;
        Test.stopTest();
        
        // Query back opps from first list & account & assert that thier Org now has the Communications Type value from the Opps      
        List<Opportunity> oppsNoOrgCommsType = [Select Id, Communication_Type__c From Opportunity Where AccountId =: testAccounts[0].Id];
        List<Account> orgNoCommsType = [Select Communication_Type_Org__c From Account Where Id =: testAccounts[0].Id];
        
        // Assert that Opp and Org Comms Type are the same - check this on 2 random opps for that Org
        System.assertEquals(oppsNoOrgCommsType[0].Communication_Type__c, orgNoCommsType[0].Communication_Type_Org__c);
        System.assertEquals(oppsNoOrgCommsType[3].Communication_Type__c, orgNoCommsType[0].Communication_Type_Org__c);
        
        // Query back opportunities from 2nd list of opps & assert that it's Org's Comms Type is not the same as Opp Comms Type and is now both Internal & External Comms Type   
        List<Opportunity> oppsOrgIntCommsType = [Select Id, Communication_Type__c From Opportunity Where AccountId =: testAccounts[1].Id];
        List<Account> orgIntCommsType = [Select Communication_Type_Org__c From Account Where Id =: testAccounts[1].Id];
        
        // Assert that Opp and Org Comms type not the same and check to ensure that Org has been assigned both Comms Types - check this on 2 sample opps for that org
        System.assertNotEquals(oppsOrgIntCommsType[0].Communication_Type__c, orgIntCommsType[0].Communication_Type_Org__c);
        System.assertEquals(orgIntCommsType[0].Communication_Type_Org__c, 'Internal Comms;External Comms');         
        System.assertNotEquals(oppsOrgIntCommsType[2].Communication_Type__c, orgIntCommsType[0].Communication_Type_Org__c);
        System.assertEquals(orgIntCommsType[0].Communication_Type_Org__c, 'Internal Comms;External Comms');                

        // Query back opportunities from 2nd list of opps & assert that it's Org's Comms Type is not the same as Opp Comms Type and is now both Internal & External Comms Type   
        List<Opportunity> oppsOrgExtCommsType = [Select Id, Communication_Type__c From Opportunity Where AccountId =: testAccounts[2].Id];
        List<Account> orgExtCommsType = [Select Communication_Type_Org__c From Account Where Id =: testAccounts[2].Id];
        
        // Assert that Opp and Org Comms type not the same and check to ensure that Org has been assigned both Comms Types - check this on 2 sample opps for that org
        System.assertNotEquals(oppsOrgExtCommsType[0].Communication_Type__c, orgExtCommsType[0].Communication_Type_Org__c);
        System.assertEquals(orgExtCommsType[0].Communication_Type_Org__c, 'Internal Comms;External Comms');         
        System.assertNotEquals(oppsOrgExtCommsType[4].Communication_Type__c, orgExtCommsType[0].Communication_Type_Org__c);
        System.assertEquals(orgExtCommsType[0].Communication_Type_Org__c, 'Internal Comms;External Comms'); 

    }
        
    static testMethod void testDuplicateLineItems(){

        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
    
        Integer i;
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
            
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, myAccount.Id);
        Contact mycontact = testContacts[0];
            
        // create the product
        Product2 p1 = new Product2(name='Internal Connect Account', IsActive=true,
                Description='My Product', ProductCode='PC_0001');
        insert p1;       
         
        // create the pricebookentry
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), 
                Product2Id=p1.id, UnitPrice=766.66, IsActive=true);
        insert pbe1;   
        
        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Dupe Line Items', 1, myAccount.Id);
        Opportunity myOpportunity = testOpportunities[0];
        myOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
          
        // create a list of line items and insert them
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for(i=1; i<5; i++){
            OpportunityLineItem oli = new OpportunityLineItem(Quantity = 1, UnitPrice = 766.66,
                PricebookEntryId = pbe1.id, OpportunityId = myOpportunity.id);
            oppLineItems.add(oli);
        }    
         
        try {
            insert oppLineItems;  
        } catch (DmlException excp){
            System.debug('DML EXCEPTION: ' + excp.getMessage());
        }
        
        List<OpportunityLineItem> savedLineItems = new List<OpportunityLineItem>();
        savedLineItems = [select id from OpportunityLineItem Where UnitPrice = 766.66];
        
        // Assert that line items were added as dupes being inserted by test code are allowed - note they won't be allowed when added by users via UI
        System.assertNotEquals(0, savedLineItems.size());
    }
*/  
    static testMethod void testUniqueLineItems(){

        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
    
        Integer i;
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPricebookId();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        Account myAccount = testAccounts[0];
    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, myAccount.Id);
        Contact mycontact = testContacts[0];
                
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 5, 'Recurring');
        
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500, 200, 300};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 5, pricebookId, uPrices);
    
        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Dupe Line Items', 1, myAccount.Id);
        Opportunity myOpportunity = testOpportunities[0];
        myOpportunity.Pricebook2Id = pricebookId;
    
        // create a list of line items and insert them
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for(i=1; i<5; i++){
            OpportunityLineItem oli = new OpportunityLineItem(Quantity = 1, UnitPrice = 766.66,
                PricebookEntryId = pBookEntries[i].id, OpportunityId = myOpportunity.id);
            oppLineItems.add(oli);
        }    
    
        try {
            insert oppLineItems;  
        } catch (DmlException excp){
            System.debug('DML EXCEPTION: ' + excp.getMessage());
        }
        
        List<OpportunityLineItem> savedLineItems = new List<OpportunityLineItem>();
        savedLineItems = [select id from OpportunityLineItem Where OpportunityId =: myOpportunity.id];
        
        // Assert that no line items were added as list contained duplicates
        System.assertNotEquals(0, savedLineItems.size());    
    }
/*    
    static testMethod void testCaseTypeRenewals(){

        //create Test Users
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
          
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPriceBookId();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
          
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Sample Product', 1, 'Recurring');
    
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 1, pricebookId, uPrices);

        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
              
        // add the line item
        OpportunityLineItem oli = new OpportunityLineItem(Quantity=1, UnitPrice=766.66, PricebookEntryId = pBookEntries[0].Id, OpportunityId=testOpportunities[0].Id);    
        insert oli;
    
        OpportunityContactRole cr = new OpportunityContactRole(opportunityId=testOpportunities[0].id,contactId=testContacts[0].id,role='Business User');
        insert cr; //insert list of contact roles
        
		// Update opp and assert case created values
        testOpportunities[0].StageName = 'Closed-Won';
        testOpportunities[0].Deal_Type__c = 'Renewal';
      	
      	Test.startTest();
        update testOpportunities[0];
		Test.stopTest();
		
        // List back all cases from the first opportunity - this opp has no cases and so the trigger will create them automatically
        List<Case> oppCases = [Select contactId, OwnerId, Subject, ParentId, RecordTypeId, Type, Opportunity_Deal_Type__c From Case Where Onboarding_Related_Opp__c =: testOpportunities[0].Id];
        
        System.assertEquals(null, oppCases[0].ParentId); // Assert that first case is master onboarding case        
        System.assertEquals('Contract Renewals', oppCases[0].Type); 
        System.assertEquals(testOpportunities[0].Deal_Type__c, oppCases[1].Opportunity_Deal_Type__c);   	
    } 
*/        
}