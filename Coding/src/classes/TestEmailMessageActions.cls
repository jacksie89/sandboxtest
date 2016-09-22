@isTest
private class TestEmailMessageActions {

	private static testmethod void testHPDomains(){
		
		List<EmailMessage> emails = new List<EmailMessage>();
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		
		//User u2 = new User(Alias = 'sales', Email='myothersalesuser@testorg.com'); 
		User u2 = new User(Alias = 'aadmi', Email='mysystemadministrator@notessatestorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Beta', LanguageLocaleKey='en_US', 
      	LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='mysystemadministrator@notessatestorg.com', UserRoleId = '00E20000001K7R0');
		
		System.runAs(u2){
			//Create Account
	    	Account myAccount = new Account (name='My Test Organization');
	        myAccount.BillingCountry = 'United Kingdom';
	        myAccount.Status__c = 'Active';
	        insert myAccount;
	        
			//Create Contact		
			Contact newContact = new Contact (FirstName='Jack', 
	                                         LastName='Black',
	                                         AccountId=myAccount.id,
	                                         email='jblack@castlebrewery.com');
			newContact.MailingCountry = 'United Kingdom';
			newContact.OtherCountry = 'United Kingdom';
	        insert newContact;
	        
			Case myCaseFromEmail = new Case (subject='My Test Case2', AccountId=myAccount.Id, Status='New', Type='Reporting', Sub_Type__c='Other', Origin='Phone');
			insert myCaseFromEmail;
			
			List<Case> myTestForCase = [select id, subject from Case where id = :myCaseFromEmail.id];
			
			//Create Email Message
			EmailMessage em = new EmailMessage(FromAddress='bctest123@notessalabs.com', FromName='Test123, Brian', ParentId=myTestForCase[0].Id);
			insert em;

			List <EmailMessage> myTestForEmail = [select ParentId, FromAddress from EmailMessage where id = :em.id];
			System.assertEquals(myTestForCase[0].Id, myTestForEmail[0].ParentId);
			
			Case myCaseFromHP = new Case (subject='My HP Case', AccountId=myAccount.Id, ContactId=newContact.Id, Status='New', Type='Reporting', Sub_Type__c='Other', Origin='Email');
			insert myCaseFromHP;
			
			Case myCaseFromHP2 = new Case (subject='My Second HP Case', AccountId=myAccount.Id, ContactId=newContact.Id, Status='New', Type='Reporting', Sub_Type__c='Other', Origin='Email');
			insert myCaseFromHP2;
						
			List<Case> myHPCases = [select id, subject from Case where id = :myCaseFromHP.id];
			List<Case> myHPCases2 = [select id, subject from Case where id = :myCaseFromHP2.id];
			
			//Create Email Message from hp
			EmailMessage emHP = new EmailMessage(FromAddress='testhp@hp.com', FromName='TestHP, Brian', ParentId=myHPCases[0].Id);
			insert emHP;
					
			List <EmailMessage> myTestForEmail2 = [select ParentId, FromAddress from EmailMessage where id = :emHP.id];
			System.assertEquals(myHPCases[0].Id, myTestForEmail2[0].ParentId);	
			
			//Create Email Message from hp
			EmailMessage emHP2 = new EmailMessage(FromAddress='testhp2@hp.com', FromName='TestHP2, Brian2', ParentId=myHPCases[0].Id);
			insert emHP2;
			
			//BULK TESTING
			for(Integer i=0; i<200;i++){
				if(i<100){
					EmailMessage email = new EmailMessage(FromAddress='testhp'+i+'@hp.com', FromName='TestHP'+i+', Brian', ParentId=myHPCases[0].Id);
					emails.add(email);	
				} else {
					EmailMessage email = new EmailMessage(FromAddress='testhp'+i+'@hp.com', FromName='TestHP'+i+', Brian', ParentId=myHPCases2[0].Id);
					emails.add(email);
				}
				
			}
			
			insert emails;
			
			//Create Email Message with no from address
			EmailMessage emEmpty = new EmailMessage(FromAddress='', FromName='TestUser, Dummy', ParentId=myTestForCase[0].Id);
			try{
				insert emEmpty;	
			} catch(Exception e){
				//Assert that expected exception was thrown
				Boolean expectedExceptionThrown = e.getMessage().contains('Email Address') ?true:false;
				System.assertEquals(expectedExceptionThrown, true);
			}			
		}		
	}
}