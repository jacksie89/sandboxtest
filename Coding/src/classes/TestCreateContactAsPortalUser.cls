@isTest
public with sharing class TestCreateContactAsPortalUser{
 
    static testMethod void singleUserInsertTest() {
        
        List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
        List<Contact> myCons = new List<Contact>();
        Id userId = user[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];

        //Test User - Sales Rep IRE - Custom - Sales User
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', UserRoleId = '00E20000001Jm8y', ProfileId = '00e20000001crK7', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
            
        System.runAs(testUser){        
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //create Ordinary Account
            Account myOrdinaryAccount = new Account (name='Ordinary Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');        
            insert myOrdinaryAccount;
    
            //create a Contact that does not need to be set up as a portal user
            Contact myOrdinaryContact = new Contact (lastName='Nonportal', FirstName='First', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='testNonportal@nonportalorg.com', AccountId=myOrdinaryAccount.Id);
            insert myOrdinaryContact;
            ProcessorControl.setNotAlreadyModified();
            
            //create a Contact that does not need to be set up as a portal user
            Contact myOrdinaryContact2 = new Contact (lastName='Nonportal', FirstName='Second', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='testNonportal2@nonportalorg.com', AccountId=myOrdinaryAccount.Id);
            insert myOrdinaryContact2;
            ProcessorControl.setNotAlreadyModified();
            
            //create a Contact that does not need to be set up as a portal user
            Contact myOrdinaryContact3 = new Contact (lastName='Bloggs', FirstName='Joe', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='jbloggs@bloggsinc.com', AccountId=myOrdinaryAccount.Id);
            insert myOrdinaryContact3;
            ProcessorControl.setNotAlreadyModified();
            
            //Insert dummy user
            User myDummyUser = new User(Username = 'testNonportal@nonportalorg.com', LastName = 'User', FirstName = 'Dummy', 
                ContactId = myOrdinaryContact2.Id, Email = 'testNonportal@nonportalorg.com', EmailEncodingKey='UTF-8', Alias='duser', 
                LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                CommunityNickname = 'duser');
            insert myDummyUser;
            
            //Insert dummy user 2
            User myDummyUser2 = new User(Username = 'jbloggs@bloggsinc.com', LastName = 'User2', FirstName = 'Dummy2', 
                ContactId = myOrdinaryContact3.Id, Email = 'jbloggs@bloggsinc.com', EmailEncodingKey='UTF-8', Alias='dusr2', 
                LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                CommunityNickname = 'dusr2');  
            insert myDummyUser2;        
            
            Test.startTest();
            
            //create Contact that needs to be set up as a Portal User       
            Contact myPortalContact = new Contact (lastName='PortalUser', FirstName='First', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testPortal1@customerportalorg.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            insert myPortalContact;
            ProcessorControl.setNotAlreadyModified();
            
            Contact myPortalContact2 = new Contact (lastName='Casey', FirstName='Brian', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testPortal2@customerportalorg2.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
           
            insert myPortalContact2;
            ProcessorControl.setNotAlreadyModified();
            
            Contact myDuplicateOrdinaryContact = new Contact (lastName='Nonportal', FirstName='Duplicate', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testNonportal2@nonportalorg.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);      
            try{
                insert myDuplicateOrdinaryContact;
            } catch (Exception e) {
                System.debug('Error detected when trying to insert duplicate contact! Error: ' + e);
            }
            //Test.startTest();
            
            //Insert Contact with same full name
            Contact sameFullName = new Contact(lastName='PortalUser', FirstName='First', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testPortal1@anyrandomorganisation.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            
            insert sameFullName;
            ProcessorControl.setNotAlreadyModified();
            
            //Insert another Contact with same full name
            Contact sameFullName2 = new Contact(lastName='PortalUser', FirstName='First', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testPortal1@anyrandomorganisation2.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            
            insert sameFullName2;        
            ProcessorControl.setNotAlreadyModified();
            
            //Insert Contact with 3 letter last name
            Contact myShortLastNameContact = new Contact(lastName='Fry', FirstName='Andrew', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testPortal3@customerportalorg2.com', 
                AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            
            insert myShortLastNameContact;
                    
            Test.stopTest();
            
            //Assert that user has not been created from Ordinary Contact
            List<User> users=[select id, ContactId from User where ContactId = :myOrdinaryContact.id];
            System.assertEquals(0, users.size());
    
            //Assert that portal user has been created from Contact
            List<User> ordinaryUsers=[select id, ContactId from User where ContactId = :myOrdinaryContact2.id];
            System.assertEquals(1, ordinaryUsers.size());
                 
            //Assert that portal user has been created from Contact
            List<User> portalUsers=[select id, ContactId from User where ContactId = :myPortalContact.id];
            System.assertEquals(1, portalUsers.size());
            
            //Assert that a second portal user has been created from Contact, passing through alias regeneration
            List<User> portalUsers2=[select id, ContactId from User where ContactId = :myPortalContact2.id];
            System.assertEquals(1, portalUsers2.size());
            
            //Assert that users with same full names are handled okay
            //User sameFullNameUser=[select id, ContactId, CommunityNickname from User where ContactId =: sameFullName.id];
            //System.assertNotEquals('First PortalUser', sameFullNameUser.CommunityNickname); 
    
            //Assert that users with same full names are handled okay
            User sameFullNameUser2=[select id, ContactId, CommunityNickname from User where ContactId =: sameFullName2.id];
            System.assertNotEquals('First PortalUser', sameFullNameUser2.CommunityNickname);
                            
            //Assert that short last name users are handled okay
            List<User> shortLastNameUsers=[select id, ContactId, Alias from User where ContactId =: myShortLastNameContact.id];
            System.assertEquals(1, shortLastNameUsers.size());
        }                  
    }
    
    static testMethod void testAssignments() {

        List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
        List<Contact> myCons = new List<Contact>();
        Id userId = user[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];

        //Test User - Sales Rep IRE - Custom - Sales User
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', UserRoleId = '00E20000001Jm8y', ProfileId = '00e20000001crK7', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
            
        System.runAs(testUser){        
            //create Ordinary Account
            Account myOrdinaryAccount = new Account (name='Ordinary Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');        
            insert myOrdinaryAccount;
    
            //create a Contact that does not need to be set up as a portal user
            Contact myOrdinaryContact = new Contact (lastName='Nonportal', FirstName='First', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='testNonportal@nonportalorg.com', AccountId=myOrdinaryAccount.Id);
            insert myOrdinaryContact;       
            ProcessorControl.setNotAlreadyModified();
            
            Contact myInternalContact = new Contact (lastName='Contact', FirstName='Internal', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testIntContact@customerportalorg.com', 
                AccountId=myOrdinaryAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            myCons.add(myInternalContact);
            
            Contact myExternalContact = new Contact (lastName='Contact', FirstName='External', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testExtContact@customerportalorg2.com', 
                AccountId=myOrdinaryAccount.Id, Notessa_User__c=true, Number_of_External_Accounts__c=1);
            myCons.add(myExternalContact);
            
            Contact myCombinedContact = new Contact(lastName='Contact', FirstName='Exceptional', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='internalandexternaluser@customerportalorg2.com', 
                AccountId=myOrdinaryAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1, Number_of_External_Accounts__c=1);   
            myCons.add(myCombinedContact);

            //Contact myCombinedContactSameName = new Contact(lastName='Contact', FirstName='Exceptional', Contact_Status__c = 'Active',
                //MailingCountry='Ireland', Email='internalandexternaluser@customerportalorg3.com', 
                //AccountId=myOrdinaryAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1, Number_of_External_Accounts__c=1);   
            //myCons.add(myCombinedContactSameName);
                        
            Test.startTest();
            
            insert myCons;        
            ProcessorControl.setNotAlreadyModified();        
            Test.stopTest();
    
            //Assert that portal users have been assigned to permission sets
            
            List<PermissionSetAssignment> permSetAssn = [Select Assignee.Name, PermissionSet.Label From 
                        PermissionSetAssignment Where Assignee.Name = 'Internal Contact' And PermissionSetId 
                        IN (Select Id From PermissionSet Where Label Like '%Community%')];
            System.assertEquals('IC Community', permSetAssn[0].PermissionSet.Label);
                        
            PermissionSetAssignment permSetAssnExt = [Select Assignee.Name, PermissionSet.Label From 
                        PermissionSetAssignment Where Assignee.Name = 'External Contact' And PermissionSetId 
                        IN (Select Id From PermissionSet Where Label Like '%Community%')];
            System.assertEquals('EC Community', permSetAssnExt.PermissionSet.Label);

            List<PermissionSetAssignment> permSetAssnIntExt = [Select Assignee.Name, PermissionSet.Label From 
                        PermissionSetAssignment Where Assignee.Name = 'Exceptional Contact' And PermissionSetId 
                        IN (Select Id From PermissionSet Where Label Like '%Community%')];
            System.assertEquals('IC Community', permSetAssnIntExt[0].PermissionSet.Label);
            System.assertEquals('EC Community', permSetAssnIntExt[1].PermissionSet.Label);
            
            //User savedCombinedUserSameName = [Select Id, Username, CommunityNickname, (Select Id From PermissionSetAssignments)
                    //From User Where Email='internalandexternaluser@customerportalorg3.com' ];
            //System.assertNotEquals('Exceptional Contact', savedCombinedUserSameName.CommunityNickname);
        }
    }
      
    static testMethod void bulkUserInsertTest() {

        List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
        List<Contact> myCons = new List<Contact>();
        List<Contact> myMixedCons = new List<Contact>();
        Id userId = user[0].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
        
        //Test User - Sales Rep IRE - Custom - Sales User
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', UserRoleId = '00E20000001Jm8y', ProfileId = '00e20000001crK7', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
            
        System.runAs(testUser){
        
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
    
            //create Portal Account 2
            Account myPortalAccount2 = new Account (name='Customer Portal Org 2', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount2;
            
            //BULK TESTING
            for(Integer i=0; i<20;i++){
                
                if(i>=10){ //Create ordinary contact and do not create user
                    Contact testCon = new Contact(Email='testcon'+i+'@nonportalorg.com', 
                    FirstName='Ordinary', LastName='Contact'+i, Contact_Status__c = 'Active', 
                    MailingCountry='Ireland', AccountId=myPortalAccount.Id, Notessa_User__c=false);   
                    myCons.add(testCon);
                }else{ //Create portal contact and create portal user
                    Contact testPortalCon = new Contact(Email='testportalcon'+i+'@customerportalorg.com', 
                    FirstName='Test', LastName='PortalUser'+i, Contact_Status__c = 'Active', 
                    MailingCountry='Ireland',AccountId=myPortalAccount.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=2);
                    myCons.add(testPortalCon);
                }       
            }
            Test.startTest();
            insert myCons;
            ProcessorControl.setNotAlreadyModified();
            //Insert 2 Contacts who have same aliases as existing users and 2 Contacts with unique alias
            Contact myExtraPortalContact1 = new Contact (lastName='Bridges', FirstName='Billy', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testExtraPortal1@customerportalorg.com', 
                AccountId=myPortalAccount2.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            myMixedCons.add(myExtraPortalContact1);
            
            Contact myExtraPortalContact2 = new Contact (lastName='Halpin', FirstName='Alan', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testExtraPortal2@customerportalorg.com', 
                AccountId=myPortalAccount2.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            myMixedCons.add(myExtraPortalContact2);
            
            Contact myExtraPortalContact3 = new Contact (lastName='Xavier', FirstName='Charles', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testExtraPortal3@customerportalorg.com', 
                AccountId=myPortalAccount2.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            myMixedCons.add(myExtraPortalContact3);
             
            Contact myExtraPortalContact4 = new Contact (lastName='Bridges', FirstName='Bob', Contact_Status__c = 'Active',
                MailingCountry='Ireland', Email='testExtraPortal4@customerportalorg.com', 
                AccountId=myPortalAccount2.Id, Notessa_User__c=true, Number_of_Internal_Accounts__c=1);
            myMixedCons.add(myExtraPortalContact4);
                    
            insert myMixedCons;
            
            Test.stopTest();
            
            List<Contact> newCons = [select id from Contact where AccountId = :myPortalAccount.id];
            //Assert that user has not been created from Contact
            List<User> bulkUsers=[select id, ContactId from User where ContactId IN :newCons];
            System.assertEquals(10, bulkUsers.size());
    
            List<Contact> mixedCons = [select id from Contact where AccountId = :myPortalAccount2.id];        
            //Assert that users with existing and unique alias have been created as users in the one tranaction
            List<User> bulkUsers2=[select id, ContactId, CommunityNickname, (Select Id From PermissionSetAssignments)
                    from User where ContactId IN :mixedCons];
            System.assertEquals(4, bulkUsers2.size());
            //System.assertNotEquals('Bob Bridges', bulkUsers2[3].CommunityNickname);
            System.assertNotEquals(0, bulkUsers2[3].PermissionSetAssignments.size());
        }       
    }
    
     static testMethod void singleUserUpdateTest() {

        //Test User - Sales Rep IRE - Custom - Sales User
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', ProfileId = '00e20000001FCk9', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
        
            List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
            List<Contact> myCons = new List<Contact>();
            Id userId = user[0].Id;
            Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
            
        System.runAs(testUser){    
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //create Ordinary Account
            Account myOrdinaryAccount = new Account (name='Ordinary Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');        
            insert myOrdinaryAccount;
            
            //create a Contact that does not need to be set up as a portal user
            Contact myOrdinaryContact = new Contact (lastName='Nonportal', FirstName='First', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='testNonportal@nonportalorg.com', AccountId=myOrdinaryAccount.Id);
            
            insert myOrdinaryContact;
            ProcessorControl.setNotAlreadyModified();
            
            //create a Contact that does need to be set up as a portal user
            Contact myPortalContact = new Contact (lastName='Black', FirstName='Jack', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='jblack@schoolofrock.com', AccountId=myPortalAccount.Id,
                    Number_of_Internal_Accounts__c=1);
            Test.startTest();
            insert myPortalContact;
            ProcessorControl.setNotAlreadyModified();
            
            //create a Contact with the same full name that does not need to be set up as a portal user
            Contact myPortalContact2 = new Contact (lastName='Black', FirstName='Jack', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='jblack@anotherschoolofrock.com', AccountId=myPortalAccount.Id);
            insert myPortalContact2;
            ProcessorControl.setNotAlreadyModified();
            
            //Update second portal contact so that a user will be created once the contact is updated
            myPortalContact2.Number_of_Internal_Accounts__c=1;     
            
            update myPortalContact2;
            
            ProcessorControl.setNotAlreadyModified();
            
            //create a third Contact with the same full name that does need to be set up as a portal user
            Contact myPortalContact3 = new Contact (lastName='Black', FirstName='Jack', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='jblack@athirdschoolofrock.com', AccountId=myPortalAccount.Id, 
                    Number_of_External_Accounts__c=3);
            insert myPortalContact3;
            ProcessorControl.setNotAlreadyModified();
            
            // Update third contact's certification status to 'registered'
            myPortalContact3.Certification_Programme__c = 'Registered';
            update myPortalContact3;
            Test.stopTest();
            
            //Assert that user has been created from first insert of portal user contact
            List<User> portalUser1 = [select id from User Where ContactId =:myPortalContact.Id];
            System.assertEquals(1, portalUser1.size());
            
            //Assert that user has been created from the update of the existing portal user Contact 2
            List<User> portalUsers=[select id, ContactId, FirstName, CommunityNickname from User where CommunityNickname Like '%Jack Black%'];
            System.assertEquals(3, portalUsers.size());
            System.assertNotEquals('Jack Black', portalUsers[1].CommunityNickname);               
            
            //Assert that third user created with same full name has had nickname regenerated
            //User portalUser3 = [select id, CommunityNickname from User Where ContactId =:myPortalContact3.Id]; 
            //System.assertNotEquals('Jack Black', portalUser3.CommunityNickname);
                        
            // Assert that contact's user's Registered flag has been updated
            List<User> updatedPortalUser3 = [select id, CommunityNickname, Registered__c from User Where ContactId =:myPortalContact3.Id];
            System.assertNotEquals('Jack Black', updatedPortalUser3[0].CommunityNickname);
            System.assert(updatedPortalUser3[0].Registered__c);
        }               
    }

    static testMethod void singleUserDeactivateTest() {
        //Contact myPortalContact = [Select FirstName, LastName From Contact Where LastName Like '%Casey%'];
        //Test User - Sales Rep IRE - Custom - Sales User
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', ProfileId = '00e20000001FCk9', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
        
            List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
            List<Contact> myCons = new List<Contact>();
            Id userId = user[0].Id;
            Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
            
        System.runAs(testUser){    
            
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //create a Contact
            Contact myContact = new Contact (lastName='One', FirstName='Contact', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='cone@customerportalorg.com', AccountId=myPortalAccount.Id);      
            insert myContact;
            
            User myPortalUser = new User(Username = 'cone@customerportalorg.com', LastName = 'User', FirstName = 'Portal',  
                ContactId = myContact.Id, Email = 'cone@customerportalorg.com', EmailEncodingKey='UTF-8', Alias='puser',  
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'Portal User', UserPreferencesHideS1BrowserUI = true, 
                UserPermissionsSFContentUser = false, UserPreferencesContentNoEmail = true, 
                UserPreferencesContentEmailAsAndWhen = true);           
            Database.insert(myPortalUser);
            
            System.debug('Portal User Enabled: ' + myPortalUser.isPortalEnabled);
            
            System.assertEquals(myPortalUser.ContactId, myContact.Id);
            
            myContact.Contact_Status__c = 'Inactive';
            
            Test.startTest();
            update myContact;
            Test.stopTest();
            
            User myDeactivatedUser = [Select isActive, Username From User Where ContactId =: myContact.Id];
            //System.assertNotEquals(true, myDeactivatedUser.isActive);
            //System.assertEquals('_cone@customerportalorg.com', myDeactivatedUser.Username);
            //System.debug('Username of deactivated user: ' + myDeactivatedUser.Username);
        }               
    }
  
    static testMethod void bulkContactsUpdateTest() {
            
        List<Contact> myCons = new List<Contact>();
        List<Contact> updateCons = new List<Contact>();
        List<Contact> consToUpdate = new List<Contact>();
        List<User> newUsers = new List<User>();
        Integer j;
        
        List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014          
        Id userId = user[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];           
        
        //Test User - Sys Admin Profile
        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', ProfileId = '00e20000001FCk9', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'ISO-8859-1',LanguageLocaleKey = 'en_US');
        
        System.runAs(testUser){

            //create Ordinary Account 
            Account myOrdinaryAccount = new Account (name='My Ordinary Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myOrdinaryAccount;
            
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //BULK INSERT CONTACTS
            for(Integer i=0; i<20;i++){ 
                if(i<10){
                    Contact testCon = new Contact(Email='testcon'+i+'@nonportalorg.com', 
                        FirstName='Ordinary', LastName='Contact'+i, Contact_Status__c = 'Active', 
                        MailingCountry='Ireland', AccountId=myOrdinaryAccount.Id);  
                    myCons.add(testCon);
                } else {
                    Contact testCon = new Contact(Email='testcon'+i+'@nonportalorg.com', 
                        FirstName='Portal', LastName='Contact'+i, Contact_Status__c = 'Active', 
                        MailingCountry='Ireland', AccountId=myPortalAccount.Id);  
                    myCons.add(testCon); 
                }                     
            }
            
            insert myCons;
            ProcessorControl.setNotAlreadyModified();
            
            List<Contact> newUserCons = [select id, Email, FirstName, LastName from Contact where AccountId = :myOrdinaryAccount.id];
            //BULK INSERT USERS
            for(Integer k=0; k<10;k++){ 

                User myPortalUser = new User(Username = newUserCons[k].Email, LastName = newUserCons[k].LastName, FirstName = newUserCons[k].FirstName,  
                    ContactId = newUserCons[k].Id, Email = newUserCons[k].Email, EmailEncodingKey='UTF-8', Alias='ocont',  
                    LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='Europe/London',
                    CommunityNickname = newUserCons[k].Firstname + ' ' + newUserCons[k].LastName + k, UserPreferencesHideS1BrowserUI = true, 
                    UserPermissionsSFContentUser = false, UserPreferencesContentNoEmail = true, 
                    UserPreferencesContentEmailAsAndWhen = true);
                newUsers.add(myPortalUser);                  
            }
            Database.insert(newUsers);
       
            updateCons = [select id, Email, FirstName, LastName from Contact where AccountId = :myPortalAccount.id OR AccountId =: myOrdinaryAccount.Id];
            //BULK UPDATE HALF THE CONTACTS
            j=0;
            
            for(Contact c : updateCons){        
                //Update ordinary contacts so that users will be created from the update  
                c.Number_of_External_Accounts__c=3;
                c.Certification_Programme__c = 'Registered';
                consToUpdate.add(c);        
            }
            Test.startTest();       
            update consToUpdate;      
            ProcessorControl.setNotAlreadyModified();
            Test.stopTest();
            
            //Assert that portal users have been created
            List<User> bulkUsers=[select id, ContactId, Username, FirstName, LastName, Registered__c from User where ContactId IN :newUserCons];
            System.assertEquals(10, bulkUsers.size());
                    
            List<Contact> updatedContacts = [select id from Contact where AccountId = :myPortalAccount.id];
            
            //Assert that 10 portal users have been created from updating of these Contacts
            List<User> bulkUsers2=[select id, ContactId, LastName, CommunityNickname from User where ContactId IN :updatedContacts];
            System.assertEquals(10, bulkUsers2.size());
            
            //Randomly assert that a sample of these users' last names have been updated!
            System.assertEquals('Portal Contact10', bulkUsers2[0].CommunityNickname);
            System.assertEquals('Portal Contact16', bulkUsers2[6].CommunityNickname);
            
            //Assert that existing users for contacts were updated
            List<Contact> existingUserCons = [select id from Contact where AccountId = :myOrdinaryAccount.id];

            List<User> existingUsersUpdated = [Select Registered__c From User Where ContactId in :existingUserCons];
            //System.assert(existingUsersUpdated[0].Registered__c);
            //System.assert(existingUsersUpdated[5].Registered__c);           
        }
    }   
    
    static testMethod void setContactCertificationToRegistered() {

        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', ProfileId = '00e20000001FCk9', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
        
            List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
            List<Contact> myCons = new List<Contact>();
            Id userId = user[0].Id;
            Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
            
        System.runAs(testUser){    
            
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //create a Contact
            Contact myContact = new Contact (lastName='One', FirstName='Contact', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='cone@customerportalorg.com', AccountId=myPortalAccount.Id, 
                    Number_of_External_Accounts__c=3);      
            insert myContact;
            ProcessorControl.setNotAlreadyModified();
            
            User myPortalUser = new User(Username = 'cone@customerportalorg.com', LastName = 'User', FirstName = 'Portal',  
                ContactId = myContact.Id, Email = 'cone@customerportalorg.com', EmailEncodingKey='UTF-8', Alias='puser',  
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'Portal User', UserPreferencesHideS1BrowserUI = true, 
                UserPermissionsSFContentUser = false, UserPreferencesContentNoEmail = true, 
                UserPreferencesContentEmailAsAndWhen = true);           
            Database.insert(myPortalUser);
            
            System.assertEquals(myPortalUser.ContactId, myContact.Id);

            List<Contact> existingUserCons = [select Id, Certification_Programme__c from Contact where Id = :myContact.id];         
            existingUserCons[0].Certification_Programme__c = 'Registered';
            
            Test.startTest();
            update existingUserCons[0];
            Test.stopTest();
            
            User myUpdatedUser = [Select Registered__c From User Where ContactId =: existingUserCons[0].Id];
            System.assert(myUpdatedUser.Registered__c);
        }               
    }

    static testMethod void setContactCertificationToNone() {

        User testUser = new User(Username= 'tester2200@nwtest2200.com',
            Email = 'tester2200@nwtest2200.com', Lastname = 'Tester2200', Firstname = 'Newsweaver',
            Alias = 'ntest', ProfileId = '00e20000001FCk9', 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US');
        
            List<User> user = [Select Id from User Where Alias='acron']; //Change from Mariam to Ann Cronin 12/09/2014
            List<Contact> myCons = new List<Contact>();
            Id userId = user[0].Id;
            Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
            
        System.runAs(testUser){    
            
            //create Portal Account 
            Account myPortalAccount = new Account (name='Customer Portal Org', OwnerId=userId, 
                                BillingCountry = 'Ireland', No_Employees__c = '0-500', Industry = 'IT', Type = '', Status__c = 'Active');
            insert myPortalAccount;
            
            //create a Contact
            Contact myContact = new Contact (lastName='One', FirstName='Contact', Contact_Status__c = 'Active',
                    MailingCountry='Ireland', Email='cone@customerportalorg.com', AccountId=myPortalAccount.Id, 
                    Certification_Programme__c = 'Registered', Number_of_External_Accounts__c=3);      
            insert myContact;
            ProcessorControl.setNotAlreadyModified();
            
            User myPortalUser = new User(Username = 'cone@customerportalorg.com', LastName = 'User', FirstName = 'Portal',  
                ContactId = myContact.Id, Email = 'cone@customerportalorg.com', EmailEncodingKey='UTF-8', Alias='puser',  
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'Portal User', UserPreferencesHideS1BrowserUI = true, 
                UserPermissionsSFContentUser = false, UserPreferencesContentNoEmail = true, 
                UserPreferencesContentEmailAsAndWhen = true);           
            Database.insert(myPortalUser);
            
            System.assertEquals(myPortalUser.ContactId, myContact.Id);
            System.assertNotEquals(myPortalUser.Registered__c, true);
            
            List<Contact> existingUserCons = [select Id, Certification_Programme__c from Contact where Id = :myContact.id];         
            existingUserCons[0].Certification_Programme__c = '';
            
            Test.startTest();
            update existingUserCons[0];
            Test.stopTest();
            
            User myUpdatedUser = [Select Registered__c From User Where ContactId =: existingUserCons[0].Id];
            System.assertNotEquals(myUpdatedUser.Registered__c, true);
        }               
    }
}