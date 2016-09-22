@isTest
private class TestRoundRobinAssignmentTrigger {

    public static testMethod void testUKRoundRobinAssignment() {       
            
        final List<GroupMember> AllSalesEUmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.SalesRREU[0].Id]; // Sales Round Robin EU members
        final Set<ID> userIdsSalesEUMembers = new Set<ID>();        
        Integer j = 0;
        List<Lead> leadsToUpdate = new List<Lead>();
         
        for(GroupMember memberSalesEU : AllSalesEUmembers){
            userIdsSalesEUMembers.add(memberSalesEU.UserOrGroupId); // add each user id to the set
        }
        
        LIST<User> rrUsersSalesEU = [select id, received_RR_Lead__c from user where id in :userIdsSalesEUMembers]; // //Build lists of UK and US users
        
        for (User u : rrUsersSalesEU){
            u.received_RR_Lead__c = false; // set user's lead flag to false (make them eligible to receive a new lead)
            update u;
        }

        TestDataFactory.createTestBulkLeads(AllSalesEUmembers.size(), True);
        RRHelper.setNotAlreadyInserted();
        
        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.SalesRREU[0].Id; //Update Owner back to Sales RR EU
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        //Re-query the updated leads
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        //Assert that lead has been moved out of RR Queue to Sales person
        System.assertNotEquals(sampleLeads[0].OwnerId, RRHelper.SalesRREU[0].Id);     
    }

    public static testMethod void testSingleEU0to5KAssignment() {
        
        //Pull out a list of EU Leads 0-5K members      
        final List<GroupMember> AllEU0to5Kmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.EU0to5K[0].Id];        
        final Set<ID> userIdsEU0to5KMembers = new Set<ID>();        
        Integer numberOfMembers = AllEU0to5Kmembers.size();
        Integer j = 0;      
        List<Lead> leadsToUpdate = new List<Lead>();
               
        for(GroupMember member : AllEU0to5Kmembers){
            userIdsEU0to5KMembers.add(member.UserOrGroupId); // add each user id to the set
        }
        
        LIST<User> usersEU0to5K = [select id, received_RR_Lead__c from user where id in :userIdsEU0to5KMembers];
        
        for (User u : usersEU0to5K){
            u.received_RR_Lead__c = false; // set their received lead flag to false (make them eligible to receive a new lead)
            update u;
        }

        TestDataFactory.createTestBulkLeads(AllEU0to5Kmembers.size(), False);
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.EU0to5K[0].Id; //Update Owner back to EU0to5K
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        // List<Lead> updatedLeads = [SELECT OwnerId FROM Lead WHERE email Like '%test1%'];
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);       
            
        }

        //Assert the assigned Owner is not the EULeads0to5K Queue 
        System.assertNotEquals(RRHelper.EU0to5K[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.EU0to5K[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the EULead0to5k Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.EU0to5K[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(2, members.size()); 
    }

    public static testMethod void testSingleEU30KplusAssignment() {
        
        //Pull out a list of EU Leads 0-5K members      
        final List<GroupMember> AllEU30Kplusmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.EU30K[0].Id];
        final Set<ID> userIdsEU30KplusMembers = new Set<ID>();          
        List<Lead> leadsToUpdate = new List<Lead>();
        Integer numberOfMembers = AllEU30Kplusmembers.size();
        Integer j = 0;      
        
        for(GroupMember member : AllEU30Kplusmembers){
            userIdsEU30KplusMembers.add(member.UserOrGroupId);
        }

        LIST<User> usersEU30K = [select id, received_RR_Lead__c from user where id in :userIdsEU30KplusMembers];
        
        //Loop through Sales EU users and set their received lead flag to false (make them eligible to receive a new lead)
        for (User u : usersEU30K){
            u.received_RR_Lead__c = false;
            update u;
        }

        TestDataFactory.createTestBulkLeads(AllEU30Kplusmembers.size(), False);
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.EU30K[0].Id; //Update Owner back to EU0to5K
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        // List<Lead> updatedLeads = [SELECT OwnerId FROM Lead WHERE email Like '%test1%'];
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);         
        }
        
        //Assert the assigned Owner is not the AllEU30Kplusmembers Queue 
        System.assertNotEquals(RRHelper.EU30K[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.EU30K[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the AllEU30Kplusmembers Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.EU30K[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(2, members.size()); 
    }

    public static testMethod void testUSRoundRobinAssignment() {
        
        final List<GroupMember> AllSalesUSmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.SalesRRUS[0].Id];
        final Set<ID> userIdsSalesUSMembers = new Set<ID>();
        Integer numberOfUSMembers = AllSalesUSmembers.size();
        Integer i = 0;
        List<Lead> leadsToUpdate = new List<Lead>();
            
        //Loop through UK group members and add each user id to the set
        for(GroupMember memberSalesUS : AllSalesUSmembers){
            userIdsSalesUSMembers.add(memberSalesUS.UserOrGroupId);
        }
      
        //Build lists of US users
        LIST<User> rrUsersSalesUS = [select id, received_RR_Lead__c from user where id in :userIdsSalesUSMembers];
        
        //Loop through US users and set their received lead flag to false (make them eligible to receive a new lead)
        for (User u : rrUsersSalesUS){
            u.received_RR_Lead__c = false;
            update u;
        }
        
        TestDataFactory.createTestBulkLeads(AllSalesUSmembers.size(), False);
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.SalesRRUS[0].Id; //Update Owner back to EU0to5K
            leadsToUpdate.add(l);
        }
        
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        // List<Lead> updatedLeads = [SELECT OwnerId FROM Lead WHERE email Like '%test1%'];
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);       
        }
        
        //Assert the assigned Owner is not the SalesRRUS[0] Queue 
        System.assertNotEquals(RRHelper.SalesRRUS[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.SalesRRUS[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the SalesRRUS[0] Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.SalesRRUS[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(4, members.size());                  
    }

    public static testMethod void testEUMktRoundRobin() {       
        
        final List<GroupMember> AllMktEUmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRREU[0].Id];
        final Set<ID> userIdsMktEUMembers = new Set<ID>();        
        Integer numberOfUKMembers = AllMktEUmembers.size();
        Integer j = 0;
        List<Lead> leadsToUpdate = new List<Lead>();
        //Loop through Marketing Round Robin EU group members and add each user id to the set
        for(GroupMember memberMktEU : AllMktEUmembers){
            userIdsMktEUMembers.add(memberMktEU.UserOrGroupId);
        }
        
        //Build lists of UK and US users
        LIST<User> rrUsersMktEU = [select id, received_RR_Lead__c from user where id in :userIdsMktEUMembers];
        
        //Loop through Sales EU users and set their received lead flag to false (make them eligible to receive a new lead)
        for (User u : rrUsersMktEU){
            u.received_RR_Lead__c = false;
            update u;
        }
        
        TestDataFactory.createTestBulkLeads(AllMktEUmembers.size(), False);
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.MktRREU[0].Id; //Update Owner back to EU0to5K
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        // List<Lead> updatedLeads = [SELECT OwnerId FROM Lead WHERE email Like '%test1%'];
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);                 
        }
        
        //Assert the assigned Owner is not the SalesRRUS[0] Queue 
        System.assertNotEquals(RRHelper.MktRREU[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.MktRREU[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the SalesRRUS[0] Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRREU[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(2, members.size());         
    }

    public static testMethod void testUSMktRoundRobin() {       
              
        final List<GroupMember> AllMktUSmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRRUS[0].Id];
        final Set<ID> userIdsMktUSMembers = new Set<ID>();        
        Integer numberOfUKMembers = AllMktUSmembers.size();
        Integer j = 0;
        List<Lead> leadsToUpdate = new List<Lead>();
        
        //Loop through Marketing Round Robin EU group members and add each user id to the set
        for(GroupMember memberMktUS : AllMktUSmembers){
            userIdsMktUSMembers.add(memberMktUS.UserOrGroupId);
        }
        
        //Build lists of UK and US users
        LIST<User> rrUsersMktUS = [select id, received_RR_Lead__c from user where id in :userIdsMktUSMembers];
        
        //Loop through Sales EU users and set their received lead flag to false (make them eligible to receive a new lead)
        for (User u : rrUsersMktUS){
            u.received_RR_Lead__c = false;
            update u;
        }

        TestDataFactory.createTestBulkLeads(AllMktUSmembers.size(), False);
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.MktRRUS[0].Id; //Update Owner back to EU0to5K
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();
        
        // List<Lead> updatedLeads = [SELECT OwnerId FROM Lead WHERE email Like '%test1%'];
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);                 
        }
        
        //Assert the assigned Owner is not the MktRRUS[0] Queue 
        System.assertNotEquals(RRHelper.MktRRUS[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.MktRRUS[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the MktRRUS[0] Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRRUS[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(4, members.size());         
    }    

    public static testMethod void testUSMktRoundRobinHot() {       
      
        final List<GroupMember> AllMktUSHotmembers = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRRUSHot[0].Id];
        final Set<ID> userIdsMktUSHotMembers = new Set<ID>();        
        
        Integer numberOfUKMembers = AllMktUSHotmembers.size();
        Integer j = 0;
        List<Lead> leadsToUpdate = new List<Lead>();
        
        //Loop through Sales Round Robin EU group members and add each user id to the set
        for(GroupMember memberMktUSHot : AllMktUSHotmembers){
            userIdsMktUSHotMembers.add(memberMktUSHot.UserOrGroupId);
        }
        
        //Build lists of UK and US users
        LIST<User> rrUsersMktUSHot = [select id, received_RR_Lead__c from user where id in :userIdsMktUSHotMembers];
        
        //Loop through Sales EU users and set their received lead flag to false (make them eligible to receive a new lead)
        for (User u : rrUsersMktUSHot){
            u.received_RR_Lead__c = false;
            update u;
        }
      
        TestDataFactory.createTestBulkLeads(AllMktUSHotmembers.size(), False);
        RRHelper.setNotAlreadyInserted();
        
        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = RRHelper.MktRRUSHot[0].Id; //Update Owner back to MktRRUSHot queue
            leadsToUpdate.add(l);
        }
        Test.startTest();
        update leadsToUpdate; 
        Test.stopTest();

        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk%'];    

        List<Id> userIds = new List<Id>();
        for(Lead l : sampleLeads){
            userIds.add(l.OwnerId);       
            
        }      

        //Assert the assigned Owner is not the MktRRUS[0] Queue 
        System.assertNotEquals(RRHelper.MktRRUSHot[0].Id, userIds[0]);
        System.assertNotEquals(RRHelper.MktRRUSHot[0].Id, userIds[1]);
             
        //Assert the newly assigned Owner is a Member of the MktRRUS[0] Queue
        final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid =: RRHelper.MktRRUSHot[0].Id and UserOrGroupId IN :userIds];
        System.assertEquals(3, members.size());      
    }

    public static testMethod void testBulkUKRoundRobinAssignment() {
          
        Profile p = [select id from profile where name='Custom - Marketing User'];
        // create a user to run the test as
        User u = new User(alias = 'test123', email='brianctest77@simplynotessatesting.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='brianctest77@simplynotessatesting.com');

        insert u;
        List<Lead> leads = new List<Lead>();
        List<Lead> leadsToUpdate = new List<Lead>();
                  
        for (Integer i=0;i<105;i++) {    
            //create 105 lead 
            String leadEmail =  'JSchmoeBulk@test'+i+'.com';
            String firstName = 'Joe'+i;
            String lastName = 'Schmoe'+i;
            String company='random'+i;
            Lead myLead = new Lead (FirstName=firstName, 
                                             LastName=lastName,
                                             Company=company,
                                             leadSource='Web',
                                             Country='Ireland',
                                             Industry = 'Advertising',
                                             Department__c = 'Account Management',
                                             No_Employees__c = '0-500',
                                             email = leadEmail,
                                             //ownerId = '00G20000001d62uEAA',
                                             Tactics__c = 'SEO',
                                             Solution_Type__c = 'Other');    
            leads.add(myLead);
        }
        Test.startTest();
        System.runAs(u) {
            insert leads;
        }
        Test.stopTest();
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk@test%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = '00G20000001d62uEAA'; //Update Owner back to Sales RR EU
            leadsToUpdate.add(l);
        }
        update leadsToUpdate; 
        
        //Re-query the updated leads
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk@test%'];
        //Assert that lead has been moved out of RR Queue to Sales person
        System.assertNotEquals(sampleLeads[5].OwnerId, '00G20000001d62uEAA');               
    }
  
    public static testMethod void testBulkUSRoundRobinAssignment() {
          
        Profile p = [select id from profile where name='Custom - Marketing User'];
        // create a user to run the test as
        User u = new User(alias = 'test123', email='brianctest77@simplynotessatesting.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='brianctest77@simplynotessatesting.com');

        insert u;
        List<Lead> leads = new List<Lead>();          
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Integer i=0;i<105;i++) {    
            //create 105 lead 
            String leadEmail =  'JSchmoeBulk@test'+i+'.com';
            String firstName = 'Joe'+i;
            String lastName = 'Schmoe'+i;
            String company='random'+i;
            Lead myLead = new Lead (FirstName=firstName, 
                                             LastName=lastName,
                                             Company=company,
                                             leadSource='Web',
                                             Country='Ireland',
                                             Industry = 'Advertising',
                                             Department__c = 'Account Management',
                                             No_Employees__c = '0-500',
                                             email = leadEmail,
                                             ownerId = '00Gw00000018RTl',
                                             Tactics__c = 'SEO',
                                             Solution_Type__c = 'Other');    
            leads.add(myLead);
        }
        Test.startTest();
        System.runAs(u) {
            insert leads;
        }
        Test.stopTest();
        RRHelper.setNotAlreadyInserted();

        List<Lead> sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk@test%'];
        
        for(Lead l : sampleLeads){
            l.OwnerId = '00Gw00000018RTl'; //Update Owner back to Sales RR EU
            leadsToUpdate.add(l);
        }
        update leadsToUpdate; 
        
        //Re-query the updated leads
        sampleLeads = [Select OwnerId from Lead Where email like '%JSchmoeBulk@test%'];
        //Assert that lead has been moved out of RR Queue to Sales person
        System.assertNotEquals(sampleLeads[5].OwnerId, '00Gw00000018RTl'); 
        System.assertNotEquals(sampleLeads[15].OwnerId, '00Gw00000018RTl');
        System.assertNotEquals(sampleLeads[45].OwnerId, '00Gw00000018RTl');     
    } 
}