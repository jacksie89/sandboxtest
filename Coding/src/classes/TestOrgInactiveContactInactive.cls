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
private class TestOrgInactiveContactInactive {

     static testMethod void myUnitTest() {
        //Create an Active Account
        Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        newAccount.Status__c = 'Active';
        insert newAccount;
        
        List <Account> savedAccount = [Select Status__c from Account where name = 'XYZ Organization'];
        
        //TEST FOR STATUS EQUAL TO 'Inactive'
        //Create Active Contacts
        Contact mycontact = new Contact (lastName='XYZ Contact',Contact_Status__c = 'Active', MailingCountry='Ireland',
        						Email='xyzcontact@notessatest.com');
        mycontact.accountId = savedAccount[0].Id;
        insert mycontact;
        
        //Update to Inactive        
        Account na = savedAccount[0];
        na.Status__c = 'Inactive';
        na.Cease_date__c = date.today();
        System.debug('Calling After Update Trigger...');
        update na;
                                
        //Assert contacts are inactive & reason is set
        List<Contact> savedContact = [Select Contact_status__c, Status_Inactive_Reason__c from Contact where name = 'XYZ Contact'];
        System.assertEquals('Inactive', savedContact[0].Contact_Status__c);
        System.assertEquals('Organisation no longer a client', savedContact[0].Status_Inactive_Reason__c);
        
        //TEST FOR STATUS EQUAL TO 'Sold-written off'
        //Create Active Contacts
        Contact mycontact2 = new Contact (lastName='DEF Contact',Contact_Status__c = 'Active', MailingCountry='Ireland',
        								Email='defcontact@notessatest.com');
        mycontact2.accountId = savedAccount[0].Id;
        insert mycontact2;
        
        //Update to Sold-written off        
        Account na2 = savedAccount[0];
        na2.Status__c = 'Sold-written off';
        na2.Cease_date__c = date.today();
        System.debug('Calling After Update Trigger...');
        update na2;
                        
        //Assert contacts are inactive & reason is set
        List<Contact> savedContact2 = [Select Contact_status__c from Contact where name = 'DEF Contact'];
        System.assertEquals('Inactive', savedContact2[0].Contact_Status__c);
        
        //TEST FOR STATUS EQUAL TO 'Inactive - nonhosted'
        //Create Active Contacts
        Contact mycontact3 = new Contact (lastName='ABC Contact',Contact_Status__c = 'Active', MailingCountry='Ireland',
        						Email='abccontact@notessatest.com');
        mycontact3.accountId = savedAccount[0].Id;
        insert mycontact3;
        
        //Update to Inactive - nonhosted        
        Account na3 = savedAccount[0];
        na3.Status__c = 'Inactive - nonhosted';
        na2.Cease_date__c = date.today();
        System.debug('Calling After Update Trigger...');
        update na3;
                        
        //Assert contacts are inactive & reason is set
        List<Contact> savedContact3 = [Select Contact_status__c from Contact where name = 'ABC Contact'];
        System.assertEquals('Inactive', savedContact3[0].Contact_Status__c);
    }
    
