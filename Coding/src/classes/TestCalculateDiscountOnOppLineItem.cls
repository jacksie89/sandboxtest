@isTest
private class TestCalculateDiscountOnOppLineItem {

    static testMethod void myUnitTestOneTime() {
        
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
        
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;       
        Id pricebookId = Test.getStandardPricebookId(); //get standard pricebook
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
        Contact mycontact = testContacts[0];
 
        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Test Product Entry ', 3, 'One Time Only');
        List<Decimal> uPrices = new List<Decimal>{50, 100, 1500};
                
        // create the pricebookentries
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 3, pricebookId, uPrices);
 
         // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
      
        // create an opportunity line item: Insert, One Time, Reduced Price < List Price, Term !=null
        OpportunityLineItem myOppLineItem = TestDataFactory.createTestOppLineItem(testOpportunities[0].id, pBookEntries[0].Id, 3.0, 35.00, 50.00, 7.5);        
        
        // Query back the line item
        OpportunityLineItem mySavedLineItem = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
        
        Decimal myTotalPrice = mySavedLineItem.TotalPrice/mySavedLineItem.Quantity;        
        System.assertEquals(myTotalPrice, mySavedLineItem.Reduced_Price__c);
        System.assertEquals(30.000000, mySavedLineItem.Discount);
		
       
        //Test with another amount and with a different term value: Update,  One Time, Reduced Price < List Price, Term !=null
        myOppLineItem.Reduced_Price__c = 42;
        myOppLineItem.Term_months__c = 5;
        myOppLineItem.Quantity = -1;
        update myOppLineItem;
                       
        //get the opportunity line item again
        OpportunityLineItem mySavedLineItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
                
        myTotalPrice = mySavedLineItem2.TotalPrice/mySavedLineItem2.Quantity;
        System.assertEquals(myTotalPrice, mySavedLineItem2.Reduced_Price__c);
        System.assertEquals(16.000000, mySavedLineItem2.Discount);
        
        //Set the reduced price to greater than the unit price: Update, One Time, Reduced Price > List Price, Term !=null
        myOppLineItem.Reduced_Price__c = 120;
        myOppLineItem.Term_months__c = 12;
        myOppLineItem.Quantity = 1;
        update myOppLineItem;
        
        mySavedLineItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
        
        System.assertEquals(120, mySavedLineItem2.Reduced_Price__c);
        System.assertEquals(00.000000, mySavedLineItem2.Discount);
              
        //Create a Quote against this Opportunity        
        Quote myQuote = TestDataFactory.createTestQuote('XYZ Quote123', testOpportunities[0].id, pricebookId);
                     
        //Create a Quote Line Item:  Insert, One Time, Reduced Price < List Price, Term =null                  
        QuoteLineItem myQuoteLineItem = TestDataFactory.createTestQuoteLineItems(myQuote.Id, pBookEntries[1].Id, 3, 100.00, 80.00, null);
        
