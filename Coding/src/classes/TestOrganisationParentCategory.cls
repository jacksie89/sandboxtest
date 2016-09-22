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
private class TestOrganisationParentCategory {

    static testMethod void myCountryRegionTest(){
    	
    	//Test User
    	User testUser = new User();
		testUser.Username= 'newsweaver.tester2200@nwtest2200.com';
		testUser.Email = 'newsweaver.tester2200@nwtest2200.com';
		testUser.Lastname = 'Tester2200';
		testUser.Firstname = 'Newsweaver';
		testUser.Alias = 'ntest';
		testUser.UserRoleId = '00E20000001Jm92'; //Finance User Role
		testUser.ProfileId = '00e20000001crJn'; //Custom - Finance User Profile
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		//insert testUser;
    	
    	System.runAs(testUser){
	    	//create Account
	    	Account myAccount = new Account (name='My Test Organization');
	        myAccount.BillingCountry = 'Ireland';
	        myAccount.Status__c = 'Pending';
	        myAccount.OwnerId = testUser.Id;
	        myAccount.Category__c = 'Standard Account';
	        insert myAccount; 
	        
	        myAccount.BillingCountry = 'Mauritius';
	        update myAccount;
	        
	        Account savedAC1 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Test Organization'];
	        System.assertEquals('Rest Of World', savedAC1.Organisation_Region__c);
	        
	        myAccount.BillingCountry = 'United States';
	        update myAccount;
	        
	        Account savedAC2 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Test Organization'];
	        System.assertEquals('US/Canada', savedAC2.Organisation_Region__c);
	        
	        //create Another Account
	
	    	Account myOtherAccount = new Account (name='My Other Test Organization');
	        myOtherAccount.BillingCountry = 'United Kingdom';
	        myOtherAccount.Status__c = 'Pending';
	        myOtherAccount.OwnerId = testUser.Id;
	        myOtherAccount.Category__c = 'Standard Account';
	        insert myOtherAccount; 
	        
	        myOtherAccount.BillingCountry = 'Ireland';
	        update myOtherAccount;
	        
	        Account savedOtherAC1 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Other Test Organization'];
	        System.assertEquals('Ireland', savedOtherAC1.Organisation_Region__c);
	        
	        myOtherAccount.BillingCountry = 'Greece';
	        update myOtherAccount;
	        
	        Account savedOtherAC2 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Other Test Organization'];
	        System.assertEquals('Europe', savedOtherAC2.Organisation_Region__c);
	              
	        //test for blank country value
	        myOtherAccount.BillingCountry = '';
	        update myOtherAccount;
	        
	        Account savedOtherAC4 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Other Test Organization'];
	        System.assertEquals('Unknown', savedOtherAC4.Organisation_Region__c);
	        
	        //test for unknown country value
	        myOtherAccount.BillingCountry = 'Unknown';
	        update myOtherAccount;
	        
	        Account savedOtherAC5 = [Select Id, Category__c, Organisation_Region__c from Account where name = 'My Other Test Organization'];
	        System.assertEquals('Unknown', savedOtherAC5.Organisation_Region__c);
    	}
    }
    
