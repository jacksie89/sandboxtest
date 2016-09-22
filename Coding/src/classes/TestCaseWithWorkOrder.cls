@isTest
public class TestCaseWithWorkOrder {

	static testMethod void myCaseTest(){

   	      
        //Create Account
    	Account myAccount = new Account (name='My Test Organization');
        myAccount.BillingCountry = 'United Kingdom';
        myAccount.Status__c = 'Active';
        insert myAccount; 
        
        //Create Contact		
		Contact newContact = new Contact (FirstName='Joe', 
                                         LastName='Schmoe',
                                         AccountId=myAccount.id,
                                         email='bizofemail@newsweaver.com');
		newContact.MailingCountry = 'United Kingdom';
		newContact.OtherCountry = 'United Kingdom';
        insert newContact;
         
        //Create Change Request
        Change_Request__c cr = new Change_Request__c(Summary__c = 'Test Change Request');
    	insert cr;
        
        //Create Work Order
        SFDC_Projects__c myWorkOrder = new SFDC_Projects__c (Contact__c = newContact.Id, No_Templates__c = 3, Organisation__c = myAccount.Id, Change_Request__c = cr.id, Start_Date__c = System.now(), Expected_Completion_Date__c = System.now());
        insert myWorkOrder;
		
		//Create Case associated with a work order
		Case myCase = new Case (subject='My Test Case', AccountId=myAccount.Id, Status='New', Type='Reporting', Sub_Type__c='Overview',
						Work_Order__c=myWorkOrder.id);
		
		insert myCase;
		
		List <CasesWorkOrdersAssociation__c> coWOAssoc = [select Work_Order__c, Case__c from CasesWorkOrdersAssociation__c where Case__c = :myCase.id];
		System.assertEquals(myCase.id, coWOAssoc[0].Case__c);
		
		//Create Standalone Case
		Case mySecondCase = new Case (subject='My Test Case2', AccountId=myAccount.Id, Status='New', Type='Reporting', Sub_Type__c='Other');
		insert mySecondCase;
		
		List <Case> myTestForStandaloneCase = [select Work_Order__c from Case where id = :mySecondCase.id];
		System.assertEquals(null, myTestForStandaloneCase[0].Work_Order__c);
	}
}