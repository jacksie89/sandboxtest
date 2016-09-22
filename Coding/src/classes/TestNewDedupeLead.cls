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
private class TestNewDedupeLead {

	// --- TEST EXACT MATCHES ON INSERTS
  
    private static testmethod void testExactDuplicateSingleInserts(){                                     
        
        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'Unique', 'unique', null, true, 'Sales Ready');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
        //Insert duplicate lead with same email address
        TestDataFactory.createTestLeadsv2(1, 'email', 'unique0@uniqueorg0.com', null, false, 'Sales Ready');
        DedupeController.setNotAlreadyRun();
        
        List<Lead> savedDupeLeads = [select Reassign__c from Lead where Email = 'unique0@uniqueorg0.com'];
        System.assertEquals(true, savedDupeLeads[0].Reassign__c); // Ensure that original unique email has been set to run through assignment rules
        System.assertEquals(false, savedDupeLeads[1].Reassign__c);
        
        //Insert new lead with same name and company but unique email
        TestDataFactory.createTestLeadsv2(1, 'namecompany', 'tlead2@notessainc2.com', 'UniqueEmail0', true, 'Sales Ready'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
 		
 		// Assert that duplicate lead is not set to reassign
        List <Lead> savedDupeNameCompanyLeads = [select Reassign__c from Lead where Email = 'tlead2@notessainc2.com'];
        System.assertEquals(false, savedDupeNameCompanyLeads[0].Reassign__c);           
    }

    private static testmethod void testExactDuplicateBulkInserts(){
    	
    	List<Lead> bulkLeadsToInsert = new List<Lead>();
    	
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'Unique', 'unique', null, true, 'Sales Ready');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
        // Create some leads with the same email address
        TestDataFactory.createTestLeadsv2(102, 'email', 'unique0@uniqueorg0.com', 'Test Unique Org', true, 'Sales Ready');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
        // Assert that duplicate lead is not set to reassign
        List<Lead> savedLeads = [Select Id, Reassign__c from Lead Where Email = 'unique0@uniqueorg0.com'];
        //System.assertEquals(true, savedLeads[0].Reassign__c); // Ensure that original unique email has been set to run through assignment rules   	
        System.assertEquals(false, savedLeads[10].Reassign__c);
        
        // Insert new lead with same name and company but unique email
        Test.startTest();
        TestDataFactory.createTestLeadsv2(102, 'namescompanies', 'notessainc', 'UniqueEmail0', true, 'Sales Ready'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        Test.stopTest();
        DedupeController.setNotAlreadyRun(); // Reset already run flag to false for next run
 		
 		// Assert that duplicate lead is not set to reassign
        List <Lead> savedDupeNameCompanyLeads = [select Reassign__c from Lead where Email Like '%notessainc%'];
        System.assertEquals(false, savedDupeNameCompanyLeads[0].Reassign__c);
    }

	// --- TEST POSSIBLE MATCHES ON INSERTS
    
    private static testmethod void testPossibleDuplicatesLeadsSingleInserts(){                                     
		
	    //create Test Users
	    User salesUser = TestDataFactory.createTestUser('Sales');
	    User csmUser = TestDataFactory.createTestUser('Account');
	      
	    Id salesUserId = salesUser.Id;
	    Id csmUserId = csmUser.Id;
        
        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'Unique', 'unique', null, true, 'Sales Ready');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
      
		//Insert duplicate domain lead
        TestDataFactory.createTestLeadsv2(1, 'domain', 'uniqueorg0.com', null, false, 'Sales Ready');        
        DedupeController.setNotAlreadyRun();
       
