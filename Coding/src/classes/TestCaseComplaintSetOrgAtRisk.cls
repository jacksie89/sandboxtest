@isTest
public class TestCaseComplaintSetOrgAtRisk {

	static testMethod void myCaseTest(){

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

		System.runAs(testUser){
	    	Account myLastAccount = new Account (name='My Last Organization');
	        myLastAccount.BillingCountry = 'United Kingdom';
	        myLastAccount.Status__c = 'Active';
	        myLastAccount.OwnerId = testUser.Id;
	        myLastAccount.Category__c = 'Standard Account';
	        myLastAccount.At_Risk__c = False;
	        insert myLastAccount; 
	        		
			//create a case
			Case myCase = new Case (subject='My Test Case', OwnerId=testUser.Id, AccountId=myLastAccount.Id, Complaint__c = False);
			myCase.priority = 'Medium';
			insert myCase;
			
			myCase.Complaint__c = True;
			update myCase;
			
			Case savedCase1 = [Select Id, priority, Complaint__c from Case where accountId=:myLastAccount.Id AND subject='My Test Case'];
			System.assertEquals(True, savedCase1.Complaint__c);
			
			Account mySavedAccount = [Select Id, name, At_Risk__c from Account where name = 'My Last Organization'];
			System.assertEquals(True, mySavedAccount.At_Risk__c);
			
			//create a second case
			Case mySecondCase = new Case (subject='My 2nd Test Case', OwnerId=testUser.Id, AccountId=myLastAccount.Id);
			mySecondCase.priority = 'Medium';
			insert mySecondCase;
			
			mySecondCase.Complaint__c = True;
			mySecondCase.Rate_Customer_Satisfaction__c = 'Very unhappy';
			update mySecondCase;
			
			Case savedCase2 = [Select Id, Complaint__c, Rate_Customer_Satisfaction__c from Case where accountId=:myLastAccount.Id AND subject='My 2nd Test Case'];
			System.assertEquals('Very unhappy', savedCase2.Rate_Customer_Satisfaction__c);
			
			Account mySavedAccount2 = [Select Id, name, At_Risk__c from Account where name = 'My Last Organization'];
			System.assertEquals(True, mySavedAccount2.At_Risk__c);
			
			//create a second case
			Case myThirdCase = new Case (subject='My 3rd Test Case', OwnerId=testUser.Id, AccountId=myLastAccount.Id);
			myThirdCase.priority = 'Medium';
			insert myThirdCase;
	
			myThirdCase.Rate_Customer_Satisfaction__c = 'Generally satisfied';
			update myThirdCase;
	
			Case savedCase3 = [Select Id, Complaint__c, Rate_Customer_Satisfaction__c from Case where accountId=:myLastAccount.Id AND subject='My 3rd Test Case'];
			System.assertEquals('Generally satisfied', savedCase3.Rate_Customer_Satisfaction__c);
			
			Account mySavedAccount3 = [Select Id, name, At_Risk__c from Account where name = 'My Last Organization'];
			System.assertEquals(True, mySavedAccount3.At_Risk__c);
		}
			
	}
	
	//TEST BULK UPDATING HANDLING OF TRIGGER
	static testMethod void testMultipleCases(){
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

		System.runAs(testUser){
	    	Account myLastAccount = new Account (name='My Last Organization');
	        myLastAccount.BillingCountry = 'United Kingdom';
	        myLastAccount.Status__c = 'Active';
	        myLastAccount.OwnerId = testUser.Id;
	        myLastAccount.Category__c = 'Standard Account';
	        myLastAccount.At_Risk__c = False;
	        insert myLastAccount; 
		
			// Create some test cases
       		Case[] cases = new List<Case>();
       		Case[] casesToUpdate = new List<Case>();
       		
	       	for (Integer i=0;i<210;i++) {
	           Case c = new Case(subject='My Test Case ' + i, OwnerId=testUser.Id, 
	           		AccountId=myLastAccount.Id, Complaint__c = False, isScrubbed__c=false);
	           cases.add(c);
	       	}
	       	insert cases;
	       	
	       	//Create a sample list of cases
	       	Set<String> caseSubjects = new Set<String>();
	       	caseSubjects.add('My Test Case 100');
	       	caseSubjects.add('My Test Case 135');
	       	caseSubjects.add('My Test Case 150');
	       	caseSubjects.add('My Test Case 177');
	       	caseSubjects.add('My Test Case 199');
	       	
	       	for (Case mycase: cases){
	       		mycase.isScrubbed__c=true;
	       		
	       		//Set the case complaint flag to true if the case exists in the sample list above
	       		if(caseSubjects.contains(mycase.Subject)){
	       			mycase.Complaint__c = true;
	       		}
	       		casesToUpdate.add(mycase);
	       	}
	       	
	       	update casesToUpdate;
		}
		
		//Assert that the account that the cases belongs to has had its At Risk flag set to true
		Account mySavedAccount = [Select Id, name, At_Risk__c from Account where name = 'My Last Organization'];
		System.assert(mySavedAccount.At_Risk__c);
		
		//Assert that the list of sample cases have had their case complaint flag set to true
		Case savedCase2 = [Select Complaint__c from Case Where subject = 'My Test Case 150'];
		System.assert(savedCase2.Complaint__c);
		
		Case savedCase3 = [Select Complaint__c from Case Where subject = 'My Test Case 177'];
		System.assert(savedCase3.Complaint__c);
		
		Case savedCase4 = [Select Complaint__c from Case Where subject = 'My Test Case 199'];
		System.assert(savedCase4.Complaint__c);	
	}

}