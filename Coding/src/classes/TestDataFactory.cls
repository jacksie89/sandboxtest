public with sharing class TestDataFactory {
    
    // ***** TEST USERS *****
    public static User createTestUser(String userType){
        
        String profileSearch = '%' + userType + '%';
        List<User> theUsers = [Select Id, Username From User Where User.Profile.Name LIKE :profileSearch and isActive=true];
        User theUser = theUsers[0];
        
        return theUser;
    }

    public static List<User> createTestUsers(String userType){
        
        String profileSearch = '%' + userType + '%';
        List<User> theUsers = [Select Id, Username From User Where User.Profile.Name LIKE :profileSearch and isActive=true Order By Email];
        
        return theUsers;
    }
    
    public static Lead createTestLeadRoundRobin(Integer j){
        
        //create a lead 
            String leadEmail =  'JSchmoe' + j +'@test1.com';
            String firstName = 'Joe'+ j;
            String lastName = 'Schmoe'+ j;
            String company='random'+ j;
        
            Lead myLead = new Lead (FirstName=firstName, 
                                    LastName=lastName,
                                    leadSource='Web',
                                    Company=company,
                                    Country='Ireland',
                                    email = leadEmail,
                                    Tactics__c = 'SEO',
                                    Solution_Type__c = 'Other');                                        
            return myLead;
    }

    public static void createTestLeadsv2(Integer numLeads, String dupeType, String value, String miscValue, Boolean useAssignment, String leadStatus){
  
        String l_email, l_lastName, l_company, l_timeStampHashed;
        String l_leadSource = 'Web';
        String l_tactics = 'Lead Referral';
        String l_status = leadStatus;
        String[] emailSplit;
        Boolean l_Dedupe;
        Boolean l_freeTrial = true;
        List<Lead> leads = new List<Lead>();
        List<Lead> existingLeads = [select Email, Company, OwnerId, RecordTypeId, Reassign__c FROM Lead Where Email != null And (Status != 'Dead' Or Status != 'Invalid') And OwnerId NOT IN('00G200000017Q51EAE', '00G200000017I6vEAE') Order By CreatedDate ASC];
        Set<String> existingEmailAddresses = new Set<String>();
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        for(Lead l : existingLeads){
            existingEmailAddresses.add(l.Email);
        }
                   
        for(Integer i = 0; i < numLeads; i++){
            //System.debug('Dupe Type is: ' + dupeType);
            if(dupeType == 'email'){
                l_email = value;
                l_lastName = 'DuplicateLead';
                l_timeStampHashed = '22';
                l_company = miscValue + i;
            } else if(dupeType == 'domain' || dupeType == 'publicdomain' || dupeType == 'publicdomain2'){
                l_email = 'samedomain' + i +'@' + value;
                l_lastName = 'DuplicateDomainLead';
                l_company = value;
                l_timeStampHashed = '21';
            } else if(dupeType == 'namecompany'){
                l_email = value;
                l_lastName = miscValue;
                l_timeStampHashed = '13';
            } else if(dupeType == 'namescompanies'){
                l_email = value + i + '@' + value + 'org' + i + '.com';
                l_lastName = miscValue;
                l_timeStampHashed = '13';
            } else if(dupeType == 'company'){
                l_email = 'samecompany' + i +'@' + value;
                l_lastName = 'DuplicateCompanyLead';
                l_timeStampHashed = '15';
            } else if(dupeType == 'none'){
                l_email = value;
                emailSplit = value.split('@');
                l_lastName = emailSplit[0];
                //l_lastName = 'DuplicateCompanyLead';
                l_timeStampHashed = '15';
                l_company = miscValue;
            } else if(dupeType == 'Unique') {
                l_email = value + i + '@' + value + 'org' + i + '.com';
                l_timeStampHashed = '14';
                l_lastName = 'UniqueEmail' + i;
            } else if(dupeType == 'sameContactDomain') {
                l_email = value;
                l_lastName = 'DuplicateContactDomain';
                l_timeStampHashed = '12';
            } else if(dupeType == 'Spam') {
                l_email = value;
                l_timeStampHashed = '11';
                l_lastName = 'SpamLead';
            } else if(dupeType == 'Other') {
                l_email = value + i + '@' + value + 'org' + i + '.com';
                l_timeStampHashed = '14';
                l_lastName = 'OtherEmail' + i;
                l_leadSource = 'Other';
                l_tactics = 'IC Grader';
                l_company = 'Notessa Inc' + i;
            } else {
                l_email = value;
                l_lastName = 'Lead' + i;
                l_timeStampHashed = '1';
            }
            
            if(l_company == null){
                l_company = 'Notessa Inc';
            }
            
            if(dupeType == 'Ignore'){
                l_Dedupe = false;
            } else {
                l_Dedupe = true;
            }
            
            if(miscValue == 'true'){
                l_freeTrial = true;
            } else {
                l_freeTrial = false;
            }
            
            Lead l = new Lead(LastName = l_lastName, FirstName = 'Test', Company = l_company, 
                    Email=l_email, Solution_Type__c='Other', LeadSource=l_leadSource, Tactics__c = l_tactics, Rating='Warm', 
                    Timestamp_Hashed__c = l_timeStampHashed, Dedupe__c = l_Dedupe, Free_Trial__c = l_freeTrial, Status=l_status);           
            
            if(useAssignment){
                l.setOptions(dmlOpts);
            }
            leads.add(l);
    
        }
        System.debug('LEADS TO INSERT: ' + leads);
    
        try{
          insert leads;
          
        } catch (Exception e){
          System.debug('DATA FACTORY: Exception caught for lead insert. Error: ' + e.getMessage());
          //return null;
        }
    }
    
    public static List<Lead> createTestLeads(Integer numLeads, String dupeType, Boolean useAssignment){

        String l_email, l_lastName;
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            
        List<Lead> leads = new List<Lead>();
        List<Lead> existingLeads = [select Email, Company, OwnerId, RecordTypeId, Reassign__c FROM Lead Where Email != null And (Status != 'Dead' Or Status != 'Invalid') And OwnerId NOT IN('00G200000017Q51EAE', '00G200000017I6vEAE') Order By CreatedDate ASC];
        Set<String> existingEmailAddresses = new Set<String>();
        
        for(Lead l : existingLeads){
          existingEmailAddresses.add(l.Email);
        }
                           
        for(Integer i = 0; i < numLeads; i++){
          
              if(dupeType == 'email'){
                l_lastName = 'DuplicateLead';
              } else if(dupeType == 'domain'){
                l_lastName = 'DuplicateDomainLead';
                System.debug('Same domain email is: ' + l_email);
              } else if(dupeType == 'namecompany'){
                l_lastName = 'Lead' + i;
              } else {
                l_lastName = 'DuplicateLead';
              }
                  Lead l = new Lead(LastName = l_lastName, FirstName = 'Test', Company = 'Notessa Inc', 
                      Email='random' + i + '@notessainc' + i + '.com', Solution_Type__c='Other', LeadSource='Web', Rating='Hot');      
              
              if(useAssignment){
                l.setOptions(dmlOpts);
              }
              do {
                leads.add(l);
                existingEmailAddresses.add(l.Email);
              } while (!existingEmailAddresses.contains(l.Email));          
        }
    
        try{
            insert leads;
            return leads;
        } catch (Exception e){
            System.debug('Exception caught for lead insert. Error: ' + e.getMessage());
            return null;
        }        
    }
    
    // **** ORIGINAL CREATE LEADS METHOD *****
    public static List<Lead> createTestLeads(Integer numLeads, Boolean dupeEmail){
    
        String l_email;
        
        List<Lead> leads = new List<Lead>();
        List<Lead> existingLeads = [select Email, Company, OwnerId, RecordTypeId, Reassign__c FROM Lead Where Email != null And (Status != 'Dead' Or Status != 'Invalid') And OwnerId NOT IN('00G200000017Q51EAE', '00G200000017I6vEAE') Order By CreatedDate ASC];
                    
        for(Integer i = 0; i < numLeads; i++){
            if(dupeEmail){
                l_email = existingLeads[0].Email;
            } else {
                l_email = 'tlead' + i + '@notessainc.com';
            }
            Lead l = new Lead(LastName = 'Lead' + i, FirstName = 'Test', Company = 'Notessa Inc', 
                    Email=l_email, Solution_Type__c='Other', LeadSource='Web', Rating='Hot');           
            leads.add(l);
        }
        insert leads;
        return leads;
    }

    public static void createTestBulkLeads(Integer numLeads, Boolean useAssignment){
  
        String l_email, l_company;
        List<Lead> leads = new List<Lead>();

        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                  
        for(Integer i = 0; i < numLeads; i++){
            //System.debug('Dupe Type is: ' + dupeType);
            
            l_email = 'JSchmoeBulk' + i + '@test' + i + '.com';
            l_company = 'Bulk Organisation ' + i;

            
            Lead l = new Lead(LastName = 'Schmoe', FirstName = 'Joe' + i, Company = l_company, Country = 'Ireland',
                    Email=l_email, Solution_Type__c='Internal Communications', LeadSource='Web', Tactics__c = 'SEO', Rating='Warm', 
                    No_Employees__c = '0-500');         
            
            if(useAssignment){
                l.setOptions(dmlOpts);
            }
            leads.add(l);
        }
        
        try{
            insert leads;  
       } catch (Exception e){
            System.debug('DATA FACTORY: Exception caught for lead insert. Error: ' + e.getMessage());
       }
    }

    // ***** TEST ORGANISATIONS *****     
    public static List<Account> createTestAccounts(String accountName, Integer numAccts, Id orgOwner, Id accManager) {
    
        List<Account> accts = new List<Account>();

        for(Integer i = 0; i < numAccts; i++){
        
            Account a = new Account(Name = accountName + i,
                BillingCountry = 'Ireland', Type = 'Prospect', Status__c = 'Prospect',
                OwnerId = orgOwner, Account_Manager__c = accManager);
            accts.add(a);
        }

        insert accts;
        return accts;
    }

    public static List<Account> createTestAccounts(String accountName, String accountType, Integer numAccts, Id orgOwner, Id accManager) {
    
        List<Account> accts = new List<Account>();

        for(Integer i = 0; i < numAccts; i++){
        
            Account a = new Account(Name = accountName + i,
                BillingCountry = 'Ireland', Type = accountType, Status__c = 'Active',
                OwnerId = orgOwner, Account_Manager__c = accManager);
            accts.add(a);
        }

        insert accts;
        return accts;
    }    

    public static List<Account> createTestAccountsNOCSM(String accountName, String accountType, Integer numAccts, Id orgOwner) {
    
        List<Account> accts = new List<Account>();

        for(Integer i = 0; i < numAccts; i++){
        
            Account a = new Account(Name = accountName + i,
                BillingCountry = 'Ireland', Type = accountType, Status__c = 'Active',
                OwnerId = orgOwner);
            accts.add(a);
        }

        insert accts;
        return accts;
    }
    
    // ***** TEST CONTACTS *****
    public static List<Contact> createTestContacts(String contactName, Integer numContacts, Id orgId) {
    
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i = 0; i < numContacts; i++){
        
            Contact myContact = new Contact (lastName=contactName + i, Contact_Status__c = 'Pending',
                MailingCountry='Ireland', Email = 'testcontact'+i+'@testAccountNewsweaver.com', accountId = orgId);
            contacts.add(myContact);
        }

        insert contacts;
        return contacts;
    }

    public static List<Contact> createTestContacts(String contactName, String contactEmail, Integer numContacts, Id orgId) {
        System.debug('DATA FACTORY DEBUG 2...');
        List<Contact> contacts = new List<Contact>();
      
        for(Integer i = 0; i < numContacts; i++){
        
            Contact myContact = new Contact (lastName=contactName + i, Contact_Status__c = 'Pending',
                MailingCountry='Ireland', Email = contactEmail, accountId = orgId);
            contacts.add(myContact);
        }

        insert contacts;
        return contacts;
    }

    public static List<Contact> createTestContacts(List<String> emailAddresses, Integer numContacts, List<Id> orgIds) {
        System.debug('DATA FACTORY DEBUG 3...');
        List<Contact> contacts = new List<Contact>();
      
        for(Integer i = 0; i < numContacts; i++){
        
            if(i< numContacts/2){
                Contact myContact = new Contact (lastName='Contact' + i, firstName = 'Customer', Contact_Status__c = 'Pending',
                    MailingCountry='Ireland', Email = emailAddresses[i], accountId = orgIds[0]);
                contacts.add(myContact);
                System.debug('myContact: ' + myContact);           
            } else {
                Contact myContact = new Contact (lastName='Contact' + i, firstName = 'Prospect', Contact_Status__c = 'Pending',
                    MailingCountry='Ireland', Email = emailAddresses[i], accountId = orgIds[1]);
                contacts.add(myContact);                       
            }        
        }

        insert contacts;
        return contacts;
    }
      
    public static List<Opportunity> createTestOpportunities(String oppName, Integer numOpportunities, Id orgId){
        
        List<Opportunity> opportunities = new List<Opportunity>();
        
        for(Integer i = 0; i < numOpportunities; i++){
            
            Opportunity myOpportunity = new Opportunity(name=oppName + i, AccountId=orgId, StageName='Open',
                                           CloseDate = date.today(), Deal_Type__c = 'Land',Reason_For_Contacting_Us__c = 'Product replacement',
                                           Billing_Method__c = 'Monthly',Billing_Schedule__c='Annual', Solution_Category__c = 'New Account (Existing Customer)',
                                           Communication_Type__c = 'Internal Comms');
            opportunities.add(myOpportunity);
        }
                
        insert opportunities;
        return opportunities;       
    }

    public static OpportunityLineItem createTestOppLineItem(Id oppId, Id pbEntryId, Decimal quantity, Decimal reducedPrice, Decimal uPrice, Decimal termMonths){
        
        OpportunityLineItem myOppLineItem = new OpportunityLineItem(OpportunityID=oppId, PriceBookEntryID=pbEntryId, 
                quantity=quantity, Reduced_Price__c = reducedPrice, UnitPrice=uPrice, Term_months__c = termMonths, Bypass_Flow__c = true);
        insert myOppLineItem;
        return myOppLineItem;
    }
    
    public static List<OpportunityLineItem> createTestOppLineItems(Id oppId, List<Id> pbEntryIds, Integer numOppLineItems, List<Decimal> quantity, List<Decimal> reducedPrices, 
                            List<Decimal> uPrices, List<Decimal> termMonths){
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        for(Integer i = 0; i < numOppLineItems; i++){
            
            OpportunityLineItem myOppLineItem = new OpportunityLineItem(OpportunityID=oppId, PriceBookEntryID=pbEntryIds[i], 
                quantity=quantity[i], Reduced_Price__c = reducedPrices[i], UnitPrice=uPrices[i], Term_months__c = termMonths[i]);
            oppLineItems.add(myOppLineItem);            
        }
        
        insert oppLineItems;
        return oppLineItems;
    }
    
    public static List<Product2> createTestProducts(String productName, Integer numProducts, String chargeType){
        
        List<Product2> products = new List<Product2>();
        
        for(Integer i = 0; i < numProducts; i++){
            
            Product2 theProduct = new Product2(name=productName + i, IsActive=true, Charge_Type__c=chargeType,
                        Description='Info for Product Upgrade: ' + productName, ProductCode='PC_0' + i);
            products.add(theProduct);
        }
                
        insert products;
        return products;        
    }

    public static List<Product2> createTestProducts2(String productName, Integer numProducts, List<String> chargeTypes){
        
        List<Product2> products = new List<Product2>();
        
        for(Integer i = 0; i < numProducts; i++){
            
            Product2 theProduct = new Product2(name=productName + i, IsActive=true, Charge_Type__c=chargeTypes[i],
                        Description='Info for Product: ' + productName, ProductCode='PC_0' + i);
            products.add(theProduct);
        }
                
        insert products;
        return products;        
    }

    public static List<PricebookEntry> createTestPriceBookEntries(List<Product2> products, Integer numPbEntries, Id pricebookId, List<Decimal> uPrices){
        
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        
        for(Integer i = 0; i < numPbEntries; i++){
            
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id=pricebookId, IsActive=true,
                        Product2Id=products[i].Id, UnitPrice= uPrices[i]);
            pbEntries.add(pbEntry);
        }
                
        insert pbEntries;
        return pbEntries;       
    }

    public static Quote createTestQuote(String qName, Id oppId, Id pricebookId){
        //Create a Quote against this Opportunity
        Quote myQuote = new Quote(name=qName, OpportunityId=oppId, Pricebook2Id = pricebookId);
        
        insert myQuote;
        return myQuote;
    }
    
    public static QuoteLineItem createTestQuoteLineItems(Id quoteId, Id pbEntryId, Integer quantity, Decimal uPrice, Decimal reducedPrice, Decimal termMonths){
        
        //Create another Quote Line Item: Insert, One Time, Reduced Price = null, Term =null               
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteID=quoteId,PriceBookEntryID=pbEntryId, 
                quantity=quantity, UnitPrice=uPrice, Reduced_Price__c = reducedPrice, Term_months__c = termMonths);
                
        insert quoteLineItem;
        return quoteLineItem;
    }
}