        // Assert that duplicate lead's reassign flag has been set to false as dupe has been detected
        List <Lead> savedDupeDomainLeads = [select Reassign__c from Lead where Email = 'samedomain0@uniqueorg0.com' and LastName = 'DuplicateDomainLead'];
        System.assertEquals(false, savedDupeDomainLeads[0].Reassign__c);

        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'Unique', 'special', null, true, 'Sales Ready');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

		//Insert duplicate company lead
        TestDataFactory.createTestLeadsv2(1, 'company', 'specialorg0.com', null, false, 'Sales Ready');               
        DedupeController.setNotAlreadyRun();
        
        // Assert that duplicate lead's reassign flag has been set to false as dupe company has been detected
        List <Lead> savedDupeCompanyLeads = [select Reassign__c from Lead where Email = 'samecompany0@specialorg0.com'];
        System.assertEquals(false, savedDupeCompanyLeads[0].Reassign__c); 
	}

    private static testmethod void testPossibleDuplicatesContactsSingleInserts(){                                     
		
	    //create Test Users
	    User salesUser = TestDataFactory.createTestUser('Sales');
	    User csmUser = TestDataFactory.createTestUser('Account');
	      
	    Id salesUserId = salesUser.Id;
	    Id csmUserId = csmUser.Id;

		//create Account
	    List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 'Customer', 1, salesUserId, csmUserId);
	                
	    //create and insert new Contact
	    List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
	    Contact mycontact = testContacts[0];
	    mycontact.OwnerId = testAccounts[0].OwnerId;
		
		// Insert a lead with duplicate domain of contact
        TestDataFactory.createTestLeadsv2(1, 'sameContactDomain', 'randomtestlead@testaccountnewsweaver.com', null, false, 'Sales Ready');        
        DedupeController.setNotAlreadyRun();		
		
        // Assert that duplicate lead's reassign flag has been set to false as dupe has been detected
        List <Lead> savedDupeContactDomainLeads = [select Reassign__c, OwnerId from Lead where Email = 'randomtestlead@testaccountnewsweaver.com'];
        System.assertEquals(false, savedDupeContactDomainLeads[0].Reassign__c);
        
        User checkForLeadSalesUser = [Select Profile.Name from User Where Id =:savedDupeContactDomainLeads[0].OwnerId];   
        User checkForContactSalesUser = [Select Profile.Name from User Where Id =:myContact.OwnerId];
        
        Boolean isLeadSalesOwner = false;
        Boolean isContactSalesOwner = false;
        
        // Check that owner's profiles are a Sales Profile
        if(checkForLeadSalesUser.Profile.Name.contains('Sales')){
        	isLeadSalesOwner = true;
        }
        
        if(checkForContactSalesUser.Profile.Name.contains('Sales')){
        	isContactSalesOwner = true;
        }
        System.assertEquals(isLeadSalesOwner, isContactSalesOwner);
    }	

   private static testmethod void testPossibleLeadsDuplicatesBulkInserts(){                                     
		
	    //create Test Users
	    User salesUser = TestDataFactory.createTestUser('Sales');
	    User csmUser = TestDataFactory.createTestUser('Account');
	      
	    Id salesUserId = salesUser.Id;
	    Id csmUserId = csmUser.Id;
        
        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead@notessainc.com', null, true, 'Sales Ready'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
      	
      	Lead uniqueLead = [Select OwnerId From Lead Where Email = 'tlead@notessainc.com'];
      	
		//Insert duplicate domain lead
        TestDataFactory.createTestLeadsv2(102, 'domain', 'notessainc.com', null, false, 'Sales Ready');        
        DedupeController.setNotAlreadyRun();
       
        // Assert that duplicate lead's reassign flag has been set to false as dupe has been detected - check lead owners match too
        List <Lead> savedDupeDomainLeads = [select OwnerId, Reassign__c from Lead where Email Like '%notessainc.com%' and LastName = 'DuplicateDomainLead'];
        System.assertEquals(false, savedDupeDomainLeads[5].Reassign__c);
        System.assertEquals(uniqueLead.OwnerId, savedDupeDomainLeads[3].OwnerId);
        System.assertEquals(false, savedDupeDomainLeads[25].Reassign__c);
        System.assertEquals(uniqueLead.OwnerId, savedDupeDomainLeads[73].OwnerId);
        
        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead2@notessainc2.gov.uk', 'Unique Org', true, 'Sales Ready'); // parameters are (numLeads, dupeEmail, useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
		
		Lead uniqueLead2 = [Select OwnerId, Reassign__c from Lead Where Email = 'tlead2@notessainc2.gov.uk'];
		System.assertEquals(true, uniqueLead2.Reassign__c);
		
		//Insert duplicate company leads
        Test.startTest();
        TestDataFactory.createTestLeadsv2(102, 'company', 'notessainc33.co.uk', null, false, 'Sales Ready');               
        Test.stopTest();
        DedupeController.setNotAlreadyRun();
        
        // Assert that duplicate lead's reassign flag has been set to false as dupe company has been detected
        List <Lead> savedDupeCompanyLeads = [select OwnerId, Reassign__c from Lead where Email Like '%notessainc33.co.uk%'];
        System.assertEquals(false, savedDupeCompanyLeads[8].Reassign__c); 
		System.assertEquals(uniqueLead2.OwnerId, savedDupeCompanyLeads[4].OwnerId);
		System.assertEquals(false, savedDupeCompanyLeads[66].Reassign__c); 
		System.assertEquals(uniqueLead2.OwnerId, savedDupeCompanyLeads[88].OwnerId);
	}    

	private static testmethod void testPossibleContactsDuplicatesBulkInserts(){
	    // create Test Users
	    User salesUser = TestDataFactory.createTestUser('Sales');
	    User csmUser = TestDataFactory.createTestUser('Account');
	      
	    Id salesUserId = salesUser.Id;
	    Id csmUserId = csmUser.Id;
	    	    
	    //create Account
	    List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 'Customer', 1, salesUserId, csmUserId);
	                
	    //create and insert new Contact
	    List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
	    Contact mycontact = testContacts[0];
	    mycontact.OwnerId = testAccounts[0].OwnerId;
		
		// Insert a lead with duplicate domain of contact
        Test.startTest();
        TestDataFactory.createTestLeadsv2(102, 'sameContactDomain', 'randomtestlead@testaccountnewsweaver.com', null, false, 'Sales Ready');        
        Test.stopTest();
        DedupeController.setNotAlreadyRun();		
		
        // Assert that duplicate lead's reassign flag has been set to false as dupe has been detected
        List <Lead> savedDupeContactDomainLeads = [select Reassign__c, OwnerId from Lead where Email = 'randomtestlead@testaccountnewsweaver.com'];
        System.assertEquals(false, savedDupeContactDomainLeads[4].Reassign__c);
        System.assertEquals(mycontact.OwnerId, savedDupeContactDomainLeads[4].OwnerId);
        System.assertEquals(false, savedDupeContactDomainLeads[8].Reassign__c);
        System.assertEquals(mycontact.OwnerId, savedDupeContactDomainLeads[8].OwnerId);
        System.assertEquals(false, savedDupeContactDomainLeads[69].Reassign__c);
        System.assertEquals(mycontact.OwnerId, savedDupeContactDomainLeads[69].OwnerId);
        
        User checkForLeadSalesUser = [Select Profile.Name from User Where Id =:savedDupeContactDomainLeads[0].OwnerId];  
        User checkForLeadSalesUser2 = [Select Profile.Name from User Where Id =:savedDupeContactDomainLeads[5].OwnerId];
        User checkForLeadSalesUser3 = [Select Profile.Name from User Where Id =:savedDupeContactDomainLeads[59].OwnerId]; 
        User checkForContactSalesUser = [Select Profile.Name from User Where Id =:myContact.OwnerId];
        
        Boolean isLeadSalesOwner = false;
        Boolean isContactSalesOwner = false;
        
        // Check that owner's profiles are a Sales Profile
        if(checkForLeadSalesUser.Profile.Name.contains('Sales')){
        	isLeadSalesOwner = true;
        }
        
        if(checkForContactSalesUser.Profile.Name.contains('Sales')){
        	isContactSalesOwner = true;
        }
        System.assertEquals(isLeadSalesOwner, isContactSalesOwner);
		
		isLeadSalesOwner = false;
        // Check that owner's profiles are a Sales Profile
        if(checkForLeadSalesUser2.Profile.Name.contains('Sales')){
        	isLeadSalesOwner = true;
        }
        System.assertEquals(isLeadSalesOwner, isContactSalesOwner); 

		isLeadSalesOwner = false;
        // Check that owner's profiles are a Sales Profile
        if(checkForLeadSalesUser3.Profile.Name.contains('Sales')){
        	isLeadSalesOwner = true;
        }
        System.assertEquals(isLeadSalesOwner, isContactSalesOwner);       		
	}
    
   
	// ##### UPDATE TRANSACTIONS #####
 
	// --- TEST EXACT MATCHES ON UPDATES    
    
    private static testmethod void testExactDuplicateSingleUpdates(){                                     
        
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'Unique', 'unique', null, true, 'New'); // unique0@uniqueorg0.com
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
                
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'None', 'special@specialorg.com', null, true, 'New');
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
        Lead savedLeadToUpdate = [select Reassign__c, OwnerId from Lead where Email Like '%special%'];
        
        //Update values on second unique lead including email to make it a duplicate email lead
        savedLeadToUpdate.Free_Trial__c = false;
        savedLeadToUpdate.Online_Demo__c = true;
        savedLeadToUpdate.Request_Quote__c = false;
        savedLeadToUpdate.Status = 'Sales Ready';
        savedLeadToUpdate.Email = 'unique0@uniqueorg0.com';
		savedLeadToUpdate.Dedupe__c = true;        
		
		try{
			update savedLeadToUpdate;		
		} catch (Exception e){
			System.debug('Exception caught for lead update with same email. Error: ' + e.getMessage());
		}

        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
                       
       	Lead updatedLead = [select OwnerId, Status, Free_Trial__c, Online_Demo__c, Request_Quote__c, Email, Dedupe__c, Reassign__c from Lead where Email Like '%unique%' AND LastName = 'special'];
        
        // Assert that updates have taken place
        System.assertEquals(false, updatedLead.Free_Trial__c); 
        System.assertEquals(true, updatedLead.Online_Demo__c); 
        System.assertEquals(false, updatedLead.Request_Quote__c);
        System.assertEquals('Sales Ready', updatedLead.Status);
		
		// Assert that this updated lead has been assigned to the same owner as the first lead via same email domain assignment
        System.assertEquals(savedLeadToUpdate.OwnerId, updatedLead.OwnerId);
        System.assertEquals(false, updatedLead.Reassign__c);
        System.assertEquals(false, updatedLead.Dedupe__c);
        
    }

 	// --- TEST POSSIBLE MATCHES ON UPDATES      

    private static testmethod void testEmailDomainUpdate(){                                     
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead@notessainc.com', 'Notessa Inc 1', true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

		Lead uniqueLead1 = [select Reassign__c, OwnerId from Lead where Email = 'tlead@notessainc.com'];
		
        // Insert another new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead2@notessainc2.com', 'Notessa Inc 2', true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
		Lead uniqueLead2 = [select Reassign__c, OwnerId from Lead where Email = 'tlead2@notessainc2.com'];
		
		// Assert that lead has not been dedupe and has been set to run through assignment rules
		System.assertEquals(true, uniqueLead2.Reassign__c);
		
		// Update uniqueLead2's email address so that it will match uniqueLead1's email domain
		uniqueLead2.Email = 'tlead2@notessainc.com';
		uniqueLead2.Status = 'Sales Ready';
		update uniqueLead2;
		
		Lead updatedUniqueLead2 = [select Reassign__c, OwnerId, Dedupe__c from Lead where Email = 'tlead2@notessainc.com'];
		
		// Assert that lead has been deduped and has been assigned to the owner of uniqueLead1
		System.assertEquals(false, updatedUniqueLead2.Reassign__c);
		System.assertEquals(uniqueLead1.OwnerId, updatedUniqueLead2.OwnerId);
		System.assertEquals(false, updatedUniqueLead2.Dedupe__c);    
    }

    private static testmethod void testCompanyUpdate(){                                     

		// Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead3@notessainc3.com', 'Notessa Inc 3', true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

		Lead uniqueLead3 = [select Reassign__c, OwnerId, Company from Lead where Email = 'tlead3@notessainc3.com'];
		
        // Insert another new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead4@notessainc4.com', 'Notessa Inc 4', true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
		Lead uniqueLead4 = [select Reassign__c, OwnerId from Lead where Email = 'tlead4@notessainc4.com'];

		// Assert that lead has not been dedupeD and has been set to run through assignment rules
		System.assertEquals(true, uniqueLead4.Reassign__c);		
		
		// Update uniqueLead4's company so that it will match uniqueLead3's company
		uniqueLead4.Company = uniqueLead3.Company;
		uniqueLead4.Status = 'Sales Ready';
		update uniqueLead4;
		
		Lead updatedUniqueLead4 = [select Reassign__c, OwnerId, Dedupe__c, Company from Lead where Email = 'tlead4@notessainc4.com'];
		
		// Assert that lead has been deduped and has been assigned to the owner of uniqueLead1
		System.assertEquals(false, updatedUniqueLead4.Reassign__c);
		System.assertEquals(uniqueLead3.Company, updatedUniqueLead4.Company);
		System.assertEquals(uniqueLead3.OwnerId, updatedUniqueLead4.OwnerId); 
		System.assertEquals(false, updatedUniqueLead4.Dedupe__c);   
    }

    private static testmethod void testPossibleLeadsDuplicatesBulkUpdates(){                                     
		
	    //create Test Users
	    User salesUser = TestDataFactory.createTestUser('Sales');
	    User csmUser = TestDataFactory.createTestUser('Account');
        List<Lead> leadsToUpdate = new List<Lead>();
        	      
	    Id salesUserId = salesUser.Id;
	    Id csmUserId = csmUser.Id;
        
        // ##### EMAIL DOMAIN DUPLICATE TEST #####
        
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead@notessainc.com', 'Notessa Inc 1', true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
 
         //Insert new unique leads
        TestDataFactory.createTestLeadsv2(102, 'Unique', 'unique', null, true, 'New'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

		// Query back all new unique leads created
		List<Lead> myUniqueLeads = [Select Id, Email, Reassign__c From Lead Where Email Like '%unique%'];
		System.assertEquals(102, myUniqueLeads.size());			
		System.assertEquals(true, myUniqueLeads[2].Reassign__c);
		System.assertEquals(true, myUniqueLeads[8].Reassign__c);
		
        // Update all leads and add to new list        
        for(Integer i=0; i<myUniqueLeads.size(); i++){
        	myUniqueLeads[i].Company = 'Notessa Inc 1';
        	myUniqueLeads[i].Status = 'Sales Ready';
        	leadsToUpdate.add(myUniqueLeads[i]);
        }
        System.debug('Inside Test Class Leads To Update: ' + leadsToUpdate);
        Test.startTest();
        update leadsToUpdate;
		Test.stopTest();
		
        // Query back all updated leads and assert that they have been deduped
		List<Lead> myUpdatedLeads = [Select Id, Email, LastName, Company, Reassign__c, Dedupe__c, Status From Lead Where Email Like '%unique%']; 
		System.assertEquals(false, myUpdatedLeads[1].Reassign__c);
		System.assertEquals(false, myUpdatedLeads[7].Reassign__c); 
		System.assertEquals(false, myUpdatedLeads[77].Reassign__c);        
		System.assertEquals(false, myUpdatedLeads[29].Dedupe__c);
		System.assertEquals('Sales Ready', myUpdatedLeads[54].Status);        
	}
	
 // ### OTHER TESTS IN DEDUPE PROCESS ###
 
    private static testmethod void testForSpamLead(){
            
        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'tlead@notessainc.com', null, true, 'Sales Ready'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
      
		//Insert duplicate spam lead
        TestDataFactory.createTestLeadsv2(1, 'Spam', 'spamlead@notessainc.com', null, true, 'Sales Ready');        
        DedupeController.setNotAlreadyRun();
          
        List <Lead> savedSpamLead = [select Spam_Lead__c, OwnerId from Lead where LastName = 'SpamLead' and Email = 'spamlead@notessainc.com'];
        
        System.assertEquals(true, savedSpamLead[0].Spam_Lead__c); // Assert that lead has been marked as Spam
        System.assertEquals('00G200000017Q51EAE', savedSpamLead[0].OwnerId); //Assert lead owner is the Spam Queue! 
    }
    
	private static testmethod void testForPublicEmailAddress(){

        // Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'public@gmail.com', null, true, 'Sales Ready'); // parameters are (numLeads, dupeType, dupeValue useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run
        
        // Insert duplicate lead with same public email domain
        TestDataFactory.createTestLeadsv2(1, 'publicdomain', 'gmail.com', null, false, 'Sales Ready');        
        DedupeController.setNotAlreadyRun();        		

        List <Lead> savedDuplicatePublicDomain = [select Reassign__c from Lead where LastName = 'DuplicateDomainLead'];
        
        //Assert that duplicate lead with public email has been set to be reassign via assignment rules & not deduped!
        System.assertEquals(true, savedDuplicatePublicDomain[0].Reassign__c);

        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

        //Insert new unique lead
        TestDataFactory.createTestLeadsv2(1, 'none', 'anyusername@yahoo.ie', null, true, 'Sales Ready'); // parameters are (numLeads, dupeEmail, useAssignment)
        DedupeController.setNotAlreadyRun(); //Reset already run flag to false for next run

		//Insert duplicate lead with same public email domain
        TestDataFactory.createTestLeadsv2(1, 'publicdomain2', 'yahoo.ie', null, false, 'Sales Ready');               
        DedupeController.setNotAlreadyRun();
        
        //Assert that duplicate lead with public email has been set to be reassign via assignment rules & not deduped!
        List <Lead> savedDupeCorporateDomain = [select Reassign__c from Lead where Email = 'samedomain0@yahoo.ie'];
        System.assertEquals(true, savedDupeCorporateDomain[0].Reassign__c); 
	}    
}