        QuoteLineItem mySavedQItem = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem.Id];
              
        //Check that the discount field is set correctly on Quote Line Item
        System.assertEquals(20.000000, mySavedQItem.Discount);
  
        //Update the Quote Line Item with reduced price equal to null: Update, One Time, Reduced Price = null, Term =null            
        myQuoteLineItem.Reduced_Price__c = null;
        update myQuoteLineItem;
        
        QuoteLineItem mySavedQItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem.Id];
               
        System.assertEquals(00.000000, mySavedQItem2.Discount); //Check that the discount field is Zero      
        System.assertEquals(100, mySavedQItem2.Reduced_Price__c); //Check that the reduced price is the same as the unit price
        
        //Create another Quote Line Item: Insert, One Time, Reduced Price = null, Term =null               
        QuoteLineItem myQuoteLineItem2 = TestDataFactory.createTestQuoteLineItems(myQuote.Id, pBookEntries[2].Id, 3, 1500.00, null, null);
        
        QuoteLineItem mySavedQItem3 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem2.Id];
              
        //Check that the discount field is set correctly on Quote Line Item
        System.assertEquals(0.000000, mySavedQItem3.Discount);
       
        //Update the Quote Line Item with reduced price greater than list price and term not null: Update, One Time, Reduced Price > List Price, Term !=null               
        myQuoteLineItem2.Reduced_Price__c = 1700;
        myQuoteLineItem2.Term_months__c = 8;
        update myQuoteLineItem2;
        
        QuoteLineItem mySavedQItem4 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem2.Id];
        
        System.assertEquals(00.000000, mySavedQItem4.Discount); //Check that the discount field is Zero        
        System.assertEquals(5100, mySavedQItem4.TotalPrice);  //Check that the total price is correct      
    }
    
    static testMethod void myUnitTestRecurring() {
        
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
        
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPricebookId(); //get standard pricebook
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
        
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
        Contact mycontact = testContacts[0];

        // create unique products
        List<Product2> prods = TestDataFactory.createTestProducts('Test Product Entry ', 4, 'Recurring');
        List<Decimal> uPrices = new List<Decimal>{5000, 12300, 10000, 22000};
                
        // create the pricebookentries
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 4, pricebookId, uPrices);             

         // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;
 
        OpportunityLineItem myOppLineItem = TestDataFactory.createTestOppLineItem(testOpportunities[0].id, pBookEntries[0].Id, 3.0, 4500.00, 5000.00, 7.0);        
         
        //get the Opp line again
        OpportunityLineItem mySavedLineItem = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
       
        Decimal myTotalPrice = mySavedLineItem.TotalPrice/mySavedLineItem.Quantity;
       
        System.assertEquals(myTotalPrice, (mySavedLineItem.Reduced_Price__c)*7/12);
        System.assertEquals(10.000000, mySavedLineItem.Discount);
        
        //Test with another amount and with a different term value: Update, Recurring, Reduced Price < list Price, Term !=null
        myOppLineItem.Reduced_Price__c = 1500;
        myOppLineItem.Term_months__c = 5;
        myOppLineItem.Quantity = -1;
        update myOppLineItem;
                       
        //get the opportunity line item again
        OpportunityLineItem mySavedLineItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
        
        myTotalPrice = mySavedLineItem2.TotalPrice.setScale(2)/mySavedLineItem2.Quantity;
        
        //Set the reduced price to greater than the unit price: Recurring, Reduced Price > list Price, Term !=null
        myOppLineItem.Reduced_Price__c = 6000;
        myOppLineItem.Quantity = 1;
        update myOppLineItem;
        
        mySavedLineItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM OpportunityLineItem WHERE Id=:myOppLineItem.Id];
        
        myTotalPrice = mySavedLineItem2.TotalPrice/mySavedLineItem2.Quantity;
        
        System.assertEquals(myTotalPrice, (mySavedLineItem2.Reduced_Price__c)*5/12);
        System.assertEquals(6000, mySavedLineItem2.Reduced_Price__c);
        System.assertEquals(00.000000, mySavedLineItem2.Discount);
        
       
        //Create a Quote against this Opportunity
        Quote myQuote = TestDataFactory.createTestQuote('XYZ Quote123', testOpportunities[0].id, pricebookId);
        
        //Create a Quote Line Item: Insert, Recurring, Reduced Price < list Price, Term !=null       
        QuoteLineItem myQuoteLineItem = TestDataFactory.createTestQuoteLineItems(myQuote.Id, pBookEntries[1].Id, 3, 12300.00, 10000.00, 9.0);
        
        QuoteLineItem mySavedQItem = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem.Id];
                       
        System.assertEquals(18.699187, mySavedQItem.Discount); //Check that the discount field is set correctly on Quote Line Item
        
        //Create a Quote Line Item with reduced price equal to null: Insert, Recurring, Reduced Price = null, Term =null                    
        QuoteLineItem myQuoteLineItem2 = TestDataFactory.createTestQuoteLineItems(myQuote.Id, pBookEntries[2].Id, 1, 12300.00, null, 9.0);
        
        QuoteLineItem mySavedQItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem2.Id];
                    
        System.assertEquals(00.000000, mySavedQItem2.Discount); //Check that the discount field is Zero
        System.assertEquals(10000, mySavedQItem2.Reduced_Price__c.setScale(2)); // Check that the reduced price is the same as the unit price
        
        //Update quote line item: Update, Recurring, Reduced Price < list Price, Term !=null    
        myQuoteLineItem2.Reduced_Price__c = 8000;
        myQuoteLineItem2.Term_months__c = 6;
        myQuoteLineItem2.Quantity = 2.5;
        
        update myQuoteLineItem2;
        
        mySavedQItem2 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem2.Id];
                       
        System.assertEquals(20.000000, mySavedQItem2.Discount); // Check that the discount field is Zero
        System.assertEquals(10000, mySavedQItem2.TotalPrice); // Check that the reduced price is the same as the unit price
        
        //Create a Quote Line Item with reduced price greater than list price: Insert, Recurring, Reduced Price > list Price, Term !=null              
        QuoteLineItem myQuoteLineItem3 = TestDataFactory.createTestQuoteLineItems(myQuote.Id, pBookEntries[3].Id, 1, 22000.00, 25000, 12.0);
        
        QuoteLineItem mySavedQItem3 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem3.Id];
               
        System.assertEquals(00.000000, mySavedQItem3.Discount); // Check that the discount field is Zero 
        System.assertEquals(25000, mySavedQItem3.TotalPrice); // Check that the reduced price is the same as the unit price
        
        // Update quote line item: Update, Recurring, Reduced Price > list Price, Term !=null 
        myQuoteLineItem3.Term_months__c = 6;
        myQuoteLineItem3.Quantity = -3;
        
        update myQuoteLineItem3;
        
        mySavedQItem3 = [SELECT TotalPrice, Quantity, Discount, Reduced_Price__c FROM QuoteLineItem WHERE Id=:myQuoteLineItem3.Id];
                     
        System.assertEquals(0.000000, mySavedQItem3.Discount); //Check that the discount field is Zero
        System.assertEquals(-37500, mySavedQItem3.TotalPrice); //Check that the reduced price is the same as the unit price    
    }
 /*  
    static testMethod void bulkInsertLineItems(){
            
        User salesUser = TestDataFactory.createTestUser('Sales');
        User csmUser = TestDataFactory.createTestUser('Account');
        
        Id salesUserId = salesUser.Id;
        Id csmUserId = csmUser.Id;
        Id pricebookId = Test.getStandardPricebookId(); //get standard pricebook 
        
        List<Id> pBookEntryIds = new List<Id>();
        
        //create Account
        List<Account> testAccounts = TestDataFactory.createTestAccounts('BC Test Organisation', 1, salesUserId, csmUserId);
                    
        //create Contacts
        List<Contact> testContacts = TestDataFactory.createTestContacts('TestContact', 1, testAccounts[0].Id);
        Contact mycontact = testContacts[0];

        // create unique products
        List<String> chargeTypes = new List<String>{'Recurring', 'One Time Only', 'Recurring', 'Recurring', 'One Time Only', 'Recurring', 'One Time Only',
                'Recurring', 'One Time Only','Recurring'}; // Build list of charge types for products
        List<Product2> prods = TestDataFactory.createTestProducts2('Test Product Entry ', 10, chargeTypes);
        
        
        List<Decimal> reducedPrices = new List<Decimal>{35, 80, null, 35, 80, null, 35, 80, null, 35};
        List<Decimal> termMonths = new List<Decimal>{12, null, null, 12, null, null, 12, null, null, 12};
        List<Decimal> quantities = new List<Decimal>{1.0, 2.0, 1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 1.0, 1.0};
        
        // create the pricebookentries
        List<Decimal> uPrices = new List<Decimal>{50, 100, 50, 50, 100, 50, 50, 100, 50, 50}; // Build list of unit prices for Pricebook Entries
        List<PricebookEntry> pBookEntries = TestDataFactory.createTestPriceBookEntries(prods, 10, pricebookId, uPrices);
        
        // Loop through Pricebook Entries created and build list of ids for creating opp line items
        for(PricebookEntry pbe : pBookEntries){
            pBookEntryIds.add(pbe.Id);
        }
        // create an opportunity        
        List<Opportunity> testOpportunities = TestDataFactory.createTestOpportunities('Test Opp', 1, testAccounts[0].Id);
        testOpportunities[0].Pricebook2Id = pricebookId;

        // create opportunity line items
        List<OpportunityLineItem> testLineItems = TestDataFactory.createTestOppLineItems(testOpportunities[0].id, pBookEntryIds, 10, quantities, reducedPrices, uPrices, termMonths);
        System.assertEquals(10, testLineItems.size());
        List<OpportunityLineItem> mySavedItems = [Select TotalPrice, Discount, Reduced_Price__c, Quantity From OpportunityLineItem Where OpportunityID=:testOpportunities[0].id];
        
        Decimal myTotalPrice = mySavedItems[0].TotalPrice/mySavedItems[0].Quantity; // Calculate total price for first opp line item
        
        // Assert that first opp line item Reduced Price and Discount are as expected
        System.assertEquals(myTotalPrice, mySavedItems[0].Reduced_Price__c);
        System.assertEquals(30.000000, mySavedItems[0].Discount);
        
        Decimal myTotalPrice2 = mySavedItems[1].TotalPrice/mySavedItems[1].Quantity; // Calculate total price for second opp line item
        
        // Assert that second opp line item Reduced Price and Discount are as expected        
        System.assertEquals(myTotalPrice2, mySavedItems[1].Reduced_Price__c);
        System.assertEquals(20.000000, mySavedItems[1].Discount);
        
        Decimal myTotalPrice7 = mySavedItems[6].TotalPrice/mySavedItems[6].Quantity; // Calculate total price for second opp line item
        
        // Assert that second opp line item Reduced Price and Discount are as expected        
        System.assertEquals(myTotalPrice7, mySavedItems[6].Reduced_Price__c);
        System.assertEquals(30.000000, mySavedItems[6].Discount);        
    }*/   
}