    static testMethod void myUnitTest() {
        //Test User
    	User testUser = new User();
		testUser.Username= 'newsweaver.tester2200@nwtest2200.com';
		testUser.Email = 'newsweaver.tester2200@nwtest2200.com';
		testUser.Lastname = 'Tester2200';
		testUser.Firstname = 'Newsweaver';
		testUser.Alias = 'ntest';
		testUser.UserRoleId = '00E20000001Jm92'; //Finance User Role
		testUser.ProfileId = '00e20000001crJn'; //Custom - Finance User Profile
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		//insert testUser;
		
		System.runAs(testUser){
			//create parent Account
	
	    	Account parentAccount = new Account (name='Parent Organization');
	        parentAccount.BillingCountry = 'Ireland';
	        parentAccount.Status__c = 'Pending';
	        parentAccount.OwnerId = testUser.Id;
	        parentAccount.Category__c = 'Standard Account';
	        insert parentAccount;     
	           
	        Account parentAcc = [Select Id, Category__c from Account where name = 'Parent Organization'];
	        
	        //create child Account 1        
	        Account childAccount = new Account (name='Child 1 Organization');
	        childAccount.BillingCountry = 'Ireland';
	        childAccount.Status__c = 'Pending';
	        childAccount.OwnerId = testUser.Id;
	        childAccount.ParentId = parentAcc.Id;
	        insert childAccount;         
	        Account savedChildAcc1 = [Select Id, Category__c from Account where name = 'Child 1 Organization'];
	        System.assertEquals('Standard Account', savedChildAcc1.Category__c);
	                
	        //create Chile Account 2
	        Account childAccount2 = new Account (name='Child 2 Organization');
	        childAccount2.BillingCountry = 'Ireland';
	        childAccount2.Status__c = 'Pending';
	        childAccount2.OwnerId = testUser.Id;
	        childAccount2.ParentId = parentAcc.Id;
	        insert childAccount2;
	        Account savedChildAcc2 = [Select Id, Category__c from Account where name = 'Child 2 Organization'];
	        System.assertEquals('Standard Account', savedChildAcc2.Category__c);
	        
	        
	        //create Account 3 - NO PARENT - control to ensure no effect on other accounts...
	        Account childAccount3 = new Account (name='Child 3 Organization');
	        childAccount3.BillingCountry = 'Ireland';
	        childAccount3.Status__c = 'Pending';
	        childAccount3.OwnerId = testUser.Id;
	        insert childAccount3;
	                      
	        // update Parent Account
	        parentAcc.Category__c = 'Key Account';
	        update parentAcc;
	        
	  		savedChildAcc1 = [Select Id, Category__c from Account where name = 'Child 1 Organization'];
	        savedChildAcc2 = [Select Id, Category__c from Account where name = 'Child 2 Organization'];
	        //test child Accounts.
	        System.assertEquals('Key Account', savedChildAcc1.Category__c);
	        System.assertEquals('Key Account', savedChildAcc2.Category__c);
	        
	        
	        //Update Child 3 and add a parntId
	        Account savedChildAcc3 = [Select parentId from Account where name = 'Child 3 Organization'];
	        savedChildAcc3.parentId = parentAcc.Id;
	        update savedChildAcc3;
	        savedChildAcc3 = [Select Id, Category__c from Account where name = 'Child 3 Organization'];
	        System.assertEquals('Key Account', savedChildAcc3.Category__c);
	        
	        
			/*--------------------------
			* Bulk update Test
			*--------------------------*/
	
			// add 200 parent accounts to the list to be inserted
	 
			List<Account> accounts = new List<Account>();
	
			for (Integer i=0;i<200;i++) {
			
				Account a = new Account(
				    Name = 'Bulk Test Account' + i,
				    OwnerId = testUser.Id,
				    BillingCountry = 'Ireland',
				    Status__c = 'Pending',   
				    Category__c = 'Standard Account'
				);
				accounts.add(a);
			}
			// Switch to the runtime context
			Test.startTest();
			insert accounts;
			Test.stopTest();
	  
			// insert 50 child accounts 
			List<Account> childAccounts = new List<Account>();  
	
			for (Integer i=0;i<50;i++) {
	
				Account a = new Account(
				    Name = 'Bulk Test Child Account' + i,
				    OwnerId = testUser.Id,
				    BillingCountry = 'Ireland',
				    Status__c = 'Pending',   
				    Category__c = 'Standard Account'          
				);
				String parentName = 'Bulk Test Account'+i;
				a.ParentId = [Select Id from Account where name = :parentName][0].Id;
				childAccounts.add(a);
			}
			insert childAccounts;
			Account testAccount = [Select ParentId from Account where name = 'Bulk Test Child Account1'][0];
			system.assertNotEquals(null, testAccount.ParentId);
		
		
			for (Account bulkParent :accounts){
				bulkParent.Category__c = 'Key Account';
			}
			update accounts;
		  
			testAccount = [Select Category__c from Account where name = 'Bulk Test Child Account1'][0];
			system.assertEquals('Key Account', testAccount.Category__c);
		}      
  }
}