    static testMethod void updateOrgCSM(){

        List<Account> newAccounts = new List<Account>();
        List<Account> updateAccounts = new List<Account>();
        List<Contact> allContacts = new List<Contact>();        
        Integer i,j;
        
        //Create an 3 Active Accounts
        for(i=1; i<=3; i++){
            Account newAccount = new Account (name='Notessa Inc ' + i);
        	newAccount.BillingCountry = 'Ireland';
        	newAccount.Status__c = 'Active';
        	newAccounts.add(newAccount);	
        }
		insert newAccounts; //Insert list of accounts

		//Query back inserted accounts
        Account savedAccount1 = [Select Status__c from Account where name = 'Notessa Inc 1'];
        Account savedAccount2 = [Select Status__c from Account where name = 'Notessa Inc 2'];
        Account savedAccount3 = [Select Status__c from Account where name = 'Notessa Inc 3'];
    	
        //Create Active Contacts for all accounts
        for(j=1; j<=3; j++){
        	Contact mycontact = new Contact (lastName='Contact'+j, Contact_Status__c = 'Active', MailingCountry='Ireland', Email='contact' + j + '@notessatest.com');
        	mycontact.accountId = savedAccount1.Id;
        	allContacts.add(mycontact);
        }
        
        for(j=4; j<=6; j++){
        	Contact mycontact = new Contact (lastName='Contact'+j, Contact_Status__c = 'Active', MailingCountry='Ireland', Email='contact' + j + '@notessatest.com');
        	mycontact.accountId = savedAccount2.Id;
        	allContacts.add(mycontact);
        }
        
        for(j=7; j<=9; j++){
        	Contact mycontact = new Contact (lastName='Contact'+j, Contact_Status__c = 'Active', MailingCountry='Ireland', Email='contact' + j + '@notessatest.com');
        	mycontact.accountId = savedAccount3.Id;
        	allContacts.add(mycontact);
        }

        insert allContacts; //Insert list of contacts
        
        //Update Account Manager value on all accounts         
        savedAccount1.Account_Manager__c = '00520000001dGSW';
        
        //Set one account to Inactive to test that this account's contacts get deactivated
        savedAccount2.Account_Manager__c = '00520000001dGSW';
        savedAccount2.Status__c = 'Inactive';
        savedAccount2.Cease_date__c = date.today();
        
        savedAccount3.Account_Manager__c = '00520000001dGSW';
        
        updateAccounts.add(savedAccount1);
        updateAccounts.add(savedAccount2);
        updateAccounts.add(savedAccount3);

        update updateAccounts; //Update list of accounts
                        
        //Assert that contact from Account 1 whose status hasn't changed (only csm updated) is still active
        Contact savedContact1 = [Select Contact_status__c from Contact where name = 'Contact1'];
        System.assertEquals('Active', savedContact1.Contact_Status__c);
        
        //Assert that contact from Account 2 that was made inactive has an inactive status
        Contact savedContact4 = [Select Contact_status__c from Contact where name = 'Contact4'];
        System.assertEquals('Inactive', savedContact4.Contact_Status__c);

        //Assert that contact from Account 3 whose status hasn't changed (only csm updated) is still active
        Contact savedContact8 = [Select Contact_status__c from Contact where name = 'Contact8'];
        System.assertEquals('Active', savedContact8.Contact_Status__c);
    }
      
    static testMethod void testBulkInsert(){
    	
    	List<Account> accounts = new List<account>();
    	List<Account> accountsToUpdate = new List<Account>();
    	List<Contact> testContacts = new List<Contact>();
    	
    	//Build list of new organisations to insert
    	for (Integer i=0;i<200;i++) {

            Account a = new Account(
                Name = 'Test Organization' + i,
                Status__c = 'Active'
            );
            accounts.add(a);

        }
        Test.startTest();
        insert accounts;
        
        //Query back inserted organisations
        List <Account> savedAccounts = [Select Status__c from Account where name like '%Test Organization%'];
        
        //Create new contacts and assign one to each organisation
        for (Integer j=0;j<50;j++){
       		//Create Active Contacts
        	Contact mycontact = new Contact (lastName='EU Contact' + j, Contact_Status__c = 'Active', MailingCountry='Ireland',
        							Email='eucontact' + j +'@notessatest.com');
        	Contact mycontact2 = new Contact (lastName='US Contact' + j, Contact_Status__c = 'Active', MailingCountry='United States',
        							Email='uscontact' + j +'@notessatest.com');
        	mycontact.accountId = savedAccounts[j].Id;
        	mycontact2.accountId = savedAccounts[j].Id;
        	testContacts.add(mycontact);
        	testContacts.add(mycontact2);
        }
        insert testContacts;
        
        //Loop through all test organisations and update each one's status to be inactive
        for (Account myAcc : savedAccounts){
        	myAcc.Status__c = 'Inactive';
        	myAcc.Cease_date__c = Date.today();
        	accountsToUpdate.add(myAcc);
        }
        update accountsToUpdate;
        Test.stopTest();
        
        //Assert contact statuses of each test organisaiton have been set to inactive
        Contact randomContact = [Select Contact_status__c from Contact where name = 'EU Contact5'];
        System.assertEquals('Inactive', randomContact.Contact_Status__c);
        
        Contact randomContact2 = [Select Contact_status__c from Contact where name = 'US Contact22'];
        System.assertEquals('Inactive', randomContact2.Contact_Status__c);
        
        Contact randomContact3 = [Select Contact_status__c from Contact where name = 'EU Contact49'];
        System.assertEquals('Inactive', randomContact3.Contact_Status__c);
    }
}